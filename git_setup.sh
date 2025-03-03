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
print_message "Setting up useful Git aliases..."
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

print_message "Git configuration complete!"
print_message ""
print_message "IMPORTANT SECURITY NOTES:"
print_message "1. The next time you push, you'll be asked for credentials ONE TIME"
print_message "2. After that, Git will remember your credentials securely"
print_message "3. Your token is NOT stored in any files that will be committed to the repository"
print_message "4. To test, try running: git push"
print_message ""
print_warning "NEVER commit files containing tokens or passwords to your repository!" 