#!/bin/bash
# Fleet Management System for Pipe Network PoP
# Main entry point for managing multiple nodes

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
SRC_DIR="${ROOT_DIR}/src"
FLEET_DIR="${ROOT_DIR}/src/fleet"
CONFIG_DIR="${ROOT_DIR}/config/fleet"
DATA_DIR="${ROOT_DIR}/data/fleet"

# Define group management paths
GROUPS_FILE="${CONFIG_DIR}/groups.json"

# Source required modules
source "${FLEET_DIR}/core/ssh.sh"
source "${FLEET_DIR}/core/registration.sh"

# Ensure dependencies
check_dependencies() {
  local missing_deps=()
  
  # Check for required tools
  if ! command -v ssh &>/dev/null; then missing_deps+=("ssh"); fi
  if ! command -v jq &>/dev/null; then missing_deps+=("jq"); fi
  if ! command -v bc &>/dev/null; then missing_deps+=("bc"); fi

  # If anything is missing, report and exit
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
    echo -e "Please install them using your package manager:"
    echo -e "  sudo apt install ${missing_deps[*]}"
    return 1
  fi
  
  return 0
}

# Initialize fleet management system
init_fleet() {
  echo -e "${CYAN}Initializing Fleet Management System...${NC}"
  
  # Create required directories
  mkdir -p "$CONFIG_DIR" "$DATA_DIR"
  chmod 750 "$CONFIG_DIR" "$DATA_DIR"
  
  # Set up SSH directory and keys
  create_ssh_directories
  generate_ssh_key
  
  # Initialize node database
  init_node_db
  
  # Initialize groups if needed
  init_groups
  
  echo -e "\n${GREEN}Fleet Management System initialized successfully.${NC}"
  echo -e "${YELLOW}Next steps:${NC}"
  echo -e "1. Register nodes using: pop --fleet register <name> <ip> <username> [port]"
  echo -e "2. Add the SSH key to your nodes' authorized_keys file"
  echo -e "3. Test connections using: pop --fleet test <name>"
}

# Initialize groups database
init_groups() {
  if [[ ! -f "$GROUPS_FILE" ]]; then
    echo -e "${BLUE}Creating groups database...${NC}"
    echo '{"groups":[]}' > "$GROUPS_FILE"
    chmod 640 "$GROUPS_FILE"
  fi
}

# Create a new node group
create_group() {
  local group_name="$1"
  local description="${2:-}"
  
  # Validate group name
  if [[ -z "$group_name" ]]; then
    echo -e "${RED}Error: Group name is required${NC}"
    return 1
  fi
  
  # Check if group exists
  if jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${YELLOW}Group '$group_name' already exists.${NC}"
    return 1
  fi
  
  # Add group to database
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  jq --arg name "$group_name" \
     --arg desc "$description" \
     --arg time "$timestamp" \
     '.groups += [{"name": $name, "description": $desc, "created": $time, "nodes": []}]' \
     "$GROUPS_FILE" > "${GROUPS_FILE}.tmp"
  
  mv "${GROUPS_FILE}.tmp" "$GROUPS_FILE"
  
  echo -e "${GREEN}Group '$group_name' created successfully.${NC}"
  return 0
}

# Delete a node group
delete_group() {
  local group_name="$1"
  
  # Validate group name
  if [[ -z "$group_name" ]]; then
    echo -e "${RED}Error: Group name is required${NC}"
    return 1
  fi
  
  # Check if group exists
  if ! jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${RED}Error: Group '$group_name' does not exist.${NC}"
    return 1
  fi
  
  # Remove group from database
  jq --arg name "$group_name" '.groups |= map(select(.name != $name))' "$GROUPS_FILE" > "${GROUPS_FILE}.tmp"
  mv "${GROUPS_FILE}.tmp" "$GROUPS_FILE"
  
  echo -e "${GREEN}Group '$group_name' deleted successfully.${NC}"
  return 0
}

# Add a node to a group
add_node_to_group() {
  local node_name="$1"
  local group_name="$2"
  
  # Validate inputs
  if [[ -z "$node_name" || -z "$group_name" ]]; then
    echo -e "${RED}Error: Both node name and group name are required${NC}"
    return 1
  fi
  
  # Check if node exists
  if ! node_exists "$node_name"; then
    echo -e "${RED}Error: Node '$node_name' does not exist.${NC}"
    return 1
  fi
  
  # Check if group exists
  if ! jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${RED}Error: Group '$group_name' does not exist.${NC}"
    return 1
  fi
  
  # Check if node is already in the group
  if jq -e ".groups[] | select(.name == \"$group_name\") | .nodes | index(\"$node_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${YELLOW}Node '$node_name' is already in group '$group_name'.${NC}"
    return 0
  fi
  
  # Add node to group
  jq --arg name "$group_name" --arg node "$node_name" \
     '.groups |= map(if .name == $name then .nodes += [$node] else . end)' \
     "$GROUPS_FILE" > "${GROUPS_FILE}.tmp"
  
  mv "${GROUPS_FILE}.tmp" "$GROUPS_FILE"
  
  echo -e "${GREEN}Added node '$node_name' to group '$group_name'.${NC}"
  return 0
}

# Remove a node from a group
remove_node_from_group() {
  local node_name="$1"
  local group_name="$2"
  
  # Validate inputs
  if [[ -z "$node_name" || -z "$group_name" ]]; then
    echo -e "${RED}Error: Both node name and group name are required${NC}"
    return 1
  fi
  
  # Check if group exists
  if ! jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${RED}Error: Group '$group_name' does not exist.${NC}"
    return 1
  fi
  
  # Check if node is in the group
  if ! jq -e ".groups[] | select(.name == \"$group_name\") | .nodes | index(\"$node_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${YELLOW}Node '$node_name' is not in group '$group_name'.${NC}"
    return 0
  fi
  
  # Remove node from group
  jq --arg name "$group_name" --arg node "$node_name" \
     '.groups |= map(if .name == $name then .nodes -= [$node] else . end)' \
     "$GROUPS_FILE" > "${GROUPS_FILE}.tmp"
  
  mv "${GROUPS_FILE}.tmp" "$GROUPS_FILE"
  
  echo -e "${GREEN}Removed node '$node_name' from group '$group_name'.${NC}"
  return 0
}

# List all groups
list_groups() {
  echo -e "${CYAN}=== FLEET MANAGEMENT GROUPS ===${NC}"
  
  # Check if groups file exists and has groups
  if [[ ! -f "$GROUPS_FILE" ]] || [[ $(jq '.groups | length' "$GROUPS_FILE") -eq 0 ]]; then
    echo -e "${YELLOW}No groups defined.${NC}"
    echo -e "Create a group using: pop --fleet group create <name> [description]"
    return 0
  fi
  
  # Print header
  printf "%-20s %-40s %-10s %-15s\n" "GROUP NAME" "DESCRIPTION" "NODES" "CREATED"
  echo "---------------------------------------------------------------------------------"
  
  # Print each group
  jq -r '.groups[] | "\(.name)\t\(.description)\t\(.nodes | length)\t\(.created)"' "$GROUPS_FILE" | \
  while IFS=$'\t' read -r name desc nodes_count created; do
    printf "%-20s %-40s %-10s %-15s\n" "$name" "${desc:0:37}${desc:37:1000000+}" "$nodes_count" "$created"
  done
  
  return 0
}

# Show details for a specific group
show_group_details() {
  local group_name="$1"
  
  # Validate input
  if [[ -z "$group_name" ]]; then
    echo -e "${RED}Error: Group name is required${NC}"
    return 1
  fi
  
  # Check if group exists
  if ! jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${RED}Error: Group '$group_name' does not exist.${NC}"
    return 1
  fi
  
  # Get group details
  local group_json=$(jq -r ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE")
  local description=$(echo "$group_json" | jq -r '.description')
  local created=$(echo "$group_json" | jq -r '.created')
  local nodes=$(echo "$group_json" | jq -r '.nodes | join(", ")')
  local node_count=$(echo "$group_json" | jq -r '.nodes | length')
  
  # Print group details
  echo -e "${CYAN}=== GROUP DETAILS: $group_name ===${NC}"
  echo -e "Description: ${description:-None}"
  echo -e "Created: $created"
  echo -e "Node count: $node_count"
  
  if [[ $node_count -gt 0 ]]; then
    echo -e "\n${CYAN}Nodes in group:${NC}"
    local node_list=$(echo "$group_json" | jq -r '.nodes[]')
    if [[ -n "$node_list" ]]; then
      local count=1
      echo "$node_list" | while read -r node; do
        # Get node status if possible
        local status="Unknown"
        if node_exists "$node"; then
          local node_data=$(get_node_data "$node")
          status=$(echo "$node_data" | jq -r '.status')
        fi
        
        # Print with status
        if [[ "$status" == "online" ]]; then
          echo -e "$count. $node ${GREEN}(online)${NC}"
        elif [[ "$status" == "offline" ]]; then
          echo -e "$count. $node ${RED}(offline)${NC}"
        else
          echo -e "$count. $node (status unknown)"
        fi
        
        ((count++))
      done
    fi
  else
    echo -e "\n${YELLOW}No nodes in this group.${NC}"
    echo -e "Add nodes using: pop --fleet group add-node <node> $group_name"
  fi
  
  return 0
}

# Get nodes in a group
get_group_nodes() {
  local group_name="$1"
  
  # Validate input
  if [[ -z "$group_name" ]]; then
    echo -e "${RED}Error: Group name is required${NC}"
    return 1
  fi
  
  # Handle special case "all" to return all nodes
  if [[ "$group_name" == "all" ]]; then
    list_node_names
    return 0
  fi
  
  # Check if group exists
  if ! jq -e ".groups[] | select(.name == \"$group_name\")" "$GROUPS_FILE" &>/dev/null; then
    echo -e "${RED}Error: Group '$group_name' does not exist.${NC}" >&2
    return 1
  fi
  
  # Get nodes in group
  jq -r ".groups[] | select(.name == \"$group_name\") | .nodes[]" "$GROUPS_FILE"
  return 0
}

# Print usage information
print_usage() {
  echo -e "${CYAN}Pipe Network Fleet Management Commands:${NC}"
  echo -e "  ${YELLOW}init${NC}                Initialize fleet management system"
  echo -e "  ${YELLOW}register${NC} <n> <ip> <user> [port]  Register a new node"
  echo -e "  ${YELLOW}unregister${NC} <name>   Remove a node from management"
  echo -e "  ${YELLOW}list${NC}                List all registered nodes"
  echo -e "  ${YELLOW}test${NC} <name>         Test connection to a node"
  echo -e "  ${YELLOW}collect${NC} [name]      Collect metrics from nodes"
  echo -e "  ${YELLOW}dashboard${NC}           Display fleet dashboard"
  echo -e "  ${YELLOW}exec${NC} <name> <cmd>   Execute command on a node"
  echo -e "  ${YELLOW}exec-all${NC} <cmd>      Execute command on all nodes"
  echo -e "  ${YELLOW}deploy${NC} <file> [nodes]  Deploy file to nodes"
  echo -e "  ${YELLOW}status${NC}              Show fleet status summary"
  echo -e "  ${YELLOW}group${NC} <subcmd>      Manage node groups (see below)"
  echo -e "  ${YELLOW}help${NC}                Show this help message"
  echo
  echo -e "${CYAN}Group Management Commands:${NC}"
  echo -e "  ${YELLOW}group create${NC} <name> [desc]       Create a new node group"
  echo -e "  ${YELLOW}group delete${NC} <name>              Delete a node group"
  echo -e "  ${YELLOW}group list${NC}                       List all groups"
  echo -e "  ${YELLOW}group show${NC} <name>                Show group details"
  echo -e "  ${YELLOW}group add-node${NC} <node> <group>    Add node to group"
  echo -e "  ${YELLOW}group remove-node${NC} <node> <group> Remove node from group"
  echo -e "  ${YELLOW}group exec${NC} <group> <cmd>         Execute on group nodes"
}

# Main command handler
fleet_command() {
  local cmd="$1"
  shift
  
  # Ensure dependencies are installed
  check_dependencies || return 1
  
  case "$cmd" in
    init)
      init_fleet
      ;;
    register)
      if [[ $# -lt 3 ]]; then
        echo -e "${RED}Error: Missing arguments${NC}"
        echo -e "Usage: pop --fleet register <name> <ip> <username> [port]"
        return 1
      fi
      register_node "$@"
      ;;
    unregister)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Node name required${NC}"
        return 1
      fi
      unregister_node "$1"
      ;;
    list)
      list_nodes
      ;;
    test)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Node name required${NC}"
        return 1
      fi
      test_node_connection "$1"
      ;;
    collect)
      echo -e "${YELLOW}Collecting metrics from nodes...${NC}"
      echo -e "${RED}Not implemented yet.${NC}"
      # Future: collect_metrics "$@"
      ;;
    dashboard)
      echo -e "${YELLOW}Opening fleet dashboard...${NC}"
      echo -e "${RED}Not implemented yet.${NC}"
      # Future: display_dashboard
      ;;
    exec)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Error: Node name and command required${NC}"
        echo -e "Usage: pop --fleet exec <node> <command>"
        return 1
      fi
      node_name="$1"
      shift
      # Future: execute_command "$node_name" "$@"
      echo -e "${RED}Not implemented yet.${NC}"
      ;;
    exec-all)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Command required${NC}"
        return 1
      fi
      # Future: execute_all_nodes "$@"
      echo -e "${RED}Not implemented yet.${NC}"
      ;;
    deploy)
      echo -e "${YELLOW}Deploying files to nodes...${NC}"
      echo -e "${RED}Not implemented yet.${NC}"
      # Future: deploy_files "$@"
      ;;
    status)
      echo -e "${YELLOW}Fleet status:${NC}"
      summarize_fleet_status
      ;;
    group)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Error: Group subcommand required${NC}"
        echo -e "Available subcommands: create, delete, list, show, add-node, remove-node, exec"
        return 1
      fi
      
      local subcmd="$1"
      shift
      
      case "$subcmd" in
        create)
          if [[ $# -lt 1 ]]; then
            echo -e "${RED}Error: Group name required${NC}"
            return 1
          fi
          create_group "$1" "$2"
          ;;
        delete)
          if [[ $# -lt 1 ]]; then
            echo -e "${RED}Error: Group name required${NC}"
            return 1
          fi
          delete_group "$1"
          ;;
        list)
          list_groups
          ;;
        show)
          if [[ $# -lt 1 ]]; then
            echo -e "${RED}Error: Group name required${NC}"
            return 1
          fi
          show_group_details "$1"
          ;;
        add-node)
          if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Node name and group name required${NC}"
            return 1
          fi
          add_node_to_group "$1" "$2"
          ;;
        remove-node)
          if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Node name and group name required${NC}"
            return 1
          fi
          remove_node_from_group "$1" "$2"
          ;;
        exec)
          if [[ $# -lt 2 ]]; then
            echo -e "${RED}Error: Group name and command required${NC}"
            return 1
          fi
          group_name="$1"
          shift
          
          # Get nodes in group
          local nodes=($(get_group_nodes "$group_name"))
          if [[ ${#nodes[@]} -eq 0 ]]; then
            echo -e "${YELLOW}No nodes in group '$group_name' or group not found.${NC}"
            return 1
          fi
          
          echo -e "${BLUE}Executing command on all nodes in group '$group_name'...${NC}"
          echo -e "Target nodes: ${nodes[*]}"
          echo -e "Command: $*"
          echo -e "${RED}Not implemented yet.${NC}"
          # Future: execute_on_nodes "${nodes[@]}" "$@"
          ;;
        *)
          echo -e "${RED}Unknown group subcommand: $subcmd${NC}"
          echo -e "Available subcommands: create, delete, list, show, add-node, remove-node, exec"
          return 1
          ;;
      esac
      ;;
    help|*)
      print_usage
      ;;
  esac
}

# Summarize fleet status
summarize_fleet_status() {
  local nodes_count=$(count_nodes)
  local online_count=$(count_online_nodes)
  
  echo -e "\n${CYAN}=== FLEET STATUS SUMMARY ===${NC}"
  echo -e "Total nodes: $nodes_count"
  echo -e "Online nodes: $online_count"
  echo -e "Offline nodes: $((nodes_count - online_count))"
  echo
  
  if [[ "$nodes_count" -eq 0 ]]; then
    echo -e "${YELLOW}No nodes registered. Use 'pop --fleet register' to add nodes.${NC}"
  elif [[ "$online_count" -eq 0 ]]; then
    echo -e "${RED}Warning: All nodes appear to be offline.${NC}"
    echo -e "Use 'pop --fleet test <node>' to verify connections."
  fi
}

# If this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  fleet_command "$@"
fi
