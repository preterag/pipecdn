#!/bin/bash

# Pipe PoP Easy Setup Script (v1.1.0)
# Interactive setup script for Pipe Network PoP nodes

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}=== $1 ===${NC}"; }

# Welcome message
clear
cat << "EOF"
╔════════════════════════════════════════════════════════╗
║             Welcome to Pipe Network Setup              ║
║        Your Gateway to Decentralized Content           ║
╚════════════════════════════════════════════════════════╝
EOF

echo -e "\nThis script will guide you through setting up your Pipe Network PoP node."
echo -e "You'll earn rewards for helping distribute content across the network.\n"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

# Function to check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    # Check CPU cores
    CPU_CORES=$(nproc)
    if [ "$CPU_CORES" -lt 2 ]; then
        print_warning "Your system has less than 2 CPU cores (Found: $CPU_CORES)"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_message "CPU cores: OK (Found: $CPU_CORES)"
    fi
    
    # Check RAM
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 4000 ]; then
        print_warning "Your system has less than 4GB RAM (Found: ${TOTAL_RAM}MB)"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_message "RAM: OK (Found: ${TOTAL_RAM}MB)"
    fi
    
    # Check disk space
    FREE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$FREE_SPACE" -lt 20 ]; then
        print_warning "You have less than 20GB free space (Found: ${FREE_SPACE}GB)"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_message "Disk space: OK (Found: ${FREE_SPACE}GB free)"
    fi
}

# Function to install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    print_message "Updating package list..."
    apt-get update
    
    print_message "Installing required packages..."
    apt-get install -y curl jq ufw
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Function to configure firewall
configure_firewall() {
    print_header "Configuring Firewall"
    
    print_message "Setting up UFW rules..."
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 8003/tcp
    
    print_message "Enabling firewall..."
    ufw --force enable
    ufw reload
    
    print_message "Firewall configured successfully"
}

# Function to get wallet address
get_wallet_address() {
    print_header "Wallet Configuration"
    
    echo -e "\nYou'll need a Solana wallet address to receive rewards."
    echo -e "If you don't have one, you can create one at https://phantom.app\n"
    
    while true; do
        read -p "Enter your Solana wallet address: " WALLET_ADDRESS
        
        if [[ $WALLET_ADDRESS =~ ^[1-9A-HJ-NP-Za-km-z]{32,44}$ ]]; then
            break
        else
            print_error "Invalid wallet address format. Please try again."
        fi
    done
    
    # Save wallet address
    echo "PIPE_WALLET_ADDRESS=$WALLET_ADDRESS" > /etc/pipe-pop.env
    echo "PIPE_REFERRAL_CODE=6ee148015d530fb0" >> /etc/pipe-pop.env
    chmod 600 /etc/pipe-pop.env
}

# Function to configure node
configure_node() {
    print_header "Node Configuration"
    
    # Create installation directory
    INSTALL_DIR="/opt/pipe-pop"
    mkdir -p "${INSTALL_DIR}"/{bin,config,cache}
    
    # Download latest binary
    print_message "Downloading Pipe Network binary..."
    curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop" -o "${INSTALL_DIR}/bin/pipe-pop"
    chmod 755 "${INSTALL_DIR}/bin/pipe-pop"
    
    # Create configuration
    print_message "Creating configuration..."
    cat > "${INSTALL_DIR}/config/config.json" << EOF
{
  "node": {
    "wallet_address": "${WALLET_ADDRESS}",
    "cache_dir": "${INSTALL_DIR}/cache",
    "log_level": "info"
  },
  "network": {
    "ports": {
      "http": 80,
      "https": 443,
      "api": 8003
    }
  },
  "referral": {
    "code": "6ee148015d530fb0",
    "enabled": true
  }
}
EOF
    chmod 600 "${INSTALL_DIR}/config/config.json"
    
    # Create systemd service
    print_message "Creating service..."
    cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
Type=simple
User=root
ExecStart=${INSTALL_DIR}/bin/pipe-pop
Restart=always
RestartSec=10
EnvironmentFile=/etc/pipe-pop.env

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable pipe-pop.service
}

# Function to setup monitoring
setup_monitoring() {
    print_header "Setting Up Monitoring"
    
    # Create monitoring directory
    mkdir -p "${INSTALL_DIR}/monitoring"
    
    # Install monitoring script
    print_message "Installing monitoring tools..."
    ln -sf "${INSTALL_DIR}/tools/pop" /usr/local/bin/pop
    
    print_message "You can now use 'pop' commands globally"
}

# Main installation process
check_requirements

echo -e "\nReady to start installation? This will:"
echo "1. Install required dependencies"
echo "2. Configure firewall rules"
echo "3. Set up your wallet"
echo "4. Install and configure the node"
echo "5. Set up monitoring tools"

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

install_dependencies
configure_firewall
get_wallet_address
configure_node
setup_monitoring

# Start the service
print_header "Starting Service"
systemctl start pipe-pop.service

# Final instructions
print_header "Setup Complete!"
echo -e "\nYour Pipe Network node is now running!"
echo -e "\nUseful commands:"
echo "  pop status         - Check node status"
echo "  pop monitoring pulse  - Monitor node in real-time"
echo "  pop help          - Show all available commands"
echo -e "\nView logs:"
echo "  pop monitoring logs"
echo -e "\nNeed help? Join our community:"
echo "  Discord: https://discord.gg/pipenetwork"
echo "  GitHub: https://github.com/pipe-network/pipe-pop"
echo -e "\nHappy earning! 🚀\n" 