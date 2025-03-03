#!/bin/bash

# Script to fix port issues for Pipe PoP node
# This script will open ports in the firewall and update the configuration
#
# NOTE: This script is a more comprehensive version of open_ports.sh.
# It includes additional functionality to check for port conflicts and
# verify the configuration file. Please use this script instead of open_ports.sh.

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

print_message "Fixing port issues for Pipe PoP node..."

# Step 1: Open ports in the firewall
print_message "Step 1: Opening ports in the firewall..."

# Check if ufw is installed
if ! command -v ufw &> /dev/null; then
    print_warning "ufw is not installed. Installing..."
    apt-get update
    apt-get install -y ufw
fi

# Check if ufw is enabled
if ! ufw status | grep -q "Status: active"; then
    print_warning "ufw is not enabled. Enabling..."
    ufw enable
fi

# Open the required ports
print_message "Opening port 80 (HTTP)..."
ufw allow 80/tcp

print_message "Opening port 443 (HTTPS)..."
ufw allow 443/tcp

print_message "Opening port 8003 (Pipe PoP)..."
ufw allow 8003/tcp

# Reload the firewall
print_message "Reloading firewall..."
ufw reload

# Show the status
print_message "Firewall status:"
ufw status | grep -E '80|443|8003'

# Step 2: Check if the ports are already in use by other services
print_message "Step 2: Checking if ports are already in use by other services..."

PORT_80_IN_USE=$(netstat -tuln | grep ":80 " | grep -v "pipe-pop")
PORT_443_IN_USE=$(netstat -tuln | grep ":443 " | grep -v "pipe-pop")
PORT_8003_IN_USE=$(netstat -tuln | grep ":8003 " | grep -v "pipe-pop")

if [ -n "$PORT_80_IN_USE" ]; then
    print_warning "Port 80 is already in use by another service:"
    echo "$PORT_80_IN_USE"
    print_warning "You may need to stop this service or configure Pipe PoP to use a different port."
fi

if [ -n "$PORT_443_IN_USE" ]; then
    print_warning "Port 443 is already in use by another service:"
    echo "$PORT_443_IN_USE"
    print_warning "You may need to stop this service or configure Pipe PoP to use a different port."
fi

if [ -n "$PORT_8003_IN_USE" ]; then
    print_warning "Port 8003 is already in use by another service:"
    echo "$PORT_8003_IN_USE"
    print_warning "You may need to stop this service or configure Pipe PoP to use a different port."
fi

# Step 3: Verify the configuration file
print_message "Step 3: Verifying the configuration file..."

CONFIG_FILE="/home/karo/Workspace/PipeNetwork/config/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Create a backup of the configuration file
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
print_message "Created backup of configuration file: ${CONFIG_FILE}.bak"

# Check if the ports are correctly configured
if ! grep -q "\"ports\".*\[.*80.*443.*8003" "$CONFIG_FILE"; then
    print_warning "Ports may not be correctly configured in config.json. Updating..."
    
    # Update the configuration file
    TMP_FILE=$(mktemp)
    jq '.network.ports = [80, 443, 8003]' "$CONFIG_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$CONFIG_FILE"
    
    print_message "Configuration file updated successfully!"
else
    print_message "Ports are correctly configured in config.json."
fi

# Step 4: Restart the service
print_message "Step 4: Restarting the Pipe PoP service..."

systemctl restart pipe-pop.service

# Check the service status
print_message "Checking service status..."
systemctl status pipe-pop.service | grep -v "status" | head -20

# Step 5: Wait for the service to start and check if ports are now in use
print_message "Step 5: Waiting for the service to start (this may take a moment)..."
sleep 10

# Check if the ports are now in use
print_message "Checking if ports are now in use..."
PORT_80_IN_USE_BY_PIPE=$(netstat -tuln | grep ":80 " | grep "pipe-pop" || echo "")
PORT_443_IN_USE_BY_PIPE=$(netstat -tuln | grep ":443 " | grep "pipe-pop" || echo "")
PORT_8003_IN_USE_BY_PIPE=$(netstat -tuln | grep ":8003 " | grep "pipe-pop" || echo "")

if [ -n "$PORT_80_IN_USE_BY_PIPE" ]; then
    print_message "Port 80 is now in use by Pipe PoP."
else
    print_warning "Port 80 is not in use by Pipe PoP. This may be normal if the node hasn't received traffic yet."
fi

if [ -n "$PORT_443_IN_USE_BY_PIPE" ]; then
    print_message "Port 443 is now in use by Pipe PoP."
else
    print_warning "Port 443 is not in use by Pipe PoP. This may be normal if the node hasn't received traffic yet."
fi

if [ -n "$PORT_8003_IN_USE_BY_PIPE" ]; then
    print_message "Port 8003 is now in use by Pipe PoP."
else
    print_warning "Port 8003 is not in use by Pipe PoP. This may be normal if the node hasn't received traffic yet."
fi

# Step 6: Provide additional information
print_message "Step 6: Additional information..."

print_message "The Pipe PoP node may not actively listen on these ports until it receives traffic."
print_message "This is normal behavior and doesn't indicate a problem with the node."
print_message "You can check the node status with: pop --status"
print_message "You can monitor the node with: pop --monitor"
print_message "You can check the service logs with: journalctl -u pipe-pop.service -n 50"

print_message "Setup complete!"
print_message "If you still have issues with ports, please check the following:"
print_message "1. Make sure no other services are using the required ports"
print_message "2. Check if your router/firewall is forwarding the ports correctly"
print_message "3. Check the service logs for any errors"
print_message "4. Try restarting the service with: sudo systemctl restart pipe-pop.service" 