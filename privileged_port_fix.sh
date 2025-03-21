#!/bin/bash
# Script to properly setup Pipe Network with privileged ports and port forwarding

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}       PIPE NETWORK PORT CONFIGURATION TOOL         ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root to bind to privileged ports.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

# Configure port forwarding using iptables
setup_port_forwarding() {
  echo -e "${YELLOW}Setting up port forwarding rules...${NC}"
  
  # Check if iptables is installed
  if ! command -v iptables &> /dev/null; then
    echo -e "${RED}iptables not found. Please install it first:${NC}"
    echo -e "${YELLOW}sudo apt install iptables${NC}"
    exit 1
  fi
  
  # Add port forwarding rules
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8003
  iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8003
  
  # Save iptables rules to make them persistent
  if command -v iptables-save &> /dev/null; then
    iptables-save > /etc/iptables/rules.v4 2>/dev/null || {
      mkdir -p /etc/iptables
      iptables-save > /etc/iptables/rules.v4
    }
    
    echo -e "${GREEN}Port forwarding rules saved to /etc/iptables/rules.v4${NC}"
    echo -e "To make these rules persistent, you might need to install iptables-persistent:"
    echo -e "${YELLOW}sudo apt install iptables-persistent${NC}"
  else
    echo -e "${YELLOW}Warning: Could not save iptables rules. Install iptables-persistent to make rules permanent.${NC}"
  fi
  
  echo -e "${GREEN}Successfully configured port forwarding:${NC}"
  echo -e "  - External port 80 -> Internal port 8003"
  echo -e "  - External port 443 -> Internal port 8003"
}

# Grant required capabilities to the binary
grant_capabilities() {
  echo -e "${YELLOW}Granting privileged port capabilities to the Pipe Network binary...${NC}"
  
  if ! command -v setcap &> /dev/null; then
    echo -e "${RED}setcap command not found. Please install it first:${NC}"
    echo -e "${YELLOW}sudo apt install libcap2-bin${NC}"
    exit 1
  }
  
  # Grant capabilities to the binary
  BINARY_PATH="/opt/pipe-pop/bin/pipe-pop"
  
  if [ -f "$BINARY_PATH" ]; then
    setcap 'cap_net_bind_service=+ep' "$BINARY_PATH"
    echo -e "${GREEN}Successfully granted network binding capability to $BINARY_PATH${NC}"
  else
    echo -e "${RED}Binary not found at $BINARY_PATH${NC}"
    echo -e "${YELLOW}Please specify the correct path to the pipe-pop binary${NC}"
    exit 1
  fi
}

# Update service to use proper configuration
update_service() {
  echo -e "${YELLOW}Updating systemd service with proper configuration...${NC}"
  
  # Modify the service file
  SERVICE_FILE="/etc/systemd/system/pipe-pop.service"
  
  if [ -f "$SERVICE_FILE" ]; then
    # Create a backup of the original file
    cp "$SERVICE_FILE" "$SERVICE_FILE.bak"
    echo -e "${GREEN}Created backup of service file at $SERVICE_FILE.bak${NC}"
    
    # Add the capability to the service
    if ! grep -q "AmbientCapabilities=CAP_NET_BIND_SERVICE" "$SERVICE_FILE"; then
      sed -i '/\[Service\]/a AmbientCapabilities=CAP_NET_BIND_SERVICE' "$SERVICE_FILE"
      echo -e "${GREEN}Added network binding capability to the service${NC}"
    fi
    
    # Reload systemd configuration
    systemctl daemon-reload
    echo -e "${GREEN}Systemd configuration reloaded${NC}"
    
    # Restart the service
    systemctl restart pipe-pop.service
    echo -e "${GREEN}Service restarted with new configuration${NC}"
  else
    echo -e "${RED}Service file not found at $SERVICE_FILE${NC}"
    echo -e "${YELLOW}Please ensure the pipe-pop service is properly installed${NC}"
    exit 1
  fi
}

# Main execution
echo -e "${YELLOW}This script will configure your Pipe Network node to use ports 80/443${NC}"
echo -e "${YELLOW}It will:${NC}"
echo -e "  1. Set up port forwarding from ports 80/443 to 8003"
echo -e "  2. Grant necessary capabilities to the pipe-pop binary"
echo -e "  3. Update the systemd service configuration"
echo

# Ask for confirmation
read -p "Do you want to proceed? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}Setup cancelled.${NC}"
  exit 1
fi

# Run the configuration steps
setup_port_forwarding
grant_capabilities
update_service

echo
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}       PIPE NETWORK CONFIGURATION COMPLETE         ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${YELLOW}Your node should now be able to use ports 80/443.${NC}"
echo -e "${YELLOW}Check the status with: sudo systemctl status pipe-pop${NC}"
echo 