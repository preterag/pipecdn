#!/bin/bash
# Community Enhancement: Core Node Management Functions
# This script provides core node management functionality for Pipe Network nodes.

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

# Constants
VERSION="community-v0.0.1"
CONFIG_DIR="/opt/pipe-pop/config"
CONFIG_FILE="$CONFIG_DIR/config.json"
DEFAULT_PORT=8080

# Status Functions
get_node_status() {
  # Check if node is running
  if pgrep -f "PipeNetwork/PoP" > /dev/null; then
    echo "running"
  else
    echo "stopped"
  fi
}

get_node_uptime() {
  # Get node uptime in seconds
  local pid=$(pgrep -f "PipeNetwork/PoP")
  if [[ -n "$pid" ]]; then
    ps -o etimes= -p "$pid"
  else
    echo "0"
  fi
}

get_wallet_address() {
  # Get wallet address from config file
  if [[ -f "$CONFIG_FILE" ]]; then
    grep -o '"wallet_address"[^,]*' "$CONFIG_FILE" | cut -d'"' -f4
  else
    echo "No wallet configured"
  fi
}

# Control Functions
start_node() {
  # Start the Pipe Network node
  echo "Starting Pipe Network node..."
  if systemctl is-active --quiet pipe-pop; then
    echo "Node is already running"
  else
    systemctl start pipe-pop
    echo "Node started"
  fi
}

stop_node() {
  # Stop the Pipe Network node
  echo "Stopping Pipe Network node..."
  systemctl stop pipe-pop
  echo "Node stopped"
}

restart_node() {
  # Restart the Pipe Network node
  echo "Restarting Pipe Network node..."
  systemctl restart pipe-pop
  echo "Node restarted"
}

# Configuration Functions
verify_config() {
  # Verify configuration file integrity
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file not found"
    return 1
  fi
  
  # Check for required fields
  if ! grep -q '"wallet_address"' "$CONFIG_FILE"; then
    echo "Wallet address not configured"
    return 1
  fi
  
  # Check port configuration
  if ! grep -q '"port"' "$CONFIG_FILE"; then
    echo "Port not configured, using default: $DEFAULT_PORT"
  fi
  
  return 0
}

# Main functionality will be implemented by the global pop command
# These functions provide the core node management capabilities

echo "Pipe Network Community Node Management v$VERSION loaded" 