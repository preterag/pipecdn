#!/bin/bash
# Simple Pipe Network Dashboard

# Constants
NODE_INFO_HOME="$HOME/node_info.json"
METRICS_DIR="/opt/pipe-pop/metrics"
METRICS_FILE="$METRICS_DIR/current.json"
REFRESH_RATE=5  # Seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

# Check if node_info.json exists
if [[ ! -f "$NODE_INFO_HOME" ]]; then
  echo -e "${RED}Error: node_info.json not found at $NODE_INFO_HOME${NC}"
  exit 1
fi

# Get node ID
NODE_ID=$(cat "$NODE_INFO_HOME" | grep -o '"node_id": "[^"]*' | cut -d'"' -f4)
if [[ -z "$NODE_ID" ]]; then
  echo -e "${RED}Error: Could not extract node ID from $NODE_INFO_HOME${NC}"
  exit 1
fi

# Main dashboard loop
clear
echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}           PIPE NETWORK NODE DASHBOARD${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}Node ID:${NC} $NODE_ID"
echo -e "${YELLOW}Refresh rate:${NC} ${REFRESH_RATE}s (Ctrl+C to exit)"
echo

while true; do
  # Get system stats
  CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  MEM_USAGE=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
  DISK_USAGE=$(df -h / | awk '$NF=="/"{print $5}')
  
  # Check if the node is running
  if pgrep -f "pipe-pop" > /dev/null; then
    NODE_STATUS="${GREEN}Running${NC}"
    
    # Get uptime
    NODE_PID=$(pgrep -f "pipe-pop" | head -1)
    if [[ -n "$NODE_PID" ]]; then
      UPTIME_SEC=$(ps -o etimes= -p "$NODE_PID")
      UPTIME_DAYS=$((UPTIME_SEC / 86400))
      UPTIME_HOURS=$(((UPTIME_SEC % 86400) / 3600))
      UPTIME_MINS=$(((UPTIME_SEC % 3600) / 60))
      UPTIME_SECS=$((UPTIME_SEC % 60))
      UPTIME="${UPTIME_DAYS}d ${UPTIME_HOURS}h ${UPTIME_MINS}m ${UPTIME_SECS}s"
    else
      UPTIME="unknown"
    fi
  else
    NODE_STATUS="${RED}Stopped${NC}"
    UPTIME="N/A"
  fi
  
  # Get metrics if available
  if [[ -f "$METRICS_FILE" ]]; then
    REPUTATION=$(jq -r '.reputation // "N/A"' "$METRICS_FILE" 2>/dev/null)
    POINTS=$(jq -r '.points // "N/A"' "$METRICS_FILE" 2>/dev/null)
    EGRESS=$(jq -r '.egress // "N/A"' "$METRICS_FILE" 2>/dev/null)
    UPTIME_PERCENT=$(jq -r '.uptime_percent // "N/A"' "$METRICS_FILE" 2>/dev/null)
  else
    REPUTATION="No metrics available"
    POINTS="No metrics available"
    EGRESS="No metrics available"
    UPTIME_PERCENT="No metrics available"
  fi
  
  # Print current stats
  echo -e "${YELLOW}Node status:${NC} $NODE_STATUS"
  echo -e "${YELLOW}Uptime:${NC} $UPTIME"
  echo
  echo -e "${YELLOW}System resources:${NC}"
  echo -e "  CPU usage: ${CPU_USAGE}%"
  echo -e "  Memory usage: ${MEM_USAGE}"
  echo -e "  Disk usage: ${DISK_USAGE}"
  echo
  echo -e "${YELLOW}Performance metrics:${NC}"
  echo -e "  Reputation: ${REPUTATION}"
  echo -e "  Points: ${POINTS}"
  echo -e "  Egress: ${EGRESS}"
  echo -e "  Uptime %: ${UPTIME_PERCENT}"
  echo
  echo -e "${YELLOW}Last update:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
  
  # Sleep before refreshing
  sleep $REFRESH_RATE
  clear
  echo -e "${CYAN}======================================================${NC}"
  echo -e "${CYAN}           PIPE NETWORK NODE DASHBOARD${NC}"
  echo -e "${CYAN}======================================================${NC}"
  echo -e "${YELLOW}Node ID:${NC} $NODE_ID"
  echo -e "${YELLOW}Refresh rate:${NC} ${REFRESH_RATE}s (Ctrl+C to exit)"
  echo
done 