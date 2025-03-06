#!/bin/bash

# Pipe PoP Setup Test Suite
# This script tests the functionality of setup.sh

TEST_LOGFILE="/tmp/pipe-pop-test.log"
SETUP_SCRIPT="${GITHUB_WORKSPACE}/setup.sh"  # Set path to setup.sh

# Ensure the setup.sh script is executable
chmod +x "$SETUP_SCRIPT"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print test results
pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# Cleanup before running tests
cleanup() {
    sudo systemctl stop pipe-pop.service &> /dev/null || true
    sudo systemctl disable pipe-pop.service &> /dev/null || true
    sudo rm -f /usr/local/bin/pipe-pop /etc/systemd/system/pipe-pop.service
    sudo rm -f "$TEST_LOGFILE"
}
trap cleanup EXIT

# Test 1: Verify script existence
test_script_exists() {
    [ -f "$SETUP_SCRIPT" ] && pass "setup.sh exists." || fail "setup.sh not found!"
}

# Test 2: Run script and capture output
test_script_runs() {
    bash "$SETUP_SCRIPT" > "$TEST_LOGFILE" 2>&1 && pass "setup.sh executed successfully." || fail "setup.sh failed to execute."
}

# Test 3: Check dependencies
test_dependencies() {
    for cmd in curl awk df free sha256sum; do
        command -v "$cmd" &> /dev/null && pass "$cmd is installed." || fail "$cmd is missing!"
    done
}

# Test 4: Check system requirements
test_system_requirements() {
    available_ram=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    disk_space=$(df -m / | awk 'NR==2 {print $4}')
    
    [ "$available_ram" -gt 2048 ] && pass "RAM check passed." || fail "Low RAM: $available_ram KB"
    [ "$disk_space" -gt 10240 ] && pass "Disk space check passed." || fail "Low disk space: $disk_space MB"
}

# Test 5: Verify Pipe PoP binary download
test_pipe_pop_download() {
    [ -f "/usr/local/bin/pipe-pop" ] && pass "Pipe PoP binary exists." || fail "Pipe PoP binary missing!"
}

# Test 6: Verify checksum validation
test_checksum_verification() {
    EXPECTED_CHECKSUM="abc123xyz456"  # Replace with actual checksum
    ACTUAL_CHECKSUM=$(sha256sum /usr/local/bin/pipe-pop | awk '{print $1}')
    
    [ "$ACTUAL_CHECKSUM" == "$EXPECTED_CHECKSUM" ] && pass "Checksum matches." || fail "Checksum mismatch!"
}

# Test 7: Check systemd service
test_systemd_service() {
    systemctl is-active --quiet pipe-pop.service && pass "Pipe PoP service is running." || fail "Pipe PoP service is not running!"
}

# Run all tests
main() {
    echo "Starting tests..."
    test_script_exists
    test_script_runs
    test_dependencies
    test_system_requirements
    test_pipe_pop_download
    test_checksum_verification
    test_systemd_service
    echo "All tests completed."
}

main