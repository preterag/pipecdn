#!/bin/bash

# Color codes for output
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
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

# Installation directory
INSTALL_DIR="/opt/pipe-pop"
CONFIG_DIR="${INSTALL_DIR}/config"
CACHE_DIR="${INSTALL_DIR}/cache"
BIN_DIR="${INSTALL_DIR}/bin"

# Create directories with proper permissions
print_message "Creating installation directories..."
mkdir -p "${INSTALL_DIR}" "${CONFIG_DIR}" "${CACHE_DIR}" "${BIN_DIR}"
chmod 755 "${INSTALL_DIR}" "${BIN_DIR}"
chmod 700 "${CONFIG_DIR}" "${CACHE_DIR}"

# Install dependencies
print_message "Installing dependencies..."
apt-get update
apt-get install -y ufw curl jq

# Configure firewall
print_message "Configuring firewall..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8003/tcp
ufw --force enable
ufw reload

# Download latest binary
print_message "Downloading latest pipe-pop binary..."
curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop" -o "${BIN_DIR}/pipe-pop"
chmod 755 "${BIN_DIR}/pipe-pop"

# Create configuration from template
print_message "Creating configuration..."
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    cp "$(dirname "$0")/../config/config.template.json" "${CONFIG_DIR}/config.json"
    chmod 600 "${CONFIG_DIR}/config.json"
fi

# Create systemd service
print_message "Creating systemd service..."
cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
Type=simple
User=root
ExecStart=${BIN_DIR}/pipe-pop
Restart=always
RestartSec=10
Environment=PIPE_CONFIG_DIR=${CONFIG_DIR}
Environment=PIPE_CACHE_DIR=${CACHE_DIR}
Environment=PIPE_REFERRAL_CODE=6ee148015d530fb0

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable pipe-pop.service

print_message "Installation complete!"
print_message "Please run 'sudo ./scripts/setup.sh --wallet YOUR_SOLANA_WALLET_ADDRESS' to configure your node."
print_message "Then start the service with 'sudo systemctl start pipe-pop.service'" 