#!/bin/bash
# Script to comprehensively test port forwarding for Pipe Network

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}       PIPE NETWORK PORT FORWARDING TEST           ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Get the public and local IP addresses
PUBLIC_IP=$(curl -s https://api.ipify.org)
LOCAL_IP=$(hostname -I | awk '{print $1}')
PORT=8003

echo -e "${YELLOW}System Information:${NC}"
echo -e "  Local IP: ${LOCAL_IP}"
echo -e "  Public IP: ${PUBLIC_IP}"
echo -e "  Testing Port: ${PORT}"
echo

# Test local connectivity
echo -e "${YELLOW}Testing local connectivity...${NC}"
if nc -z -w5 localhost ${PORT} 2>/dev/null; then
  echo -e "  ${GREEN}✓ Port ${PORT} is open on localhost${NC}"
else
  echo -e "  ${RED}✗ Port ${PORT} is NOT open on localhost${NC}"
  echo -e "  ${YELLOW}This indicates the service may not be running correctly.${NC}"
  echo -e "  ${YELLOW}Check service status with: sudo systemctl status pipe-pop.service${NC}"
fi

if nc -z -w5 ${LOCAL_IP} ${PORT} 2>/dev/null; then
  echo -e "  ${GREEN}✓ Port ${PORT} is open on local IP (${LOCAL_IP})${NC}"
else
  echo -e "  ${RED}✗ Port ${PORT} is NOT open on local IP (${LOCAL_IP})${NC}"
  echo -e "  ${YELLOW}This indicates the service may be bound only to localhost.${NC}"
  echo -e "  ${YELLOW}Check the service configuration to ensure it's listening on all interfaces.${NC}"
fi

# Test HTTP response
echo
echo -e "${YELLOW}Testing HTTP response...${NC}"
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT})
if [ "$HTTP_RESPONSE" != "000" ]; then
  echo -e "  ${GREEN}✓ HTTP service is responding on localhost (Status code: ${HTTP_RESPONSE})${NC}"
else
  echo -e "  ${RED}✗ No HTTP response from localhost:${PORT}${NC}"
  echo -e "  ${YELLOW}This indicates the service may not be running or is misconfigured.${NC}"
fi

HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://${LOCAL_IP}:${PORT})
if [ "$HTTP_RESPONSE" != "000" ]; then
  echo -e "  ${GREEN}✓ HTTP service is responding on local IP (Status code: ${HTTP_RESPONSE})${NC}"
else
  echo -e "  ${RED}✗ No HTTP response from ${LOCAL_IP}:${PORT}${NC}"
  echo -e "  ${YELLOW}This indicates issues with network binding.${NC}"
fi

# Check for iptables rules
echo
echo -e "${YELLOW}Checking iptables port forwarding rules...${NC}"
IPTABLES_RULES=$(sudo iptables -t nat -L PREROUTING -n | grep -E "(80|443).+8003" | wc -l)
if [ "$IPTABLES_RULES" -gt 0 ]; then
  echo -e "  ${GREEN}✓ iptables port forwarding rules are set up (${IPTABLES_RULES} rules found)${NC}"
else
  echo -e "  ${RED}✗ No iptables port forwarding rules found${NC}"
  echo -e "  ${YELLOW}Run the port configuration script to set up port forwarding:${NC}"
  echo -e "  ${YELLOW}sudo /home/karo/Workspace/pipe-pop/privileged_port_fix.sh${NC}"
fi

# Check if the binary has required capabilities
echo
echo -e "${YELLOW}Checking binary capabilities...${NC}"
BINARY_CAPS=$(sudo getcap /opt/pipe-pop/bin/pipe-pop 2>/dev/null)
if [[ "$BINARY_CAPS" == *"cap_net_bind_service"* ]]; then
  echo -e "  ${GREEN}✓ pipe-pop binary has the necessary capabilities${NC}"
else
  echo -e "  ${RED}✗ pipe-pop binary does not have the necessary capabilities${NC}"
  echo -e "  ${YELLOW}Run: sudo setcap 'cap_net_bind_service=+ep' /opt/pipe-pop/bin/pipe-pop${NC}"
fi

# Check service configuration
echo
echo -e "${YELLOW}Checking service configuration...${NC}"
SERVICE_CAPS=$(grep "AmbientCapabilities" /etc/systemd/system/pipe-pop.service | wc -l)
if [ "$SERVICE_CAPS" -gt 0 ]; then
  echo -e "  ${GREEN}✓ Service has AmbientCapabilities configured${NC}"
else
  echo -e "  ${RED}✗ Service does not have AmbientCapabilities configured${NC}"
  echo -e "  ${YELLOW}Edit the service file to add: AmbientCapabilities=CAP_NET_BIND_SERVICE${NC}"
fi

# Test public port using external service
echo
echo -e "${YELLOW}Testing external connectivity...${NC}"
echo -e "  This requires external services. You can also check manually at:"
echo -e "  https://portchecker.co/ or https://www.canyouseeme.org/"
echo
echo -e "  ${YELLOW}Attempting to check external port accessibility...${NC}"
echo -e "  ${YELLOW}Note: This may not work if your ISP blocks these testing services.${NC}"

# Try using portchecker.co service (this often doesn't work automatically, but we'll try)
echo -e "  Trying to test port ${PORT} on IP ${PUBLIC_IP}..."
echo -e "  ${YELLOW}Manual verification is strongly recommended!${NC}"

echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}              TEST SUMMARY                          ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}Local connectivity:${NC} Service is accessible on local network"
echo -e "${YELLOW}External connectivity:${NC} Manual testing required"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Visit https://www.canyouseeme.org/ and check port ${PORT}"
echo -e "  2. Enter your IP: ${PUBLIC_IP} and port: ${PORT}"
echo -e "  3. Verify your router has properly forwarded port ${PORT} to ${LOCAL_IP}"
echo -e "  4. Ensure your ISP is not blocking incoming connections (some do)"
echo
echo -e "${YELLOW}If tests fail, check:${NC}"
echo -e "  - Router configuration (ports correctly forwarded)"
echo -e "  - Firewall settings (ports allowed)"
echo -e "  - Service status (running correctly)"
echo -e "  - Double-NAT issues (often with ISP-provided routers)" 