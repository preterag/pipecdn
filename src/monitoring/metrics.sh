#!/bin/bash
# Metrics Collection Module for Pipe Network PoP Node Management Tools
# This module handles collection and display of node metrics and status information.

# Define metrics file paths
METRICS_DIR="${INSTALL_DIR}/metrics"
METRICS_FILE="${METRICS_DIR}/current.json"
HISTORY_DIR="${METRICS_DIR}/history"
NODE_INFO_FILE="${INSTALL_DIR}/node_info.json"
LOCAL_NODE_INFO_FILE="./node_info.json"

# Ensure metrics directory exists
ensure_metrics_dir() {
  if [[ ! -d "$METRICS_DIR" ]]; then
    sudo mkdir -p "$METRICS_DIR"
    sudo chmod 755 "$METRICS_DIR"
  fi
  
  if [[ ! -d "$HISTORY_DIR" ]]; then
    sudo mkdir -p "$HISTORY_DIR"
    sudo chmod 755 "$HISTORY_DIR"
  fi
}

# =====================
# Status Display
# =====================

# Show node status
show_status() {
  print_header "STATUS"
  
  # Get node status
  local status=$(get_node_status)
  
  if [[ "$status" == "running" ]]; then
    echo -e "Status: ${GREEN}Running${NC}"
    
    # Get additional status information if node is running
    local uptime=$(get_node_uptime)
    local uptime_formatted=$(printf '%dd %dh %dm %ds' $(($uptime/86400)) $(($uptime%86400/3600)) $(($uptime%3600/60)) $(($uptime%60)))
    echo -e "Uptime: $uptime_formatted"
    
    # Get wallet information
    local wallet=$(get_wallet_address)
    if [[ -n "$wallet" && "$wallet" != "No wallet configured" ]]; then
      echo -e "Wallet: $wallet"
    else
      echo -e "Wallet: ${RED}Not configured${NC}"
    fi
    
    # Check registration status
    local registered=$(check_registration)
    if [[ "$registered" == "yes" ]]; then
      echo -e "Registered: ${GREEN}Yes${NC}"
    else
      echo -e "Registered: ${RED}No${NC} (run 'pop configure' to register)"
    fi
    
    # Get port status
    local port_80=$(check_port 80)
    local port_443=$(check_port 443)
    local port_8003=$(check_port 8003)
    
    echo -e "Ports:"
    echo -e "  80:   ${port_80}"
    echo -e "  443:  ${port_443}"
    echo -e "  8003: ${port_8003}"
    
    # Get metrics if available
    show_metrics_summary
  else
    echo -e "Status: ${RED}Not Running${NC}"
    echo -e "${YELLOW}Use 'pop start' to start the node.${NC}"
  fi
  
  echo
}

# Show brief metrics summary (used in status display)
show_metrics_summary() {
  if [[ -f "$METRICS_FILE" ]]; then
    echo -e "Performance Metrics:"
    
    # Try to extract metrics from the file
    if command -v jq &> /dev/null; then
      local reputation=$(jq -r '.reputation // "N/A"' "$METRICS_FILE" 2>/dev/null)
      local points=$(jq -r '.points // "N/A"' "$METRICS_FILE" 2>/dev/null)
      local egress=$(jq -r '.egress // "N/A"' "$METRICS_FILE" 2>/dev/null)
      local uptime_score=$(jq -r '.uptime_score // "N/A"' "$METRICS_FILE" 2>/dev/null)
      
      echo -e "  Reputation: ${CYAN}$reputation${NC}"
      echo -e "  Points: ${CYAN}$points${NC}"
      echo -e "  Egress: ${CYAN}$egress${NC}"
      echo -e "  Uptime Score: ${CYAN}$uptime_score${NC}"
    else
      echo -e "  ${YELLOW}jq not installed, cannot parse metrics file.${NC}"
    fi
  else
    echo -e "${YELLOW}No metrics data available. Run 'pop pulse' to generate metrics.${NC}"
  fi
}

# =====================
# Metrics Collection
# =====================

# Check node registration status
check_registration() {
  local node_info_file=""
  
  # Try to find node_info.json
  if [[ -f "$LOCAL_NODE_INFO_FILE" ]]; then
    node_info_file="$LOCAL_NODE_INFO_FILE"
  elif [[ -f "$NODE_INFO_FILE" ]]; then
    node_info_file="$NODE_INFO_FILE"
  fi
  
  if [[ -n "$node_info_file" ]]; then
    if command -v jq &> /dev/null; then
      local registered=$(jq -r '.registered // false' "$node_info_file" 2>/dev/null)
      if [[ "$registered" == "true" ]]; then
        echo "yes"
        return 0
      fi
    fi
  fi
  
  echo "no"
  return 1
}

# Check if a port is open and accessible
check_port() {
  local port="$1"
  
  # Check if port is listening
  if netstat -tuln | grep -q ":$port "; then
    # Port is at least listening locally
    echo "${GREEN}Listening${NC}"
  else
    echo "${RED}Not Listening${NC}"
    return 1
  fi
  
  return 0
}

# Get wallet address from configuration
get_wallet_address() {
  local wallet=""
  
  # First try local config file
  if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
    wallet=$(jq -r '.node.wallet // ""' "$LOCAL_CONFIG_FILE" 2>/dev/null)
    if [[ -z "$wallet" ]]; then
      wallet=$(jq -r '.node.wallet_address // ""' "$LOCAL_CONFIG_FILE" 2>/dev/null)
    fi
    
    if [[ -n "$wallet" ]]; then
      echo "$wallet"
      return 0
    fi
  fi
  
  # Then try system config file
  if [[ -f "$CONFIG_FILE" ]]; then
    wallet=$(jq -r '.node.wallet // ""' "$CONFIG_FILE" 2>/dev/null)
    if [[ -z "$wallet" ]]; then
      wallet=$(jq -r '.node.wallet_address // ""' "$CONFIG_FILE" 2>/dev/null)
    fi
    
    if [[ -n "$wallet" ]]; then
      echo "$wallet"
      return 0
    fi
  fi
  
  echo "No wallet configured"
  return 1
}

# Collect current metrics and save to file
collect_metrics() {
  ensure_metrics_dir
  
  local metrics_file="${METRICS_DIR}/current.json"
  local temp_file="${METRICS_DIR}/temp_metrics.json"
  
  # Default metrics structure
  echo '{
    "timestamp": '$(date +%s)',
    "reputation": 0,
    "points": 0,
    "egress": "0 B",
    "uptime_score": "0%",
    "historical_score": "0%",
    "egress_score": "0%",
    "node_id": "",
    "uptime": 0
  }' > "$temp_file"
  
  # Update metrics from various sources
  if [[ -f "$NODE_INFO_FILE" ]]; then
    # Extract node_id
    local node_id=$(jq -r '.node_id // ""' "$NODE_INFO_FILE" 2>/dev/null)
    if [[ -n "$node_id" ]]; then
      jq --arg node_id "$node_id" '.node_id = $node_id' "$temp_file" > "${temp_file}.new"
      mv "${temp_file}.new" "$temp_file"
    fi
  fi
  
  # Get uptime
  local uptime=$(get_node_uptime)
  jq --arg uptime "$uptime" '.uptime = ($uptime | tonumber)' "$temp_file" > "${temp_file}.new"
  mv "${temp_file}.new" "$temp_file"
  
  # TODO: Get reputation, points, egress, scores from external API
  # This would typically involve making API calls to the Pipe Network service
  # For now, we'll use placeholder values or calculate estimates
  
  # Save to metrics file
  mv "$temp_file" "$metrics_file"
  
  # Save historical copy
  local date_str=$(date +%Y%m%d_%H%M%S)
  cp "$metrics_file" "${HISTORY_DIR}/metrics_${date_str}.json"
  
  # Clean up old history files (keep last 100)
  find "${HISTORY_DIR}" -type f -name "metrics_*.json" | sort -r | tail -n +101 | xargs -r rm
  
  return 0
}

# =====================
# Monitoring Functions
# =====================

# Run pulse monitoring (real-time metrics)
run_pulse_monitoring() {
  local refresh_rate=5
  local compact=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --refresh=*)
        refresh_rate="${1#*=}"
        shift
        ;;
      --refresh)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
          refresh_rate="$2"
          shift 2
        else
          log_error "Invalid or missing value for --refresh"
          return 1
        fi
        ;;
      --compact)
        compact=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  
  print_header "PULSE MONITORING"
  
  echo -e "Starting pulse monitoring (refresh: ${refresh_rate}s)..."
  echo -e "Press Ctrl+C to exit"
  echo
  
  # Ensure we can collect metrics
  collect_metrics
  
  # Display metrics in a loop
  while true; do
    clear
    print_header "PULSE MONITORING"
    
    # Collect fresh metrics
    collect_metrics
    
    # Check if node is running
    local status=$(get_node_status)
    if [[ "$status" == "running" ]]; then
      echo -e "Status: ${GREEN}Running${NC}"
    else
      echo -e "Status: ${RED}Not Running${NC}"
      echo -e "${YELLOW}Use 'pop start' to start the node.${NC}"
      echo
      sleep "$refresh_rate"
      continue
    fi
    
    # Show uptime
    local uptime=$(get_node_uptime)
    local uptime_formatted=$(printf '%dd %dh %dm %ds' $(($uptime/86400)) $(($uptime%86400/3600)) $(($uptime%3600/60)) $(($uptime%60)))
    echo -e "Uptime: $uptime_formatted"
    
    # Show metrics
    if [[ -f "$METRICS_FILE" ]]; then
      if command -v jq &> /dev/null; then
        # Format timestamp
        local timestamp=$(jq -r '.timestamp // 0' "$METRICS_FILE" 2>/dev/null)
        local time_str=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
        
        echo -e "Last Update: $time_str"
        echo
        
        if [[ "$compact" == "true" ]]; then
          # Compact view
          echo -e "Reputation: $(jq -r '.reputation // "N/A"' "$METRICS_FILE")\tPoints: $(jq -r '.points // "N/A"' "$METRICS_FILE")"
          echo -e "Egress: $(jq -r '.egress // "N/A"' "$METRICS_FILE")\tUptime Score: $(jq -r '.uptime_score // "N/A"' "$METRICS_FILE")"
        else
          # Detailed view
          echo -e "Performance Metrics:"
          echo -e "  Reputation: ${CYAN}$(jq -r '.reputation // "N/A"' "$METRICS_FILE")${NC}"
          echo -e "  Points: ${CYAN}$(jq -r '.points // "N/A"' "$METRICS_FILE")${NC}"
          echo -e "  Egress: ${CYAN}$(jq -r '.egress // "N/A"' "$METRICS_FILE")${NC}"
          echo
          echo -e "Scoring Components:"
          echo -e "  Uptime Score: ${CYAN}$(jq -r '.uptime_score // "N/A"' "$METRICS_FILE")${NC} (40% weight)"
          echo -e "  Historical Score: ${CYAN}$(jq -r '.historical_score // "N/A"' "$METRICS_FILE")${NC} (30% weight)"
          echo -e "  Egress Score: ${CYAN}$(jq -r '.egress_score // "N/A"' "$METRICS_FILE")${NC} (30% weight)"
          
          # Show node ID if available
          local node_id=$(jq -r '.node_id // ""' "$METRICS_FILE")
          if [[ -n "$node_id" ]]; then
            echo
            echo -e "Node ID: ${BLUE}$node_id${NC}"
          fi
        fi
      else
        echo -e "${YELLOW}jq not installed, cannot parse metrics file.${NC}"
      fi
    else
      echo -e "${YELLOW}No metrics data available.${NC}"
    fi
    
    sleep "$refresh_rate"
  done
}

# Get node status from systemd
get_node_status() {
  if systemctl list-unit-files | grep -q "pipe-pop.service"; then
    if systemctl is-active --quiet pipe-pop.service; then
      echo "running"
    else
      echo "stopped"
    fi
  else
    echo "not_installed"
  fi
}

# Get node uptime in seconds
get_node_uptime() {
  if systemctl list-unit-files | grep -q "pipe-pop.service" && systemctl is-active --quiet pipe-pop.service; then
    local uptime_info=$(systemctl show pipe-pop.service -p ActiveEnterTimestamp)
    local uptime_timestamp=${uptime_info#*=}
    
    if [[ -n "$uptime_timestamp" ]]; then
      local now=$(date +%s)
      local start_time=$(date -d "$uptime_timestamp" +%s 2>/dev/null)
      
      if [[ -n "$start_time" ]]; then
        echo $((now - start_time))
        return 0
      fi
    fi
  fi
  
  echo "0"
}
