#!/bin/bash

# Script to update the PPN binary
# Version: 1.0.0
#
# This script downloads and installs the latest version of the PPN binary
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Usage: sudo ./update_binary.sh [version]
# If version is not provided, it will try to get the latest version

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

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

print_message "========================================"
print_message "   PPN Binary Updater"
print_message "========================================"

# Get the current version if the binary exists
current_version="unknown"
if [ -f "bin/pipe-pop" ]; then
    # Try multiple methods to get the current version
    # Method 1: Try using --version flag
    version_output=$(./bin/pipe-pop --version 2>&1)
    if [[ $version_output =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        current_version=${BASH_REMATCH[0]}
    fi

    # Method 2: If still unknown, try using -V flag
    if [ "$current_version" == "unknown" ]; then
        version_output=$(./bin/pipe-pop -V 2>&1)
        if [[ $version_output =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            current_version=${BASH_REMATCH[0]}
        fi
    fi

    # Method 3: If still unknown, try extracting from binary directly
    if [ "$current_version" == "unknown" ]; then
        version_output=$(strings bin/pipe-pop | grep -E "v[0-9]+\.[0-9]+\.[0-9]+" | head -1)
        if [[ $version_output =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            current_version=${BASH_REMATCH[0]}
        fi
    fi

    # Method 4: Check if we have a version file
    if [ "$current_version" == "unknown" ] && [ -f "bin/version.txt" ]; then
        current_version=$(cat bin/version.txt)
        print_message "Using version from version.txt file: ${current_version}"
    fi

    # If we still don't know the version, check the download link directly
    if [ "$current_version" == "unknown" ]; then
        # Use the known download link to get the version
        known_version="v0.2.8"
        download_url="https://dl.pipecdn.app/${known_version}/pop"
        
        # Check if the file exists at the known URL
        if curl --silent --head --fail "$download_url" > /dev/null; then
            current_version="${known_version}"
            print_message "Detected version from download link: ${current_version}"
            # Create a version file for future reference
            echo "$current_version" > bin/version.txt
            print_message "Created version.txt file with detected version."
        else
            print_warning "Could not determine current version and download link check failed."
        fi
    else
        print_message "Current version: ${current_version}"
    fi
fi

# Get the version to update to
if [ -z "$1" ]; then
    # If no version is provided, try to determine the latest version
    print_message "No version specified. Attempting to find the latest version..."
    
    # Try to get the latest version by checking common version numbers
    latest_version="unknown"
    for major in {0..1}; do
        for minor in {0..9}; do
            for patch in {0..20}; do
                version_to_check="v$major.$minor.$patch"
                url="https://dl.pipecdn.app/$version_to_check/pop"
                
                # Use curl with --head to only fetch headers and check if the file exists
                if curl --silent --head --fail "$url" > /dev/null; then
                    latest_version="$version_to_check"
                fi
            done
        done
    done
    
    # If we couldn't determine the latest version, use the known download link version
    if [ "$latest_version" == "unknown" ]; then
        known_version="v0.2.8"
        download_url="https://dl.pipecdn.app/${known_version}/pop"
        
        # Check if the file exists at the known URL
        if curl --silent --head --fail "$download_url" > /dev/null; then
            latest_version="${known_version}"
            print_message "Using version from known download link: ${latest_version}"
        else
            print_error "Could not determine latest version and download link check failed."
            exit 1
        fi
    else
        print_message "Latest version found: ${latest_version}"
    fi
    
    version="$latest_version"
else
    # Use the provided version
    version="$1"
    # Add 'v' prefix if not present
    if [[ ! "$version" =~ ^v ]]; then
        version="v$version"
    fi
    print_message "Using specified version: ${version}"
fi

# Check if we're already on the requested version
if [ "$current_version" == "$version" ]; then
    print_message "You are already running version ${version}. No update needed."
    print_message "If you want to force a reinstall, use: sudo ./update_binary.sh ${version} --force"
    if [[ "$2" != "--force" ]]; then
        exit 0
    else
        print_message "Force flag detected. Proceeding with reinstall..."
    fi
fi

# Construct the download URL
download_url="https://dl.pipecdn.app/${version}/pop"
print_message "Download URL: ${download_url}"

# Verify the download URL exists
if ! curl --silent --head --fail "$download_url" > /dev/null; then
    print_error "The download URL does not exist: ${download_url}"
    print_error "Please check the version number and try again."
    exit 1
fi

# Create a backup of the current binary
if [ -f "bin/pipe-pop" ]; then
    print_message "Creating backup of current binary..."
    backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    cp bin/pipe-pop "$backup_dir/pipe-pop.bak"
    print_message "Backup created at: ${backup_dir}/pipe-pop.bak"
else
    print_warning "No existing binary found. Skipping backup."
    mkdir -p bin
fi

# Download the new binary
print_message "Downloading new binary..."
if curl -s --fail -o bin/pipe-pop.new "$download_url"; then
    print_message "Download successful."
else
    print_error "Failed to download binary from ${download_url}"
    print_error "Please check the version number and your internet connection."
    exit 1
fi

# Make the new binary executable
print_message "Setting executable permissions..."
chmod +x bin/pipe-pop.new

# Verify the new binary
print_message "Verifying new binary..."
verification_success=false

# Try multiple verification methods
# Method 1: Try using --version flag
if ./bin/pipe-pop.new --version &> /dev/null; then
    verification_success=true
fi

# Method 2: If still failed, try using -V flag
if [ "$verification_success" = false ] && ./bin/pipe-pop.new -V &> /dev/null; then
    verification_success=true
fi

# Method 3: If still failed, check if it's a valid executable
if [ "$verification_success" = false ] && file bin/pipe-pop.new | grep -q "executable"; then
    print_warning "Binary doesn't respond to version flags but appears to be executable. Proceeding with caution."
    verification_success=true
fi

if [ "$verification_success" = true ]; then
    print_message "Binary verification successful."
    # Save the version to a file for future reference
    echo "$version" > bin/version.txt
    print_message "Updated version.txt file with new version: ${version}"
else
    print_error "Binary verification failed. The downloaded binary may be corrupted."
    print_error "Restoring backup..."
    if [ -f "$backup_dir/pipe-pop.bak" ]; then
        cp "$backup_dir/pipe-pop.bak" bin/pipe-pop
        print_message "Backup restored."
    fi
    rm bin/pipe-pop.new
    exit 1
fi

# Replace the old binary with the new one
print_message "Replacing old binary with new one..."
mv bin/pipe-pop.new bin/pipe-pop

# Restart the service
print_message "Restarting PPN service..."
systemctl restart pipe-pop.service

# Check service status
print_message "Checking service status..."
if systemctl is-active --quiet pipe-pop.service; then
    print_message "========================================"
    print_message "Update successful! PPN service is running."
    print_message "New version: ${version}"
    print_message "========================================"
else
    print_warning "========================================"
    print_warning "Update completed, but service is not running."
    print_warning "Please check the service logs: journalctl -u pipe-pop.service"
    print_warning "========================================"
fi

exit 0 