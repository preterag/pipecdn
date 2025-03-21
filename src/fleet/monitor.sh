#!/bin/bash
# Fleet Management - Monitoring Module
# Collects and displays metrics from multiple nodes

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Ensure we're in the correct directory
if [[ -z "$ROOT_DIR" ]]; then
  # Determine script location for relative paths
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Define paths
FLEET_DIR="${ROOT_DIR}/src/fleet"
CONFIG_DIR="${ROOT_DIR}/config/fleet"
DATA_DIR="${ROOT_DIR}/data/fleet"
METRICS_DIR="${DATA_DIR}/metrics"
NODE_DB="${CONFIG_DIR}/nodes.json"
SSH_DIR="${CONFIG_DIR}/ssh"
KEY_FILE="${SSH_DIR}/fleet_rsa"

# Source required modules
source "${FLEET_DIR}/core/ssh.sh"
source "${FLEET_DIR}/core/registration.sh"

# Ensure metrics directory exists
mkdir -p "$METRICS_DIR"

# Collect metrics from a specific node
collect_node_metrics() {
  local node_name="$1"
  
  # Verify node exists
  if ! node_exists "$node_name"; then
    echo -e "${RED}Error: Node '$node_name' not found in the database.${NC}"
    return 1
  fi
  
  # Get node connection details
  local node_data=$(get_node_data "$node_name")
  local host=$(echo "$node_data" | jq -r '.ip')
  local username=$(echo "$node_data" | jq -r '.username')
  local port=$(echo "$node_data" | jq -r '.port')
  
  echo -e "${BLUE}Collecting metrics from:${NC} $node_name ($username@$host:$port)"
  
  # Create node-specific metrics directory
  local node_metrics_dir="${METRICS_DIR}/${node_name}"
  mkdir -p "$node_metrics_dir"
  
  # Run remote command to get metrics
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local metrics_file="${node_metrics_dir}/metrics_${timestamp}.json"
  
  # Test connection first
  ssh -i "$KEY_FILE" -p "$port" -o ConnectTimeout=5 -o BatchMode=yes "$username@$host" exit &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Cannot connect to node $node_name.${NC}"
    mark_node_offline "$node_name"
    return 1
  fi
  
  # Get metrics via SSH
  ssh -i "$KEY_FILE" -p "$port" "$username@$host" "~/tools/pop --pulse --export json" > "$metrics_file"
  
  if [[ $? -eq 0 && -s "$metrics_file" ]]; then
    echo -e "${GREEN}Metrics collected successfully.${NC}"
    mark_node_online "$node_name"
    
    # Update last metrics timestamp
    update_node_last_metrics "$node_name" "$timestamp"
    
    # Print summary
    echo -e "${YELLOW}Metrics summary:${NC}"
    cat "$metrics_file" | jq -r '.status, "CPU: \(.cpu_usage)%", "Memory: \(.memory_usage)%", "Disk: \(.disk_usage)%"'
    
    return 0
  else
    echo -e "${RED}Failed to collect metrics from $node_name.${NC}"
    rm -f "$metrics_file"  # Remove empty file
    return 1
  fi
}

# Collect metrics from all nodes
collect_all_metrics() {
  local nodes=($(list_node_names))
  
  if [[ ${#nodes[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No nodes are registered. Use 'pop --fleet register' to add nodes.${NC}"
    return 1
  fi
  
  local success_count=0
  local failed_nodes=()
  
  echo -e "${CYAN}=== COLLECTING METRICS FROM ALL NODES ===${NC}"
  
  # Collect from each node
  for node in "${nodes[@]}"; do
    collect_node_metrics "$node"
    if [[ $? -eq 0 ]]; then
      ((success_count++))
    else
      failed_nodes+=("$node")
    fi
    echo
  done
  
  # Summary
  echo -e "${CYAN}Collection Summary:${NC}"
  echo -e "Total nodes: ${#nodes[@]}"
  echo -e "Successful: $success_count"
  echo -e "Failed: ${#failed_nodes[@]}"
  
  if [[ ${#failed_nodes[@]} -gt 0 ]]; then
    echo -e "${RED}Failed nodes: ${failed_nodes[*]}${NC}"
  fi
  
  # Save collection timestamp
  echo "$(date +"%Y-%m-%d %H:%M:%S")" > "${DATA_DIR}/last_collection.txt"
  
  return 0
}

# Display node metrics dashboard
display_metrics_dashboard() {
  local nodes=($(list_node_names))
  
  if [[ ${#nodes[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No nodes are registered. Use 'pop --fleet register' to add nodes.${NC}"
    return 1
  fi
  
  # Check if we have recent metrics
  if [[ ! -f "${DATA_DIR}/last_collection.txt" ]]; then
    echo -e "${YELLOW}No metrics have been collected yet. Run 'pop --fleet collect' first.${NC}"
    return 1
  fi
  
  local last_collection=$(cat "${DATA_DIR}/last_collection.txt")
  
  echo -e "${CYAN}=== FLEET METRICS DASHBOARD ===${NC}"
  echo -e "Last collection: $last_collection"
  echo -e "Total nodes: ${#nodes[@]}"
  echo
  
  # Header
  printf "%-20s %-10s %-10s %-10s %-10s %-15s\n" "NODE" "STATUS" "CPU%" "MEM%" "DISK%" "UPTIME"
  echo "----------------------------------------------------------------------"
  
  # Data for each node
  for node in "${nodes[@]}"; do
    local status="Unknown"
    local cpu="--"
    local mem="--"
    local disk="--"
    local uptime="--"
    
    # Get latest metrics file
    local node_metrics_dir="${METRICS_DIR}/${node}"
    local latest_metrics=$(ls -t "${node_metrics_dir}/metrics_"*.json 2>/dev/null | head -1)
    
    if [[ -f "$latest_metrics" ]]; then
      status=$(jq -r '.status // "Unknown"' "$latest_metrics")
      cpu=$(jq -r '.cpu_usage // "--"' "$latest_metrics")
      mem=$(jq -r '.memory_usage // "--"' "$latest_metrics")
      disk=$(jq -r '.disk_usage // "--"' "$latest_metrics")
      uptime=$(jq -r '.uptime // "--"' "$latest_metrics")
      
      # Format values
      [[ "$cpu" != "--" ]] && cpu="${cpu}%"
      [[ "$mem" != "--" ]] && mem="${mem}%"
      [[ "$disk" != "--" ]] && disk="${disk}%"
    else
      status="Offline"
    fi
    
    # Color the status
    local status_colored="$status"
    if [[ "$status" == "Running" ]]; then
      status_colored="${GREEN}Running${NC}"
    elif [[ "$status" == "Offline" ]]; then
      status_colored="${RED}Offline${NC}"
    elif [[ "$status" == "Starting" ]]; then
      status_colored="${YELLOW}Starting${NC}"
    fi
    
    printf "%-20s %-25s %-10s %-10s %-10s %-15s\n" "$node" "$status_colored" "$cpu" "$mem" "$disk" "$uptime"
  done
  
  echo
  echo -e "${YELLOW}Use 'pop --fleet collect' to refresh metrics.${NC}"
  
  return 0
}

# Main entry point for monitoring commands
monitor_command() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    collect)
      if [[ $# -ge 1 ]]; then
        collect_node_metrics "$1"
      else
        collect_all_metrics
      fi
      ;;
    dashboard)
      display_metrics_dashboard
      ;;
    *)
      echo -e "${RED}Unknown monitoring command: $cmd${NC}"
      echo -e "Available commands:"
      echo -e "  collect [node]    Collect metrics from all nodes or a specific node"
      echo -e "  dashboard         Display fleet metrics dashboard"
      return 1
      ;;
  esac
}

# Mark a node as online in the database
mark_node_online() {
  local node_name="$1"
  update_node_status "$node_name" "online"
}

# Mark a node as offline in the database
mark_node_offline() {
  local node_name="$1"
  update_node_status "$node_name" "offline"
}

# Update node's last metrics timestamp
update_node_last_metrics() {
  local node_name="$1"
  local timestamp="$2"
  
  # Update the node data
  local temp_file=$(mktemp)
  jq --arg name "$node_name" --arg ts "$timestamp" '
    .nodes |= map(
      if .name == $name then
        . + {"last_metrics": $ts}
      else
        .
      end
    )
  ' "$NODE_DB" > "$temp_file"
  
  # Replace the original file
  mv "$temp_file" "$NODE_DB"
}

# If this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  monitor_command "$@"
fi
