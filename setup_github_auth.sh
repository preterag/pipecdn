#!/bin/bash

# Script to set up GitHub authentication
# This script helps users set up their own GitHub authentication without exposing tokens

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

# Function to check if a git remote URL is valid
check_git_remote_url() {
    git ls-remote "$1" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Failed to connect to the repository URL. Please check your username and repository name."
        exit 1
    fi
}

print_message "GitHub Authentication Setup"
print_message "============================"
print_message ""
print_message "This script will help you set up authentication for GitHub."
print_message "You'll need to create a Personal Access Token (PAT) on GitHub."
print_message ""

# Ask if the user already has a token
read -p "Do you already have a GitHub Personal Access Token? (y/n): " has_token

if [[ $has_token != "y" && $has_token != "Y" ]]; then
    print_message ""
    print_message "To create a Personal Access Token:"
    print_message "1. Go to GitHub: https://github.com/settings/tokens"
    print_message "2. Click 'Generate new token' (classic)"
    print_message "3. Give it a name like 'PipeNetwork Access'"
    print_message "4. Select at least these scopes: 'repo', 'workflow'"
    print_message "5. Click 'Generate token'"
    print_message "6. Copy the token (you won't see it again!)"
    print_message ""
    print_warning "IMPORTANT: Keep this token secure and don't share it with anyone!"
    print_message ""
    read -p "Press Enter when you have your token ready..."
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

# Ask for repository information
print_message ""
print_message "Now, let's set up your repository information."
read -p "Enter your GitHub username: " github_username
read -p "Enter the repository name (e.g., 'pipecdn'): " repo_name

if [ -z "$github_username" ] || [ -z "$repo_name" ]; then
    print_error "Username or repository name cannot be empty."
    exit 1
fi

# Set the remote URL
print_message "Setting remote URL..."
git remote set-url origin "https://github.com/${github_username}/${repo_name}.git"

# Check if the repository URL is valid
check_git_remote_url "https://github.com/${github_username}/${repo_name}.git"

print_message ""
print_message "Setup complete! The next time you push, you'll be asked for your"
print_message "GitHub username and the Personal Access Token (instead of password)."
print_message "After that, Git will remember your credentials."
print_message ""
print_message "To test, try running: ./secure_push.sh"
print_message ""
print_warning "REMEMBER: Never commit files containing tokens or passwords to your repository!"
