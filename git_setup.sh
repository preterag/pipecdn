#!/bin/bash

# Script to set up Git credentials for persistent authentication
# This will configure Git to remember your credentials WITHOUT storing them in the repo

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

# Check if Git is installed
if ! command -v git > /dev/null 2>&1; then
    print_error "Git is not installed. Please install Git before running this script."
    exit 1
fi

# Check current credential helper configuration
current_helper=$(git config --global credential.helper)
if [ -n "$current_helper" ]; then
    print_warning "Git is already configured with a credential helper: $current_helper"
    read -p "Do you want to overwrite this configuration? (y/n): " choice
    case "$choice" in
        y|Y ) print_message "Proceeding with configuration overwrite...";;
        n|N ) print_message "Keeping the current Git configuration."; exit 0;;
        * ) print_warning "Invalid choice. Keeping the current Git configuration."; exit 0;;
    esac
fi

# Configure Git to store credentials securely
print_message "Configuring Git to store credentials securely..."

# Set up credential storage - choose the most secure option available
if command -v git-credential-libsecret > /dev/null 2>&1; then
    # Use libsecret if available (most secure)
    print_message "Using libsecret for credential storage (most secure)"
    git config --global credential.helper libsecret
elif command -v git-credential-manager > /dev/null 2>&1; then
    # Use Git Credential Manager if available
    print_message "Using Git Credential Manager for credential storage"
    git config --global credential.helper manager
else
    # Fall back to cache with a long timeout (1 week = 604800 seconds)
    print_message "Using cache for credential storage with 1 week timeout"
    git config --global credential.helper 'cache --timeout=604800'
    
    # Also set up store as a backup
    print_message "Also setting up store as a backup"
    git config --global credential.helper store
fi

# Set up useful Git aliases
read -p "Would you like to set up useful Git aliases? (y/n): " alias_choice
if [[ "$alias_choice" =~ ^[yY]$ ]]; then
    print_message "Setting up useful Git aliases..."
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
fi

print_message "Git configuration complete!"
print_message ""
print_message "IMPORTANT SECURITY NOTES:"
print_message "1. The next time you push, you'll be asked for credentials ONE TIME"
print_message "2. After that, Git will remember your credentials securely"
print_message "3. Your token is NOT stored in any files that will be committed to the repository"
print_message "4. To test, try running: git push"
print_message ""
print_warning "NEVER commit files containing tokens or passwords to your repository!"
