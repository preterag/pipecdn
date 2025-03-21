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
  echo -e "[${YELLOW}WARNING${NC}] $1"
}

# Log error message
log_error() {
  echo -e "[${RED}ERROR${NC}] $1"
}

# Log debug message
log_debug() {
  if [[ "$DEBUG" == "true" ]]; then
    echo -e "[${BLUE}DEBUG${NC}] $1"
  fi
}

# Print a header block
print_header() {
  local title="$1"
  local width=${#title}
  local padding=$((width + 6))
  
  echo
  printf "%${padding}s\n" | tr " " "="
  echo -e "   ${CYAN}${title}${NC}"
  printf "%${padding}s\n" | tr " " "="
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

# Load a module
load_module() {
  local module="$1"
  local module_path="${SRC_DIR}/${module}"
  
  if [[ -f "$module_path" ]]; then
    source "$module_path"
    return 0
  else
    log_error "Module not found: $module_path"
    return 1
  fi
}

# =====================
# Command Functions
# =====================

# Show help text
show_help() {
  echo -e "Pipe Network PoP Node Management Tools"
  echo -e "Usage: pop [--options] [--command] [arguments]"
  echo
  echo -e "Commands:"
  echo -e "  ${CYAN}--status${NC}                Show node status information"
  echo -e "  ${CYAN}--start${NC}                 Start node service"
  echo -e "  ${CYAN}--stop${NC}                  Stop node service"
  echo -e "  ${CYAN}--restart${NC}               Restart node service"
  echo -e "  ${CYAN}--logs${NC} [--follow]       View service logs"
  echo -e "  ${CYAN}--configure${NC} [--wizard]  Configure node settings"
  echo -e "  ${CYAN}--wallet${NC} [--import]     Manage wallet settings"
  echo -e "  ${CYAN}--pulse${NC}                 Check node performance"
  echo -e "  ${CYAN}--dashboard${NC}             Interactive status dashboard"
  echo -e "  ${CYAN}--history${NC}               View historical metrics"
  echo -e "  ${CYAN}--alerts${NC}                Manage alert configurations"
  echo -e "  ${CYAN}--auth${NC}                  Authenticate sudo access once"
  echo
  echo -e "Global Options:"
  echo -e "  ${CYAN}--help, -h${NC}              Show this help message"
  echo -e "  ${CYAN}--version, -v${NC}           Show version information"
  echo -e "  ${CYAN}--debug${NC}                 Enable debug logging"
  echo -e "  ${CYAN}--quiet, -q${NC}             Minimize output"
  echo
  echo -e "Installation Options:"
  echo -e "  ${CYAN}--install${NC} [--user]      Install globally or user-only"
  echo -e "  ${CYAN}--install --dir=PATH${NC}    Custom installation location"
  echo -e "  ${CYAN}--uninstall${NC}             Remove installation"
  echo
  echo -e "Examples:"
  echo -e "  pop --status                # Show node status"
  echo -e "  pop --start                 # Start the node service"
  echo -e "  pop --configure --wizard    # Run configuration wizard"
  echo -e "  pop --logs --follow         # View and follow service logs"
  echo -e "  pop --install --user        # Install for current user only"
  echo
  echo -e "For more information, visit: https://pipenetwork.io/pop-node"
}

# Show version information
show_version() {
  echo -e "Pipe Network PoP Node Management Tools ${CYAN}${VERSION}${NC}"
  echo -e "For more information, visit: https://pipenetwork.io/pop-node"
}

# =====================
# Command Parsing
# =====================

# Convert traditional command to flag format
standardize_command() {
  local cmd="$1"
  
  # If it already starts with --, return as is
  if [[ "$cmd" == --* ]]; then
    echo "$cmd"
    return 0
  fi
  
  # Otherwise add -- prefix
  echo "--$cmd"
}

# Load the privilege helper module
ensure_privilege_helper() {
  if [[ "$(type -t request_sudo_once)" != "function" ]]; then
    load_module "core/privilege.sh"
  fi
}

# Parse and execute command line arguments
parse_command_line() {
  # Handle empty invocation
  if [[ $# -eq 0 ]]; then
    show_help
    return 0
  fi
  
  # Load the privilege helper if needed
  ensure_privilege_helper
  
  local command=""
  local global_args=()
  local command_args=()
  
  # First pass: Look for global options
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
      --install)
        load_module "core/install.sh"
        install_global_command "${@:2}"
        return $?
        ;;
      --uninstall)
        load_module "core/install.sh"
        uninstall_global_command "${@:2}"
        return $?
        ;;
      --auth)
        ensure_privilege_helper
        auth_sudo
        return $?
        ;;
      -*)
        # If this is a command (starts with --), capture it
        if [[ "$1" == --* && "$1" != "--debug" && "$1" != "--quiet" && "$1" != "--help" && "$1" != "--version" ]]; then
          command="${1:2}" # Remove -- prefix
          shift
          command_args=("$@")
          break
        else
          # Otherwise it's a global arg
          global_args+=("$1")
          shift
        fi
        ;;
      *)
        # For backward compatibility, treat first non-flag arg as a command
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
  
  # Load modules and execute command
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
      load_module "core/wallet.sh"
      manage_wallet "${command_args[@]}"
      ;;
    pulse)
      load_module "core/service.sh"
      load_module "core/monitoring/pulse.sh"
      check_pulse "${command_args[@]}"
      ;;
    dashboard)
      load_module "monitoring/metrics.sh"
      load_module "monitoring/dashboard.sh"
      show_dashboard "${command_args[@]}"
      ;;
    history)
      load_module "monitoring/metrics.sh"
      load_module "monitoring/history.sh"
      show_history "${command_args[@]}"
      ;;
    alerts)
      load_module "monitoring/metrics.sh"
      load_module "monitoring/alerts.sh"
      run_alerts "${command_args[@]}"
      ;;
    *)
      log_error "Unknown command: $command"
      echo -e "Run 'pop --help' for usage information."
      return 1
      ;;
  esac
  
  return $?
}

# =====================
# Main Command Execution
# =====================

# Execute main command
run_command() {
  local exit_code=0
  
  # Parse command line arguments
  parse_command_line "$@"
  exit_code=$?
  
  return $exit_code
}
