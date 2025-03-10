#!/bin/bash

# Script to fix naming inconsistencies in the Pipe Network PoP project
# This script will update all references from ppn to pipe-pop

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
    echo "Please run with: sudo ./fix_naming.sh"
    exit 1
fi

print_message "Starting the naming fix process..."

# 1. Update the service file
print_message "1. Updating the service file..."
cat > pipe-pop.service << EOF
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
User=root
WorkingDirectory=/home/karo/Workspace/PipeNetwork
ExecStart=/home/karo/Workspace/PipeNetwork/start_pipe_pop.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# 2. Install the updated service file
print_message "2. Installing the updated service file..."
cp pipe-pop.service /etc/systemd/system/
systemctl daemon-reload

# 3. Check if ppn.service exists and remove it
if [ -f "/etc/systemd/system/ppn.service" ]; then
    print_message "3. Removing old ppn.service file..."
    systemctl stop ppn.service 2>/dev/null
    systemctl disable ppn.service 2>/dev/null
    rm /etc/systemd/system/ppn.service
    systemctl daemon-reload
else
    print_message "3. No old ppn.service file found, skipping removal."
fi

# 4. Enable and start the pipe-pop service
print_message "4. Enabling and starting the pipe-pop service..."
systemctl enable pipe-pop.service
systemctl restart pipe-pop.service

# 5. Check the service status
print_message "5. Checking service status..."
systemctl status pipe-pop.service

print_message "Naming fix process completed."
print_message "You can check the service logs with: journalctl -u pipe-pop.service -f"
print_message "You can check the node status with: ./pop --status" 