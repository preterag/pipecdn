#!/bin/bash

# Pipe PoP Node Monitoring Script
# Version: 1.0.0
#
# This script monitors the Pipe PoP node's performance and status
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Monitoring script for Pipe PoP node
# This script checks the status of the node and provides basic monitoring

# Installation directory
INSTALL_DIR="/opt/pipe-pop"
# Main PipeNetwork directory
PIPE_DIR="/home/karo/Workspace/PipeNetwork"

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

# Check if the node is running
check_node_status() {
    if pgrep -f "pipe-pop" > /dev/null; then
        print_message "Pipe PoP node is running."
        return 0
    else
        print_error "Pipe PoP node is not running."
        return 1
    fi
}

# Check system resources
check_system_resources() {
    print_message "Checking system resources..."
    
    # Check RAM usage
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    used_ram=$(free -m | awk '/^Mem:/{print $3}')
    free_ram=$(free -m | awk '/^Mem:/{print $4}')
    
    ram_usage_percent=$((used_ram * 100 / total_ram))
    
    if [ "$ram_usage_percent" -gt 90 ]; then
        print_error "RAM usage is high: ${ram_usage_percent}% (${used_ram}MB/${total_ram}MB)"
    elif [ "$ram_usage_percent" -gt 70 ]; then
        print_warning "RAM usage is moderate: ${ram_usage_percent}% (${used_ram}MB/${total_ram}MB)"
    else
        print_message "RAM usage is normal: ${ram_usage_percent}% (${used_ram}MB/${total_ram}MB)"
    fi
    
    # Check disk space
    disk_total=$(df -m . | awk 'NR==2 {print $2}')
    disk_used=$(df -m . | awk 'NR==2 {print $3}')
    disk_free=$(df -m . | awk 'NR==2 {print $4}')
    
    disk_usage_percent=$((disk_used * 100 / disk_total))
    
    if [ "$disk_usage_percent" -gt 90 ]; then
        print_error "Disk usage is high: ${disk_usage_percent}% (${disk_used}MB/${disk_total}MB)"
    elif [ "$disk_usage_percent" -gt 70 ]; then
        print_warning "Disk usage is moderate: ${disk_usage_percent}% (${disk_used}MB/${disk_total}MB)"
    else
        print_message "Disk usage is normal: ${disk_usage_percent}% (${disk_used}MB/${disk_total}MB)"
    fi
}

# Check cache directory size
check_cache_size() {
    if [ -d "${PIPE_DIR}/cache" ]; then
        cache_size=$(du -sm "${PIPE_DIR}/cache" | cut -f1)
        print_message "Cache directory size: ${cache_size}MB"
        
        if [ "$cache_size" -gt 5000 ]; then
            print_warning "Cache directory is quite large. Consider cleaning up old data if needed."
        fi
    else
        print_warning "Cache directory not found."
    fi
}

# Check node_info.json
check_node_info() {
    if [ -f "${PIPE_DIR}/cache/node_info.json" ]; then
        print_message "node_info.json exists."
        
        # Check when it was last modified
        last_modified=$(stat -c %y "${PIPE_DIR}/cache/node_info.json" | cut -d. -f1)
        print_message "Last modified: ${last_modified}"
        
        # Check file size
        file_size=$(du -h "${PIPE_DIR}/cache/node_info.json" | cut -f1)
        print_message "File size: ${file_size}"
    else
        print_warning "node_info.json not found."
    fi
}

# Check port availability
check_ports() {
    print_message "Checking required ports..."
    
    # First check if the ports are in use by any process
    for port in 80 443 8003; do
        if netstat -tuln | grep ":${port} " > /dev/null; then
            print_message "Port ${port} is in use."
        else
            print_warning "Port ${port} is not in use. It may need to be opened in your firewall."
            print_message "  - To open port ${port}, run: sudo ufw allow ${port}/tcp"
        fi
    done
    
    # Check if the Pipe PoP service is configured to use these ports
    if [ -f "${PIPE_DIR}/config/config.json" ]; then
        if grep -q "\"ports\".*\[.*80.*443.*8003" "${PIPE_DIR}/config/config.json"; then
            print_message "Ports are correctly configured in config.json."
        else
            print_warning "Ports may not be correctly configured in config.json. Please check the configuration."
        fi
    else
        print_warning "config.json not found. Cannot verify port configuration."
    fi
    
    print_message "Note: The Pipe PoP node may not actively listen on these ports until it receives traffic."
    print_message "      This is normal behavior and doesn't indicate a problem with the node."
}

# Main function
main() {
    print_message "=== Pipe PoP Node Monitoring ==="
    print_message "Time: $(date)"
    print_message "================================="
    
    check_node_status
    check_system_resources
    check_cache_size
    check_node_info
    check_ports
    
    print_message "================================="
    print_message "Monitoring completed."
}

# Run the main function
main 