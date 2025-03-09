#!/bin/bash

# Script to open the required ports for pipe-pop
# Version: 1.0.0 (Deprecated)
#
# DEPRECATION NOTICE: This script is deprecated and will be removed in a future update.
# Please use fix_ports.sh instead, which provides more comprehensive port configuration
# and troubleshooting functionality.

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

# Display deprecation warning
print_warning "DEPRECATION NOTICE: This script is deprecated (v1.0.0)."
print_warning "Please use fix_ports.sh (v1.1.0) instead, which provides more comprehensive functionality."
print_message "Redirecting to fix_ports.sh..."

# Check if fix_ports.sh exists
if [ -f "fix_ports.sh" ]; then
    # Execute fix_ports.sh with the same arguments
    chmod +x fix_ports.sh
    ./fix_ports.sh "$@"
else
    print_error "fix_ports.sh not found. Please download the latest version from the repository."
    exit 1
fi 