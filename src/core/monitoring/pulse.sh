#!/bin/bash
# Community Enhancement: Node Pulse Monitoring
# This script provides real-time monitoring for Pipe Network nodes.

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

# Constants
VERSION="community-v0.0.1"
CONFIG_DIR="/opt/pipe-pop/config"
CONFIG_FILE="$CONFIG_DIR/config.json"
METRICS_FILE="/opt/pipe-pop/metrics/current.json"
DEFAULT_REFRESH=5

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check dependencies
check_dependencies() {
  for cmd in top free netstat jq curl; do
    if ! command -v $cmd &> /dev/null; then
      echo -e "${RED}Error: $cmd is not installed. Please install it to use pulse monitoring.${NC}"
      exit 1
    fi
  done
}

# Get system resources
get_cpu_usage() {
  top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
}

get_memory_usage() {
  free -m | awk 'NR==2{printf "%.2f", $3*100/$2}'
}

get_disk_usage() {
  df -h / | awk '$NF=="/"{printf "%s", $5}' | sed 's/%//'
}

# Get node metrics
get_node_metrics() {
  # First check for the standard metrics file
  if [[ -f "$METRICS_FILE" ]]; then
    jq -r '. | {
      reputation: .reputation,
      points: .points,
      egress: .egress,
      uptime_percent: .uptime_percent
    }' "$METRICS_FILE" 2>/dev/null || echo "{}"
  # Then check for our sample metrics file in the current directory
  elif [[ -f "./sample-metrics.json" ]]; then
    jq -r '. | {
      reputation: .reputation,
      points: .points,
      egress: .egress,
      uptime_percent: .uptime_percent
    }' "./sample-metrics.json" 2>/dev/null || echo "{}"
  else
    echo "{}"
  fi
}

# Check port status
check_port_status() {
  local port=$(jq -r '.network.port // 8080' "$CONFIG_FILE" 2>/dev/null)
  if netstat -tuln | grep -q ":$port "; then
    echo -e "${GREEN}OPEN${NC}"
  else
    echo -e "${RED}CLOSED${NC}"
  fi
}

# Display monitoring header with bordered box
print_header() {
  local title="${1:-PULSE MONITOR}"
  clear
  
  # Create more distinctive header with double lines
  echo -e "${CYAN}=================================================${NC}"
  echo -e "${CYAN}PIPE NETWORK POP NODE ${title}${NC}"
  echo -e "${CYAN}=================================================${NC}"
  echo
  echo -e "Time: $(date '+%Y-%m-%d %H:%M:%S')"
  if [[ -n "$metrics_file_to_use" ]]; then
    local node_id=$(jq -r '.node_id // "N/A"' "$metrics_file_to_use" 2>/dev/null)
    echo -e "Node ID: ${node_id}"
  else
    # Try to find node id from different sources
    local node_id=$(jq -r '.node_id // "N/A"' "$METRICS_FILE" 2>/dev/null || jq -r '.node_id // "N/A"' "./sample-metrics.json" 2>/dev/null || echo "N/A")
    echo -e "Node ID: ${node_id}"
  fi
  echo
}

# Create section header with consistent styling
print_section_header() {
  local title="$1"
  echo -e "${CYAN}────────────────────────────────────────────${NC}"
  echo -e "${CYAN}${title}${NC}"
  echo -e "${CYAN}────────────────────────────────────────────${NC}"
}

# Get trend indicator
get_trend_indicator() {
  local current="$1"
  local previous="$2"
  
  if [[ "$current" > "$previous" ]]; then
    echo -e "\e[1;32m↑\e[0m"
  elif [[ "$current" < "$previous" ]]; then
    echo -e "\e[1;31m↓\e[0m"
  else
    echo -e "→"
  fi
}

# Display system metrics
display_system_metrics() {
  local cpu=$(get_cpu_usage)
  local mem=$(get_memory_usage)
  local disk=$(get_disk_usage)
  
  echo -e "${YELLOW}System Resources:${NC}"
  echo -e "CPU: ${cpu}%"
  echo -e "Memory: ${mem}%"
  echo -e "Disk: ${disk}%"
  echo -e "Port Status: $(check_port_status)"
  echo
}

# Display node metrics
display_node_metrics() {
  local metrics=$(get_node_metrics)
  local reputation=$(echo "$metrics" | jq -r '.reputation // "N/A"')
  local points=$(echo "$metrics" | jq -r '.points // "N/A"')
  local egress=$(echo "$metrics" | jq -r '.egress // "N/A"')
  local uptime=$(echo "$metrics" | jq -r '.uptime_percent // "N/A"')
  
  echo -e "${YELLOW}Node Performance:${NC}"
  echo -e "Reputation: ${reputation}"
  echo -e "Points: ${points}"
  echo -e "Egress: ${egress}"
  echo -e "Uptime: ${uptime}%"
  echo
}

# Dashboard monitoring with more organized layout
dashboard_monitor() {
  local refresh=${1:-$DEFAULT_REFRESH}
  local compact="$2"
  local export_format="$3"
  
  check_dependencies
  
  # Set the metrics file to use
  local metrics_file_to_use="$METRICS_FILE"
  if [[ ! -f "$metrics_file_to_use" && -f "./sample-metrics.json" ]]; then
    metrics_file_to_use="./sample-metrics.json"
  fi
  
  # Get any previous metrics for trend comparison
  local previous_metrics=""
  if [[ -f "$metrics_file_to_use.prev" ]]; then
    previous_metrics=$(cat "$metrics_file_to_use.prev")
  else
    # If no previous metrics, make a copy for next time
    [[ -f "$metrics_file_to_use" ]] && cp "$metrics_file_to_use" "$metrics_file_to_use.prev"
  fi
  
  while true; do
    print_header "DASHBOARD"
    
    # STATUS SECTION
    print_section_header "STATUS"
    
    # Get status info
    local pid=$(pgrep -f "PipeNetwork/PoP" || echo "N/A")
    local running=false
    if [[ "$pid" != "N/A" ]]; then
      running=true
    fi
    
    # Get system uptime
    local system_uptime=$(uptime -p 2>/dev/null | sed 's/up //' || echo "N/A")
    
    # Get service uptime
    local service_started=$(systemctl show pipe-pop.service --property=ActiveEnterTimestamp 2>/dev/null | awk -F= '{print $2}' | xargs -I{} date -d {} '+%a %b %d %H:%M:%S %Y' 2>/dev/null || echo "N/A")
    
    # Display status info in a clean format
    if [[ "$running" == "true" ]]; then
      echo -e "Status: ${GREEN}Running${NC} (PID: $pid)"
    else
      echo -e "Status: ${RED}Stopped${NC}"
    fi
    echo -e "Uptime: ${CYAN}$system_uptime${NC}"
    echo -e "Started: $service_started"
    
    # Get and display system resource usage
    local cpu=$(get_cpu_usage)
    local mem=$(get_memory_usage)
    local mem_total=$(free -m | awk 'NR==2{printf "%d", $2}')
    local mem_used=$(free -m | awk 'NR==2{printf "%d", $3}')
    local disk=$(get_disk_usage)
    local disk_used=$(df -h / | awk 'NR==2{printf "%d", $3}' | sed 's/G//')
    local disk_total=$(df -h / | awk 'NR==2{printf "%d", $2}' | sed 's/G//')
    
    echo -e "Resources: CPU: ${cpu}% | RAM: ${mem}% (${mem_used}/${mem_total} MB) | Disk: ${disk}% (${disk_used}/${disk_total} GB)"
    
    # Check port status for all relevant ports
    echo -ne "Ports: 80: "
    if netstat -tuln | grep -q ":80 "; then
      echo -ne "${GREEN}✓${NC}"
    else
      echo -ne "${RED}✗${NC}"
    fi
    
    echo -ne " 443: "
    if netstat -tuln | grep -q ":443 "; then
      echo -ne "${GREEN}✓${NC}"
    else
      echo -ne "${RED}✗${NC}"
    fi
    
    echo -ne " 8003: "
    if netstat -tuln | grep -q ":8003 "; then
      echo -e "${GREEN}✓${NC}"
    else
      echo -e "${RED}✗${NC}"
    fi
    
    echo
    
    # PERFORMANCE METRICS SECTION
    print_section_header "PERFORMANCE METRICS"
    
    # Get node metrics
    local metrics=$(get_node_metrics)
    local reputation=$(echo "$metrics" | jq -r '.reputation // "N/A"')
    local points=$(echo "$metrics" | jq -r '.points // "N/A"')
    local egress=$(echo "$metrics" | jq -r '.egress // "N/A"')
    
    # Get node rank if available
    local rank="N/A"
    local total_nodes="N/A"
    if [[ -f "$metrics_file_to_use" ]]; then
      rank=$(jq -r '.rank // "N/A"' "$metrics_file_to_use" 2>/dev/null)
      total_nodes=$(jq -r '.total_nodes // "N/A"' "$metrics_file_to_use" 2>/dev/null)
    fi
    
    # Show main performance metrics in a single line
    echo -e "Rank: ${CYAN}$rank${NC} | Reputation: ${CYAN}$reputation${NC} | Points: ${CYAN}$points${NC} | Egress: ${CYAN}$egress${NC}"
    
    echo
    
    # HISTORICAL TRENDS SECTION
    print_section_header "HISTORICAL TRENDS"
    
    # Get previous metrics for comparison if available
    local prev_reputation="0"
    local prev_points="0"
    local prev_egress="0"
    local prev_rank="0"
    
    if [[ -n "$previous_metrics" ]]; then
      prev_reputation=$(echo "$previous_metrics" | jq -r '.reputation // 0')
      prev_points=$(echo "$previous_metrics" | jq -r '.points // 0')
      prev_egress=$(echo "$previous_metrics" | jq -r '.egress // "0"' | sed 's/[^0-9.]//g')
      prev_rank=$(echo "$previous_metrics" | jq -r '.rank // 0')
    fi
    
    # Current values as plain numbers for comparison
    local curr_points=$points
    local curr_egress=$(echo "$egress" | sed 's/[^0-9.]//g')
    local curr_rank=$rank
    
    # Calculate differences
    local points_diff=$(echo "$curr_points - $prev_points" | bc 2>/dev/null || echo "0")
    local egress_diff=$(echo "$curr_egress - $prev_egress" | bc 2>/dev/null || echo "0")
    local rank_diff=$(echo "$prev_rank - $curr_rank" | bc 2>/dev/null || echo "0")
    
    # Format the differences with proper sign
    [[ "$points_diff" != "0" ]] && points_diff="(${points_diff})"
    [[ "$egress_diff" != "0" ]] && egress_diff="(${egress_diff} TB)"
    [[ "$rank_diff" != "0" ]] && rank_diff="(+${rank_diff})"
    
    # Show trend indicators
    echo -ne "Reputation: "
    if (( $(echo "$reputation > $prev_reputation" | bc -l) )); then
      echo -ne "${GREEN}↑${NC}"
    elif (( $(echo "$reputation < $prev_reputation" | bc -l) )); then
      echo -ne "${RED}↓${NC}"
    else
      echo -ne "→"
    fi
    
    echo -ne " | Points: "
    if (( $(echo "$curr_points > $prev_points" | bc -l) )); then
      echo -ne "${GREEN}↑${NC}"
    elif (( $(echo "$curr_points < $prev_points" | bc -l) )); then
      echo -ne "${RED}↓${NC}"
    else
      echo -ne "→"
    fi
    echo -ne " ${CYAN}$points_diff${NC}"
    
    echo -ne " | Egress: "
    if (( $(echo "$curr_egress > $prev_egress" | bc -l) )); then
      echo -ne "${GREEN}↑${NC}"
    elif (( $(echo "$curr_egress < $prev_egress" | bc -l) )); then
      echo -ne "${RED}↓${NC}"
    else
      echo -ne "→"
    fi
    echo -ne " ${CYAN}$egress_diff${NC}"
    
    echo -ne " | Rank: "
    if (( $(echo "$curr_rank < $prev_rank" | bc -l) )); then
      echo -ne "${GREEN}↑${NC}"
    elif (( $(echo "$curr_rank > $prev_rank" | bc -l) )); then
      echo -ne "${RED}↓${NC}"
    else
      echo -ne "→"
    fi
    echo -e " ${CYAN}$rank_diff${NC}"
    
    echo
    
    # ACTIONS SECTION
    print_section_header "ACTIONS"
    
    # Show available actions with global command names
    echo -e "- View detailed metrics: ${CYAN}pop --pulse${NC}"
    echo -e "- View leaderboard: ${CYAN}pop --leaderboard${NC}"
    echo -e "- View historical data: ${CYAN}pop --history${NC}"
    echo -e "- Restart node: ${CYAN}pop --restart${NC}"
    
    echo
    echo -e "Press Ctrl+C to exit"
    
    # Save current metrics for next comparison
    [[ -f "$metrics_file_to_use" ]] && cp "$metrics_file_to_use" "$metrics_file_to_use.prev"
    
    # Sleep for refresh
    sleep $refresh
  done
}

# Main monitoring function
pulse_monitor() {
  local refresh=${1:-$DEFAULT_REFRESH}
  check_dependencies
  
  while true; do
    print_header "PULSE MONITOR"
    display_system_metrics
    display_node_metrics
    
    echo -e "${BLUE}Press Ctrl+C to exit. Refreshing every ${refresh} seconds...${NC}"
    sleep $refresh
  done
}

# Parse command line arguments
parse_args() {
  # Default values
  local mode="pulse"
  local refresh=$DEFAULT_REFRESH
  local compact=""
  local export_format=""
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dashboard)
        mode="dashboard"
        shift
        ;;
      --interactive|-i)
        mode="pulse"
        shift
        ;;
      --continuous|-c)
        mode="pulse"
        shift
        ;;
      --refresh)
        refresh="$2"
        shift 2
        ;;
      --compact)
        compact="yes"
        shift
        ;;
      --export)
        export_format="$2"
        shift 2
        ;;
      *)
        # If it's a number, assume it's the refresh rate
        if [[ "$1" =~ ^[0-9]+$ ]]; then
          refresh="$1"
        fi
        shift
        ;;
    esac
  done
  
  # Run the appropriate mode
  if [[ "$mode" == "dashboard" ]]; then
    dashboard_monitor "$refresh" "$compact" "$export_format"
  else
    pulse_monitor "$refresh"
  fi
}

# If called directly, parse arguments and run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  parse_args "$@"
fi 