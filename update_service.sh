#!/bin/bash

# Color codes for output
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
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    echo "Please run with: sudo ./update_service.sh"
    exit 1
fi

print_message "Updating the pipe-pop service file..."

# Copy the new service file to the systemd directory
cp pipe-pop.service.new /etc/systemd/system/pipe-pop.service

# Reload systemd to recognize the changes
print_message "Reloading systemd daemon..."
systemctl daemon-reload

# Restart the service
print_message "Restarting pipe-pop service..."
systemctl restart pipe-pop.service

# Check the status of the service
print_message "Checking service status..."
systemctl status pipe-pop.service

print_message "Service update completed."
print_message "You can check the service logs with: journalctl -u pipe-pop.service -f" 