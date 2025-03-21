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
  
  echo -e "\n${GREEN}Fleet Management System initialized successfully.${NC}"
  echo -e "${YELLOW}Next steps:${NC}"
  echo -e "1. Register nodes using: pop --fleet register <name> <ip> <username> [port]"
  echo -e "2. Add the SSH key to your nodes' authorized_keys file"
  echo -e "3. Test connections using: pop --fleet test <name>"
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
  echo -e "  ${YELLOW}help${NC}                Show this help message"
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
