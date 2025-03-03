#!/bin/bash

# Script to check for updates to the Pipe PoP binary
# This script compares the local version with the latest available version

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

# Get the current version
print_message "Checking current version..."
current_version=$(./bin/pipe-pop --version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")

if [ "$current_version" == "unknown" ]; then
    print_warning "Could not determine current version. The binary may be outdated or corrupted."
else
    print_message "Current version: ${current_version}"
fi

# Check the latest version from the official source
print_message "Checking latest available version..."
latest_version=$(curl -s https://api.github.com/repos/pipe-network/pipe-pop/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "unknown")

if [ "$latest_version" == "unknown" ]; then
    print_warning "Could not determine latest version. Please check your internet connection."
    exit 1
fi

print_message "Latest version: ${latest_version}"

# Compare versions
if [ "$current_version" == "$latest_version" ]; then
    print_message "Your Pipe PoP binary is up to date."
elif [ "$current_version" == "unknown" ]; then
    print_warning "Cannot compare versions. Consider updating to the latest version."
else
    print_warning "A new version is available: ${latest_version}"
    print_message "To update, run: sudo ./update_binary.sh <BINARY_URL>"
    print_message "Or use the pop script: sudo ./pop --update"
fi

exit 0 