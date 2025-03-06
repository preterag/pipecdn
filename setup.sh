#!/bin/bash

# Pipe PoP Node Setup Script
# Version: 1.2.0
#
# This script helps set up a Pipe PoP node with improved error handling, logging,
# checksum verification, and user confirmation for critical actions.
#
# NOTE: This is a non-interactive setup script. For a guided installation, use easy_setup.sh.
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines.

set -e # Exit immediately on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log file setup
LOGFILE="/var/log/pipe-pop-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Prevent multiple instances
LOCKFILE="/tmp/pipe-pop-setup.lock"
if [ -f "$LOCKFILE" ]; then
    echo -e "${RED}[ERROR]${NC} Another instance is already running. Exiting."
    exit 1
fi
touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

# Cleanup function for graceful shutdown
cleanup() {
    echo -e "${YELLOW}[WARNING]${NC} An error occurred. Cleaning up..."
    exit 1
}
trap cleanup ERR SIGINT SIGTERM

# Function to print messages
print_message() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "Troubleshooting:"
    echo "- Check internet connection."
    echo "- Verify permissions (use sudo if necessary)."
    echo "- Review the log: $LOGFILE"
    exit 1
}

# User confirmation prompt
confirm_action() {
    read -p "Do you want to proceed? (y/n): " choice
    case "$choice" in
        y|Y ) print_message "Proceeding...";;
        n|N ) print_warning "Action canceled by user."; exit 0;;
        * ) print_warning "Invalid choice."; confirm_action;;
    esac
}

print_message "This script will install Pipe PoP and modify system settings."
confirm_action

# Display version information
print_message "Pipe PoP Setup Tool v1.2.0"

# Check and install dependencies
check_dependencies() {
    print_message "Checking dependencies..."
    for cmd in curl awk df free sha256sum; do
        if ! command -v $cmd &> /dev/null; then
            print_warning "$cmd is not installed. Attempting to install..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y $cmd
            elif command -v yum &> /dev/null; then
                sudo yum install -y $cmd
            else
                print_error "Could not install $cmd. Please install it manually."
            fi
        fi
    done
    print_message "Dependencies check passed."
}

# Check system requirements
check_system_requirements() {
    print_message "Checking system requirements..."
    
    # RAM check
    total_ram=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    available_ram=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    available_ram_mb=$((available_ram / 1024))
    total_ram_mb=$((total_ram / 1024))

    if [ "$available_ram_mb" -lt 2048 ]; then
        print_warning "Available RAM is less than 2GB ($available_ram_mb MB). This might affect performance."
    else
        print_message "RAM check passed: $available_ram_mb MB available out of $total_ram_mb MB total."
    fi

    # Disk space check
    disk_space=$(df -m / | awk 'NR==2 {print $4}')
    if [ "$disk_space" -lt 10240 ]; then
        print_warning "Available disk space is less than 10GB ($disk_space MB)."
    else
        print_message "Disk space check passed: $disk_space MB available."
    fi
}

# Install Solana CLI
install_solana_cli() {
    if ! command -v solana &> /dev/null; then
        print_message "Installing Solana CLI..."
        curl -sSfL https://release.solana.com/stable/install | sh
        SOLANA_BIN="$HOME/.local/share/solana/install/active_release/bin"
        export PATH="$SOLANA_BIN:$PATH"
        echo "export PATH=\"$SOLANA_BIN:\$PATH\"" | tee -a ~/.bashrc ~/.profile ~/.zshrc
        source ~/.bashrc
        print_message "Solana CLI installed successfully."
    else
        print_message "Solana CLI is already installed."
    fi
}

# Setup Solana Wallet
setup_solana_wallet() {
    print_message "Setting up Solana wallet..."
    if [ -f "$HOME/.config/solana/id.json" ]; then
        print_message "Solana wallet already exists."
        solana address
    else
        print_message "Creating new Solana wallet..."
        solana-keygen new --no-passphrase
        solana address
    fi
}

# Install Pipe PoP Binary with Checksum Verification
install_pipe_pop() {
    print_message "Downloading Pipe PoP binary..."
    INSTALL_DIR="/usr/local/bin"
    sudo mkdir -p "$INSTALL_DIR"

    # Define expected checksum (replace with actual checksum from release)
    EXPECTED_CHECKSUM="abc123xyz456"  # Replace with the actual SHA-256 checksum

    # Download the binary
    sudo curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop-linux-amd64" -o "$INSTALL_DIR/pipe-pop"

    # Verify checksum
    ACTUAL_CHECKSUM=$(sha256sum "$INSTALL_DIR/pipe-pop" | awk '{print $1}')
    if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
        print_error "Checksum verification failed! Expected: $EXPECTED_CHECKSUM, Got: $ACTUAL_CHECKSUM"
    fi

    sudo chmod +x "$INSTALL_DIR/pipe-pop"
    print_message "Pipe PoP binary installed successfully."
}

# Create Systemd Service
create_systemd_service() {
    print_message "Creating systemd service file..."
    
    SERVICE_FILE="/etc/systemd/system/pipe-pop.service"
    cat <<EOF | sudo tee "$SERVICE_FILE"
[Unit]
Description=Pipe PoP Node
After=network.target

[Service]
User=$(whoami)
ExecStart=/usr/local/bin/pipe-pop --cache-dir /var/lib/pipe-pop --enable-80-443
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=append:/var/log/pipe-pop.log
StandardError=append:/var/log/pipe-pop.log

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable pipe-pop.service
    sudo systemctl start pipe-pop.service
    print_message "Pipe PoP service installed and started."
}

# Main Execution
main() {
    print_message "Starting Pipe PoP node setup..."
    check_dependencies
    check_system_requirements
    install_solana_cli
    setup_solana_wallet
    install_pipe_pop
    create_systemd_service
    print_message "Setup completed successfully!"
}

# Run main function
main
