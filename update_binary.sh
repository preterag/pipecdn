#!/bin/bash

# Script to download and install the actual Pipe PoP binary
# Usage: ./update_binary.sh [BINARY_URL]

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

# Check if URL is provided
if [ $# -ne 1 ]; then
    print_error "Usage: $0 BINARY_URL"
    print_error "Example: $0 https://pipe.network/downloads/pipe-pop-linux-amd64"
    exit 1
fi

BINARY_URL=$1

# Create backup of current binary
print_message "Creating backup of current binary..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p backups/bin
cp bin/pipe-pop "backups/bin/pipe-pop_${TIMESTAMP}"
print_message "Backup created: backups/bin/pipe-pop_${TIMESTAMP}"

# Download the new binary
print_message "Downloading new binary from ${BINARY_URL}..."
if curl -L "${BINARY_URL}" -o bin/pipe-pop.new; then
    print_message "Download completed successfully."
else
    print_error "Failed to download binary. Please check the URL and try again."
    exit 1
fi

# Make the new binary executable
print_message "Setting executable permissions..."
chmod +x bin/pipe-pop.new

# Test the new binary
print_message "Testing the new binary..."
if ./bin/pipe-pop.new --version; then
    print_message "Binary test successful."
else
    print_error "Binary test failed. Restoring backup..."
    cp "backups/bin/pipe-pop_${TIMESTAMP}" bin/pipe-pop
    print_message "Backup restored. Please check the binary URL and try again."
    rm bin/pipe-pop.new
    exit 1
fi

# Replace the old binary with the new one
print_message "Replacing old binary with new one..."
mv bin/pipe-pop.new bin/pipe-pop

# Restart the service if it's running
if systemctl is-active --quiet pipe-pop.service; then
    print_message "Restarting the Pipe PoP service..."
    sudo systemctl restart pipe-pop.service
    
    # Check if service started successfully
    if systemctl is-active --quiet pipe-pop.service; then
        print_message "Service restarted successfully."
    else
        print_error "Failed to restart service. Please check the logs."
        exit 1
    fi
else
    print_warning "Pipe PoP service is not running. No need to restart."
fi

print_message "Binary update completed successfully!"
print_message "You can now run the node with the new binary." 