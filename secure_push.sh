#!/bin/bash

# Secure GitHub Push Script
# This script helps push to GitHub without exposing tokens in the repository

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
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git to continue."
    exit 1
fi

# Check if we have any changes to commit
if [ -n "$(git status --porcelain)" ]; then
    # We have changes
    print_message "Changes detected in the repository."
    
    # Ask if user wants to commit all changes
    read -p "Do you want to commit all changes? (y/n): " commit_all
    
    if [[ $commit_all == "y" || $commit_all == "Y" ]]; then
        # Add all changes
        print_message "Adding all changes..."
        git add .
        
        # Ask for commit message
        read -p "Enter commit message: " commit_message
        
        if [ -z "$commit_message" ]; then
            commit_message="Update files"
            print_warning "No commit message provided. Using default: '$commit_message'"
        fi
        
        # Commit changes
        print_message "Committing changes with message: '$commit_message'"
        git commit -m "$commit_message"
    else
        print_message "Skipping automatic commit. Please commit your changes manually."
        exit 0
    fi
else
    print_message "No changes detected in the repository."
fi

# Check if remote origin is set
REMOTE=$(git remote get-url origin 2>/dev/null)

if [ -z "$REMOTE" ]; then
    print_error "No remote repository found. Please set up a remote repository."
    exit 1
fi

# Push changes
print_message "Pushing changes to remote repository..."
git push

# Check if push was successful
if [ $? -eq 0 ]; then
    print_message "Changes pushed successfully!"
else
    print_error "Failed to push changes. Please check your credentials and try again."
    print_message "You may need to enter your credentials once if this is the first time pushing."
    exit 1
fi

exit 0
