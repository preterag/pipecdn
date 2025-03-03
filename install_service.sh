#!/bin/bash

# Script to install and manage the Pipe Network PoP (PPN) systemd service

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

# Function to install the service
install_service() {
    print_message "Installing PPN service..."
    
    # Copy the service file
    cp ppn.service /etc/systemd/system/
    
    # Reload systemd
    systemctl daemon-reload
    
    print_message "Service installed successfully."
}

# Function to enable the service
enable_service() {
    print_message "Enabling PPN service to start on boot..."
    
    systemctl enable ppn.service
    
    print_message "Service enabled successfully."
}

# Function to start the service
start_service() {
    print_message "Starting PPN service..."
    
    systemctl start ppn.service
    
    print_message "Service started successfully."
}

# Function to check service status
check_status() {
    print_message "Checking PPN service status..."
    
    systemctl status ppn.service
}

# Function to stop the service
stop_service() {
    print_message "Stopping PPN service..."
    
    systemctl stop ppn.service
    
    print_message "Service stopped successfully."
}

# Function to disable the service
disable_service() {
    print_message "Disabling PPN service..."
    
    systemctl disable ppn.service
    
    print_message "Service disabled successfully."
}

# Function to uninstall the service
uninstall_service() {
    print_message "Uninstalling PPN service..."
    
    # Stop and disable the service
    systemctl stop ppn.service
    systemctl disable ppn.service
    
    # Remove the service file
    rm /etc/systemd/system/ppn.service
    
    # Reload systemd
    systemctl daemon-reload
    
    print_message "Service uninstalled successfully."
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Install and manage the Pipe Network PoP (PPN) systemd service."
    echo ""
    echo "Options:"
    echo "  install    Install the service"
    echo "  enable     Enable the service to start on boot"
    echo "  start      Start the service"
    echo "  status     Check the service status"
    echo "  stop       Stop the service"
    echo "  disable    Disable the service"
    echo "  uninstall  Uninstall the service"
    echo "  all        Install, enable, and start the service"
    echo "  help       Show this help message"
}

# Main execution
case "$1" in
    install)
        install_service
        ;;
    enable)
        enable_service
        ;;
    start)
        start_service
        ;;
    status)
        check_status
        ;;
    stop)
        stop_service
        ;;
    disable)
        disable_service
        ;;
    uninstall)
        uninstall_service
        ;;
    all)
        install_service
        enable_service
        start_service
        check_status
        ;;
    help|*)
        show_help
        ;;
esac 