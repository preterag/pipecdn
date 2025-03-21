#!/bin/bash
# Script to properly configure the Pipe Network service for ports 80 and 443

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}  PIPE NETWORK SERVICE CONFIGURATION TOOL            ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

# Define paths
SERVICE_FILE="/etc/systemd/system/pipe-pop.service"
NODE_INFO="/home/karo/node_info.json"
PIPE_POP_BIN="/opt/pipe-pop/bin/pipe-pop"
PIPE_POP_DIR="/opt/pipe-pop"

# Check if node_info.json exists
echo -e "${YELLOW}Checking for node_info.json...${NC}"
if [ ! -f "$NODE_INFO" ]; then
  echo -e "${RED}Error: node_info.json not found at $NODE_INFO${NC}"
  echo -e "Please create this file with the proper node ID before continuing."
  exit 1
else
  echo -e "  ${GREEN}✓ node_info.json found${NC}"
fi

# Copy node_info.json to necessary locations
echo -e "${YELLOW}Copying node_info.json to necessary locations...${NC}"
cp "$NODE_INFO" "$PIPE_POP_DIR/node_info.json"
cp "$NODE_INFO" "$PIPE_POP_DIR/bin/node_info.json"
chmod 644 "$PIPE_POP_DIR/node_info.json" "$PIPE_POP_DIR/bin/node_info.json"
echo -e "  ${GREEN}✓ Copied node_info.json to required locations${NC}"

# Set capabilities on the binary
echo -e "${YELLOW}Setting capabilities on the binary...${NC}"
setcap 'cap_net_bind_service=+ep' "$PIPE_POP_BIN"
echo -e "  ${GREEN}✓ Set capabilities on binary${NC}"

# Create the service file
echo -e "${YELLOW}Creating service file...${NC}"
cat > "$SERVICE_FILE" << EOL
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
Type=simple
User=karo
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
ExecStart=$PIPE_POP_BIN --ram 8 --max-disk 500 --cache-dir /data --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --enable-80-443
Restart=always
RestartSec=10
WorkingDirectory=$PIPE_POP_DIR
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOL
echo -e "  ${GREEN}✓ Created service file${NC}"

# Reload systemd
echo -e "${YELLOW}Reloading systemd and restarting service...${NC}"
systemctl daemon-reload
systemctl restart pipe-pop.service
echo -e "  ${GREEN}✓ Service reloaded and restarted${NC}"

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 8003/tcp
  ufw reload
  echo -e "  ${GREEN}✓ Firewall configured${NC}"
else
  echo -e "  ${YELLOW}⚠️ UFW not found. Please ensure ports 80, 443, and 8003 are open in your firewall.${NC}"
fi

# Check service status
echo -e "${YELLOW}Checking service status...${NC}"
sleep 5
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
echo -e "${CYAN}            TROUBLESHOOTING TIPS                     ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "If ports are not responding, try the following:"
echo
echo -e "1. ${YELLOW}Check the service logs:${NC}"
echo -e "   sudo journalctl -u pipe-pop.service -n 50"
echo
echo -e "2. ${YELLOW}Try running with root (alternative approach):${NC}"
echo -e "   sudo ./root_service.sh"
echo
echo -e "3. ${YELLOW}Check if the binary accepts the --enable-80-443 flag:${NC}"
echo -e "   strings $PIPE_POP_BIN | grep enable-80-443"
echo
echo -e "4. ${YELLOW}Verify port conflicts:${NC}"
echo -e "   sudo lsof -i :80 -i :443 -i :8003"
echo
echo -e "5. ${YELLOW}Test the binary manually:${NC}"
echo -e "   cd $PIPE_POP_DIR && sudo ./bin/pipe-pop --ram 8 --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --enable-80-443"
echo
echo -e "${GREEN}Configuration completed.${NC}" 