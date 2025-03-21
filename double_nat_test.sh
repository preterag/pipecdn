#!/bin/bash
# Script to detect possible Double NAT issues that could prevent port forwarding

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}       DOUBLE NAT DETECTION TOOL                   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# Get default gateway
DEFAULT_GATEWAY=$(ip route | grep default | awk '{print $3}')
# Get your local IP 
LOCAL_IP=$(hostname -I | awk '{print $1}')
# Get public IP
PUBLIC_IP=$(curl -s https://api.ipify.org)

echo -e "${YELLOW}Network Information:${NC}"
echo -e "  Local IP: ${LOCAL_IP}"
echo -e "  Default Gateway: ${DEFAULT_GATEWAY}"
echo -e "  Public IP: ${PUBLIC_IP}"
echo

# Check for multiple gateways (could indicate multiple routers)
GATEWAY_COUNT=$(ip route | grep default | wc -l)
echo -e "${YELLOW}Gateway Check:${NC}"
if [ "$GATEWAY_COUNT" -gt 1 ]; then
  echo -e "  ${RED}⚠ Multiple default gateways detected!${NC}"
  echo -e "  ${YELLOW}This often indicates a Double NAT situation.${NC}"
  ip route | grep default
else
  echo -e "  ${GREEN}✓ Single default gateway detected.${NC}"
fi

# Try to determine if default gateway is ISP or local router
echo
echo -e "${YELLOW}Gateway Analysis:${NC}"
GATEWAY_MAC=$(arp -n | grep "$DEFAULT_GATEWAY" | awk '{print $3}')
OUI=${GATEWAY_MAC:0:8}

echo -e "  Gateway MAC address: $GATEWAY_MAC"

# Extract the vendor from MAC address using the first portion of the MAC
echo -e "  ${YELLOW}Analyzing gateway hardware...${NC}"
if [[ "$OUI" == "00:50:56" || "$OUI" == "00:1A:6D" ]]; then
  echo -e "  ${YELLOW}Gateway appears to be virtualized or from a VM environment${NC}"
elif [[ "$OUI" == *"9c:53:22"* || "$OUI" == *"74:da:38"* || "$OUI" == *"44:94:fc"* ]]; then
  echo -e "  ${YELLOW}Gateway appears to be TP-Link hardware${NC}"
elif [[ "$OUI" == *"00:18:01"* || "$OUI" == *"00:13:49"* || "$OUI" == *"00:1d:7e"* ]]; then
  echo -e "  ${YELLOW}Gateway appears to be Linksys/Cisco hardware${NC}"
elif [[ "$OUI" == *"f8:1a:67"* || "$OUI" == *"b0:7f:b9"* || "$OUI" == *"aa:86:bb"* ]]; then
  echo -e "  ${YELLOW}Gateway appears to be Netgear hardware${NC}"
elif [[ "$OUI" == *"a0:f3:c1"* || "$OUI" == *"00:30:44"* ]]; then
  echo -e "  ${YELLOW}Gateway may be ISP-provided equipment${NC}"
else
  echo -e "  ${YELLOW}Unable to determine gateway hardware vendor${NC}"
fi

# Traceroute to internet to check for multiple hops before reaching internet
echo
echo -e "${YELLOW}Traceroute Analysis:${NC}"
echo -e "  ${YELLOW}Performing traceroute to detect multiple hops...${NC}"
echo -e "  ${YELLOW}(This might indicate Double NAT if there are multiple private IPs)${NC}"

HOPS=$(traceroute -n -m 5 8.8.8.8 2>/dev/null | grep -E '192\.168\.|10\.|172\.16\.' | wc -l)

if [ "$HOPS" -gt 1 ]; then
  echo -e "  ${RED}⚠ Multiple private network hops detected in traceroute!${NC}"
  echo -e "  ${YELLOW}This suggests you may have Double NAT.${NC}"
  traceroute -n -m 5 8.8.8.8 2>/dev/null | grep -E '192\.168\.|10\.|172\.16\.'
else
  echo -e "  ${GREEN}✓ No signs of Double NAT in traceroute.${NC}"
fi

# Check for CGNAT (Carrier-Grade NAT)
echo
echo -e "${YELLOW}CGNAT Detection:${NC}"
# Most CGNAT implementations use specific IP ranges
if [[ "$PUBLIC_IP" == 100.64.* || "$PUBLIC_IP" == 100.65.* || "$PUBLIC_IP" == 100.66.* || 
      "$PUBLIC_IP" == 100.67.* || "$PUBLIC_IP" == 100.68.* || "$PUBLIC_IP" == 100.69.* || 
      "$PUBLIC_IP" == 100.70.* || "$PUBLIC_IP" == 100.71.* || "$PUBLIC_IP" == 100.72.* || 
      "$PUBLIC_IP" == 100.73.* || "$PUBLIC_IP" == 100.74.* || "$PUBLIC_IP" == 100.75.* || 
      "$PUBLIC_IP" == 100.76.* || "$PUBLIC_IP" == 100.77.* || "$PUBLIC_IP" == 100.78.* || 
      "$PUBLIC_IP" == 100.79.* || "$PUBLIC_IP" == 100.80.* || "$PUBLIC_IP" == 100.127.* ]]; then
  echo -e "  ${RED}⚠ Your public IP ($PUBLIC_IP) appears to be in a CGNAT range!${NC}"
  echo -e "  ${YELLOW}CGNAT makes port forwarding impossible without special ISP configuration.${NC}"
else
  echo -e "  ${GREEN}✓ Your public IP ($PUBLIC_IP) does not appear to be in a CGNAT range.${NC}"
fi

# Summary
echo
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}              TEST SUMMARY                          ${NC}"
echo -e "${CYAN}====================================================${NC}"

DOUBLE_NAT=false
CGNAT=false

if [ "$GATEWAY_COUNT" -gt 1 ] || [ "$HOPS" -gt 1 ]; then
  DOUBLE_NAT=true
fi

if [[ "$PUBLIC_IP" == 100.64.* || "$PUBLIC_IP" == 100.65.* || "$PUBLIC_IP" == 100.127.* ]]; then
  CGNAT=true
fi

if [ "$DOUBLE_NAT" = true ] || [ "$CGNAT" = true ]; then
  echo -e "${RED}⚠ Possible port forwarding issues detected!${NC}"
  
  if [ "$DOUBLE_NAT" = true ]; then
    echo -e "${YELLOW}Double NAT detected:${NC} You appear to have multiple routers/gateways"
    echo -e "${YELLOW}Solution:${NC}"
    echo -e "  1. Identify all routers in your network"
    echo -e "  2. Set all but the main internet-facing router to bridge mode, OR"
    echo -e "  3. Configure port forwarding on ALL routers in sequence"
  fi
  
  if [ "$CGNAT" = true ]; then
    echo -e "${YELLOW}CGNAT detected:${NC} Your ISP is using Carrier-Grade NAT"
    echo -e "${YELLOW}Solution:${NC}"
    echo -e "  1. Contact your ISP and request a public IP address"
    echo -e "  2. Consider upgrading to a business internet plan"
    echo -e "  3. Consider using a VPN service that supports port forwarding"
  fi
else
  echo -e "${GREEN}✓ No obvious Double NAT or CGNAT issues detected.${NC}"
  echo -e "${YELLOW}If port forwarding still doesn't work, check:${NC}"
  echo -e "  1. Router configuration (correct IP and port settings)"
  echo -e "  2. Firewall settings (on both router and local machine)"
  echo -e "  3. ISP policies (some block specific ports)"
fi

echo
echo -e "${YELLOW}Final recommendation:${NC}"
echo -e "  1. Log into your router at http://$DEFAULT_GATEWAY/"
echo -e "  2. Verify port forwarding is set up correctly"
echo -e "  3. Check if your router has a Double NAT detection feature"
echo -e "  4. Try port forwarding to a different port (e.g., 9000)" 