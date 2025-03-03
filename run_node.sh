#!/bin/bash

# Script to manually run the Pipe PoP node
# This is an alternative to using the systemd service

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
if [ ! -f "bin/pipe-pop" ]; then
    print_error "Pipe PoP binary not found. Please run setup.sh first."
    exit 1
fi

# Create log directory if it doesn't exist
mkdir -p logs

# Get current timestamp for log file
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="logs/pipe-pop_${timestamp}.log"

print_message "Starting Pipe PoP node..."
print_message "Logs will be saved to: ${log_file}"
print_message "Press Ctrl+C to stop the node"

# Run the node with output to both console and log file
./bin/pipe-pop --cache-dir "$(pwd)/cache" --enable-80-443 2>&1 | tee -a "${log_file}" 