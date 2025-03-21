#!/bin/bash
# Script to register a Pipe Network node with the Surrealine referral code

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}     PIPE NETWORK NODE REGISTRATION TOOL            ${NC}"
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
BACKUP_FILE="/home/karo/node_info_backup_$(date +%Y%m%d_%H%M%S).json"

# Backup current node_info.json if it exists
if [ -f "$NODE_INFO_FILE" ]; then
    echo -e "${YELLOW}Backing up existing node_info.json...${NC}"
    cp "$NODE_INFO_FILE" "$BACKUP_FILE"
    echo -e "  ${GREEN}✓ Backup created at $BACKUP_FILE${NC}"
fi

# Stop the service if running
echo -e "${YELLOW}Stopping the pipe-pop service...${NC}"
systemctl stop pipe-pop.service
echo -e "  ${GREEN}✓ Service stopped${NC}"

# Wait for service to fully stop
echo -e "${YELLOW}Waiting for service to stop completely...${NC}"
sleep 5

# Registration 
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
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$NODE_INFO_FILE"
        echo -e "  ${GREEN}✓ Restored from backup${NC}"
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

# Check if registration was successful by examining node_info.json
if [ -f "$NODE_INFO_FILE" ]; then
    TOKEN=$(grep -o '"token": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)
    if [ "$TOKEN" != "temporary_token_to_bypass_registration" ]; then
        echo -e "${GREEN}✓ Verified: Node info updated with valid token${NC}"
    else
        echo -e "${YELLOW}⚠️ Node info still contains temporary token.${NC}"
        echo -e "${YELLOW}Registration may not have fully completed.${NC}"
    fi
fi

# Copy node_info.json to required locations
echo -e "${YELLOW}Copying node_info.json to necessary locations...${NC}"
cp "$NODE_INFO_FILE" "/opt/pipe-pop/node_info.json"
cp "$NODE_INFO_FILE" "/opt/pipe-pop/bin/node_info.json"
chmod 644 "/opt/pipe-pop/node_info.json" "/opt/pipe-pop/bin/node_info.json"
echo -e "  ${GREEN}✓ Copied node_info.json to required locations${NC}"

# Restart the service
echo -e "${YELLOW}Starting the pipe-pop service...${NC}"
systemctl start pipe-pop.service
echo -e "  ${GREEN}✓ Service started${NC}"

# Display final status
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}             REGISTRATION SUMMARY                   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}Node ID:${NC} $(grep -o '"node_id": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)"
echo -e "${YELLOW}Registration Status:${NC} $(grep -o '"registered": [^,]*' "$NODE_INFO_FILE" | cut -d' ' -f2)"
echo -e "${YELLOW}Last Updated:${NC} $(grep -o '"last_updated": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)"
echo

echo -e "${GREEN}Registration process completed.${NC}"
echo -e "${YELLOW}You can check the node status with:${NC} sudo systemctl status pipe-pop.service" 