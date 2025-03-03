#!/bin/bash

# Pipe PoP Node Setup Script
# Version: 1.0.0
#
# This script helps set up a Pipe PoP node
#
# NOTE: This is a non-interactive setup script. If you prefer a more
# user-friendly guided installation with interactive prompts, please
# use easy_setup.sh instead.
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

set -e

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

# Display version information
print_message "Pipe PoP Setup Tool v1.0.0"

# Check and install dependencies
check_dependencies() {
    print_message "Checking dependencies..."
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_warning "curl is not installed. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl
        else
            print_error "Could not install curl. Please install it manually and run this script again."
            exit 1
        fi
    fi
    
    print_message "Dependencies check passed."
}

# Check system requirements
check_system_requirements() {
    print_message "Checking system requirements..."
    
    # Check RAM
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    available_ram=$(free -m | awk '/^Mem:/{print $7}')
    
    if [ "$available_ram" -lt 2048 ]; then
        print_warning "Available RAM is less than 2GB. This might affect performance."
    else
        print_message "RAM check passed: ${available_ram}MB available out of ${total_ram}MB total."
    fi
    
    # Check disk space
    disk_space=$(df -m . | awk 'NR==2 {print $4}')
    
    if [ "$disk_space" -lt 10240 ]; then
        print_warning "Available disk space is less than 10GB. This might not be enough for long-term operation."
    else
        print_message "Disk space check passed: ${disk_space}MB available."
    fi
}

# Install Solana CLI if not already installed
install_solana_cli() {
    if ! command -v solana &> /dev/null; then
        print_message "Installing Solana CLI..."
        
        # Make sure curl is available
        if ! command -v curl &> /dev/null; then
            print_error "curl is required but not installed. Please install curl and try again."
            exit 1
        fi
        
        sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
        export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc
        print_message "Solana CLI installed successfully."
        print_message "Please run 'source ~/.bashrc' or restart your terminal to use Solana CLI."
        
        # Source the updated PATH
        source ~/.bashrc
    else
        print_message "Solana CLI is already installed."
    fi
}

# Create or import Solana wallet
setup_solana_wallet() {
    print_message "Setting up Solana wallet..."
    
    # Make sure solana-keygen is available
    if ! command -v solana-keygen &> /dev/null; then
        if [ -f "$HOME/.local/share/solana/install/active_release/bin/solana-keygen" ]; then
            export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        else
            print_error "solana-keygen not found. Please ensure Solana CLI is installed correctly."
            exit 1
        fi
    fi
    
    if [ -f "$HOME/.config/solana/id.json" ]; then
        print_message "Solana wallet already exists."
        solana address
    else
        print_message "Creating new Solana wallet..."
        solana-keygen new --no-passphrase
        print_message "Solana wallet created successfully."
        solana address
    fi
}

# Download and install Pipe PoP binary
install_pipe_pop() {
    print_message "Downloading Pipe PoP binary..."
    
    # Create bin directory if it doesn't exist
    mkdir -p bin
    
    # Download the latest binary (URL needs to be updated with the actual source)
    # This is a placeholder - replace with actual download URL
    curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop-linux-amd64" -o bin/pipe-pop
    
    # Make it executable
    chmod +x bin/pipe-pop
    
    print_message "Pipe PoP binary installed successfully."
}

# Create systemd service file
create_systemd_service() {
    print_message "Creating systemd service file..."
    
    cat > pipe-pop.service << EOF
[Unit]
Description=Pipe PoP Node
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/bin/pipe-pop --cache-dir $(pwd)/cache
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    print_message "Systemd service file created: pipe-pop.service"
    print_message "To install the service, run:"
    print_message "sudo cp pipe-pop.service /etc/systemd/system/"
    print_message "sudo systemctl daemon-reload"
    print_message "sudo systemctl enable pipe-pop.service"
    print_message "sudo systemctl start pipe-pop.service"
}

# Main execution
main() {
    print_message "Starting Pipe PoP node setup..."
    
    check_dependencies
    check_system_requirements
    install_solana_cli
    setup_solana_wallet
    install_pipe_pop
    create_systemd_service
    
    print_message "Setup completed successfully!"
    print_message "Please follow the instructions above to start the Pipe PoP node service."
}

# Run the main function
main 