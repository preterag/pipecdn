#!/bin/bash
# Command Parser for Pipe Network PoP Node Management Tools
# This module handles command-line argument parsing and routing

# =====================
# Basic Information
# =====================

# Version information
VERSION="v0.0.1"

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# =====================
# Logging Functions
# =====================

# Log info message
log_info() {
  echo -e "[${GREEN}INFO${NC}] $1"
}

# Log warning message
log_warn() {
  echo -e "[${YELLOW}WARN${NC}] $1" >&2
}

# Log error message
log_error() {
  echo -e "[${RED}ERROR${NC}] $1" >&2
}

# Log debug message (only when debug is enabled)
log_debug() {
  if [[ "$DEBUG" == "true" ]]; then
    echo -e "[${BLUE}DEBUG${NC}] $1"
  fi
}

# Print a section header
print_header() {
  local title="$1"
  local width=50
  local padding=$(( (width - ${#title} - 2) / 2 ))
  local left_padding=$padding
  local right_padding=$padding
  
  if (( ${#title} % 2 == 1 )); then
    right_padding=$((right_padding + 1))
  fi
  
  echo
  echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
  echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $left_padding)) ${title} $(printf '=%.0s' $(seq 1 $right_padding))${NC}"
  echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
  echo
}

# =====================
# Utility Functions
# =====================

# Ensures all required paths are set up
setup_paths() {
  # If ROOT_DIR is not set, try to determine it
  if [[ -z "$ROOT_DIR" ]]; then
    # Get the directory of this script
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    ROOT_DIR="$(cd "$script_dir/../.." && pwd)"
  fi
  
  # Set up common directories
  SRC_DIR="${ROOT_DIR}/src"
  BIN_DIR="${ROOT_DIR}/bin"
  TOOLS_DIR="${ROOT_DIR}/tools"
  
  # Set up installation directories if not already set
  if [[ -z "$INSTALL_DIR" ]]; then
    INSTALL_DIR="/opt/pipe-pop"
  fi
  
  if [[ -z "$CONFIG_DIR" ]]; then
    CONFIG_DIR="${INSTALL_DIR}/config"
  fi
  
  if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE="${CONFIG_DIR}/config.json"
  fi
  
  if [[ -z "$LOCAL_CONFIG_FILE" ]]; then
    LOCAL_CONFIG_FILE="./config.json"
  fi
  
  # Export all paths for use by other modules
  export ROOT_DIR
  export SRC_DIR
  export BIN_DIR
  export TOOLS_DIR
  export INSTALL_DIR
  export CONFIG_DIR
  export CONFIG_FILE
  export LOCAL_CONFIG_FILE
}

# Validate the environment (required files, dependencies)
validate_environment() {
  local errors=0
  
  # Check for critical dependencies
  if ! command -v jq &> /dev/null; then
    log_warn "jq is not installed. Some features may not work properly."
  fi
  
  if ! command -v systemctl &> /dev/null; then
    log_warn "systemctl is not available. Service management features may not work."
  fi
  
  if (( errors > 0 )); then
    log_error "Environment validation failed with $errors errors."
    return 1
  fi
  
  return 0
}

# Load a module by name
load_module() {
  local module_name="$1"
  local module_path="${SRC_DIR}/${module_name}"
  
  if [[ ! -f "$module_path" ]]; then
    log_error "Module not found: $module_path"
    return 1
  fi
  
  source "$module_path"
  return $?
}

# =====================
# Command Functions
# =====================

# Display version information
show_version() {
  print_header "VERSION"
  echo -e "Pipe Network PoP Node Management Tools"
  echo -e "Version: ${GREEN}${VERSION}${NC}"
  echo
  echo -e "Visit ${BLUE}https://pipe.network${NC} for more information."
  return 0
}

# Display help message
show_help() {
  print_header "HELP"
  
  echo -e "Usage: pop [OPTIONS] [COMMAND]"
  echo
  echo -e "The Pipe Network PoP Node Management Tools provide a unified"
  echo -e "interface for managing your Pipe Network point-of-presence nodes."
  echo
  
  echo -e "Commands:"
  echo -e "  ${CYAN}status${NC}                 Show current node status"
  echo -e "  ${CYAN}start${NC}                  Start the node service"
  echo -e "  ${CYAN}stop${NC}                   Stop the node service"
  echo -e "  ${CYAN}restart${NC}                Restart the node service"
  echo -e "  ${CYAN}logs${NC}                   View node service logs"
  echo -e "  ${CYAN}configure${NC}              Configure node settings"
  echo -e "  ${CYAN}wallet${NC}                 Manage wallet information"
  echo -e "  ${CYAN}pulse${NC}                  View real-time node metrics"
  echo
  
  echo -e "Global Options:"
  echo -e "  ${CYAN}--help${NC}, ${CYAN}-h${NC}             Show this help message"
  echo -e "  ${CYAN}--version${NC}, ${CYAN}-v${NC}          Show version information"
  echo -e "  ${CYAN}--debug${NC}                Enable debug output"
  echo -e "  ${CYAN}--quiet${NC}, ${CYAN}-q${NC}            Suppress non-essential output"
  echo
  
  echo -e "Installation Options:"
  echo -e "  ${CYAN}--install${NC}              Install pop command globally"
  echo -e "  ${CYAN}--uninstall${NC}            Remove pop command and all files"
  echo -e "  ${CYAN}--update-installation${NC}  Update an existing installation"
  echo
  
  echo -e "Examples:"
  echo -e "  ${CYAN}pop status${NC}             Show current node status"
  echo -e "  ${CYAN}pop start${NC}              Start the node service"
  echo -e "  ${CYAN}pop configure --wizard${NC} Run the configuration wizard"
  echo -e "  ${CYAN}pop logs --follow${NC}      View and follow service logs"
  echo
  
  echo -e "For more information, visit ${BLUE}https://pipe.network${NC}"
  
  return 0
}

# =====================
# Command Routing
# =====================

# Main function that parses and routes commands
main() {
  # Setup paths
  setup_paths
  
  # Parse global options
  local global_args=()
  local command=""
  local command_args=()
  
  # Parse command line
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --debug)
        DEBUG="true"
        global_args+=("$1")
        shift
        ;;
      --quiet|-q)
        QUIET="true"
        global_args+=("$1")
        shift
        ;;
      --help|-h)
        show_help
        return 0
        ;;
      --version|-v)
        show_version
        return 0
        ;;
      -*)
        global_args+=("$1")
        shift
        ;;
      *)
        command="$1"
        shift
        command_args=("$@")
        break
        ;;
    esac
  done
  
  # Handle empty command (default to status)
  if [[ -z "$command" ]]; then
    command="status"
  fi
  
  # Load modules based on the command
  case "$command" in
    status)
      # Load required modules
      load_module "core/service.sh"
      load_module "monitoring/metrics.sh"
      
      # Execute command
      show_status
      ;;
    start)
      load_module "core/service.sh"
      start_service "${command_args[@]}"
      ;;
    stop)
      load_module "core/service.sh"
      stop_service "${command_args[@]}"
      ;;
    restart)
      load_module "core/service.sh"
      restart_service "${command_args[@]}"
      ;;
    logs)
      load_module "core/service.sh"
      view_logs "${command_args[@]}"
      ;;
    configure)
      load_module "core/config.sh"
      configure_node "${command_args[@]}"
      ;;
    wallet)
      load_module "core/config.sh"
      manage_wallet "${command_args[@]}"
      ;;
    pulse)
      load_module "monitoring/metrics.sh"
      run_pulse_monitoring "${command_args[@]}"
      ;;
    dashboard)
      load_module "monitoring/metrics.sh"
      load_module "monitoring/dashboard.sh"
      run_dashboard "${command_args[@]}"
      ;;
    *)
      log_error "Unknown command: $command"
      echo -e "Run 'pop --help' for usage information."
      return 1
      ;;
  esac
  
  return $?
}
