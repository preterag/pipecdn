#!/bin/bash
# Community Enhancement: Node Registration for Pipe Network Fleet
# This script handles node registration, discovery, and inventory management

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
SSH_MODULE="$(dirname "$0")/ssh.sh"

# Import SSH module if available
if [[ -f "$SSH_MODULE" ]]; then
  source "$SSH_MODULE"
fi

# Ensure directories exist
create_db_directories() {
  mkdir -p "$DB_DIR"
  chmod 755 "$DB_DIR"
  echo -e "${GREEN}Database directory created at $DB_DIR${NC}"
  
  # Create empty nodes database if it doesn't exist
  if [[ ! -f "$NODES_DB" ]]; then
    echo "{\"nodes\":[]}" > "$NODES_DB"
    chmod 644 "$NODES_DB"
    echo -e "${GREEN}Nodes database created at $NODES_DB${NC}"
  fi
}

# Register a new node
register_node() {
  local name="$1"
  local ip="$2"
  local username="$3"
  local port="${4:-22}"
  local location="$5"
  local description="$6"
  
  # Validate inputs
  if [[ -z "$name" || -z "$ip" || -z "$username" ]]; then
    echo -e "${RED}Error: Missing required parameters.${NC}"
    echo -e "Usage: register_node <name> <ip> <username> [port] [location] [description]"
    return 1
  fi
  
  # Ensure DB directory exists
  if [[ ! -d "$DB_DIR" ]]; then
    create_db_directories
  fi
  
  # Check if name already exists
  if jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${YELLOW}A node with name '$name' already exists.${NC}"
    read -p "Update it? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
      echo -e "${YELLOW}Registration canceled.${NC}"
      return 0
    fi
    
    # Remove existing node
    jq ".nodes |= map(select(.name != \"$name\"))" "$NODES_DB" > "$NODES_DB.tmp"
    mv "$NODES_DB.tmp" "$NODES_DB"
  fi
  
  # Check connection if SSH module is available
  local status="Unknown"
  if type test_ssh_connection &>/dev/null; then
    if test_ssh_connection "$ip" "$username" "$port"; then
      status="Connected"
    else
      status="Disconnected"
    fi
  fi
  
  # Create node object
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local node_json=$(jq -n \
    --arg name "$name" \
    --arg ip "$ip" \
    --arg username "$username" \
    --arg port "$port" \
    --arg location "${location:-Unknown}" \
    --arg description "${description:-}" \
    --arg status "$status" \
    --arg registered "$timestamp" \
    --arg last_seen "$timestamp" \
    '{name: $name, ip: $ip, username: $username, port: $port, location: $location, 
    description: $description, status: $status, registered: $registered, 
    last_seen: $last_seen, metrics: {}}')
  
  # Add node to database
  jq ".nodes += [$node_json]" "$NODES_DB" > "$NODES_DB.tmp"
  mv "$NODES_DB.tmp" "$NODES_DB"
  
  echo -e "${GREEN}Node '$name' registered successfully.${NC}"
  
  # Add node to SSH configuration if available
  if type add_node &>/dev/null; then
    add_node "$name" "$ip" "$username" "$port"
  fi
  
  return 0
}

# Update an existing node
update_node() {
  local name="$1"
  local field="$2"
  local value="$3"
  
  # Validate inputs
  if [[ -z "$name" || -z "$field" || -z "$value" ]]; then
    echo -e "${RED}Error: Missing required parameters.${NC}"
    echo -e "Usage: update_node <name> <field> <value>"
    return 1
  fi
  
  # Check if node exists
  if ! jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${RED}No node with name '$name' found.${NC}"
    return 1
  fi
  
  # Validate field
  case "$field" in
    ip|username|port|location|description|status)
      # Valid fields
      ;;
    *)
      echo -e "${RED}Invalid field: '$field'.${NC}"
      echo -e "Valid fields: ip, username, port, location, description, status"
      return 1
      ;;
  esac
  
  # Update node field
  jq ".nodes |= map(if .name == \"$name\" then .${field} = \"${value}\" else . end)" "$NODES_DB" > "$NODES_DB.tmp"
  mv "$NODES_DB.tmp" "$NODES_DB"
  
  echo -e "${GREEN}Node '$name' updated: $field = $value${NC}"
  
  # Update SSH configuration if needed
  if [[ "$field" == "ip" || "$field" == "username" || "$field" == "port" ]] && type add_node &>/dev/null; then
    # Get current node details
    local ip=$(jq -r ".nodes[] | select(.name == \"$name\") | .ip" "$NODES_DB")
    local username=$(jq -r ".nodes[] | select(.name == \"$name\") | .username" "$NODES_DB")
    local port=$(jq -r ".nodes[] | select(.name == \"$name\") | .port" "$NODES_DB")
    
    # Update SSH configuration
    add_node "$name" "$ip" "$username" "$port"
  fi
  
  return 0
}

# Remove a node
unregister_node() {
  local name="$1"
  
  # Validate inputs
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Node name is required.${NC}"
    echo -e "Usage: unregister_node <name>"
    return 1
  fi
  
  # Check if node exists
  if ! jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${RED}No node with name '$name' found.${NC}"
    return 1
  fi
  
  # Ask for confirmation
  read -p "Are you sure you want to unregister node '$name'? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo -e "${YELLOW}Unregistration canceled.${NC}"
    return 0
  fi
  
  # Remove node from database
  jq ".nodes |= map(select(.name != \"$name\"))" "$NODES_DB" > "$NODES_DB.tmp"
  mv "$NODES_DB.tmp" "$NODES_DB"
  
  echo -e "${GREEN}Node '$name' unregistered successfully.${NC}"
  
  # Remove from SSH configuration if available
  if type remove_node &>/dev/null; then
    remove_node "$name"
  fi
  
  return 0
}

# List all registered nodes
list_registered_nodes() {
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${CYAN}     PIPE NETWORK REGISTERED NODES${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo
  
  if [[ ! -f "$NODES_DB" ]]; then
    echo -e "${YELLOW}No nodes registered yet.${NC}"
    return 0
  fi
  
  local node_count=$(jq '.nodes | length' "$NODES_DB")
  
  if [[ "$node_count" -eq 0 ]]; then
    echo -e "${YELLOW}No nodes registered yet.${NC}"
    return 0
  fi
  
  # Print header
  printf "%-15s %-15s %-12s %-15s %-15s %-20s\n" "NAME" "IP ADDRESS" "PORT" "STATUS" "LOCATION" "REGISTERED"
  echo "------------------------------------------------------------------------------------------------"
  
  # Print nodes
  jq -r '.nodes[] | "\(.name) \(.ip) \(.port) \(.status) \(.location) \(.registered)"' "$NODES_DB" | \
  while read -r name ip port status location registered; do
    # Color status
    if [[ "$status" == "Connected" ]]; then
      status="${GREEN}Connected${NC}"
    elif [[ "$status" == "Disconnected" ]]; then
      status="${RED}Disconnected${NC}"
    else
      status="${YELLOW}Unknown${NC}"
    fi
    
    printf "%-15s %-15s %-12s %-15b %-15s %-20s\n" "$name" "$ip" "$port" "$status" "$location" "$registered"
  done
  
  echo -e "\nTotal registered nodes: $node_count"
  echo
}

# Get details of a specific node
get_node_details() {
  local name="$1"
  
  # Validate inputs
  if [[ -z "$name" ]]; then
    echo -e "${RED}Error: Node name is required.${NC}"
    echo -e "Usage: get_node_details <name>"
    return 1
  fi
  
  # Check if node exists
  if ! jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${RED}No node with name '$name' found.${NC}"
    return 1
  fi
  
  # Get and print node details
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${CYAN}     NODE DETAILS: $name${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo
  
  # Extract details
  local details=$(jq -r ".nodes[] | select(.name == \"$name\")" "$NODES_DB")
  
  echo -e "Name:        $(echo "$details" | jq -r .name)"
  echo -e "IP Address:  $(echo "$details" | jq -r .ip)"
  echo -e "Username:    $(echo "$details" | jq -r .username)"
  echo -e "Port:        $(echo "$details" | jq -r .port)"
  echo -e "Location:    $(echo "$details" | jq -r .location)"
  echo -e "Status:      $(echo "$details" | jq -r .status)"
  echo -e "Registered:  $(echo "$details" | jq -r .registered)"
  echo -e "Last Seen:   $(echo "$details" | jq -r .last_seen)"
  
  # Show description if present
  local description=$(echo "$details" | jq -r .description)
  if [[ -n "$description" && "$description" != "null" && "$description" != "" ]]; then
    echo -e "\nDescription: $description"
  fi
  
  echo
  
  # Show metrics if present
  local metrics=$(echo "$details" | jq -r .metrics)
  if [[ -n "$metrics" && "$metrics" != "{}" ]]; then
    echo -e "Performance Metrics:"
    echo "$metrics" | jq -r
  fi
  
  return 0
}

# Update node status
update_node_status() {
  local name="$1"
  local status="$2"
  
  # Validate inputs
  if [[ -z "$name" || -z "$status" ]]; then
    echo -e "${RED}Error: Missing required parameters.${NC}"
    echo -e "Usage: update_node_status <name> <status>"
    return 1
  fi
  
  # Check if node exists
  if ! jq -e ".nodes[] | select(.name == \"$name\")" "$NODES_DB" >/dev/null 2>&1; then
    echo -e "${RED}No node with name '$name' found.${NC}"
    return 1
  fi
  
  # Update status and last_seen
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  jq ".nodes |= map(if .name == \"$name\" then .status = \"$status\" | .last_seen = \"$timestamp\" else . end)" "$NODES_DB" > "$NODES_DB.tmp"
  mv "$NODES_DB.tmp" "$NODES_DB"
  
  echo -e "${GREEN}Node '$name' status updated to $status${NC}"
  return 0
}

# Main function to process commands
process_registration_command() {
  local command="$1"
  shift
  
  case "$command" in
    init)
      create_db_directories
      ;;
    register)
      if [[ $# -lt 3 ]]; then
        echo -e "${RED}Usage: --fleet register <name> <ip> <username> [port] [location] [description]${NC}"
        return 1
      fi
      register_node "$@"
      ;;
    update)
      if [[ $# -lt 3 ]]; then
        echo -e "${RED}Usage: --fleet update <name> <field> <value>${NC}"
        return 1
      fi
      update_node "$@"
      ;;
    unregister)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Usage: --fleet unregister <name>${NC}"
        return 1
      fi
      unregister_node "$@"
      ;;
    list)
      list_registered_nodes
      ;;
    details)
      if [[ $# -lt 1 ]]; then
        echo -e "${RED}Usage: --fleet details <name>${NC}"
        return 1
      fi
      get_node_details "$@"
      ;;
    status)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Usage: --fleet status <name> <status>${NC}"
        return 1
      fi
      update_node_status "$@"
      ;;
    *)
      echo -e "${RED}Unknown registration command: $command${NC}"
      echo -e "Available commands: init, register, update, unregister, list, details, status"
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
    echo "  init                        - Initialize the node database"
    echo "  register <name> <ip> <user> - Register a new node"
    echo "  update <name> <field> <val> - Update node field"
    echo "  unregister <name>           - Remove a node"
    echo "  list                        - List all registered nodes"
    echo "  details <name>              - Show details for a node"
    echo "  status <name> <status>      - Update node status"
    exit 1
  fi
  
  # Process command
  process_registration_command "$@"
  exit $?
fi 