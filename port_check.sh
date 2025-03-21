#!/bin/bash
# Script to test external port access for Pipe Network PoP

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     PIPE NETWORK PORT FORWARDING CHECK TOOL        ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Retrieve public IP
echo -e "${YELLOW}Retrieving your public IP address...${NC}"
PUBLIC_IP=$(curl -s 'https://api.ipify.org?format=json' | grep -o '"ip":"[^"]*' | cut -d'"' -f4)

if [ -z "$PUBLIC_IP" ]; then
  echo -e "${RED}Failed to retrieve public IP. Check your internet connection.${NC}"
  exit 1
fi

echo -e "  ${GREEN}✓ Public IP: $PUBLIC_IP${NC}"

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
  echo -e "${YELLOW}nmap is not installed. Installing...${NC}"
  sudo apt-get update && sudo apt-get install -y nmap
  echo -e "  ${GREEN}✓ nmap installed${NC}"
fi

# Get local IP
echo -e "${YELLOW}Getting local IP address...${NC}"
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo -e "  ${GREEN}✓ Local IP: $LOCAL_IP${NC}"

# Check local port binding
echo -e "${YELLOW}Checking if ports are bound locally...${NC}"
echo -e "  Checking port 80..."
if netstat -tuln | grep -q ":80 "; then
  echo -e "    ${GREEN}✓ Port 80 is bound locally${NC}"
else
  echo -e "    ${RED}✗ Port 80 is NOT bound locally${NC}"
fi

echo -e "  Checking port 443..."
if netstat -tuln | grep -q ":443 "; then
  echo -e "    ${GREEN}✓ Port 443 is bound locally${NC}"
else
  echo -e "    ${RED}✗ Port 443 is NOT bound locally${NC}"
fi

echo -e "  Checking port 8003..."
if netstat -tuln | grep -q ":8003 "; then
  echo -e "    ${GREEN}✓ Port 8003 is bound locally${NC}"
else
  echo -e "    ${RED}✗ Port 8003 is NOT bound locally${NC}"
fi

# Check external access using an online port checker
echo -e "${YELLOW}Checking external port access...${NC}"

check_external_port() {
  local port=$1
  echo -e "  Testing port $port using online service..."
  
  # Use HTTPbin to check if port is open from outside
  result=$(curl -s "https://api.open-ports.io/check-port?port=$port&ip=$PUBLIC_IP" | grep -o '"open":[^,]*' | cut -d':' -f2)
  
  if [ "$result" == "true" ]; then
    echo -e "    ${GREEN}✓ Port $port is accessible from the internet${NC}"
    return 0
  else
    echo -e "    ${RED}✗ Port $port is NOT accessible from the internet${NC}"
    return 1
  fi
}

check_external_port 80
PORT_80_STATUS=$?

check_external_port 443
PORT_443_STATUS=$?

check_external_port 8003
PORT_8003_STATUS=$?

# Local testing with nc
echo -e "${YELLOW}Testing local connectivity...${NC}"

check_local_port() {
  local port=$1
  echo -e "  Testing local connection to port $port..."
  timeout 5 nc -z localhost $port &>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "    ${GREEN}✓ Port $port is accessible locally${NC}"
    return 0
  else
    echo -e "    ${RED}✗ Port $port is NOT accessible locally${NC}"
    return 1
  fi
}

check_local_port 80
check_local_port 443
check_local_port 8003

# Summarize findings
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}                   SUMMARY                          ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}Local IP:${NC} $LOCAL_IP"
echo -e "${YELLOW}Public IP:${NC} $PUBLIC_IP"
echo

echo -e "${YELLOW}Port 80:${NC}"
if netstat -tuln | grep -q ":80 "; then
  echo -e "  - Local binding: ${GREEN}ACTIVE${NC}"
else
  echo -e "  - Local binding: ${RED}NOT ACTIVE${NC}"
fi
if [ $PORT_80_STATUS -eq 0 ]; then
  echo -e "  - External access: ${GREEN}ACCESSIBLE${NC}"
else
  echo -e "  - External access: ${RED}NOT ACCESSIBLE${NC}"
fi

echo -e "${YELLOW}Port 443:${NC}"
if netstat -tuln | grep -q ":443 "; then
  echo -e "  - Local binding: ${GREEN}ACTIVE${NC}"
else
  echo -e "  - Local binding: ${RED}NOT ACTIVE${NC}"
fi
if [ $PORT_443_STATUS -eq 0 ]; then
  echo -e "  - External access: ${GREEN}ACCESSIBLE${NC}"
else
  echo -e "  - External access: ${RED}NOT ACCESSIBLE${NC}"
fi

echo -e "${YELLOW}Port 8003:${NC}"
if netstat -tuln | grep -q ":8003 "; then
  echo -e "  - Local binding: ${GREEN}ACTIVE${NC}"
else
  echo -e "  - Local binding: ${RED}NOT ACTIVE${NC}"
fi
if [ $PORT_8003_STATUS -eq 0 ]; then
  echo -e "  - External access: ${GREEN}ACCESSIBLE${NC}"
else
  echo -e "  - External access: ${RED}NOT ACCESSIBLE${NC}"
fi

# Recommendations
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}             RECOMMENDATIONS                        ${NC}"
echo -e "${CYAN}====================================================${NC}"

if [ $PORT_80_STATUS -ne 0 ] || [ $PORT_443_STATUS -ne 0 ] || [ $PORT_8003_STATUS -ne 0 ]; then
  echo -e "${YELLOW}Port forwarding configuration needed:${NC}"
  echo -e "1. Access your router's admin panel (usually http://192.168.1.1)"
  echo -e "2. Find the port forwarding section (may be called 'Virtual Server', 'NAT', or 'Port Forwarding')"
  echo -e "3. Add the following rules:"
  
  if [ $PORT_80_STATUS -ne 0 ]; then
    echo -e "   - ${CYAN}Forward external port 80 to internal IP $LOCAL_IP port 80 (TCP)${NC}"
  fi
  
  if [ $PORT_443_STATUS -ne 0 ]; then
    echo -e "   - ${CYAN}Forward external port 443 to internal IP $LOCAL_IP port 443 (TCP)${NC}"
  fi
  
  if [ $PORT_8003_STATUS -ne 0 ]; then
    echo -e "   - ${CYAN}Forward external port 8003 to internal IP $LOCAL_IP port 8003 (TCP)${NC}"
  fi
  
  echo -e "4. Save settings and restart your router"
  echo -e "5. Run this script again to verify the changes"
else
  echo -e "${GREEN}All ports are correctly forwarded!${NC}"
  echo -e "Your Pipe Network node should be able to communicate with the network correctly."
fi

echo
echo -e "${YELLOW}Note:${NC} Some ISPs block ports 80 and 443 for residential connections."
echo -e "If you cannot get these ports working, contact your ISP to verify if they are blocked." 