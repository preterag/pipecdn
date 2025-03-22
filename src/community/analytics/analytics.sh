#!/usr/bin/env bash
# Pipe Network PoP Node Management Tools
# Analytics System Module

# Import common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "${ROOT_DIR}/src/utils/common.sh"

# Define data directories
DATA_DIR="${ROOT_DIR}/data/analytics"
CONFIG_DIR="${ROOT_DIR}/config/analytics"
ANALYTICS_DB="${DATA_DIR}/analytics.json"
LEADERBOARD_DB="${DATA_DIR}/leaderboard.json"
NETWORK_STATS="${DATA_DIR}/network_stats.json"

# Set color definitions for medals
GOLD="${YELLOW}"
SILVER="\033[0;37m"  # Light gray/silver
BRONZE="\033[0;33m"  # Orange/bronze

# Ensure directories exist
mkdir -p "${DATA_DIR}" "${CONFIG_DIR}"

# Initialize analytics database if it doesn't exist
init_analytics_db() {
  if [[ ! -f "${ANALYTICS_DB}" ]]; then
    echo -e "${BLUE}Initializing analytics database...${NC}"
    echo '{
      "nodes": {},
      "daily_stats": {},
      "usage_metrics": {
        "commands": {},
        "features": {}
      }
    }' > "${ANALYTICS_DB}"
    chmod 640 "${ANALYTICS_DB}"
  fi
}

# Initialize leaderboard database if it doesn't exist
init_leaderboard_db() {
  if [[ ! -f "${LEADERBOARD_DB}" ]]; then
    echo -e "${BLUE}Initializing leaderboard database...${NC}"
    echo '{
      "uptime": [],
      "bandwidth": [],
      "transactions": [],
      "score": [],
      "last_updated": null
    }' > "${LEADERBOARD_DB}"
    chmod 640 "${LEADERBOARD_DB}"
  fi
}

# Initialize network stats if it doesn't exist
init_network_stats() {
  if [[ ! -f "${NETWORK_STATS}" ]]; then
    echo -e "${BLUE}Initializing network statistics...${NC}"
    echo '{
      "total_nodes": 0,
      "active_nodes": 0,
      "total_bandwidth": 0,
      "total_uptime": 0,
      "total_transactions": 0,
      "regions": {},
      "versions": {},
      "historical": {}
    }' > "${NETWORK_STATS}"
    chmod 640 "${NETWORK_STATS}"
  fi
}

# Record node statistics for analytics
record_node_stats() {
  local node_id="$1"
  local uptime="$2"
  local bandwidth="$3"
  local transactions="$4"
  local score="$5"
  local region="${6:-unknown}"
  local version="${7:-unknown}"
  
  # Validate inputs
  if [[ -z "$node_id" ]]; then
    echo -e "${RED}Error: Node ID is required.${NC}"
    return 1
  fi
  
  # Initialize databases if needed
  init_analytics_db
  
  # Prepare timestamp for today
  local today=$(date +"%Y-%m-%d")
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Update analytics database with node stats
  jq --arg id "$node_id" \
     --arg time "$timestamp" \
     --arg uptime "$uptime" \
     --arg bw "$bandwidth" \
     --arg tx "$transactions" \
     --arg score "$score" \
     --arg region "$region" \
     --arg version "$version" \
     '.nodes[$id] = {
        "last_updated": $time,
        "uptime": ($uptime | tonumber),
        "bandwidth": ($bw | tonumber),
        "transactions": ($tx | tonumber),
        "score": ($score | tonumber),
        "region": $region,
        "version": $version
      }' "${ANALYTICS_DB}" > "${ANALYTICS_DB}.tmp"
  
  mv "${ANALYTICS_DB}.tmp" "${ANALYTICS_DB}"
  
  # Update daily stats
  jq --arg date "$today" \
     --arg id "$node_id" \
     --arg bw "$bandwidth" \
     --arg tx "$transactions" \
     '.daily_stats[$date] = (.daily_stats[$date] // {
        "total_nodes": 0,
        "bandwidth": 0,
        "transactions": 0,
        "node_ids": []
      }) | 
      if (.daily_stats[$date].node_ids | index($id)) then . 
      else 
        .daily_stats[$date].node_ids += [$id] | 
        .daily_stats[$date].total_nodes = (.daily_stats[$date].node_ids | length) |
        .daily_stats[$date].bandwidth = (.daily_stats[$date].bandwidth + ($bw | tonumber)) |
        .daily_stats[$date].transactions = (.daily_stats[$date].transactions + ($tx | tonumber))
      end' "${ANALYTICS_DB}" > "${ANALYTICS_DB}.tmp"
  
  mv "${ANALYTICS_DB}.tmp" "${ANALYTICS_DB}"
  
  echo -e "${GREEN}Node statistics recorded successfully.${NC}"
  return 0
}

# Record command usage for analytics
record_command_usage() {
  local command="$1"
  
  # Validate input
  if [[ -z "$command" ]]; then
    return 0  # Silently exit if no command provided
  fi
  
  # Initialize if needed
  init_analytics_db
  
  # Update command usage count
  jq --arg cmd "$command" \
     '.usage_metrics.commands[$cmd] = ((.usage_metrics.commands[$cmd] // 0) + 1)' \
     "${ANALYTICS_DB}" > "${ANALYTICS_DB}.tmp"
  
  mv "${ANALYTICS_DB}.tmp" "${ANALYTICS_DB}"
  
  return 0
}

# Update network-wide statistics
update_network_stats() {
  # Initialize databases if needed
  init_analytics_db
  init_network_stats
  
  # Get analytics data
  local node_data=$(jq -r '.nodes' "${ANALYTICS_DB}")
  if [[ -z "$node_data" || "$node_data" == "null" || "$node_data" == "{}" ]]; then
    echo -e "${YELLOW}No node data available for network statistics.${NC}"
    return 0
  fi
  
  # Calculate network-wide statistics
  local total_nodes=$(jq '.nodes | length' "${ANALYTICS_DB}")
  local active_nodes=$(jq '.nodes | [to_entries[] | select(.value.uptime > 0)] | length' "${ANALYTICS_DB}")
  local total_bandwidth=$(jq '.nodes | [to_entries[] | .value.bandwidth] | add' "${ANALYTICS_DB}")
  local total_transactions=$(jq '.nodes | [to_entries[] | .value.transactions] | add' "${ANALYTICS_DB}")
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Extract region and version statistics
  jq -r '.nodes | to_entries[] | [.value.region, .value.version] | @tsv' "${ANALYTICS_DB}" > "${DATA_DIR}/temp_stats.tsv"
  
  # Count regions
  local region_counts=$(cat "${DATA_DIR}/temp_stats.tsv" | cut -f1 | sort | uniq -c | awk '{print "\""$2"\": "$1","}' | tr '\n' ' ' | sed 's/,\s*$//')
  region_counts="{${region_counts}}"
  
  # Count versions
  local version_counts=$(cat "${DATA_DIR}/temp_stats.tsv" | cut -f2 | sort | uniq -c | awk '{print "\""$2"\": "$1","}' | tr '\n' ' ' | sed 's/,\s*$//')
  version_counts="{${version_counts}}"
  
  # Clean up temp file
  rm -f "${DATA_DIR}/temp_stats.tsv"
  
  # Update network stats
  local today=$(date +"%Y-%m-%d")
  jq --arg total "$total_nodes" \
     --arg active "$active_nodes" \
     --arg bw "$total_bandwidth" \
     --arg tx "$total_transactions" \
     --arg time "$timestamp" \
     --arg date "$today" \
     --argjson regions "$region_counts" \
     --argjson versions "$version_counts" \
     '{
       "total_nodes": ($total | tonumber),
       "active_nodes": ($active | tonumber),
       "total_bandwidth": ($bw | tonumber),
       "total_transactions": ($tx | tonumber),
       "last_updated": $time,
       "regions": $regions,
       "versions": $versions,
       "historical": (.historical // {}) | .[$date] = {
         "total_nodes": ($total | tonumber),
         "active_nodes": ($active | tonumber),
         "total_bandwidth": ($bw | tonumber),
         "total_transactions": ($tx | tonumber)
       }
     }' "${NETWORK_STATS}" > "${NETWORK_STATS}.tmp"
  
  mv "${NETWORK_STATS}.tmp" "${NETWORK_STATS}"
  
  echo -e "${GREEN}Network statistics updated successfully.${NC}"
  return 0
}

# Update leaderboard rankings
update_leaderboard() {
  # Initialize databases if needed
  init_analytics_db
  init_leaderboard_db
  
  # Get analytics data
  local node_data=$(jq -r '.nodes' "${ANALYTICS_DB}")
  if [[ -z "$node_data" || "$node_data" == "null" || "$node_data" == "{}" ]]; then
    echo -e "${YELLOW}No node data available for leaderboard.${NC}"
    return 0
  fi
  
  # Generate leaderboards for different metrics
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Extract and sort by metrics
  jq '{
    "uptime": [.nodes | to_entries | sort_by(-.value.uptime) | limit(100) | map({
      "id": .key,
      "value": .value.uptime,
      "rank": 0
    })],
    "bandwidth": [.nodes | to_entries | sort_by(-.value.bandwidth) | limit(100) | map({
      "id": .key,
      "value": .value.bandwidth,
      "rank": 0
    })],
    "transactions": [.nodes | to_entries | sort_by(-.value.transactions) | limit(100) | map({
      "id": .key,
      "value": .value.transactions,
      "rank": 0
    })],
    "score": [.nodes | to_entries | sort_by(-.value.score) | limit(100) | map({
      "id": .key,
      "value": .value.score,
      "rank": 0
    })],
    "last_updated": "'$timestamp'"
  }' "${ANALYTICS_DB}" > "${LEADERBOARD_DB}.tmp"
  
  # Add ranks to each entry
  jq '
    .uptime = .uptime | map(. + {"rank": (.uptime | index(.) + 1)}) |
    .bandwidth = .bandwidth | map(. + {"rank": (.bandwidth | index(.) + 1)}) |
    .transactions = .transactions | map(. + {"rank": (.transactions | index(.) + 1)}) |
    .score = .score | map(. + {"rank": (.score | index(.) + 1)})
  ' "${LEADERBOARD_DB}.tmp" > "${LEADERBOARD_DB}"
  
  # Clean up
  rm -f "${LEADERBOARD_DB}.tmp"
  
  echo -e "${GREEN}Leaderboard updated successfully.${NC}"
  return 0
}

# Display leaderboard
show_leaderboard() {
  local metric="${1:-score}"
  local limit="${2:-10}"
  
  # Initialize if needed
  init_leaderboard_db
  
  # Validate metric
  case "$metric" in
    uptime|bandwidth|transactions|score)
      # Valid metric
      ;;
    *)
      echo -e "${RED}Error: Invalid metric.${NC}"
      echo -e "Valid metrics: uptime, bandwidth, transactions, score"
      return 1
      ;;
  esac
  
  # Check if leaderboard data exists
  if [[ ! -f "${LEADERBOARD_DB}" ]]; then
    echo -e "${YELLOW}No leaderboard data available.${NC}"
    echo -e "Run 'pop --community analytics update' to generate leaderboard data."
    return 0
  fi
  
  # Get leaderboard data for the selected metric
  local data=$(jq -r --arg metric "$metric" --arg limit "$limit" '.[$metric] | limit(($limit | tonumber))' "${LEADERBOARD_DB}")
  local last_updated=$(jq -r '.last_updated' "${LEADERBOARD_DB}")
  
  if [[ -z "$data" || "$data" == "null" || "$data" == "[]" ]]; then
    echo -e "${YELLOW}No data available for the selected metric.${NC}"
    return 0
  fi
  
  # Display leaderboard
  echo -e "${CYAN}=== PIPE NETWORK ${metric^^} LEADERBOARD ===${NC}"
  echo -e "Top $limit nodes ranked by $metric"
  echo -e "Last updated: $last_updated\n"
  
  # Print header
  case "$metric" in
    uptime)
      printf "%-5s %-20s %-15s\n" "Rank" "Node ID" "Uptime (hours)"
      ;;
    bandwidth)
      printf "%-5s %-20s %-15s\n" "Rank" "Node ID" "Bandwidth (GB)"
      ;;
    transactions)
      printf "%-5s %-20s %-15s\n" "Rank" "Node ID" "Transactions"
      ;;
    score)
      printf "%-5s %-20s %-15s\n" "Rank" "Node ID" "Score"
      ;;
  esac
  
  echo "---------------------------------------"
  
  # Print entries
  jq -r '.[] | "\(.rank)\t\(.id)\t\(.value)"' <<< "$data" | \
  while IFS=$'\t' read -r rank id value; do
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
    
    # Format ID for display (truncate if too long)
    if [[ ${#id} -gt 15 ]]; then
      display_id="${id:0:12}..."
    else
      display_id="$id"
    fi
    
    printf "%-5s %-20s %-15s\n" "$rank_formatted" "$display_id" "$value"
  done
  
  echo -e "\nView more details with: pop --community analytics stats <node_id>"
  
  return 0
}

# Show network statistics
show_network_stats() {
  # Initialize if needed
  init_network_stats
  
  # Check if network stats exist
  if [[ ! -f "${NETWORK_STATS}" ]]; then
    echo -e "${YELLOW}No network statistics available.${NC}"
    echo -e "Run 'pop --community analytics update' to generate network statistics."
    return 0
  fi
  
  # Get stats data
  local total_nodes=$(jq -r '.total_nodes' "${NETWORK_STATS}")
  local active_nodes=$(jq -r '.active_nodes' "${NETWORK_STATS}")
  local total_bandwidth=$(jq -r '.total_bandwidth' "${NETWORK_STATS}")
  local total_transactions=$(jq -r '.total_transactions' "${NETWORK_STATS}")
  local last_updated=$(jq -r '.last_updated' "${NETWORK_STATS}")
  
  # Calculate active percentage
  local active_percent=0
  if (( total_nodes > 0 )); then
    active_percent=$(echo "scale=2; ($active_nodes / $total_nodes) * 100" | bc)
  fi
  
  # Display network stats
  echo -e "${CYAN}=== PIPE NETWORK STATISTICS ===${NC}"
  echo -e "Last updated: $last_updated\n"
  
  echo -e "${BLUE}Node Information:${NC}"
  echo -e "Total Nodes: ${CYAN}${total_nodes}${NC}"
  echo -e "Active Nodes: ${CYAN}${active_nodes}${NC} (${active_percent}%)"
  
  echo -e "\n${BLUE}Network Performance:${NC}"
  echo -e "Total Bandwidth: ${CYAN}${total_bandwidth} GB${NC}"
  echo -e "Total Transactions: ${CYAN}${total_transactions}${NC}"
  
  # Display region distribution
  echo -e "\n${BLUE}Regional Distribution:${NC}"
  jq -r '.regions | to_entries | sort_by(-.value) | .[]' "${NETWORK_STATS}" | \
  while IFS= read -r region_data; do
    local region=$(echo "$region_data" | jq -r '.key')
    local count=$(echo "$region_data" | jq -r '.value')
    local percent=$(echo "scale=2; ($count / $total_nodes) * 100" | bc)
    echo -e "${region}: ${CYAN}${count}${NC} nodes (${percent}%)"
  done
  
  # Display version distribution
  echo -e "\n${BLUE}Version Distribution:${NC}"
  jq -r '.versions | to_entries | sort_by(-.value) | .[]' "${NETWORK_STATS}" | \
  while IFS= read -r version_data; do
    local version=$(echo "$version_data" | jq -r '.key')
    local count=$(echo "$version_data" | jq -r '.value')
    local percent=$(echo "scale=2; ($count / $total_nodes) * 100" | bc)
    echo -e "v${version}: ${CYAN}${count}${NC} nodes (${percent}%)"
  done
  
  return 0
}

# Show node-specific statistics
show_node_stats() {
  local node_id="$1"
  
  # Validate input
  if [[ -z "$node_id" ]]; then
    echo -e "${RED}Error: Node ID is required.${NC}"
    return 1
  fi
  
  # Initialize if needed
  init_analytics_db
  
  # Check if node exists in database
  if ! jq -e --arg id "$node_id" '.nodes[$id]' "${ANALYTICS_DB}" &>/dev/null; then
    echo -e "${RED}Error: Node not found in analytics database.${NC}"
    return 1
  fi
  
  # Get node data
  local node_data=$(jq -r --arg id "$node_id" '.nodes[$id]' "${ANALYTICS_DB}")
  local uptime=$(echo "$node_data" | jq -r '.uptime')
  local bandwidth=$(echo "$node_data" | jq -r '.bandwidth')
  local transactions=$(echo "$node_data" | jq -r '.transactions')
  local score=$(echo "$node_data" | jq -r '.score')
  local region=$(echo "$node_data" | jq -r '.region')
  local version=$(echo "$node_data" | jq -r '.version')
  local last_updated=$(echo "$node_data" | jq -r '.last_updated')
  
  # Get ranks from leaderboard
  init_leaderboard_db
  local uptime_rank=$(jq -r --arg id "$node_id" '.uptime[] | select(.id == $id) | .rank' "${LEADERBOARD_DB}")
  local bandwidth_rank=$(jq -r --arg id "$node_id" '.bandwidth[] | select(.id == $id) | .rank' "${LEADERBOARD_DB}")
  local transactions_rank=$(jq -r --arg id "$node_id" '.transactions[] | select(.id == $id) | .rank' "${LEADERBOARD_DB}")
  local score_rank=$(jq -r --arg id "$node_id" '.score[] | select(.id == $id) | .rank' "${LEADERBOARD_DB}")
  
  # Display node stats
  echo -e "${CYAN}=== NODE STATISTICS: $node_id ===${NC}"
  echo -e "Last updated: $last_updated\n"
  
  echo -e "${BLUE}Node Information:${NC}"
  echo -e "Region: ${CYAN}${region}${NC}"
  echo -e "Version: ${CYAN}${version}${NC}"
  
  echo -e "\n${BLUE}Performance Metrics:${NC}"
  echo -e "Uptime: ${CYAN}${uptime} hours${NC} (Rank: ${uptime_rank:-N/A})"
  echo -e "Bandwidth: ${CYAN}${bandwidth} GB${NC} (Rank: ${bandwidth_rank:-N/A})"
  echo -e "Transactions: ${CYAN}${transactions}${NC} (Rank: ${transactions_rank:-N/A})"
  echo -e "Overall Score: ${CYAN}${score}${NC} (Rank: ${score_rank:-N/A})"
  
  return 0
}

# Generate visualization of network growth
generate_growth_chart() {
  local days="${1:-30}"
  
  # Initialize if needed
  init_network_stats
  
  # Check if network stats exist
  if [[ ! -f "${NETWORK_STATS}" ]]; then
    echo -e "${YELLOW}No network statistics available for visualization.${NC}"
    echo -e "Run 'pop --community analytics update' to generate network statistics."
    return 0
  fi
  
  # Get historical data
  local historical_data=$(jq -r '.historical' "${NETWORK_STATS}")
  if [[ -z "$historical_data" || "$historical_data" == "null" || "$historical_data" == "{}" ]]; then
    echo -e "${YELLOW}No historical data available for visualization.${NC}"
    echo -e "Data will be collected over time as the analytics service runs."
    return 0
  fi
  
  # Get dates to show (limit to requested number of days)
  local dates=$(jq -r '.historical | keys | sort | .[-'$days':][]' "${NETWORK_STATS}")
  if [[ -z "$dates" ]]; then
    echo -e "${YELLOW}Not enough historical data available.${NC}"
    echo -e "Current data spans fewer than $days days."
    return 0
  fi
  
  echo -e "${CYAN}=== NETWORK GROWTH OVER TIME ===${NC}"
  echo -e "Last $days days of network statistics\n"
  
  # Create simple ASCII charts for total nodes
  echo -e "${BLUE}Active Nodes Growth:${NC}"
  echo "$dates" | while read -r date; do
    local active_nodes=$(jq -r --arg date "$date" '.historical[$date].active_nodes' "${NETWORK_STATS}")
    local bar_length=$(( active_nodes / 10 ))
    if [[ $bar_length -lt 1 ]]; then bar_length=1; fi
    if [[ $bar_length -gt 50 ]]; then bar_length=50; fi
    
    printf "%-10s [%-50s] %d\n" "$date" "$(printf '%0.s#' $(seq 1 $bar_length))" "$active_nodes"
  done
  
  echo
  
  # Create simple ASCII charts for bandwidth
  echo -e "${BLUE}Total Bandwidth Growth (GB):${NC}"
  echo "$dates" | while read -r date; do
    local bandwidth=$(jq -r --arg date "$date" '.historical[$date].total_bandwidth' "${NETWORK_STATS}")
    local bar_length=$(( bandwidth / 100 ))
    if [[ $bar_length -lt 1 ]]; then bar_length=1; fi
    if [[ $bar_length -gt 50 ]]; then bar_length=50; fi
    
    printf "%-10s [%-50s] %d\n" "$date" "$(printf '%0.s#' $(seq 1 $bar_length))" "$bandwidth"
  done
  
  echo
  
  # Create simple ASCII charts for transactions
  echo -e "${BLUE}Total Transactions Growth:${NC}"
  echo "$dates" | while read -r date; do
    local transactions=$(jq -r --arg date "$date" '.historical[$date].total_transactions' "${NETWORK_STATS}")
    local bar_length=$(( transactions / 1000 ))
    if [[ $bar_length -lt 1 ]]; then bar_length=1; fi
    if [[ $bar_length -gt 50 ]]; then bar_length=50; fi
    
    printf "%-10s [%-50s] %d\n" "$date" "$(printf '%0.s#' $(seq 1 $bar_length))" "$transactions"
  done
  
  return 0
}

# Main entry point for analytics commands
analytics_command() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    record)
      record_node_stats "$@"
      ;;
    update)
      update_network_stats
      update_leaderboard
      echo -e "${GREEN}Analytics data updated successfully.${NC}"
      ;;
    leaderboard)
      show_leaderboard "$@"
      ;;
    network)
      show_network_stats
      ;;
    stats)
      show_node_stats "$1"
      ;;
    growth)
      generate_growth_chart "$1"
      ;;
    help|*)
      echo -e "${CYAN}Pipe Network Analytics Commands:${NC}"
      echo -e "  ${YELLOW}record <args...>${NC}      Record node statistics (for system use)"
      echo -e "  ${YELLOW}update${NC}                Update network stats and leaderboards"
      echo -e "  ${YELLOW}leaderboard [metric] [n]${NC}  Show leaderboard (metric: score, uptime, bandwidth, transactions)"
      echo -e "  ${YELLOW}network${NC}               Show global network statistics"
      echo -e "  ${YELLOW}stats <node_id>${NC}       Show detailed stats for a specific node"
      echo -e "  ${YELLOW}growth [days]${NC}         Show network growth visualization"
      echo -e "  ${YELLOW}help${NC}                  Show this help message"
      ;;
  esac
}

# If the script is run directly, assume the first argument is the command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  analytics_command "$@"
fi
