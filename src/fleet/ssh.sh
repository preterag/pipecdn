#!/bin/bash
# Fleet Management - SSH Command Execution Module
# Allows executing commands on remote nodes via SSH

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
NODE_DB="${CONFIG_DIR}/nodes.json"
SSH_DIR="${CONFIG_DIR}/ssh"
KEY_FILE="${SSH_DIR}/fleet_rsa"

# Source required modules
source "${FLEET_DIR}/core/ssh.sh"
source "${FLEET_DIR}/core/registration.sh"

# Execute a command on a specific node
execute_node_command() {
  local node_name="$1"
  shift
  local command="$*"
  
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
  
  echo -e "${BLUE}Executing command on node:${NC} $node_name ($username@$host:$port)"
  echo -e "${YELLOW}Command:${NC} $command"
  
  # Test connection first
  ssh -i "$KEY_FILE" -p "$port" -o ConnectTimeout=5 -o BatchMode=yes "$username@$host" exit &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Cannot connect to node $node_name.${NC}"
    mark_node_offline "$node_name"
    return 1
  fi
  
  # Execute the command
  echo -e "${CYAN}=== COMMAND OUTPUT ===${NC}"
  ssh -i "$KEY_FILE" -p "$port" "$username@$host" "$command"
  local status=$?
  
  if [[ $status -eq 0 ]]; then
    echo -e "${GREEN}Command executed successfully.${NC}"
    mark_node_online "$node_name"
  else
    echo -e "${RED}Command failed with exit code: $status${NC}"
  fi
  
  return $status
}

# Execute a command on all nodes
execute_all_nodes() {
  local command="$*"
  local nodes=($(list_node_names))
  
  if [[ ${#nodes[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No nodes are registered. Use 'pop --fleet register' to add nodes.${NC}"
    return 1
  fi
  
  local success_count=0
  local failed_nodes=()
  
  echo -e "${CYAN}=== EXECUTING COMMAND ON ALL NODES ===${NC}"
  echo -e "${YELLOW}Command:${NC} $command"
  echo
  
  # Execute on each node
  for node in "${nodes[@]}"; do
    echo -e "${CYAN}Node: $node${NC}"
    execute_node_command "$node" "$command" | sed 's/^/  /'
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
      ((success_count++))
    else
      failed_nodes+=("$node")
    fi
    echo
  done
  
  # Summary
  echo -e "${CYAN}Execution Summary:${NC}"
  echo -e "Total nodes: ${#nodes[@]}"
  echo -e "Successful: $success_count"
  echo -e "Failed: ${#failed_nodes[@]}"
  
  if [[ ${#failed_nodes[@]} -gt 0 ]]; then
    echo -e "${RED}Failed nodes: ${failed_nodes[*]}${NC}"
    return 1
  fi
  
  return 0
}

# Execute command on nodes in a group
execute_group_command() {
  local group_name="$1"
  shift
  local command="$*"
  
  # Check if group functions are available
  if ! type get_group_nodes &>/dev/null; then
    echo -e "${RED}Group management functions not available.${NC}"
    echo -e "Make sure you're using the latest version of the Fleet Management System."
    return 1
  fi
  
  # Handle special case "all" for all nodes
  if [[ "$group_name" == "all" ]]; then
    execute_all_nodes "$command"
    return $?
  fi
  
  # Get nodes in the specified group
  local nodes=($(get_group_nodes "$group_name" 2>/dev/null))
  
  if [[ ${#nodes[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No nodes found in group '$group_name' or group doesn't exist.${NC}"
    return 1
  fi
  
  local success_count=0
  local failed_nodes=()
  
  echo -e "${CYAN}=== EXECUTING COMMAND ON GROUP: $group_name ===${NC}"
  echo -e "${YELLOW}Command:${NC} $command"
  echo -e "${BLUE}Target nodes:${NC} ${nodes[*]}"
  echo
  
  # Execute on each node in the group
  for node in "${nodes[@]}"; do
    echo -e "${CYAN}Node: $node${NC}"
    execute_node_command "$node" "$command" | sed 's/^/  /'
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
      ((success_count++))
    else
      failed_nodes+=("$node")
    fi
    echo
  done
  
  # Summary
  echo -e "${CYAN}Execution Summary:${NC}"
  echo -e "Group: $group_name"
  echo -e "Total nodes: ${#nodes[@]}"
  echo -e "Successful: $success_count"
  echo -e "Failed: ${#failed_nodes[@]}"
  
  if [[ ${#failed_nodes[@]} -gt 0 ]]; then
    echo -e "${RED}Failed nodes: ${failed_nodes[*]}${NC}"
    return 1
  fi
  
  return 0
}

# Generate a script to execute on remote nodes
generate_remote_script() {
  local script_content="$1"
  local script_name="$2"
  local temp_dir="$3"
  local temp_script="${temp_dir}/${script_name}"
  
  # Create script file
  echo "#!/bin/bash" > "$temp_script"
  echo "$script_content" >> "$temp_script"
  chmod +x "$temp_script"
  
  echo "$temp_script"
}

# Execute a local script on a remote node
execute_node_script() {
  local node_name="$1"
  local script_content="$2"
  
  # Create temporary directory for script
  local temp_dir=$(mktemp -d)
  local script_name="remote_script_$(date +%s).sh"
  local local_script=$(generate_remote_script "$script_content" "$script_name" "$temp_dir")
  
  # Verify node exists
  if ! node_exists "$node_name"; then
    echo -e "${RED}Error: Node '$node_name' not found in the database.${NC}"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Get node connection details
  local node_data=$(get_node_data "$node_name")
  local host=$(echo "$node_data" | jq -r '.ip')
  local username=$(echo "$node_data" | jq -r '.username')
  local port=$(echo "$node_data" | jq -r '.port')
  
  echo -e "${BLUE}Executing script on node:${NC} $node_name ($username@$host:$port)"
  
  # Copy script to remote node
  local remote_script="/tmp/${script_name}"
  scp -i "$KEY_FILE" -P "$port" "$local_script" "$username@$host:$remote_script" &>/dev/null
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Failed to copy script to node $node_name.${NC}"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Execute the script
  echo -e "${CYAN}=== SCRIPT OUTPUT ===${NC}"
  ssh -i "$KEY_FILE" -p "$port" "$username@$host" "chmod +x $remote_script && $remote_script; rm -f $remote_script"
  local status=$?
  
  # Clean up local temp files
  rm -rf "$temp_dir"
  
  if [[ $status -eq 0 ]]; then
    echo -e "${GREEN}Script executed successfully.${NC}"
    mark_node_online "$node_name"
  else
    echo -e "${RED}Script failed with exit code: $status${NC}"
  fi
  
  return $status
}

# Interactive SSH session to a node
connect_to_node() {
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
  
  echo -e "${BLUE}Connecting to node:${NC} $node_name ($username@$host:$port)"
  echo -e "${YELLOW}Starting SSH session...${NC}"
  
  # Start SSH session
  ssh -i "$KEY_FILE" -p "$port" "$username@$host"
  local status=$?
  
  if [[ $status -eq 0 ]]; then
    echo -e "${GREEN}SSH session completed successfully.${NC}"
    mark_node_online "$node_name"
  else
    echo -e "${RED}SSH session failed with exit code: $status${NC}"
    mark_node_offline "$node_name"
  fi
  
  return $status
}

# Main entry point for SSH commands
ssh_command() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    exec)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Error: Node name and command required${NC}"
        echo -e "Usage: pop --fleet ssh exec <node> <command>"
        return 1
      fi
      local node_name="$1"
      shift
      execute_node_command "$node_name" "$@"
      ;;
    exec-all)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Command required${NC}"
        echo -e "Usage: pop --fleet ssh exec-all <command>"
        return 1
      fi
      execute_all_nodes "$@"
      ;;
    exec-group)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Error: Group name and command required${NC}"
        echo -e "Usage: pop --fleet ssh exec-group <group> <command>"
        return 1
      fi
      local group_name="$1"
      shift
      execute_group_command "$group_name" "$@"
      ;;
    script)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Error: Node name and script content required${NC}"
        echo -e "Usage: pop --fleet ssh script <node> <script-content>"
        return 1
      fi
      local node_name="$1"
      shift
      execute_node_script "$node_name" "$*"
      ;;
    connect)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Node name required${NC}"
        echo -e "Usage: pop --fleet ssh connect <node>"
        return 1
      fi
      connect_to_node "$1"
      ;;
    *)
      echo -e "${RED}Unknown SSH command: $cmd${NC}"
      echo -e "Available commands:"
      echo -e "  exec <node> <command>       Execute command on a specific node"
      echo -e "  exec-all <command>          Execute command on all nodes"
      echo -e "  exec-group <group> <cmd>    Execute command on all nodes in a group"
      echo -e "  script <node> <script>      Execute a script on a node"
      echo -e "  connect <node>              Start interactive SSH session"
      return 1
      ;;
  esac
}

# If this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  ssh_command "$@"
fi
