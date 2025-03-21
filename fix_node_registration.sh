#!/bin/bash
# Script to fix node registration by using the properly registered node_info.json everywhere

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}    PIPE NETWORK NODE REGISTRATION FIX TOOL         ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root.${NC}"
  echo -e "Please run with: ${YELLOW}sudo $0${NC}"
  exit 1
fi

# Define paths
SOURCE_NODE_INFO="/home/karo/Workspace/pipe-pop/node_info.json"
TARGET_LOCATIONS=(
  "/home/karo/node_info.json"
  "/opt/pipe-pop/node_info.json"
  "/opt/pipe-pop/bin/node_info.json"
  "/root/node_info.json"  # In case root user needs it
  "/etc/pipe-pop/node_info.json"  # Common config location
)

# First verify that the source node_info.json is properly registered
echo -e "${YELLOW}Verifying source node_info.json at $SOURCE_NODE_INFO...${NC}"
if [ ! -f "$SOURCE_NODE_INFO" ]; then
  echo -e "${RED}Error: Source node_info.json not found!${NC}"
  exit 1
fi

NODE_ID=$(grep -o '"node_id": "[^"]*' "$SOURCE_NODE_INFO" | cut -d'"' -f4)
REGISTERED=$(grep -o '"registered": [^,]*' "$SOURCE_NODE_INFO" | cut -d' ' -f2)
TOKEN=$(grep -o '"token": "[^"]*' "$SOURCE_NODE_INFO" | cut -d'"' -f4)

if [ -z "$NODE_ID" ] || [ "$REGISTERED" != "true" ] || [ "$TOKEN" == "temporary_token_to_bypass_registration" ] || [ -z "$TOKEN" ]; then
  echo -e "${RED}Error: Source node_info.json is not properly registered!${NC}"
  echo -e "  ${YELLOW}Node ID:${NC} $NODE_ID"
  echo -e "  ${YELLOW}Registered:${NC} $REGISTERED"
  echo -e "  ${YELLOW}Token:${NC} $(if [ "$TOKEN" == "temporary_token_to_bypass_registration" ] || [ -z "$TOKEN" ]; then echo "${RED}Invalid${NC}"; else echo "${GREEN}Valid${NC}"; fi)"
  echo -e "${YELLOW}Please register the node properly first!${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Source node_info.json is valid and registered${NC}"
echo -e "  ${YELLOW}Node ID:${NC} $NODE_ID"
echo -e "  ${YELLOW}Registration Status:${NC} $REGISTERED"

# Stop the service
echo -e "${YELLOW}Stopping the pipe-pop service...${NC}"
systemctl stop pipe-pop.service
echo -e "  ${GREEN}✓ Service stopped${NC}"
sleep 5

# Backup existing node_info.json files
echo -e "${YELLOW}Backing up existing node_info.json files...${NC}"
for target in "${TARGET_LOCATIONS[@]}"; do
  if [ -f "$target" ]; then
    cp "$target" "${target}.backup-$(date +%Y%m%d_%H%M%S)"
    echo -e "  ${GREEN}✓ Backed up $target${NC}"
  fi
done

# Create parent directories if they don't exist
echo -e "${YELLOW}Creating parent directories if needed...${NC}"
for target in "${TARGET_LOCATIONS[@]}"; do
  target_dir=$(dirname "$target")
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    echo -e "  ${GREEN}✓ Created directory $target_dir${NC}"
  fi
done

# Copy the registered node_info.json to all target locations
echo -e "${YELLOW}Copying registered node_info.json to all locations...${NC}"
for target in "${TARGET_LOCATIONS[@]}"; do
  cp "$SOURCE_NODE_INFO" "$target"
  chmod 644 "$target"
  echo -e "  ${GREEN}✓ Updated $target${NC}"
done

# Update some extra locations based on user directories
echo -e "${YELLOW}Checking for additional user directories...${NC}"
for user_dir in /home/*; do
  if [ -d "$user_dir" ] && [ "$user_dir" != "/home/karo" ]; then
    user=$(basename "$user_dir")
    if id "$user" &>/dev/null; then
      # Get the user's home directory from passwd
      home_dir=$(getent passwd "$user" | cut -d: -f6)
      if [ -d "$home_dir" ]; then
        target="$home_dir/node_info.json"
        if [ -f "$target" ]; then
          cp "$SOURCE_NODE_INFO" "$target"
          chown "$user":"$user" "$target"
          chmod 644 "$target"
          echo -e "  ${GREEN}✓ Updated $target for user $user${NC}"
        fi
      fi
    fi
  fi
done

# Start the service
echo -e "${YELLOW}Starting the pipe-pop service...${NC}"
systemctl start pipe-pop.service
echo -e "  ${GREEN}✓ Service started${NC}"
sleep 5

# Verify the service is using the correct node ID
echo -e "${YELLOW}Verifying the pipe-pop service...${NC}"
if ps aux | grep -v grep | grep pipe-pop | grep -q "$NODE_ID"; then
  echo -e "  ${GREEN}✓ Service is running with the correct node ID${NC}"
else
  echo -e "  ${YELLOW}⚠️ Service is running but node ID could not be verified${NC}"
fi

# Summary
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}                SUMMARY                             ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "${YELLOW}Node ID:${NC} $NODE_ID"
echo -e "${YELLOW}Registered:${NC} $REGISTERED"
echo

echo -e "${YELLOW}To verify the fix, try running these commands:${NC}"
echo -e "  ${CYAN}cd ~ && pop --status${NC}"
echo -e "  ${CYAN}cd /home/karo/Workspace/pipe-pop && pop --status${NC}"
echo

echo -e "${GREEN}Node registration fix completed.${NC}"
echo -e "${YELLOW}Your registered node information has been copied to all necessary locations.${NC}" 