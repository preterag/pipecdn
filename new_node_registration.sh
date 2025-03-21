#!/bin/bash
# Script to completely reset a Pipe Network node and get a new node ID

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}    PIPE NETWORK NODE RESET & REGISTRATION TOOL     ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

REFERRAL_CODE="6ee148015d530fb0"
NODE_INFO_FILE="/home/karo/node_info.json"
NODE_INFO_BACKUP="/home/karo/node_info_backup_$(date +%Y%m%d_%H%M%S).json"
DATA_DIR="/data"

# Backup the current node_info.json if it exists
if [ -f "$NODE_INFO_FILE" ]; then
  echo -e "${YELLOW}Backing up current node_info.json...${NC}"
  cp "$NODE_INFO_FILE" "$NODE_INFO_BACKUP"
  echo -e "  ${GREEN}✓ Backup created at $NODE_INFO_BACKUP${NC}"
fi

# Stop the service
echo -e "${YELLOW}Stopping the pipe-pop service...${NC}"
systemctl stop pipe-pop.service
echo -e "  ${GREEN}✓ Service stopped${NC}"

# Wait for the service to fully stop
echo -e "${YELLOW}Waiting for service to completely stop...${NC}"
sleep 5

# Clear the cache directory
echo -e "${YELLOW}Clearing the cache directory...${NC}"
if [ -d "$DATA_DIR" ]; then
  rm -rf "$DATA_DIR"/*
  echo -e "  ${GREEN}✓ Cache directory cleared${NC}"
else
  echo -e "  ${YELLOW}⚠ Cache directory not found at $DATA_DIR${NC}"
  mkdir -p "$DATA_DIR"
  echo -e "  ${GREEN}✓ Created new cache directory${NC}"
fi

# Delete old node_info.json files
echo -e "${YELLOW}Deleting old node_info.json files...${NC}"
rm -f "$NODE_INFO_FILE" /opt/pipe-pop/node_info.json /opt/pipe-pop/bin/node_info.json
echo -e "  ${GREEN}✓ Old node_info.json files removed${NC}"

# Generate a new node ID
echo -e "${YELLOW}Generating a new node ID...${NC}"
NEW_NODE_ID=$(uuidgen)
echo -e "  ${GREEN}✓ New node ID generated: $NEW_NODE_ID${NC}"

# Create a new node_info.json file with the new node ID
echo -e "${YELLOW}Creating new node_info.json...${NC}"
cat > "$NODE_INFO_FILE" << EOL
{
  "node_id": "$NEW_NODE_ID",
  "registered": false,
  "token": "",
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOL
chmod 644 "$NODE_INFO_FILE"
echo -e "  ${GREEN}✓ New node_info.json created${NC}"

# Copy node_info.json to required locations
echo -e "${YELLOW}Copying node_info.json to all required locations...${NC}"
cp "$NODE_INFO_FILE" /opt/pipe-pop/node_info.json
cp "$NODE_INFO_FILE" /opt/pipe-pop/bin/node_info.json
chmod 644 /opt/pipe-pop/node_info.json /opt/pipe-pop/bin/node_info.json
echo -e "  ${GREEN}✓ node_info.json copied to all locations${NC}"

# Register with the referral code
echo -e "${YELLOW}Registering node with referral code: $REFERRAL_CODE${NC}"
echo -e "${YELLOW}This may take a moment...${NC}"

cd /opt/pipe-pop
./bin/pipe-pop --signup-by-referral-route "$REFERRAL_CODE"
REGISTRATION_STATUS=$?

if [ $REGISTRATION_STATUS -eq 0 ]; then
  echo -e "${GREEN}✓ Registration successful!${NC}"
else
  echo -e "${RED}✗ Registration failed with status code: $REGISTRATION_STATUS${NC}"
  echo -e "${YELLOW}Restoring from backup...${NC}"
  if [ -f "$NODE_INFO_BACKUP" ]; then
    cp "$NODE_INFO_BACKUP" "$NODE_INFO_FILE"
    cp "$NODE_INFO_BACKUP" /opt/pipe-pop/node_info.json
    cp "$NODE_INFO_BACKUP" /opt/pipe-pop/bin/node_info.json
    echo -e "  ${GREEN}✓ Restored from backup${NC}"
  else
    echo -e "  ${RED}✗ No backup found, cannot restore${NC}"
  fi
  
  echo -e "${RED}Please check the following:${NC}"
  echo -e "1. Internet connection is working"
  echo -e "2. The Pipe Network servers are online"
  echo -e "3. The referral code is valid"
  echo
  echo -e "${YELLOW}You can try again later or contact support.${NC}"
  
  # Start the service again before exiting
  echo -e "${YELLOW}Starting the pipe-pop service again...${NC}"
  systemctl start pipe-pop.service
  exit 1
fi

# Verify the registration was successful
echo -e "${YELLOW}Verifying registration...${NC}"
if [ -f "$NODE_INFO_FILE" ]; then
  TOKEN=$(grep -o '"token": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)
  REGISTERED=$(grep -o '"registered": [^,]*' "$NODE_INFO_FILE" | cut -d' ' -f2)
  
  if [ "$TOKEN" != "" ] && [ "$TOKEN" != "temporary_token_to_bypass_registration" ] && [ "$REGISTERED" == "true" ]; then
    echo -e "  ${GREEN}✓ Registration verified: Node has a valid token${NC}"
  else
    echo -e "  ${YELLOW}⚠ Registration may not have completed properly:${NC}"
    echo -e "    - Token: $(if [ "$TOKEN" != "" ] && [ "$TOKEN" != "temporary_token_to_bypass_registration" ]; then echo "${GREEN}Valid${NC}"; else echo "${RED}Invalid${NC}"; fi)"
    echo -e "    - Registered: $(if [ "$REGISTERED" == "true" ]; then echo "${GREEN}Yes${NC}"; else echo "${RED}No${NC}"; fi)"
  fi
fi

# Start the service
echo -e "${YELLOW}Starting the pipe-pop service...${NC}"
systemctl start pipe-pop.service
echo -e "  ${GREEN}✓ Service started${NC}"

# Display final status
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}            REGISTRATION SUMMARY                    ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}New Node ID:${NC} $NEW_NODE_ID"
echo -e "${YELLOW}Registration Status:${NC} $(grep -o '"registered": [^,]*' "$NODE_INFO_FILE" | cut -d' ' -f2)"
echo -e "${YELLOW}Last Updated:${NC} $(grep -o '"last_updated": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)"
echo

echo -e "${GREEN}Node reset and registration completed.${NC}"
echo -e "${YELLOW}You can check the node status with:${NC} sudo systemctl status pipe-pop.service"
echo
echo -e "${YELLOW}Please ensure your port forwarding is still configured correctly for the node.${NC}" 