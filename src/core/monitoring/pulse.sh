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
  if [[ -f "$METRICS_FILE" ]]; then
    jq -r '. | {
      reputation: .reputation,
      points: .points,
      egress: .egress,
      uptime_percent: .uptime_percent
    }' "$METRICS_FILE" 2>/dev/null || echo "{}"
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

# Display monitoring header
print_header() {
  clear
  echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║        PIPE NETWORK NODE PULSE MONITOR     ║${NC}"
  echo -e "${CYAN}║           Community Enhancement            ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
  echo
  echo -e "Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "Version: ${VERSION}"
  echo
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

# Main monitoring function
pulse_monitor() {
  local refresh=${1:-$DEFAULT_REFRESH}
  check_dependencies
  
  while true; do
    print_header
    display_system_metrics
    display_node_metrics
    
    echo -e "${BLUE}Press Ctrl+C to exit. Refreshing every ${refresh} seconds...${NC}"
    sleep $refresh
  done
}

# If called directly, run pulse monitor
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  pulse_monitor "$@"
fi 