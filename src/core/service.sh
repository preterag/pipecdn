#!/bin/bash
# Service Management Module for Pipe Network PoP Node Management Tools
# This module handles starting, stopping, restarting, and viewing logs for the node service.

# Service name
SERVICE_NAME="pipe-pop"

# =====================
# Service Control
# =====================

# Start the node service
start_node() {
  print_header "SERVICE START"
  
  # Check if service is already running
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    log_info "Node is already running."
    return 0
  fi
  
  # Check if service exists
  if ! systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    log_error "Service not installed. Please run the installation script first."
    echo -e "To install: sudo ./INSTALL"
    return 1
  fi
  
  echo -e "Starting Pipe Network node..."
  sudo systemctl start "$SERVICE_NAME"
  
  # Check if service started successfully
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}Node started successfully.${NC}"
    echo
    # Show brief status
    show_brief_status
  else
    log_error "Failed to start node service."
    echo -e "Check logs for details: pop logs"
    return 1
  fi
  
  return 0
}

# Stop the node service
stop_node() {
  print_header "SERVICE STOP"
  
  # Check if service is running
  if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    log_info "Node is not running."
    return 0
  fi
  
  echo -e "Stopping Pipe Network node..."
  sudo systemctl stop "$SERVICE_NAME"
  
  # Check if service stopped successfully
  if ! systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}Node stopped successfully.${NC}"
  else
    log_error "Failed to stop node service."
    return 1
  fi
  
  return 0
}

# Restart the node service
restart_node() {
  print_header "SERVICE RESTART"
  
  # Check if service exists
  if ! systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    log_error "Service not installed. Please run the installation script first."
    echo -e "To install: sudo ./INSTALL"
    return 1
  fi
  
  echo -e "Restarting Pipe Network node..."
  sudo systemctl restart "$SERVICE_NAME"
  
  # Check if service restarted successfully
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}Node restarted successfully.${NC}"
    echo
    # Show brief status
    show_brief_status
  else
    log_error "Failed to restart node service."
    echo -e "Check logs for details: pop logs"
    return 1
  fi
  
  return 0
}

# View service logs
view_logs() {
  local lines="50"
  local follow=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lines=*)
        lines="${1#*=}"
        shift
        ;;
      --lines)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
          lines="$2"
          shift 2
        else
          log_error "Invalid or missing value for --lines"
          return 1
        fi
        ;;
      --follow|-f)
        follow=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  
  print_header "SERVICE LOGS"
  
  # Check if service exists
  if ! systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    log_error "Service not installed. No logs available."
    return 1
  fi
  
  if [[ "$follow" == true ]]; then
    echo -e "Showing logs with follow mode. Press Ctrl+C to exit."
    echo
    sudo journalctl -u "$SERVICE_NAME" -f
  else
    echo -e "Showing last $lines lines of logs."
    echo
    sudo journalctl -u "$SERVICE_NAME" -n "$lines"
  fi
  
  return 0
}

# =====================
# Helper Functions
# =====================

# Show brief status (internal helper)
show_brief_status() {
  echo -e "Current node status:"
  
  # Get node status
  if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "Status: ${GREEN}Running${NC}"
    
    # Get additional status information if node is running
    local uptime_info=$(systemctl show "$SERVICE_NAME" -p ActiveEnterTimestamp)
    local uptime_timestamp=${uptime_info#*=}
    
    if [[ -n "$uptime_timestamp" ]]; then
      local now=$(date +%s)
      local start_time=$(date -d "$uptime_timestamp" +%s 2>/dev/null)
      
      if [[ -n "$start_time" ]]; then
        local uptime=$((now - start_time))
        local uptime_formatted=$(printf '%dd %dh %dm %ds' $((uptime/86400)) $((uptime%86400/3600)) $((uptime%3600/60)) $((uptime%60)))
        echo -e "Uptime: $uptime_formatted"
      fi
    fi
  else
    echo -e "Status: ${RED}Not Running${NC}"
  fi
  
  echo
}

# Get service installation status
is_service_installed() {
  if systemctl list-unit-files | grep -q "$SERVICE_NAME.service"; then
    return 0
  else
    return 1
  fi
}
