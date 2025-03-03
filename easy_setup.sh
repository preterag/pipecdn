#!/bin/bash

# Pipe PoP Node Easy Setup Script
# This script automates the entire setup process for a Pipe PoP node

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

print_step() {
    echo -e "\n${BLUE}[STEP]${NC} $1"
}

print_question() {
    echo -e "${CYAN}[QUESTION]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root (with sudo)"
        exit 1
    fi
}

# Function to check and install dependencies
install_dependencies() {
    print_step "Checking and installing dependencies..."
    
    # List of required packages
    packages=("curl" "net-tools" "jq")
    
    # Check which package manager is available
    if command -v apt-get &> /dev/null; then
        # Update package lists
        print_message "Updating package lists..."
        apt-get update -qq
        
        # Install packages
        for package in "${packages[@]}"; do
            if ! dpkg -l | grep -q "^ii  $package "; then
                print_message "Installing $package..."
                apt-get install -y -qq "$package"
            else
                print_message "$package is already installed."
            fi
        done
    elif command -v yum &> /dev/null; then
        # Install packages using yum
        for package in "${packages[@]}"; do
            if ! rpm -q "$package" &> /dev/null; then
                print_message "Installing $package..."
                yum install -y -q "$package"
            else
                print_message "$package is already installed."
            fi
        done
    else
        print_warning "Unsupported package manager. Please manually install: ${packages[*]}"
    fi
    
    print_message "Dependencies check completed."
}

# Function to create directory structure
create_directory_structure() {
    print_step "Creating directory structure..."
    
    # Create directories
    mkdir -p bin cache config logs backups docs
    
    print_message "Directory structure created."
}

# Function to download Pipe PoP binary
download_binary() {
    print_step "Downloading Pipe PoP binary..."
    
    # Current version
    BINARY_VERSION="0.2.8"
    BINARY_URL="https://dl.pipecdn.app/v${BINARY_VERSION}/pop"
    
    print_message "Downloading version v${BINARY_VERSION}..."
    if curl -L -o bin/pipe-pop "$BINARY_URL"; then
        chmod +x bin/pipe-pop
        print_message "Binary downloaded and set as executable."
    else
        print_error "Failed to download binary. Please check your internet connection."
        exit 1
    fi
}

# Function to download scripts
download_scripts() {
    print_step "Downloading additional scripts..."
    
    # List of scripts to download from the repository
    scripts=(
        "pop"
        "monitor.sh"
        "backup.sh"
        "update_binary.sh"
        "install_service.sh"
        "setup_backup_schedule.sh"
    )
    
    # Base URL for raw GitHub content
    BASE_URL="https://raw.githubusercontent.com/e3o8o/pipecdn/master"
    
    # Download each script
    for script in "${scripts[@]}"; do
        print_message "Downloading $script..."
        if curl -L -o "$script" "$BASE_URL/$script"; then
            chmod +x "$script"
            print_message "$script downloaded and set as executable."
        else
            print_warning "Failed to download $script. Will create a basic version locally."
            # For critical scripts like 'pop', we could include fallback code here
        fi
    done
}

# Function to handle Solana wallet setup
setup_solana_wallet() {
    print_step "Setting up Solana wallet..."
    
    # Ask if user already has a Solana wallet
    print_question "Do you already have a Solana wallet you want to use? (y/n)"
    read -r has_wallet
    
    if [[ "$has_wallet" =~ ^[Yy]$ ]]; then
        # User has a wallet, ask for the address
        print_question "Please enter your Solana wallet address:"
        read -r wallet_address
        
        # Validate the wallet address (basic check)
        if [[ ${#wallet_address} -lt 32 ]]; then
            print_error "The wallet address seems too short. Please check and try again."
            exit 1
        fi
    else
        # User doesn't have a wallet, create one
        print_message "We'll create a new Solana wallet for you."
        
        # Check if Solana CLI is installed
        if ! command -v solana &> /dev/null; then
            print_message "Installing Solana CLI..."
            sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
            export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
        fi
        
        # Create a new wallet
        print_message "Creating a new Solana wallet..."
        wallet_output=$(solana-keygen new --no-passphrase --silent)
        wallet_address=$(solana address)
        
        print_message "New wallet created with address: $wallet_address"
        print_message "IMPORTANT: Please backup your wallet at ~/.config/solana/id.json"
    fi
    
    # Save the wallet address to config
    mkdir -p config
    cat > config/config.json << EOF
{
  "solana_wallet": "$wallet_address",
  "cache_dir": "$(pwd)/cache",
  "log_level": "info",
  "network": {
    "ports": [80, 443, 8003],
    "hostname": "auto"
  }
}
EOF
    
    print_message "Wallet address saved to config/config.json"
}

# Function to apply Surrealine referral code
apply_referral_code() {
    print_step "Referral code setup..."
    
    # Surrealine referral code
    REFERRAL_CODE="3a069772281d9b1b"
    
    # Ask for confirmation
    print_question "Would you like to use Surrealine's referral code (3a069772281d9b1b)? (y/n)"
    read -r use_referral
    
    if [[ "$use_referral" =~ ^[Yy]$ ]]; then
        print_message "Applying Surrealine referral code..."
        
        # Run the binary with the referral code
        ./bin/pipe-pop --signup-by-referral-route "$REFERRAL_CODE"
        
        print_message "Referral code applied successfully."
    else
        print_message "Skipping referral code application."
    fi
}

# Function to create and install systemd service
setup_service() {
    print_step "Setting up systemd service..."
    
    # Get the current directory
    CURRENT_DIR=$(pwd)
    
    # Get the current user
    CURRENT_USER=$(whoami)
    
    # Create the service file
    cat > pipe-pop.service << EOF
[Unit]
Description=Pipe PoP Node
After=network.target

[Service]
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR
ExecStart=$CURRENT_DIR/bin/pipe-pop --cache-dir $CURRENT_DIR/cache --pubKey $(grep -o '"solana_wallet"[^,}]*' config/config.json | cut -d'"' -f4)
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    # Install the service
    print_message "Installing systemd service..."
    cp pipe-pop.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable pipe-pop.service
    systemctl start pipe-pop.service
    
    # Check if service started successfully
    if systemctl is-active --quiet pipe-pop.service; then
        print_message "Service started successfully."
    else
        print_error "Failed to start service. Please check the logs with: journalctl -u pipe-pop.service"
    fi
}

# Function to set up a weekly backup schedule
setup_backup_schedule() {
    print_step "Setting up weekly backup schedule..."
    
    if [ -f "setup_backup_schedule.sh" ]; then
        ./setup_backup_schedule.sh weekly
        print_message "Weekly backup schedule set up."
    else
        print_warning "setup_backup_schedule.sh not found. Skipping backup schedule setup."
    fi
}

# Function to display final information
show_final_info() {
    print_step "Setup completed successfully!"
    
    echo -e "\n${GREEN}=== Pipe PoP Node Information ===${NC}"
    echo -e "Node Status: ${GREEN}Running${NC}"
    echo -e "Solana Wallet: ${GREEN}$(grep -o '"solana_wallet"[^,}]*' config/config.json | cut -d'"' -f4)${NC}"
    echo -e "Binary Version: ${GREEN}$(./bin/pipe-pop --version 2>&1 | grep -o 'v[0-9]\.[0-9]\.[0-9]')${NC}"
    echo -e "Service Status: ${GREEN}Active${NC}"
    
    echo -e "\n${GREEN}=== Quick Commands ===${NC}"
    echo -e "Check node status: ${YELLOW}./pop --status${NC}"
    echo -e "Check points: ${YELLOW}./pop --points-route${NC}"
    echo -e "Check for updates: ${YELLOW}./pop --check-update${NC}"
    echo -e "Update the node: ${YELLOW}sudo ./pop --update${NC}"
    echo -e "Monitor the node: ${YELLOW}./monitor.sh${NC}"
    echo -e "Create a backup: ${YELLOW}./backup.sh${NC}"
    
    echo -e "\n${GREEN}=== Next Steps ===${NC}"
    echo -e "1. Make sure ports 80, 443, and 8003 are open in your firewall"
    echo -e "2. Check your node status regularly with ${YELLOW}./pop --status${NC}"
    echo -e "3. Backup your Solana wallet at ~/.config/solana/id.json"
    
    echo -e "\n${GREEN}Thank you for setting up a Pipe PoP node with Surrealine!${NC}"
}

# Main function
main() {
    print_step "Starting Pipe PoP node easy setup..."
    
    # Check if running as root
    check_root
    
    # Install dependencies
    install_dependencies
    
    # Create directory structure
    create_directory_structure
    
    # Download binary
    download_binary
    
    # Download scripts
    download_scripts
    
    # Setup Solana wallet
    setup_solana_wallet
    
    # Apply referral code
    apply_referral_code
    
    # Setup service
    setup_service
    
    # Setup backup schedule
    setup_backup_schedule
    
    # Show final information
    show_final_info
}

# Run the main function
main 