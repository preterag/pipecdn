#!/bin/bash

# Script to install the pop command globally
# This will allow you to run the pop command from anywhere

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Get the current directory
CURRENT_DIR=$(pwd)
INSTALL_DIR="/opt/pipe-pop"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

print_header "Installing Global Pop Command"
print_message "Installing pop command for system-wide access..."

# Create a modified version of the pop script that uses absolute paths
cat > /usr/local/bin/pop << 'EOF'
#!/bin/bash

# Pipe PoP Node Management Script
# This script provides a convenient wrapper around the pipe-pop binary

# Installation directory
INSTALL_DIR="/opt/pipe-pop"

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

# Make the script executable
chmod +x /usr/local/bin/pop

print_message "Creating installation directory if it doesn't exist..."
mkdir -p ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}/bin
mkdir -p ${INSTALL_DIR}/config
mkdir -p ${INSTALL_DIR}/logs
mkdir -p ${INSTALL_DIR}/backups
mkdir -p ${INSTALL_DIR}/cache

# Check if we're in the PipeNetwork directory
if [ -f "./bin/pipe-pop" ]; then
    print_message "Found Pipe PoP installation in current directory."
    
    # Copy necessary files to the installation directory
    print_message "Copying files to ${INSTALL_DIR}..."
    cp -r ./bin/* ${INSTALL_DIR}/bin/
    
    if [ -f "./monitor.sh" ]; then
        cp ./monitor.sh ${INSTALL_DIR}/
        chmod +x ${INSTALL_DIR}/monitor.sh
    fi
    
    if [ -f "./backup.sh" ]; then
        cp ./backup.sh ${INSTALL_DIR}/
        chmod +x ${INSTALL_DIR}/backup.sh
    fi
    
    if [ -d "./config" ]; then
        cp -r ./config/* ${INSTALL_DIR}/config/
    fi
    
    print_highlight "Installation complete!"
    print_highlight "You can now run the 'pop' command from anywhere on your system."
else
    print_warning "Current directory doesn't seem to be a Pipe PoP installation."
    print_warning "Please run this script from your PipeNetwork directory."
    
    # Ask for the location of the PipeNetwork directory
    read -p "Enter the path to your PipeNetwork directory (or press Enter to cancel): " pipe_dir
    
    if [ -z "$pipe_dir" ]; then
        print_error "Installation cancelled."
        # Remove the script we created
        rm -f /usr/local/bin/pop
        exit 1
    fi
    
    if [ -f "${pipe_dir}/bin/pipe-pop" ]; then
        print_message "Found Pipe PoP installation in ${pipe_dir}."
        
        # Copy necessary files to the installation directory
        print_message "Copying files to ${INSTALL_DIR}..."
        cp -r ${pipe_dir}/bin/* ${INSTALL_DIR}/bin/
        
        if [ -f "${pipe_dir}/monitor.sh" ]; then
            cp ${pipe_dir}/monitor.sh ${INSTALL_DIR}/
            chmod +x ${INSTALL_DIR}/monitor.sh
        fi
        
        if [ -f "${pipe_dir}/backup.sh" ]; then
            cp ${pipe_dir}/backup.sh ${INSTALL_DIR}/
            chmod +x ${INSTALL_DIR}/backup.sh
        fi
        
        if [ -d "${pipe_dir}/config" ]; then
            cp -r ${pipe_dir}/config/* ${INSTALL_DIR}/config/
        fi
        
        print_highlight "Installation complete!"
        print_highlight "You can now run the 'pop' command from anywhere on your system."
    else
        print_error "Invalid directory. Installation cancelled."
        # Remove the script we created
        rm -f /usr/local/bin/pop
        exit 1
    fi
fi

# Test the global pop command
print_header "Testing Global Pop Command"
print_message "Running a quick test of the global pop command..."
if command -v pop &> /dev/null; then
    print_highlight "Success! The global 'pop' command is installed and accessible."
    echo "Try it now with: pop --help"
else
    print_warning "The global 'pop' command may not be accessible. Please check your PATH settings."
    print_message "You can still use it with the full path: /usr/local/bin/pop"
fi

print_message "To test, try running: pop --status" 