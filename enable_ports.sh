#!/bin/bash
# Script to enable ports 80 and 443 for Pipe Network node

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     PIPE NETWORK PORT 80/443 ENABLEMENT TOOL       ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root to configure privileged ports.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

# Service path
SERVICE_FILE="/etc/systemd/system/pipe-pop.service"
BINARY_PATH="/opt/pipe-pop/bin/pipe-pop"

# Check if pipe-pop service exists
if [ ! -f "$SERVICE_FILE" ]; then
  echo -e "${RED}Error: Service file not found at $SERVICE_FILE${NC}"
  exit 1
fi

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
  echo -e "${RED}Error: Pipe-pop binary not found at $BINARY_PATH${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 1: Setting capabilities on the binary...${NC}"
setcap 'cap_net_bind_service=+ep' "$BINARY_PATH"
if [ $? -eq 0 ]; then
  echo -e "  ${GREEN}✓ Successfully set capabilities on binary${NC}"
else
  echo -e "  ${RED}✗ Failed to set capabilities on binary${NC}"
  exit 1
fi

echo -e "${YELLOW}Step 2: Updating service file with required capabilities...${NC}"
# Check if capabilities are already set
if grep -q "AmbientCapabilities=CAP_NET_BIND_SERVICE" "$SERVICE_FILE" && \
   grep -q "CapabilityBoundingSet=CAP_NET_BIND_SERVICE" "$SERVICE_FILE"; then
  echo -e "  ${GREEN}✓ Capabilities already set in service file${NC}"
else
  # Create backup
  cp "$SERVICE_FILE" "${SERVICE_FILE}.bak"
  echo -e "  ${GREEN}✓ Created backup at ${SERVICE_FILE}.bak${NC}"
  
  # Update service file
  sed -i '/\[Service\]/a AmbientCapabilities=CAP_NET_BIND_SERVICE\nCapabilityBoundingSet=CAP_NET_BIND_SERVICE' "$SERVICE_FILE"
  echo -e "  ${GREEN}✓ Updated service file with necessary capabilities${NC}"
fi

echo -e "${YELLOW}Step 3: Opening firewall ports...${NC}"
if command -v ufw &> /dev/null; then
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 8003/tcp
  ufw reload
  echo -e "  ${GREEN}✓ Firewall ports opened and rules reloaded${NC}"
else
  echo -e "  ${YELLOW}UFW not installed. Please open ports manually:${NC}"
  echo -e "  - Port 80/tcp"
  echo -e "  - Port 443/tcp"
  echo -e "  - Port 8003/tcp"
fi

echo -e "${YELLOW}Step 4: Reloading and restarting service...${NC}"
systemctl daemon-reload
if [ $? -eq 0 ]; then
  echo -e "  ${GREEN}✓ Systemd configuration reloaded${NC}"
else
  echo -e "  ${RED}✗ Failed to reload systemd configuration${NC}"
  exit 1
fi

systemctl restart pipe-pop.service
if [ $? -eq 0 ]; then
  echo -e "  ${GREEN}✓ Service restarted successfully${NC}"
else
  echo -e "  ${RED}✗ Failed to restart service${NC}"
  exit 1
fi

# Check service status
echo -e "${YELLOW}Step 5: Verifying service status...${NC}"
if systemctl is-active --quiet pipe-pop.service; then
  echo -e "  ${GREEN}✓ Service is running${NC}"
else
  echo -e "  ${RED}✗ Service is not running${NC}"
  echo -e "  ${YELLOW}Checking latest logs:${NC}"
  journalctl -u pipe-pop.service --no-pager -n 10
  exit 1
fi

echo -e "${YELLOW}Step 6: Adding the '--enable-80-443' flag to service...${NC}"
# Check if the flag is already present
if grep -q -- "--enable-80-443" "$SERVICE_FILE"; then
  echo -e "  ${GREEN}✓ '--enable-80-443' flag already present${NC}"
else
  # Add the flag to the ExecStart line
  sed -i 's/ExecStart=.*pipe-pop/& --enable-80-443/' "$SERVICE_FILE"
  echo -e "  ${GREEN}✓ Added '--enable-80-443' flag to service${NC}"
  
  # Reload and restart again
  systemctl daemon-reload
  systemctl restart pipe-pop.service
  echo -e "  ${GREEN}✓ Service reloaded and restarted with new flag${NC}"
fi

echo -e "${YELLOW}Step 7: Testing port connectivity...${NC}"
sleep 5  # Give the service time to bind to ports

echo -e "  Testing port 8003..."
if curl -s -I -m 5 http://localhost:8003 &> /dev/null; then
  echo -e "  ${GREEN}✓ Port 8003 is responding${NC}"
else
  echo -e "  ${RED}✗ Port 8003 is not responding${NC}"
fi

echo -e "  Testing port 80..."
if curl -s -I -m 5 http://localhost:80 &> /dev/null; then
  echo -e "  ${GREEN}✓ Port 80 is responding${NC}"
else
  echo -e "  ${RED}✗ Port 80 is not responding${NC}"
fi

echo -e "  Testing port 443..."
if curl -s -I -m 5 https://localhost:443 &> /dev/null; then
  echo -e "  ${GREEN}✓ Port 443 is responding${NC}"
else
  echo -e "  ${RED}✗ Port 443 is not responding${NC}"
  echo -e "  ${YELLOW}Note: HTTPS may not respond until certificates are set up${NC}"
fi

echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}            CONFIGURATION SUMMARY                   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}Binary capabilities:${NC} cap_net_bind_service+ep"
echo -e "${YELLOW}Service capabilities:${NC} AmbientCapabilities=CAP_NET_BIND_SERVICE, CapabilityBoundingSet=CAP_NET_BIND_SERVICE"
echo -e "${YELLOW}Service status:${NC} $(systemctl is-active pipe-pop.service)"
echo -e "${YELLOW}Firewall ports:${NC} 80/tcp, 443/tcp, 8003/tcp"
echo

echo -e "${GREEN}Configuration completed. The Pipe Network node should now be able to use ports 80 and 443.${NC}"
echo -e "${YELLOW}If ports 80/443 are still not working, check the logs with:${NC}"
echo -e "  sudo journalctl -u pipe-pop.service -n 50"
echo
echo -e "${YELLOW}To verify port connectivity from outside, use an online port checking tool or:${NC}"
echo -e "  curl http://your-public-ip"
echo -e "  curl https://your-public-ip" 