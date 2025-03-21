#!/bin/bash
# Community Enhancement: SSH Management for Pipe Network Fleet
# This script provides SSH key and connection management for multiple nodes

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

# Ensure we're in the correct directory
if [[ -z "$ROOT_DIR" ]]; then
  # Determine script location for relative paths
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
fi

# Define paths
FLEET_DIR="${ROOT_DIR}/src/fleet"
CONFIG_DIR="${ROOT_DIR}/config/fleet"
SSH_DIR="${CONFIG_DIR}/ssh"
KEY_FILE="${SSH_DIR}/fleet_rsa"
KNOWN_HOSTS="${SSH_DIR}/known_hosts"
AUTH_COMMAND="~/tools/pop --status; ~/tools/pop --pulse --export json"

# Create SSH directory and files
create_ssh_directories() {
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  
  if [[ ! -f "$KNOWN_HOSTS" ]]; then
    touch "$KNOWN_HOSTS"
    chmod 600 "$KNOWN_HOSTS"
  fi
  
  echo -e "${GREEN}SSH directories created.${NC}"
}

# Generate a new SSH key for fleet management
generate_ssh_key() {
  # Check if key already exists
  if [[ -f "$KEY_FILE" ]]; then
    echo -e "${YELLOW}SSH key already exists.${NC}"
    echo -e "Use 'pop --fleet keygen --force' to regenerate."
    return 0
  fi
  
  # Generate SSH key
  echo -e "${BLUE}Generating SSH key pair for fleet management...${NC}"
  ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -N "" -C "pipe-pop-fleet-$(hostname)"
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to generate SSH key.${NC}"
    return 1
  fi
  
  chmod 600 "$KEY_FILE"
  chmod 644 "${KEY_FILE}.pub"
  
  echo -e "${GREEN}SSH key pair generated successfully.${NC}"
  echo -e "${YELLOW}Public key:${NC}"
  echo -e "${CYAN}$(cat ${KEY_FILE}.pub)${NC}"
  
  echo
  echo -e "${YELLOW}When registering a node, you should add this public key to the node's"
  echo -e "~/.ssh/authorized_keys file with appropriate restrictions:${NC}"
  echo -e "${CYAN}command=\"~/tools/pop --status; ~/tools/pop --pulse --export json\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat ${KEY_FILE}.pub)${NC}"
  
  return 0
}

# Test SSH connection to a node
test_ssh_connection() {
  local node_ip="$1"
  local username="$2"
  local port="${3:-22}"
  
  echo -e "Testing SSH connection to ${username}@${node_ip}:${port}..."
  if ssh -i "$KEY_FILE" -o "StrictHostKeyChecking=no" -p "$port" "${username}@${node_ip}" exit 2>/dev/null; then
    echo -e "${GREEN}Connection successful!${NC}"
    return 0
  else
    echo -e "${RED}Connection failed.${NC}"
    return 1
  fi
}

# Add node to configuration
add_node() {
  local name="$1"
  local ip="$2"
  local username="$3"
  local port="${4:-22}"
  
  # Check if node already exists
  if grep -q "^$name:" "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${YELLOW}Node '$name' already exists in configuration.${NC}"
    read -p "Update it? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
      echo -e "${YELLOW}Keeping existing configuration.${NC}"
      return 0
    fi
    # Remove existing entry
    sed -i "/^$name:/d" "$CONFIG_FILE"
  fi
  
  # Add node to configuration file
  echo "$name:$ip:$username:$port" >> "$CONFIG_FILE"
  echo -e "${GREEN}Node '$name' added to configuration.${NC}"
}

# Remove node from configuration
remove_node() {
  local name="$1"
  
  if ! grep -q "^$name:" "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}Node '$name' not found in configuration.${NC}"
    return 1
  fi
  
  # Remove node from configuration file
  sed -i "/^$name:/d" "$CONFIG_FILE"
  echo -e "${GREEN}Node '$name' removed from configuration.${NC}"
}

# List all nodes
list_nodes() {
  echo -e "${CYAN}==================================================${NC}"
  echo -e "${CYAN}     PIPE NETWORK FLEET NODES${NC}"
  echo -e "${CYAN}==================================================${NC}"
  echo
  
  if [[ ! -f "$CONFIG_FILE" || ! -s "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}No nodes configured yet.${NC}"
    echo -e "Use 'pop --fleet add-node' to add nodes."
    return 0
  fi
  
  printf "%-20s %-15s %-15s %-10s %-15s\n" "NAME" "IP ADDRESS" "USERNAME" "PORT" "STATUS"
  echo "-------------------------------------------------------------------------"
  
  while IFS=: read -r name ip username port; do
    # Test connection and get status
    if ssh -i "$KEY_FILE" -o "StrictHostKeyChecking=no" -o "ConnectTimeout=2" -p "$port" "${username}@${ip}" exit 2>/dev/null; then
      status="${GREEN}Connected${NC}"
    else
      status="${RED}Disconnected${NC}"
    fi
    
    printf "%-20s %-15s %-15s %-10s %-15b\n" "$name" "$ip" "$username" "${port:-22}" "$status"
  done < "$CONFIG_FILE"
  
  echo
}

# Execute command on a node
execute_command() {
  local node="$1"
  local command="$2"
  
  # Get node details
  local node_details=$(grep "^$node:" "$CONFIG_FILE" 2>/dev/null)
  if [[ -z "$node_details" ]]; then
    echo -e "${RED}Node '$node' not found in configuration.${NC}"
    return 1
  fi
  
  IFS=: read -r name ip username port <<< "$node_details"
  
  echo -e "Executing command on $name (${username}@${ip}:${port:-22})..."
  ssh -i "$KEY_FILE" -o "StrictHostKeyChecking=no" -p "${port:-22}" "${username}@${ip}" "$command"
  
  return $?
}

# Execute command on all nodes
execute_command_all() {
  local command="$1"
  
  if [[ ! -f "$CONFIG_FILE" || ! -s "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}No nodes configured yet.${NC}"
    return 1
  fi
  
  while IFS=: read -r name ip username port; do
    echo -e "\n${CYAN}==================================================${NC}"
    echo -e "${CYAN}     EXECUTING ON: $name (${username}@${ip})${NC}"
    echo -e "${CYAN}==================================================${NC}"
    
    ssh -i "$KEY_FILE" -o "StrictHostKeyChecking=no" -p "${port:-22}" "${username}@${ip}" "$command" || \
      echo -e "${RED}Command failed on $name.${NC}"
  done < "$CONFIG_FILE"
  
  return 0
}

# Main function to process commands
process_ssh_command() {
  local command="$1"
  shift
  
  case "$command" in
    setup)
      create_ssh_directories
      generate_ssh_key
      ;;
    test)
      if [[ $# -lt 2 ]]; then
        echo -e "${RED}Usage: --fleet ssh test <ip> <username> [port]${NC}"
        return 1
      fi
      test_ssh_connection "$1" "$2" "$3"
      ;;
    *)
      echo -e "${RED}Unknown SSH command: $command${NC}"
      echo -e "Available commands: setup, test"
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
    echo "  setup             - Set up SSH directories and generate keys"
    echo "  test <ip> <user>  - Test SSH connection to a node"
    exit 1
  fi
  
  # Process command
  process_ssh_command "$@"
  exit $?
fi 