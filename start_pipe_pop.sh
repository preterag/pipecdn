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

# Directory paths
PIPE_DIR="/home/karo/Workspace/PipeNetwork"
NODE_INFO="${PIPE_DIR}/node_info.json"
CACHE_DIR="${PIPE_DIR}/cache"
BINARY="${PIPE_DIR}/bin/pipe-pop"
PUBKEY="H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8"

# Ensure UFW is installed and ports are open
print_message "Ensuring firewall ports are open..."
if ! command -v ufw &> /dev/null; then
    print_message "Installing UFW..."
    apt-get update
    apt-get install -y ufw
fi

# Enable UFW if not already enabled
if ! ufw status | grep -q "Status: active"; then
    print_message "Enabling UFW..."
    ufw --force enable
fi

# Open required ports
print_message "Opening required ports..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8003/tcp
ufw reload

print_message "Firewall status:"
ufw status

# Create a valid node_info.json file
print_message "Setting up node_info.json..."
NODE_ID="d058ae47-05c5-44d9-b642-53f11719d474"

# Create a new node_info.json with registered set to true
cat > "$NODE_INFO" << EOF
{
  "node_id": "$NODE_ID",
  "registered": true,
  "token": "temporary_token_to_bypass_registration",
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
print_message "Created node_info.json with temporary registration"

# Start the Pipe PoP node
print_message "Starting Pipe PoP node..."
exec "$BINARY" --cache-dir "$CACHE_DIR" --pubKey "$PUBKEY" 