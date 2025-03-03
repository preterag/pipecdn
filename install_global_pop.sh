#!/bin/bash

# Script to install the global 'pop' command
# Version: 1.0.0
#
# This script installs the 'pop' command globally for easy management of the Pipe PoP node
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

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

print_header() {
    echo -e "${BOLD}$1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

# Get the current directory (where the PipeNetwork is installed)
PIPE_DIR="$(pwd)"
INSTALL_DIR="/opt/pipe-pop"
GLOBAL_CMD="/usr/local/bin/pop"

print_header "Installing Global Pop Command"
print_message "This will install the pop command globally on your system."
print_message "Installation directory: ${INSTALL_DIR}"
print_message "Global command: ${GLOBAL_CMD}"
print_message "PipeNetwork directory: ${PIPE_DIR}"

# Create the installation directory
print_message "Creating installation directory..."
mkdir -p "${INSTALL_DIR}/bin"

# Copy the binary
print_message "Copying binary..."
cp "${PIPE_DIR}/bin/pipe-pop" "${INSTALL_DIR}/bin/"

# Create the monitor script with absolute paths
print_message "Creating monitor script with absolute paths..."
cat > "${INSTALL_DIR}/monitor.sh" << 'EOF'
#!/bin/bash

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
EOF

# Create the backup script with absolute paths
print_message "Creating backup script with absolute paths..."
cat > "${INSTALL_DIR}/backup.sh" << 'EOF'
#!/bin/bash

# Backup script for Pipe PoP node
# This script creates backups of important node data

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

# Create backup directory if it doesn't exist
mkdir -p "${PIPE_DIR}/backups"

# Get current timestamp for backup file
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="${PIPE_DIR}/backups/backup_${timestamp}"
mkdir -p "${backup_dir}"

# Backup node_info.json if it exists
if [ -f "${PIPE_DIR}/cache/node_info.json" ]; then
    print_message "Backing up node_info.json..."
    cp "${PIPE_DIR}/cache/node_info.json" "${backup_dir}/"
    print_message "node_info.json backed up successfully."
else
    print_warning "node_info.json not found. Skipping backup."
fi

# Backup Solana wallet if it exists
if [ -f "$HOME/.config/solana/id.json" ]; then
    print_message "Backing up Solana wallet..."
    cp "$HOME/.config/solana/id.json" "${backup_dir}/solana_id.json"
    print_message "Solana wallet backed up successfully."
else
    print_warning "Solana wallet not found. Skipping backup."
fi

# Backup configuration files
print_message "Backing up configuration files..."
if [ -d "${PIPE_DIR}/config" ]; then
    cp -r "${PIPE_DIR}/config" "${backup_dir}/"
    print_message "Configuration files backed up successfully."
else
    print_warning "Configuration directory not found. Skipping backup."
fi

# Create a compressed archive of the backup
print_message "Creating compressed archive..."
tar -czf "${backup_dir}.tar.gz" -C "${PIPE_DIR}/backups" "backup_${timestamp}"

# Remove the uncompressed backup directory
rm -rf "${backup_dir}"

print_message "Backup completed successfully: ${backup_dir}.tar.gz"
print_message "Please store this backup in a safe location."
EOF

# Create the global pop command
print_message "Creating global pop command..."
cat > "${GLOBAL_CMD}" << 'EOF'
#!/bin/bash

# Pipe PoP Node Management Script
# This script provides a convenient wrapper around the pipe-pop binary

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

# Check if the binary exists
if [ ! -f "${INSTALL_DIR}/bin/pipe-pop" ]; then
    print_error "Pipe PoP binary not found. Please check your installation."
    exit 1
fi

# Function to show help
show_help() {
    echo "Pipe PoP Node Management Script"
    echo "Usage: pop [OPTION]"
    echo ""
    echo "Options:"
    echo "  --status                Check node status and reputation"
    echo "  --check-update          Check for available updates"
    echo "  --update                Update to the latest version"
    echo "  --gen-referral-route    Generate a referral code"
    echo "  --points-route          Check points and rewards"
    echo "  --monitor               Monitor node status"
    echo "  --backup                Create a backup"
    echo "  --restart               Restart the node service"
    echo "  --logs                  View service logs"
    echo "  --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  pop --status            Check node status"
    echo "  pop --update            Update to the latest version"
}

# Main execution
case "$1" in
    --status)
        print_message "Checking node status..."
        ${INSTALL_DIR}/bin/pipe-pop --status
        ;;
    --check-update)
        print_message "Checking for updates..."
        ${INSTALL_DIR}/bin/pipe-pop --check-update
        ;;
    --update)
        print_message "Updating to the latest version..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command must be run as root (with sudo)"
            exit 1
        fi
        ${INSTALL_DIR}/bin/pipe-pop --update
        ;;
    --gen-referral-route)
        print_message "Generating referral code..."
        ${INSTALL_DIR}/bin/pipe-pop --gen-referral-route
        ;;
    --points-route)
        print_message "Checking points and rewards..."
        ${INSTALL_DIR}/bin/pipe-pop --points-route
        ;;
    --monitor)
        print_message "Monitoring node status..."
        ${INSTALL_DIR}/monitor.sh
        ;;
    --backup)
        print_message "Creating backup..."
        ${INSTALL_DIR}/backup.sh
        ;;
    --restart)
        print_message "Restarting node service..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command must be run as root (with sudo)"
            exit 1
        fi
        sudo systemctl restart pipe-pop.service
        print_message "Service restarted."
        ;;
    --logs)
        print_message "Viewing service logs..."
        journalctl -u pipe-pop.service -n 50
        ;;
    --help|*)
        show_help
        ;;
esac

exit 0
EOF

# Make all scripts executable
print_message "Setting executable permissions..."
chmod +x "${INSTALL_DIR}/monitor.sh"
chmod +x "${INSTALL_DIR}/backup.sh"
chmod +x "${INSTALL_DIR}/bin/pipe-pop"
chmod +x "${GLOBAL_CMD}"

# Test the installation
print_message "Testing the installation..."
if [ -f "${GLOBAL_CMD}" ] && [ -x "${GLOBAL_CMD}" ]; then
    print_message "Global pop command installed successfully!"
    print_message "You can now run 'pop --help' from anywhere on your system."
else
    print_error "Failed to install global pop command."
    exit 1
fi

print_header "Installation Complete!"
print_message "The global pop command has been installed and is ready to use."
print_message "Try running 'pop --status' to check your node status."
print_message "Or 'pop --monitor' to monitor your node."
print_message "For a list of all available commands, run 'pop --help'." 