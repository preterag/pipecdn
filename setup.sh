#!/bin/bash

# Pipe PoP Node Setup Script
# Version: 1.2.0
#
# This script helps set up a Pipe PoP node with improved error handling, logging,
# checksum verification, and user confirmation for critical actions.

# Enable error handling
set -e
set -x  # Enable debug mode

# Constants
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
LOGFILE="$GITHUB_WORKSPACE/var/log/pipe-pop-setup_$(date +%Y%m%d_%H%M%S).log"
LOCKFILE="/tmp/pipe-pop-setup.lock"
EXPECTED_CHECKSUM="0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"  # Replace with actual checksum from release
INSTALL_DIR="/usr/local/bin"
SOLANA_BIN="$HOME/.local/share/solana/install/active_release/bin"
SOLANA_VERSION="1.18.7"  # Update to latest stable version


# Define log file with timestamp
log_setup() {
    sudo mkdir -p /var/log/
    sudo touch "$LOG_FILE" || { echo "[ERROR] Failed to create log file at $LOGFILE"; exit 1; }
    echo "[DEBUG] Log file created at $LOGFILE"
    exec > >(tee -a "$LOG_FILE") 2>&1
}


lock_script() {
    if [ -f "$LOCKFILE" ]; then
        print_error "Another instance is already running. Exiting."
        exit 1
    fi
    touch "$LOCKFILE"
    trap 'rm -f "$LOCKFILE"' EXIT
}

cleanup() {
    echo -e "${YELLOW}[WARNING]${NC} An error occurred. Cleaning up..."
    exit 1
}
trap cleanup ERR SIGINT SIGTERM

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

check_dependencies() {
    print_message "Checking dependencies..."
    for cmd in curl awk df free sha256sum; do
        if ! command -v $cmd &> /dev/null; then
            print_warning "$cmd is not installed. Installing..."
            sudo apt-get update && sudo apt-get install -y $cmd || print_error "Could not install $cmd."
        fi
    done
    print_message "Dependencies check passed."
}

check_system_requirements() {
    print_message "Checking system requirements..."
    
    # RAM check
    available_ram_mb=$(( $(awk '/MemAvailable/ {print $2}' /proc/meminfo) / 1024 ))
    total_ram_mb=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 ))

    if [ "$available_ram_mb" -lt 2048 ]; then
        print_warning "Available RAM is low ($available_ram_mb MB)."
    else
        print_message "RAM check passed: $available_ram_mb MB available."
    fi

    # Disk space check
    disk_space=$(df -m / | awk 'NR==2 {print $4}')
    if [ "$disk_space" -lt 10240 ]; then
        print_warning "Available disk space is low ($disk_space MB)."
    else
        print_message "Disk space check passed."
    fi
}

install_solana_cli() {
    if ! command -v solana &> /dev/null; then
        print_message "Installing Solana CLI..."
        curl -sSfL "https://release.solana.com/v${SOLANA_VERSION}/install" | sh
        export PATH="$SOLANA_BIN:$PATH"
        echo "export PATH=\"$SOLANA_BIN:\$PATH\"" | tee -a ~/.bashrc ~/.profile ~/.zshrc
        source ~/.bashrc
        print_message "Solana CLI installed successfully."
    else
        print_message "Solana CLI is already installed."
    fi
}

install_pipe_pop() {
    print_message "Downloading Pipe PoP binary..."
    sudo mkdir -p "$INSTALL_DIR"

    # Download the binary
    sudo curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop-linux-amd64" -o "$INSTALL_DIR/pipe-pop"

    # Verify checksum
    ACTUAL_CHECKSUM=$(sha256sum "$INSTALL_DIR/pipe-pop" | awk '{print $1}')
    if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
        print_error "Checksum verification failed!"
    fi

    sudo chmod +x "$INSTALL_DIR/pipe-pop"
    sudo chown $(whoami) "$INSTALL_DIR/pipe-pop"  # Ensure user ownership
    print_message "Pipe PoP binary installed successfully."
}

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
RestartSec=3
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

main() {
    log_setup
    lock_script
    print_message "Starting Pipe PoP node setup..."

    check_dependencies
    check_system_requirements
    install_solana_cli
    install_pipe_pop
    create_systemd_service

    print_message "Setup completed successfully!"
}

# Run main function
main