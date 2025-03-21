#!/bin/bash
# Community Enhancement: Node Security Check
# This script provides security checks for Pipe Network nodes.

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

# Constants
VERSION="community-v0.0.1"
CONFIG_DIR="/opt/pipe-pop/config"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print header
print_header() {
  echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║        PIPE NETWORK SECURITY CHECK         ║${NC}"
  echo -e "${CYAN}║           Community Enhancement            ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
  echo
  echo -e "Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "Version: ${VERSION}"
  echo
}

# Check file permissions
check_file_permissions() {
  echo -e "${BLUE}Checking file permissions...${NC}"
  
  # Check config directory
  if [[ -d "$CONFIG_DIR" ]]; then
    local config_perm=$(stat -c "%a" "$CONFIG_DIR")
    if [[ "$config_perm" != "700" && "$config_perm" != "750" && "$config_perm" != "755" ]]; then
      echo -e "${YELLOW}Warning: Config directory has potentially insecure permissions: $config_perm${NC}"
      echo -e "  Recommended: chmod 700 $CONFIG_DIR"
    else
      echo -e "${GREEN}✓ Config directory permissions are secure${NC}"
    fi
  else
    echo -e "${RED}Error: Config directory not found: $CONFIG_DIR${NC}"
  fi
  
  # Check config file
  if [[ -f "$CONFIG_FILE" ]]; then
    local config_file_perm=$(stat -c "%a" "$CONFIG_FILE")
    if [[ "$config_file_perm" != "600" && "$config_file_perm" != "640" && "$config_file_perm" != "644" ]]; then
      echo -e "${YELLOW}Warning: Config file has potentially insecure permissions: $config_file_perm${NC}"
      echo -e "  Recommended: chmod 600 $CONFIG_FILE"
    else
      echo -e "${GREEN}✓ Config file permissions are secure${NC}"
    fi
  else
    echo -e "${RED}Error: Config file not found: $CONFIG_FILE${NC}"
  fi
  
  echo
}

# Check firewall status
check_firewall() {
  echo -e "${BLUE}Checking firewall status...${NC}"
  
  # Check if UFW is installed and active
  if command -v ufw &> /dev/null; then
    local ufw_status=$(ufw status | grep "Status" | awk '{print $2}')
    if [[ "$ufw_status" == "active" ]]; then
      echo -e "${GREEN}✓ Firewall (UFW) is active${NC}"
      
      # Check if the required port is open
      local node_port=$(jq -r '.network.port // 8080' "$CONFIG_FILE" 2>/dev/null)
      if ufw status | grep -q "$node_port"; then
        echo -e "${GREEN}✓ Port $node_port is allowed through the firewall${NC}"
      else
        echo -e "${YELLOW}Warning: Port $node_port is not explicitly allowed in the firewall rules${NC}"
        echo -e "  Recommended: ufw allow $node_port/tcp"
      fi
    else
      echo -e "${YELLOW}Warning: Firewall (UFW) is installed but not active${NC}"
      echo -e "  Recommended: ufw enable"
    fi
  else
    # Check if iptables has rules
    if iptables -L | grep -q "Chain"; then
      echo -e "${GREEN}✓ Firewall (iptables) has rules configured${NC}"
    else
      echo -e "${YELLOW}Warning: No active firewall detected (UFW not installed, iptables empty)${NC}"
      echo -e "  Recommended: Install and configure a firewall (e.g., 'apt install ufw')"
    fi
  fi
  
  echo
}

# Check open ports
check_open_ports() {
  echo -e "${BLUE}Checking open ports...${NC}"
  
  # Get the configured port
  local node_port=$(jq -r '.network.port // 8080' "$CONFIG_FILE" 2>/dev/null)
  
  # Check if netstat or ss is available
  if command -v ss &> /dev/null; then
    local open_ports=$(ss -tln | awk 'NR>1 {print $4}' | awk -F: '{print $NF}' | sort -n | uniq)
  elif command -v netstat &> /dev/null; then
    local open_ports=$(netstat -tln | awk 'NR>2 {print $4}' | awk -F: '{print $NF}' | sort -n | uniq)
  else
    echo -e "${YELLOW}Warning: Cannot check open ports (ss/netstat not installed)${NC}"
    return
  fi
  
  # Check if the required port is open
  if echo "$open_ports" | grep -q "^$node_port$"; then
    echo -e "${GREEN}✓ Required port $node_port is open${NC}"
  else
    echo -e "${RED}Error: Required port $node_port is not open${NC}"
    echo -e "  Check if the node is running and configured correctly"
  fi
  
  # Check for potentially suspicious ports
  local suspicious_ports=(21 22 23 25 3306 5432 27017 6379)
  local found_suspicious=false
  
  for port in $open_ports; do
    if [[ " ${suspicious_ports[@]} " =~ " ${port} " ]]; then
      found_suspicious=true
      echo -e "${YELLOW}Warning: Potentially sensitive port $port is open${NC}"
    fi
  done
  
  if [[ "$found_suspicious" == "false" ]]; then
    echo -e "${GREEN}✓ No suspicious ports detected${NC}"
  fi
  
  echo
}

# Check configuration security
check_config_security() {
  echo -e "${BLUE}Checking configuration security...${NC}"
  
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Config file not found: $CONFIG_FILE${NC}"
    return
  fi
  
  # Check wallet address is set
  local wallet=$(jq -r '.node.wallet_address // ""' "$CONFIG_FILE" 2>/dev/null)
  if [[ -z "$wallet" || "$wallet" == "null" ]]; then
    echo -e "${RED}Error: Wallet address is not configured${NC}"
  else
    echo -e "${GREEN}✓ Wallet address is configured${NC}"
  fi
  
  # Check if firewall is enabled in config
  local firewall_enabled=$(jq -r '.network.firewall_enabled // false' "$CONFIG_FILE" 2>/dev/null)
  if [[ "$firewall_enabled" == "true" ]]; then
    echo -e "${GREEN}✓ Firewall is enabled in configuration${NC}"
  else
    echo -e "${YELLOW}Warning: Firewall is not enabled in configuration${NC}"
  fi
  
  echo
}

# Check system updates
check_system_updates() {
  echo -e "${BLUE}Checking for system updates...${NC}"
  
  if command -v apt &> /dev/null; then
    # For Debian/Ubuntu
    echo -e "${YELLOW}Checking for available updates (this may take a moment)...${NC}"
    apt-get update -qq
    local updates=$(apt-get upgrade -s | grep -P '^\d+ upgraded' | cut -d" " -f1)
    
    if [[ "$updates" == "0" ]]; then
      echo -e "${GREEN}✓ System is up to date${NC}"
    else
      echo -e "${YELLOW}Warning: $updates package updates available${NC}"
      echo -e "  Recommended: apt-get upgrade"
    fi
  elif command -v dnf &> /dev/null; then
    # For Fedora/RHEL/CentOS
    echo -e "${YELLOW}Checking for available updates (this may take a moment)...${NC}"
    local updates=$(dnf check-update --quiet | grep -v "^$" | wc -l)
    
    if [[ "$updates" == "0" ]]; then
      echo -e "${GREEN}✓ System is up to date${NC}"
    else
      echo -e "${YELLOW}Warning: $updates package updates available${NC}"
      echo -e "  Recommended: dnf upgrade"
    fi
  else
    echo -e "${YELLOW}Warning: Cannot check for system updates (unsupported package manager)${NC}"
  fi
  
  echo
}

# Perform all security checks
security_check() {
  print_header
  check_file_permissions
  check_firewall
  check_open_ports
  check_config_security
  check_system_updates
  
  echo -e "${BLUE}Security check completed.${NC}"
  echo -e "${YELLOW}Note: This is a community-enhanced security check and may not cover all potential security issues.${NC}"
}

# Main function
main() {
  security_check
}

# If called directly, run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi 