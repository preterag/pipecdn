#!/bin/bash

# Pipe PoP Node Easy Setup Script
# This script provides a one-command setup for the Pipe PoP node

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

# Welcome message
clear
print_header "Pipe PoP Node Easy Setup"
echo ""
print_message "Welcome to the Pipe PoP Node Easy Setup!"
print_message "This script will guide you through setting up a Pipe PoP node for the Pipe Network decentralized CDN."
echo ""
print_message "The setup will:"
echo "  - Install all necessary dependencies"
echo "  - Set up your Solana wallet (or use your existing one)"
echo "  - Download and configure the Pipe PoP binary"
echo "  - Set up a systemd service for reliable operation"
echo "  - Configure automatic backups"
echo "  - Apply the Surrealine referral code (optional)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Create a temporary directory for the setup
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Step 1: Check system requirements
print_header "Checking System Requirements"

# Check RAM
total_ram=$(free -m | awk '/^Mem:/{print $2}')
available_ram=$(free -m | awk '/^Mem:/{print $7}')

if [ "$available_ram" -lt 2048 ]; then
    print_warning "Available RAM is less than 2GB (${available_ram}MB). This might affect performance."
else
    print_message "RAM check passed: ${available_ram}MB available out of ${total_ram}MB total."
fi

# Check disk space
disk_space=$(df -m . | awk 'NR==2 {print $4}')

if [ "$disk_space" -lt 10240 ]; then
    print_warning "Available disk space is less than 10GB (${disk_space}MB). This might not be enough for long-term operation."
else
    print_message "Disk space check passed: ${disk_space}MB available."
fi

# Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_message "Operating System: $PRETTY_NAME"
else
    print_warning "Could not determine OS version."
fi

# Step 2: Install dependencies
print_header "Installing Dependencies"

print_message "Updating package lists..."
apt-get update

print_message "Installing required packages..."
apt-get install -y curl net-tools jq

# Step 3: Clone the repository
print_header "Setting Up Pipe PoP Node"

print_message "Creating installation directory..."
INSTALL_DIR="/opt/pipe-pop"
mkdir -p "$INSTALL_DIR"

print_message "Downloading Pipe PoP node files..."
git clone https://github.com/preterag/pipecdn.git "$INSTALL_DIR" || {
    print_message "Repository already exists, updating instead..."
    cd "$INSTALL_DIR"
    git pull
}

cd "$INSTALL_DIR"

# Step 4: Set up Solana wallet
print_header "Setting Up Solana Wallet"

print_message "Installing Solana CLI..."
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc

# Ask if user wants to use an existing wallet or create a new one
echo ""
print_message "Solana wallet setup:"
echo "  1) Create a new wallet"
echo "  2) Use an existing wallet address"
echo ""
read -p "Enter your choice (1/2): " wallet_choice

SOLANA_WALLET=""

if [ "$wallet_choice" = "1" ]; then
    print_message "Creating new Solana wallet..."
    solana-keygen new --no-passphrase
    SOLANA_WALLET=$(solana address)
    print_message "Wallet created with address: $SOLANA_WALLET"
else
    read -p "Enter your Solana wallet address: " SOLANA_WALLET
    print_message "Using wallet address: $SOLANA_WALLET"
fi

# Step 5: Download and configure the Pipe PoP binary
print_header "Setting Up Pipe PoP Binary"

print_message "Creating directories..."
mkdir -p bin cache config logs backups

print_message "Downloading Pipe PoP binary..."
curl -L -o bin/pipe-pop https://dl.pipecdn.app/v0.2.8/pop
chmod +x bin/pipe-pop

print_message "Creating configuration file..."
cat > config/config.json << EOF
{
  "solana_wallet": "$SOLANA_WALLET",
  "cache_dir": "$INSTALL_DIR/cache",
  "log_level": "info",
  "network": {
    "ports": [80, 443, 8003],
    "hostname": "auto"
  }
}
EOF

# Step 6: Ask about referral code
print_header "Referral Code Setup"

echo ""
print_message "Would you like to use the Surrealine referral code?"
echo "Using a referral code helps support the Surrealine platform and benefits your node."
echo ""
read -p "Use Surrealine referral code? (y/n): " use_referral

if [ "$use_referral" = "y" ] || [ "$use_referral" = "Y" ]; then
    print_message "Signing up with Surrealine referral code..."
    ./bin/pipe-pop --signup-by-referral-route 3a069772281d9b1b
    print_message "Referral code applied successfully."
else
    print_message "Skipping referral code."
fi

# Step 7: Set up systemd service
print_header "Setting Up Systemd Service"

print_message "Creating systemd service file..."
cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=Pipe PoP Node
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/bin/pipe-pop --cache-dir $INSTALL_DIR/cache --pubKey $SOLANA_WALLET
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

print_message "Enabling and starting the service..."
systemctl daemon-reload
systemctl enable pipe-pop.service
systemctl start pipe-pop.service

# Step 8: Set up backup schedule
print_header "Setting Up Backup Schedule"

print_message "Setting up weekly backups..."
chmod +x setup_backup_schedule.sh
./setup_backup_schedule.sh weekly

# Step 9: Final steps
print_header "Setup Complete"

print_message "Pipe PoP node has been successfully set up!"
print_message "You can manage your node using the following commands:"
echo ""
echo "  Check node status:    $INSTALL_DIR/pop --status"
echo "  Monitor node:         $INSTALL_DIR/pop --monitor"
echo "  Create backup:        $INSTALL_DIR/pop --backup"
echo "  Check for updates:    $INSTALL_DIR/pop --check-update"
echo "  Update node:          sudo $INSTALL_DIR/pop --update"
echo "  View logs:            $INSTALL_DIR/pop --logs"
echo ""
print_message "For more information, refer to the documentation in the $INSTALL_DIR/docs directory."
echo ""
print_message "Thank you for joining the Pipe Network ecosystem!"

# Clean up
rm -rf "$TEMP_DIR"

exit 0 