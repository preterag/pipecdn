#!/usr/bin/env bash
# Pipe Network PoP Node Management Tools
# Referral System Module

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/src/utils/common.sh"

# Define data directories
DATA_DIR="${ROOT_DIR}/data/community"
REFERRAL_DB="${DATA_DIR}/referrals.json"
CONFIG_DIR="${ROOT_DIR}/config/community"
REFERRAL_CONFIG="${CONFIG_DIR}/referral_config.json"

# Ensure directories exist
mkdir -p "${DATA_DIR}" "${CONFIG_DIR}"

# Initialize the referral database if it doesn't exist
init_referral_db() {
  if [[ ! -f "${REFERRAL_DB}" ]]; then
    echo -e "${BLUE}Initializing referral database...${NC}"
    echo '{
      "referrals": [],
      "codes": {},
      "redeemed": {}
    }' > "${REFERRAL_DB}"
    chmod 640 "${REFERRAL_DB}"
  fi
}

# Initialize referral configuration if it doesn't exist
init_referral_config() {
  if [[ ! -f "${REFERRAL_CONFIG}" ]]; then
    echo -e "${BLUE}Creating default referral configuration...${NC}"
    echo '{
      "points_per_referral": 10,
      "valid_days": 30,
      "min_points_redemption": 50,
      "reward_tiers": {
        "50": "Basic Reward",
        "100": "Silver Reward",
        "250": "Gold Reward",
        "500": "Platinum Reward"
      }
    }' > "${REFERRAL_CONFIG}"
    chmod 640 "${REFERRAL_CONFIG}"
  fi
}

# Generate a unique referral code for the user
generate_referral_code() {
  local username="$1"
  local custom_suffix="${2:-}"
  
  # Ensure username is provided
  if [[ -z "$username" ]]; then
    echo -e "${RED}Error: Username is required to generate a referral code.${NC}"
    return 1
  fi
  
  # Initialize if needed
  init_referral_db
  init_referral_config
  
  # Check if user already has a code
  local existing_code=$(jq -r --arg user "$username" '.codes[$user] // ""' "${REFERRAL_DB}")
  if [[ -n "$existing_code" && "$existing_code" != "null" ]]; then
    echo -e "${YELLOW}You already have a referral code: ${CYAN}$existing_code${NC}"
    echo -e "Use this code to invite others to the Pipe Network."
    return 0
  fi
  
  # Generate a unique code with prefix PIPE- and random alphanumeric
  local prefix="PIPE"
  local random_part=""
  
  # If custom suffix is provided, use it, otherwise generate random
  if [[ -n "$custom_suffix" ]]; then
    # Ensure suffix is alphanumeric and convert to uppercase
    custom_suffix=$(echo "$custom_suffix" | tr -cd '[:alnum:]' | tr '[:lower:]' '[:upper:]')
    if [[ -z "$custom_suffix" ]]; then
      echo -e "${RED}Error: Custom suffix must contain alphanumeric characters.${NC}"
      return 1
    fi
    random_part="${custom_suffix}"
  else
    # Generate random 6 character alphanumeric string
    random_part=$(tr -dc 'A-Z0-9' < /dev/urandom | head -c 6)
  fi
  
  # Combine to create code
  local code="${prefix}-${random_part}"
  
  # Check if code already exists
  if jq -e --arg code "$code" '.codes[] | select(. == $code)' "${REFERRAL_DB}" &>/dev/null; then
    echo -e "${RED}Error: Generated code already exists. Please try again or use a different suffix.${NC}"
    return 1
  fi
  
  # Add code to database
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  jq --arg user "$username" \
     --arg code "$code" \
     --arg time "$timestamp" \
     '.codes[$user] = $code | .referrals += [{"code": $code, "owner": $user, "created": $time, "used_by": [], "points": 0}]' \
     "${REFERRAL_DB}" > "${REFERRAL_DB}.tmp"
  
  mv "${REFERRAL_DB}.tmp" "${REFERRAL_DB}"
  
  echo -e "${GREEN}Your new referral code is: ${CYAN}${code}${NC}"
  echo -e "Share this code with friends to earn points when they join the Pipe Network."
  
  return 0
}

# Record when a referral code is used
record_referral_use() {
  local code="$1"
  local new_user="$2"
  
  # Validate inputs
  if [[ -z "$code" || -z "$new_user" ]]; then
    echo -e "${RED}Error: Both referral code and new username are required.${NC}"
    return 1
  fi
  
  # Initialize if needed
  init_referral_db
  init_referral_config
  
  # Standardize code format to uppercase
  code=$(echo "$code" | tr '[:lower:]' '[:upper:]')
  
  # Check if code exists
  if ! jq -e --arg code "$code" '.referrals[] | select(.code == $code)' "${REFERRAL_DB}" &>/dev/null; then
    echo -e "${RED}Error: Invalid referral code.${NC}"
    return 1
  fi
  
  # Get code owner
  local owner=$(jq -r --arg code "$code" '.referrals[] | select(.code == $code) | .owner' "${REFERRAL_DB}")
  
  # Prevent self-referral
  if [[ "$owner" == "$new_user" ]]; then
    echo -e "${RED}Error: You cannot use your own referral code.${NC}"
    return 1
  }
  
  # Check if this user has already been referred
  if jq -e --arg user "$new_user" '.redeemed[$user] != null' "${REFERRAL_DB}" &>/dev/null; then
    echo -e "${YELLOW}This user has already redeemed a referral code.${NC}"
    return 1
  fi
  
  # Get points per referral from config
  local points_per_referral=$(jq -r '.points_per_referral' "${REFERRAL_CONFIG}")
  
  # Record referral use
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  jq --arg code "$code" \
     --arg user "$new_user" \
     --arg time "$timestamp" \
     --arg points "$points_per_referral" \
     --arg owner "$owner" \
     '.referrals = [.referrals[] | if .code == $code then 
        .used_by += [$user] | .points = (.points + ($points | tonumber)) 
        else . end] |
      .redeemed[$user] = {"code": $code, "timestamp": $time, "referrer": $owner}' \
     "${REFERRAL_DB}" > "${REFERRAL_DB}.tmp"
  
  mv "${REFERRAL_DB}.tmp" "${REFERRAL_DB}"
  
  echo -e "${GREEN}Referral code ${CYAN}${code}${GREEN} successfully applied!${NC}"
  echo -e "User ${CYAN}${owner}${NC} has been credited with ${CYAN}${points_per_referral}${NC} points."
  
  return 0
}

# Display user's referral status and points
show_referral_status() {
  local username="$1"
  
  # Validate input
  if [[ -z "$username" ]]; then
    echo -e "${RED}Error: Username is required.${NC}"
    return 1
  fi
  
  # Initialize if needed
  init_referral_db
  init_referral_config
  
  # Check if user has a referral code
  local user_code=$(jq -r --arg user "$username" '.codes[$user] // ""' "${REFERRAL_DB}")
  if [[ -z "$user_code" || "$user_code" == "null" ]]; then
    echo -e "${YELLOW}You don't have a referral code yet.${NC}"
    echo -e "Generate one using: pop --community referral generate"
    return 0
  fi
  
  # Get user's referral data
  local referral_data=$(jq -r --arg code "$user_code" '.referrals[] | select(.code == $code)' "${REFERRAL_DB}")
  if [[ -z "$referral_data" || "$referral_data" == "null" ]]; then
    echo -e "${RED}Error: Could not find your referral data.${NC}"
    return 1
  fi
  
  # Extract relevant information
  local created=$(echo "$referral_data" | jq -r '.created')
  local used_by_count=$(echo "$referral_data" | jq -r '.used_by | length')
  local points=$(echo "$referral_data" | jq -r '.points')
  local used_by=$(echo "$referral_data" | jq -r '.used_by | join(", ")')
  
  # Get reward tiers
  local reward_tiers=$(jq -r '.reward_tiers' "${REFERRAL_CONFIG}")
  
  # Display status
  echo -e "${CYAN}=== REFERRAL STATUS FOR ${username} ===${NC}"
  echo -e "Referral Code: ${CYAN}${user_code}${NC}"
  echo -e "Created: ${created}"
  echo -e "Total Referrals: ${CYAN}${used_by_count}${NC}"
  echo -e "Points Earned: ${CYAN}${points}${NC}"
  
  if [[ $used_by_count -gt 0 ]]; then
    echo -e "\nUsers referred: ${used_by}"
  fi
  
  # Show current tier and next tier
  echo -e "\n${CYAN}Reward Tiers:${NC}"
  echo "$reward_tiers" | jq -r 'to_entries | sort_by(.key | tonumber) | .[] | "\(.key) points: \(.value)"' | \
  while read -r tier; do
    local tier_points=$(echo "$tier" | cut -d' ' -f1)
    if (( points >= tier_points )); then
      echo -e "${GREEN}✓ $tier${NC} (ELIGIBLE)"
    else
      echo -e "${YELLOW}○ $tier${NC} (Need $(( tier_points - points )) more points)"
      break
    fi
  done
  
  return 0
}

# Redeem points for rewards
redeem_points() {
  local username="$1"
  local tier="$2"
  
  # Validate inputs
  if [[ -z "$username" ]]; then
    echo -e "${RED}Error: Username is required.${NC}"
    return 1
  fi
  
  # Initialize if needed
  init_referral_db
  init_referral_config
  
  # Get user's referral code
  local user_code=$(jq -r --arg user "$username" '.codes[$user] // ""' "${REFERRAL_DB}")
  if [[ -z "$user_code" || "$user_code" == "null" ]]; then
    echo -e "${RED}Error: You don't have a referral code.${NC}"
    echo -e "Generate one using: pop --community referral generate"
    return 1
  fi
  
  # Get user's current points
  local current_points=$(jq -r --arg code "$user_code" '.referrals[] | select(.code == $code) | .points' "${REFERRAL_DB}")
  if [[ -z "$current_points" || "$current_points" == "null" ]]; then
    echo -e "${RED}Error: Could not find your referral data.${NC}"
    return 1
  fi
  
  # Get min points for redemption
  local min_points=$(jq -r '.min_points_redemption' "${REFERRAL_CONFIG}")
  
  if (( current_points < min_points )); then
    echo -e "${RED}Error: You need at least ${min_points} points to redeem rewards.${NC}"
    echo -e "Current points: ${current_points}"
    return 1
  fi
  
  # If tier is not specified, show available tiers
  if [[ -z "$tier" ]]; then
    echo -e "${CYAN}=== AVAILABLE REWARD TIERS ===${NC}"
    echo -e "Current points: ${CYAN}${current_points}${NC}\n"
    
    jq -r '.reward_tiers | to_entries | sort_by(.key | tonumber) | .[]' "${REFERRAL_CONFIG}" | \
    while IFS= read -r tier_data; do
      local tier_points=$(echo "$tier_data" | jq -r '.key')
      local tier_name=$(echo "$tier_data" | jq -r '.value')
      
      if (( current_points >= tier_points )); then
        echo -e "${GREEN}✓ ${tier_points} points: ${tier_name}${NC} (ELIGIBLE)"
        echo -e "   Redeem with: pop --community referral redeem ${tier_points}"
      else
        echo -e "${YELLOW}○ ${tier_points} points: ${tier_name}${NC} (Need $(( tier_points - current_points )) more points)"
      fi
    done
    
    return 0
  fi
  
  # Check if the specified tier exists
  local tier_name=$(jq -r --arg tier "$tier" '.reward_tiers[$tier] // ""' "${REFERRAL_CONFIG}")
  if [[ -z "$tier_name" || "$tier_name" == "null" ]]; then
    echo -e "${RED}Error: Invalid tier.${NC}"
    echo -e "Use 'pop --community referral redeem' to see available tiers."
    return 1
  fi
  
  # Check if user has enough points
  if (( current_points < tier )); then
    echo -e "${RED}Error: You don't have enough points for this tier.${NC}"
    echo -e "Current points: ${current_points}"
    echo -e "Required: ${tier}"
    return 1
  fi
  
  # Process redemption
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local new_points=$(( current_points - tier ))
  
  # Update database
  jq --arg code "$user_code" \
     --arg tier "$tier" \
     --arg tier_name "$tier_name" \
     --arg time "$timestamp" \
     --arg new_points "$new_points" \
     '.referrals = [.referrals[] | if .code == $code then 
        .points = ($new_points | tonumber) | 
        .redemptions = (if .redemptions then .redemptions else [] end) + [
          {"tier": $tier, "reward": $tier_name, "timestamp": $time}
        ]
        else . end]' \
     "${REFERRAL_DB}" > "${REFERRAL_DB}.tmp"
  
  mv "${REFERRAL_DB}.tmp" "${REFERRAL_DB}"
  
  echo -e "${GREEN}Congratulations! You have redeemed the ${CYAN}${tier_name}${GREEN} reward.${NC}"
  echo -e "Points used: ${tier}"
  echo -e "Remaining points: ${new_points}"
  echo -e "\nAn email with redemption details will be sent to your registered email address."
  echo -e "Please allow 24-48 hours for processing."
  
  return 0
}

# Show referral leaderboard
show_leaderboard() {
  # Initialize if needed
  init_referral_db
  
  # Check if there are any referrals
  local referral_count=$(jq '.referrals | length' "${REFERRAL_DB}")
  if [[ "$referral_count" -eq 0 ]]; then
    echo -e "${YELLOW}No referrals have been recorded yet.${NC}"
    return 0
  fi
  
  echo -e "${CYAN}=== REFERRAL LEADERBOARD ===${NC}"
  echo -e "Top referrers in the Pipe Network community:\n"
  
  # Print header
  printf "%-4s %-20s %-15s %-10s %-15s\n" "Rank" "Username" "Code" "Points" "Referrals"
  echo "-------------------------------------------------------------"
  
  # Get sorted leaderboard
  jq -r '.referrals | sort_by(.points) | reverse | limit(20) | to_entries[] | 
    "\(.key+1)\t\(.value.owner)\t\(.value.code)\t\(.value.points)\t\(.value.used_by | length)"' "${REFERRAL_DB}" | \
  while IFS=$'\t' read -r rank username code points referrals; do
    # Format rank with color based on position
    if [[ "$rank" -eq 1 ]]; then
      rank_formatted="${GOLD}#$rank${NC}"
    elif [[ "$rank" -eq 2 ]]; then
      rank_formatted="${SILVER}#$rank${NC}"
    elif [[ "$rank" -eq 3 ]]; then
      rank_formatted="${BRONZE}#$rank${NC}"
    else
      rank_formatted="#$rank"
    fi
    
    printf "%-4s %-20s %-15s %-10s %-15s\n" "$rank_formatted" "$username" "$code" "$points" "$referrals"
  done
  
  return 0
}

# Main entry point for referral commands
referral_command() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    generate)
      generate_referral_code "$USER" "$1"
      ;;
    use|redeem-code)
      record_referral_use "$1" "$USER"
      ;;
    status)
      show_referral_status "$USER"
      ;;
    redeem)
      redeem_points "$USER" "$1"
      ;;
    leaderboard)
      show_leaderboard
      ;;
    help|*)
      echo -e "${CYAN}Pipe Network Referral System Commands:${NC}"
      echo -e "  ${YELLOW}generate [suffix]${NC}   Generate a new referral code (optional custom suffix)"
      echo -e "  ${YELLOW}use <code>${NC}          Redeem a referral code"
      echo -e "  ${YELLOW}status${NC}              Show your referral status and points"
      echo -e "  ${YELLOW}redeem [tier]${NC}       Redeem points for rewards (show tiers if no tier specified)"
      echo -e "  ${YELLOW}leaderboard${NC}         Display top referrers"
      echo -e "  ${YELLOW}help${NC}                Show this help message"
      ;;
  esac
}

# If the script is run directly, assume the first argument is the command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  referral_command "$@"
fi
