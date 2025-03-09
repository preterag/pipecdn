#!/bin/bash

# Script to check for updates to the pipe-pop binary and scripts
# Version: 1.0.0
#
# This script checks for updates to the pipe-pop node binary and scripts
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

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

print_message "========================================"
print_message "   pipe-pop Update Checker"
print_message "========================================"
print_message "Checking for updates to your pipe-pop..."

# Check if the binary exists
if [ ! -f "bin/pipe-pop" ]; then
    print_error "pipe-pop binary not found. Please run setup.sh first."
    exit 1
fi

# Get the current version - try multiple methods
print_message "Checking current version..."
current_version="unknown"

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
    # Update the version file for future reference
    echo "$current_version" > bin/version.txt
fi

# Remove the 'v' prefix for version comparison
current_version_num=${current_version#v}

# Check the latest version by querying the download server
print_message "Checking latest available version..."

# Try to get the latest version by checking common version numbers
# This is a simple approach - in production, you would want a more robust method
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
        print_warning "Could not determine latest version and download link check failed."
        exit 1
    fi
else
    print_message "Latest version: ${latest_version}"
fi

# Remove the 'v' prefix for version comparison
latest_version_num=${latest_version#v}

# Compare versions (simple string comparison - can be improved with version comparison logic)
if [ "$current_version_num" == "$latest_version_num" ]; then
    print_message "========================================"
    print_message "Your pipe-pop binary is up to date (${current_version})."
    print_message "========================================"
elif [ "$current_version" == "unknown" ]; then
    print_warning "========================================"
    print_warning "Cannot compare versions. Consider updating to the latest version: ${latest_version}"
    print_warning "To update, run: sudo ./update_binary.sh ${latest_version}"
    print_warning "Or use the pop script: sudo pop --update"
    print_warning "========================================"
else
    print_warning "========================================"
    print_warning "A new version is available: ${latest_version} (you have ${current_version})"
    print_warning "Download URL: https://dl.pipecdn.app/${latest_version}/pop"
    print_warning "To update, run: sudo ./update_binary.sh ${latest_version}"
    print_warning "Or use the pop script: sudo pop --update"
    print_warning "========================================"
fi

exit 0 