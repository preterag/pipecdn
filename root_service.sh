#!/bin/bash
# Script to configure Pipe Network to run as root for ports 80 and 443

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  PIPE NETWORK ROOT SERVICE CONFIGURATION TOOL      ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

echo -e "${YELLOW}This script will configure pipe-pop to run as root${NC}"
echo -e "${YELLOW}This is an alternative approach when capabilities don't work${NC}"
echo

# Service path
SERVICE_FILE="/etc/systemd/system/pipe-pop.service"
ROOT_SERVICE_FILE="/home/karo/Workspace/pipe-pop/pipe-pop-root.service"

# Create a new service file that runs as root
echo -e "${YELLOW}Creating a root service file...${NC}"

cat > "$ROOT_SERVICE_FILE" << EOL
[Unit]
Description=Pipe Network PoP Node (Root)
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/pipe-pop/bin/pipe-pop --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --ram 8 --max-disk 500 --cache-dir /data --enable-80-443
Restart=always
RestartSec=10
WorkingDirectory=/opt/pipe-pop
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOL

echo -e "  ${GREEN}✓ Created root service file at $ROOT_SERVICE_FILE${NC}"

# Fix permissions of the data directory
echo -e "${YELLOW}Adjusting permissions for the data directory...${NC}"
if [ -d "/data" ]; then
  chown -R root:root /data
  echo -e "  ${GREEN}✓ Changed ownership of /data to root${NC}"
else
  echo -e "  ${YELLOW}Warning: /data directory not found, will be created by the service${NC}"
fi

# Make sure node_info.json is accessible by root
echo -e "${YELLOW}Making node_info.json accessible by root...${NC}"
if [ -f "/home/karo/node_info.json" ]; then
  cp /home/karo/node_info.json /opt/pipe-pop/
  chown root:root /opt/pipe-pop/node_info.json
  echo -e "  ${GREEN}✓ Copied node_info.json to /opt/pipe-pop/ with root ownership${NC}"
else
  echo -e "  ${YELLOW}Warning: node_info.json not found at /home/karo/node_info.json${NC}"
fi

# Install the new service
echo -e "${YELLOW}Installing the root service...${NC}"
cp "$ROOT_SERVICE_FILE" "$SERVICE_FILE"
echo -e "  ${GREEN}✓ Installed root service file${NC}"

# Reload systemd
echo -e "${YELLOW}Reloading systemd and restarting service...${NC}"
systemctl daemon-reload
systemctl restart pipe-pop.service
echo -e "  ${GREEN}✓ Service reloaded and restarted${NC}"

# Check service status
echo -e "${YELLOW}Checking service status...${NC}"
if systemctl is-active --quiet pipe-pop.service; then
  echo -e "  ${GREEN}✓ Service is running${NC}"
else
  echo -e "  ${RED}✗ Service is not running${NC}"
  echo -e "  ${YELLOW}Check logs with: journalctl -u pipe-pop.service -n 20${NC}"
fi

# Wait for service to start binding to ports
echo -e "${YELLOW}Waiting for ports to be available (10 seconds)...${NC}"
sleep 10

# Test port connectivity
echo -e "${YELLOW}Testing port connectivity...${NC}"
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
echo -e "${YELLOW}Service user:${NC} root (running with full privileges)"
echo -e "${YELLOW}Ports configured:${NC} 80, 443, 8003"
echo -e "${YELLOW}Service status:${NC} $(systemctl is-active pipe-pop.service)"
echo

echo -e "${GREEN}Root configuration completed. The Pipe Network node should now be able to use ports 80 and 443.${NC}"
echo -e "${YELLOW}If ports are still not working, check the logs with:${NC}"
echo -e "  sudo journalctl -u pipe-pop.service -n 50"
echo
echo -e "${YELLOW}Note: Running as root is less secure than using capabilities,${NC}"
echo -e "${YELLOW}but it's a reliable approach when capabilities don't work.${NC}" 