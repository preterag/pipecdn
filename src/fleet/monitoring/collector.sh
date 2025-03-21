#!/bin/bash
# Community Enhancement: Metrics Collector for Pipe Network Fleet
# This script collects and stores metrics from multiple nodes

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Constants
FLEET_DIR="${INSTALL_DIR:-/opt/pipe-pop}/fleet"
DB_DIR="$FLEET_DIR/db"
NODES_DB="$DB_DIR/nodes.json"
METRICS_DIR="$FLEET_DIR/metrics"
HISTORY_DIR="$METRICS_DIR/history"
SSH_MODULE="$(dirname "$0")/../core/ssh.sh"
REG_MODULE="$(dirname "$0")/../core/registration.sh"

# Import modules if available
if [[ -f "$SSH_MODULE" ]]; then
  source "$SSH_MODULE"
fi

if [[ -f "$REG_MODULE" ]]; then
  source "$REG_MODULE"
fi

# Ensure directories exist
create_metrics_directories() {
  mkdir -p "$METRICS_DIR/history"
  chmod 755 "$METRICS_DIR"
  chmod 755 "$METRICS_DIR/history"
  echo -e "${GREEN}Metrics directories created at $METRICS_DIR${NC}"
}

# Collect metrics from a single node
collect_node_metrics() {
  local name="$1"
  local verbose="${2:-false}"
  
  # Validate inputs
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Node name is required.${NC}"
    echo -e "Usage: collect_node_metrics <name> [verbose]"
    return 1
  fi
  
  if [[ ! -f "$NODES_DB" ]]; then
    echo -e "${RED}Error: Nodes database not found.${NC}"
    echo -e "Run 'pop --fleet register init' to initialize the database."
    return 1
  fi
  
  # Check if node exists
  if ! jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${RED}No node with name '$name' found.${NC}"
    return 1
  fi
  
  # Get node details
  local ip=$(jq -r ".nodes[] | select(.name == \"$name\") | .ip" "$NODES_DB")
  local username=$(jq -r ".nodes[] | select(.name == \"$name\") | .username" "$NODES_DB")
  local port=$(jq -r ".nodes[] | select(.name == \"$name\") | .port" "$NODES_DB")
  
  [[ "$verbose" == "true" ]] && echo -e "Collecting metrics from ${username}@${ip}:${port}..."
  
  # Create timestamp
  local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
  local date_formatted=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Ensure metrics directory exists
  mkdir -p "$METRICS_DIR/$name/history"
  
  # Try to collect metrics
  local result
  local status="Disconnected"
  if type execute_command &>/dev/null; then
    # Use the fleet command mechanism if available
    result=$(execute_command "$name" "./tools/pop --pulse --export json" 2>/dev/null)
    
    # Check command result
    if [[ $? -eq 0 && -n "$result" ]]; then
      status="Connected"
      
      # Save raw metrics to file
      echo "$result" > "$METRICS_DIR/$name/current.json"
      
      # Save to history
      cp "$METRICS_DIR/$name/current.json" "$METRICS_DIR/$name/history/${timestamp}.json"
      
      # Extract relevant metrics and add metadata
      local enhanced_metrics=$(echo "$result" | jq --arg timestamp "$date_formatted" --arg name "$name" '. + {collection_time: $timestamp, node_name: $name}')
      echo "$enhanced_metrics" > "$METRICS_DIR/$name/current_enhanced.json"
      
      # Update node status and metrics in database
      if type update_node_status &>/dev/null; then
        update_node_status "$name" "Connected" >/dev/null 2>&1
      fi
      
      # Update metrics in node database
      jq -r ".nodes |= map(if .name == \"$name\" then .metrics = $enhanced_metrics else . end)" "$NODES_DB" > "$NODES_DB.tmp"
      mv "$NODES_DB.tmp" "$NODES_DB"
      
      [[ "$verbose" == "true" ]] && echo -e "${GREEN}Metrics collected successfully.${NC}"
      [[ "$verbose" == "true" ]] && echo -e "Saved to: $METRICS_DIR/$name/current.json"
      
      return 0
    else
      [[ "$verbose" == "true" ]] && echo -e "${RED}Failed to collect metrics.${NC}"
      
      # Update node status
      if type update_node_status &>/dev/null; then
        update_node_status "$name" "Disconnected" >/dev/null 2>&1
      fi
      
      return 1
    fi
  else
    [[ "$verbose" == "true" ]] && echo -e "${RED}SSH command execution module not available.${NC}"
    return 1
  fi
}

# Collect metrics from all nodes
collect_all_metrics() {
  local verbose="${1:-false}"
  
  # Ensure directories exist
  if [[ ! -d "$METRICS_DIR" ]]; then
    create_metrics_directories
  fi
  
  if [[ ! -f "$NODES_DB" ]]; then
    echo -e "${RED}Error: Nodes database not found.${NC}"
    echo -e "Run 'pop --fleet register init' to initialize the database."
    return 1
  fi
  
  # Get total node count
  local node_count=$(jq '.nodes | length' "$NODES_DB")
  
  if [[ "$node_count" -eq 0 ]]; then
    echo -e "${YELLOW}No nodes registered yet.${NC}"
    return 0
  fi
  
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${CYAN}     COLLECTING METRICS FROM $node_count NODES${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo
  
  local success_count=0
  local fail_count=0
  
  # Process each node
  jq -r '.nodes[].name' "$NODES_DB" | while read -r node_name; do
    echo -e "Processing node: $node_name..."
    
    if collect_node_metrics "$node_name" "$verbose"; then
      ((success_count++))
      echo -e "  ${GREEN}✓${NC} Metrics collected successfully."
    else
      ((fail_count++))
      echo -e "  ${RED}✗${NC} Failed to collect metrics."
    fi
    
    echo
  done
  
  echo -e "Collection summary:"
  echo -e "  ${GREEN}$success_count${NC} nodes successful"
  echo -e "  ${RED}$fail_count${NC} nodes failed"
  echo -e "  Total: $node_count nodes"
  
  return 0
}

# Generate a fleet-wide metrics summary
generate_fleet_summary() {
  local output_file="$METRICS_DIR/fleet_summary.json"
  
  if [[ ! -f "$NODES_DB" ]]; then
    echo -e "${RED}Error: Nodes database not found.${NC}"
    return 1
  fi
  
  # Create summary data
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local total_nodes=$(jq '.nodes | length' "$NODES_DB")
  local connected_nodes=$(jq '.nodes | map(select(.status == "Connected")) | length' "$NODES_DB")
  local disconnected_nodes=$(jq '.nodes | map(select(.status == "Disconnected")) | length' "$NODES_DB")
  local unknown_nodes=$((total_nodes - connected_nodes - disconnected_nodes))
  
  # Get aggregated metrics from all connected nodes
  local total_points=0
  local total_reputation=0
  local total_egress=0
  local max_rank=0
  local min_rank=999999
  
  # Process metrics
  jq -r '.nodes[] | select(.status == "Connected") | .metrics | "\(.points) \(.reputation) \(.egress) \(.rank)"' "$NODES_DB" 2>/dev/null | 
  while read -r points reputation egress rank; do
    # Convert values to numbers (with defaults of 0)
    points=${points:-0}
    reputation=${reputation:-0}
    egress=${egress:-0}
    rank=${rank:-0}
    
    # Strip non-numeric characters from values
    points=$(echo "$points" | sed 's/[^0-9.]//g')
    reputation=$(echo "$reputation" | sed 's/[^0-9.]//g')
    egress=$(echo "$egress" | sed 's/[^0-9.]//g')
    rank=$(echo "$rank" | sed 's/[^0-9.]//g')
    
    # Add to totals
    total_points=$(echo "$total_points + $points" | bc -l 2>/dev/null || echo "$total_points")
    total_reputation=$(echo "$total_reputation + $reputation" | bc -l 2>/dev/null || echo "$total_reputation")
    total_egress=$(echo "$total_egress + $egress" | bc -l 2>/dev/null || echo "$total_egress")
    
    # Update min/max rank
    if [[ -n "$rank" && "$rank" != "N/A" && "$rank" -gt 0 ]]; then
      if [[ "$rank" -gt "$max_rank" ]]; then
        max_rank=$rank
      fi
      if [[ "$rank" -lt "$min_rank" ]]; then
        min_rank=$rank
      fi
    fi
  done
  
  # Format for output
  if [[ "$min_rank" -eq 999999 ]]; then
    min_rank="N/A"
  fi
  if [[ "$max_rank" -eq 0 ]]; then
    max_rank="N/A"
  fi
  
  # Create JSON summary
  local summary=$(jq -n \
    --arg timestamp "$timestamp" \
    --arg total_nodes "$total_nodes" \
    --arg connected_nodes "$connected_nodes" \
    --arg disconnected_nodes "$disconnected_nodes" \
    --arg unknown_nodes "$unknown_nodes" \
    --arg total_points "$total_points" \
    --arg total_reputation "$total_reputation" \
    --arg total_egress "$total_egress" \
    --arg min_rank "$min_rank" \
    --arg max_rank "$max_rank" \
    '{
      timestamp: $timestamp,
      total_nodes: $total_nodes|tonumber,
      connected_nodes: $connected_nodes|tonumber,
      disconnected_nodes: $disconnected_nodes|tonumber,
      unknown_nodes: $unknown_nodes|tonumber,
      fleet_metrics: {
        total_points: $total_points|tonumber,
        total_reputation: $total_reputation|tonumber,
        total_egress: $total_egress|tonumber,
        min_rank: $min_rank,
        max_rank: $max_rank
      }
    }')
  
  # Save summary
  echo "$summary" > "$output_file"
  
  # Save historical copy
  local history_timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
  mkdir -p "$HISTORY_DIR"
  echo "$summary" > "$HISTORY_DIR/summary_${history_timestamp}.json"
  
  echo -e "${GREEN}Fleet summary generated at $output_file${NC}"
  return 0
}

# Start a scheduled metrics collection job
start_scheduled_collection() {
  local interval="${1:-15}" # Default to 15 minutes
  local log_file="$METRICS_DIR/collector.log"
  
  # Validate input
  if ! [[ "$interval" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Interval must be a number (minutes).${NC}"
    echo -e "Usage: start_scheduled_collection [interval]"
    return 1
  fi
  
  echo -e "Starting scheduled metrics collection every $interval minutes..."
  echo -e "Logging to $log_file"
  
  # Create a simple daemon that runs in the background
  (
    while true; do
      echo "$(date): Starting metrics collection..." >> "$log_file"
      
      # Collect metrics and generate summary
      collect_all_metrics false >> "$log_file" 2>&1
      generate_fleet_summary >> "$log_file" 2>&1
      
      echo "$(date): Collection complete. Sleeping for $interval minutes..." >> "$log_file"
      sleep $((interval * 60))
    done
  ) &
  
  # Save PID for later management
  echo $! > "$METRICS_DIR/collector.pid"
  
  echo -e "${GREEN}Collector started with PID $(cat "$METRICS_DIR/collector.pid")${NC}"
  return 0
}

# Stop the scheduled metrics collection job
stop_scheduled_collection() {
  local pid_file="$METRICS_DIR/collector.pid"
  
  if [[ ! -f "$pid_file" ]]; then
    echo -e "${YELLOW}No running collector found.${NC}"
    return 0
  fi
  
  local pid=$(cat "$pid_file")
  
  if ps -p "$pid" >/dev/null 2>&1; then
    echo -e "Stopping metrics collector (PID: $pid)..."
    kill "$pid"
    rm "$pid_file"
    echo -e "${GREEN}Metrics collector stopped.${NC}"
  else
    echo -e "${YELLOW}Collector process not found, removing stale PID file.${NC}"
    rm "$pid_file"
  fi
  
  return 0
}

# Main function to process commands
process_collector_command() {
  local command="$1"
  shift
  
  case "$command" in
    collect)
      if [[ $# -eq 0 ]]; then
        collect_all_metrics true
      else
        collect_node_metrics "$1" true
      fi
      ;;
    summary)
      generate_fleet_summary
      ;;
    start)
      start_scheduled_collection "$1"
      ;;
    stop)
      stop_scheduled_collection
      ;;
    status)
      local pid_file="$METRICS_DIR/collector.pid"
      
      if [[ ! -f "$pid_file" ]]; then
        echo -e "${YELLOW}No metrics collector is running.${NC}"
      else
        local pid=$(cat "$pid_file")
        if ps -p "$pid" >/dev/null 2>&1; then
          echo -e "${GREEN}Metrics collector is running (PID: $pid).${NC}"
        else
          echo -e "${RED}Metrics collector appears to have died. Stale PID: $pid${NC}"
          rm "$pid_file"
        fi
      fi
      ;;
    *)
      echo -e "${RED}Unknown collector command: $command${NC}"
      echo -e "Available commands: collect, summary, start, stop, status"
      return 1
      ;;
  esac
  
  return 0
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Show usage information if no arguments
  if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <command> [arguments]"
    echo "Commands:"
    echo "  collect [node]  - Collect metrics from all nodes or a specific node"
    echo "  summary         - Generate a fleet-wide metrics summary"
    echo "  start [interval]- Start scheduled metrics collection (interval in minutes)"
    echo "  stop            - Stop scheduled metrics collection"
    echo "  status          - Check if scheduled collection is running"
    exit 1
  fi
  
  # Process command
  process_collector_command "$@"
  exit $?
fi 