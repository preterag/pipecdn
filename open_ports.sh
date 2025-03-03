#!/bin/bash

# Script to open the required ports for Pipe PoP node
# This script will open ports 80, 443, and 8003 in the firewall

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

print_message "Opening required ports for Pipe PoP node..."

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

print_message "Ports opened successfully!"
print_message "Now updating the service file to ensure ports are used..."

# Update the service file to explicitly use the ports
SERVICE_FILE="/etc/systemd/system/pipe-pop.service"

# Check if the service file exists
if [ ! -f "$SERVICE_FILE" ]; then
    print_error "Service file not found: $SERVICE_FILE"
    exit 1
fi

# Create a backup of the service file
cp "$SERVICE_FILE" "${SERVICE_FILE}.bak"
print_message "Created backup of service file: ${SERVICE_FILE}.bak"

# Update the service file
cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Pipe PoP Node
After=network.target

[Service]
User=karo
WorkingDirectory=/home/karo/Workspace/PipeNetwork
ExecStart=/home/karo/Workspace/PipeNetwork/bin/pipe-pop --cache-dir /home/karo/Workspace/PipeNetwork/cache --pubKey H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8 --ports 80,443,8003
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

print_message "Service file updated successfully!"

# Reload systemd
print_message "Reloading systemd..."
systemctl daemon-reload

# Restart the service
print_message "Restarting Pipe PoP service..."
systemctl restart pipe-pop.service

# Check the service status
print_message "Checking service status..."
systemctl status pipe-pop.service | grep -v "status" | head -20

print_message "Waiting for ports to be opened (this may take a moment)..."
sleep 10

# Check if the ports are now in use
print_message "Checking if ports are now in use..."
netstat -tulpn | grep -E ':(80|443|8003)' | grep pipe-pop

print_message "Setup complete!"
print_message "If you don't see the ports listed above, please wait a few minutes and check again with:"
print_message "  sudo netstat -tulpn | grep -E ':(80|443|8003)'"
print_message "You can also check the service logs with:"
print_message "  journalctl -u pipe-pop.service -n 50" 