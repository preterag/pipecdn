#!/bin/bash

# Test Script for Pipe PoP Node Easy Setup
# This script validates the setup script for functionality and errors.

set -e

TEST_LOG="/tmp/test_pipe_pop_setup.log"
exec > >(tee -a "$TEST_LOG") 2>&1

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_failure() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    log_failure "This script must be run as root. Use sudo."
fi

# Test log file creation
echo "Testing log file creation..."
LOG_FILE="/var/log/pipe-pop-setup_$(date +%Y%m%d_%H%M%S).log"
mkdir -p /var/log/
touch "$LOG_FILE" && log_success "Log file created: $LOG_FILE" || log_failure "Failed to create log file."

# Test dependency installation
echo "Testing package installation..."
REQUIRED_PACKAGES=(curl net-tools jq git)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    dpkg -s "$pkg" &>/dev/null && log_success "$pkg is installed." || log_failure "$pkg is missing."
done

# Test Pipe PoP installation
echo "Testing Pipe PoP setup..."
INSTALL_DIR="/opt/pipe-pop"
[ -d "$INSTALL_DIR" ] && log_success "Pipe PoP directory exists." || log_failure "Pipe PoP directory missing."
[ -d "$INSTALL_DIR/.git" ] && log_success "Git repository exists." || log_failure "Git repository missing."

# Test Solana installation
echo "Testing Solana CLI setup..."
command -v solana &>/dev/null && log_success "Solana CLI installed." || log_failure "Solana CLI not found."

# Test systemd service setup
echo "Testing systemd service..."
systemctl is-active --quiet pipe-pop && log_success "Pipe PoP service is running." || log_failure "Pipe PoP service failed."

# Test global command installation
echo "Testing global command..."
command -v pop &>/dev/null && log_success "Global command 'pop' installed." || log_failure "'pop' command missing."
command -v pop-update &>/dev/null && log_success "Global command 'pop-update' installed." || log_failure "'pop-update' command missing."

log_success "All tests passed successfully!"
