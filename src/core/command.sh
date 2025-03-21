#!/bin/bash
# Command Parser for Pipe Network PoP Node Management Tools
# This module handles command-line argument parsing and routing

# ====================
# Core Command Parser
# ====================

# Version information
VERSION="v0.0.1"

# Color definitions for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Log levels
LOG_LEVEL_ERROR=0
LOG_LEVEL_WARN=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO

# =====================
# Logging Functions
# =====================

# Log an error message
log_error() {
  if [[ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_ERROR ]]; then
    echo -e "${RED}ERROR: $1${NC}" >&2
  fi
}

# Log a warning message
log_warn() {
  if [[ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_WARN ]]; then
    echo -e "${YELLOW}WARNING: $1${NC}" >&2
  fi
}

# Log an informational message
log_info() {
  if [[ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_INFO ]]; then
    echo -e "${BLUE}INFO: $1${NC}"
  fi
}

# Log a debug message
log_debug() {
  if [[ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]]; then
    echo -e "${PURPLE}DEBUG: $1${NC}"
  fi
}

# =====================
# Utility Functions
# =====================

# Print header for various outputs
print_header() {
  local title="$1"
  echo -e "${CYAN}=================================================${NC}"
  echo -e "${CYAN}     PIPE NETWORK NODE ${title}${NC}"
  echo -e "${CYAN}     PoP Node Management Tools v${VERSION}${NC}"
  echo -e "${CYAN}=================================================${NC}"
  echo
}

# Get value of named parameter
# Usage: get_param "--name" "$@"
get_param() {
  local param_name="$1"
  shift
  
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "$param_name" ]]; then
      if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then
        echo "$2"
        return 0
      else
        # Parameter exists but has no value
        echo "true"
        return 0
      fi
    elif [[ "$1" =~ ^$param_name=(.*)$ ]]; then
      # Handle --param=value syntax
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
    shift
  done
  
  # Parameter not found
  echo ""
  return 1
}

# Check if a parameter flag exists
# Usage: has_param "--flag" "$@"
has_param() {
  local param_name="$1"
  shift
  
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "$param_name" || "$1" =~ ^$param_name= ]]; then
      return 0
    fi
    shift
  done
  
  return 1
}

# Validate that required tools are available
validate_environment() {
  local required_tools=("jq" "systemctl" "curl" "basename" "dirname")
  local missing_tools=()
  
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      missing_tools+=("$tool")
    fi
  done
  
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    log_error "Missing required tools: ${missing_tools[*]}"
    echo -e "Please install the missing tools using your package manager."
    echo -e "For example: sudo apt-get install ${missing_tools[*]}"
    return 1
  fi
  
  return 0
}

# =====================
# Command Routing
# =====================

# Display help information
show_help() {
  local command="$1"
  
  if [[ -z "$command" ]]; then
    # Show general help
    print_header "HELP"
    echo -e "Usage: pop [command] [options]"
    echo
    echo -e "Available commands:"
    echo
    echo -e "  ${YELLOW}Monitoring Commands:${NC}"
    echo -e "    status                  Check if your node is running"
    echo -e "    pulse [options]         View detailed node metrics"
    echo -e "    dashboard [options]     Open performance dashboard"
    echo -e "    history [options]       View historical performance"
    echo
    echo -e "  ${YELLOW}Service Management Commands:${NC}"
    echo -e "    start                   Start your node"
    echo -e "    stop                    Stop your node"
    echo -e "    restart                 Restart your node"
    echo -e "    logs [options]          View service logs"
    echo
    echo -e "  ${YELLOW}Backup & Recovery Commands:${NC}"
    echo -e "    backup [options]        Create a data backup"
    echo -e "    restore [options]       Restore from a backup"
    echo -e "    list-backups            List all backups"
    echo
    echo -e "  ${YELLOW}Configuration Commands:${NC}"
    echo -e "    configure [options]     Adjust node settings"
    echo -e "    ports [options]         Configure port settings"
    echo -e "    wallet [options]        Manage wallet settings"
    echo
    echo -e "  ${YELLOW}Update & Maintenance Commands:${NC}"
    echo -e "    update [options]        Update the PoP Node Management Tools"
    echo -e "    refresh                 Refresh node registration and tokens"
    echo
    echo -e "  ${YELLOW}Fleet Management Commands:${NC}"
    echo -e "    fleet-add [options]     Add a node to your fleet"
    echo -e "    fleet-list [options]    List all nodes in your fleet"
    echo -e "    fleet-status [options]  Show status of all fleet nodes"
    echo -e "    fleet-deploy [options]  Deploy config or updates to all nodes"
    echo
    echo -e "  ${YELLOW}Help & Information:${NC}"
    echo -e "    help [command]          Show help for a specific command"
    echo -e "    version                 Show version information"
    echo
    echo -e "For detailed help on a specific command, use: pop help [command]"
    echo -e "For more information, see: https://github.com/user/pipe-pop"
  else
    # Show command-specific help
    case "$command" in
      status)
        print_header "HELP: STATUS"
        echo -e "Usage: pop status"
        echo
        echo -e "Description:"
        echo -e "  Check the status of your Pipe Network node."
        echo
        echo -e "Options:"
        echo -e "  None"
        ;;
      pulse)
        print_header "HELP: PULSE"
        echo -e "Usage: pop pulse [options]"
        echo
        echo -e "Description:"
        echo -e "  View real-time metrics of your node."
        echo
        echo -e "Options:"
        echo -e "  --compact             Display metrics in a compact format"
        echo -e "  --refresh=N           Set refresh interval in seconds (default: 5)"
        ;;
      # Add more command-specific help sections as needed
      *)
        log_error "Unknown command: $command"
        echo -e "Use 'pop help' to see available commands."
        return 1
        ;;
    esac
  fi
  
  return 0
}

# Display version information
show_version() {
  echo -e "Pipe Network PoP Node Management Tools v${VERSION}"
  echo -e "Community-maintained toolkit for Pipe Network nodes"
  echo
}

# Route commands to appropriate handlers
route_command() {
  local command="$1"
  shift
  
  log_debug "Routing command: $command"
  log_debug "Arguments: $*"
  
  case "$command" in
    # Monitoring Commands
    status)
      source "$SCRIPT_DIR/../src/monitoring/metrics.sh"
      show_status "$@"
      ;;
    pulse)
      source "$SCRIPT_DIR/../src/monitoring/metrics.sh"
      run_pulse_monitoring "$@"
      ;;
    dashboard)
      source "$SCRIPT_DIR/../src/monitoring/dashboard.sh"
      run_dashboard "$@"
      ;;
    history)
      source "$SCRIPT_DIR/../src/monitoring/history.sh"
      show_history "$@"
      ;;
      
    # Service Management Commands
    start)
      source "$SCRIPT_DIR/../src/core/service.sh"
      start_node "$@"
      ;;
    stop)
      source "$SCRIPT_DIR/../src/core/service.sh"
      stop_node "$@"
      ;;
    restart)
      source "$SCRIPT_DIR/../src/core/service.sh"
      restart_node "$@"
      ;;
    logs)
      source "$SCRIPT_DIR/../src/core/service.sh"
      view_logs "$@"
      ;;
      
    # Backup & Recovery Commands
    backup)
      source "$SCRIPT_DIR/../src/maintenance/backup.sh"
      create_backup "$@"
      ;;
    restore)
      source "$SCRIPT_DIR/../src/maintenance/backup.sh"
      restore_backup "$@"
      ;;
    list-backups)
      source "$SCRIPT_DIR/../src/maintenance/backup.sh"
      list_backups "$@"
      ;;
      
    # Configuration Commands
    configure)
      source "$SCRIPT_DIR/../src/core/config.sh"
      configure_node "$@"
      ;;
    ports)
      source "$SCRIPT_DIR/../src/core/network.sh"
      configure_ports "$@"
      ;;
    wallet)
      source "$SCRIPT_DIR/../src/core/config.sh"
      manage_wallet "$@"
      ;;
      
    # Update & Maintenance Commands
    update)
      source "$SCRIPT_DIR/../src/maintenance/updates.sh"
      update_software "$@"
      ;;
    refresh)
      source "$SCRIPT_DIR/../src/maintenance/updates.sh"
      refresh_token "$@"
      ;;
      
    # Fleet Management Commands
    fleet-add|fleet_add)
      source "$SCRIPT_DIR/../src/fleet/manager.sh"
      fleet_add_node "$@"
      ;;
    fleet-list|fleet_list)
      source "$SCRIPT_DIR/../src/fleet/manager.sh"
      fleet_list_nodes "$@"
      ;;
    fleet-status|fleet_status)
      source "$SCRIPT_DIR/../src/fleet/monitor.sh"
      fleet_status "$@"
      ;;
    fleet-deploy|fleet_deploy)
      source "$SCRIPT_DIR/../src/fleet/deploy.sh"
      fleet_deploy "$@"
      ;;
      
    # Help & Information Commands
    help)
      show_help "$1"
      ;;
    version)
      show_version
      ;;
      
    # Handle unknown commands
    *)
      if [[ -z "$command" ]]; then
        # No command specified, show help
        show_help
      else
        log_error "Unknown command: $command"
        echo -e "Use 'pop help' to see available commands."
        return 1
      fi
      ;;
  esac
  
  return $?
}

# Main function to parse global options and route commands
parse_command() {
  # Global options handling first
  local skip_count=0
  
  # Handle verbose/debug flag
  if has_param "--verbose" "$@" || has_param "-v" "$@"; then
    CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
    log_debug "Debug logging enabled"
    ((skip_count++))
  fi
  
  # Handle quiet flag
  if has_param "--quiet" "$@" || has_param "-q" "$@"; then
    CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
    ((skip_count++))
  fi
  
  # Skip processed global options
  shift $skip_count
  
  # Route to appropriate command handler
  if [[ $# -eq 0 ]]; then
    # No command provided, show help
    show_help
    return 0
  fi
  
  local command="$1"
  shift
  
  # Convert any --command format to just command format
  if [[ "$command" =~ ^--(.+)$ ]]; then
    command="${BASH_REMATCH[1]}"
  fi
  
  # Route the command
  route_command "$command" "$@"
  return $?
}
