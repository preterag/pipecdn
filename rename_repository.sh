#!/bin/bash

# Pipe PoP Node Repository Rename Script
# Version: 1.0.0
#
# This script helps update references to the repository name in the codebase
# when renaming the repository from 'pipecdn' to 'pipe-pop-node'.
#
# Contributors:
# - Preterag Team (original implementation)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Display version information
print_header "Pipe PoP Node Repository Rename Tool v1.0.0"

# Set variables
OLD_REPO_NAME="pipecdn"
NEW_REPO_NAME="pipe-pop-node"
OLD_REPO_URL="https://github.com/preterag/pipecdn"
NEW_REPO_URL="https://github.com/preterag/pipe-pop-node"
OLD_RAW_URL="https://raw.githubusercontent.com/preterag/pipecdn"
NEW_RAW_URL="https://raw.githubusercontent.com/preterag/pipe-pop-node"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_warning "This script is not running as root. Some operations may fail."
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        print_message "Exiting. Please run with sudo if you encounter permission issues."
        exit 0
    fi
fi

# Function to update references in a file
update_file_references() {
    local file=$1
    local old_string=$2
    local new_string=$3
    
    if [ ! -f "$file" ]; then
        print_warning "File not found: $file"
        return 1
    fi
    
    print_message "Updating references in $file..."
    
    # Create a backup of the file
    cp "$file" "${file}.bak"
    
    # Replace the string
    sed -i "s|$old_string|$new_string|g" "$file"
    
    # Count the number of replacements
    local count=$(grep -c "$new_string" "$file")
    
    print_message "Updated $count references in $file"
    
    return 0
}

# Function to find files containing a string
find_files_with_string() {
    local search_string=$1
    local exclude_dirs=$2
    
    print_message "Finding files containing '$search_string'..."
    
    # Use grep to find files containing the string, excluding specified directories
    grep -r --include="*.sh" --include="*.md" --include="*.yml" --include="*.yaml" "$search_string" . $exclude_dirs
    
    return 0
}

# Main menu
while true; do
    print_header "Repository Rename Menu"
    echo "1. Find files containing old repository name"
    echo "2. Find files containing old repository URL"
    echo "3. Update references in a specific file"
    echo "4. Update all references in the codebase"
    echo "5. Create a backup of the repository"
    echo "6. Exit"
    
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            print_header "Finding Files with Old Repository Name"
            find_files_with_string "$OLD_REPO_NAME" "--exclude-dir=.git"
            ;;
        2)
            print_header "Finding Files with Old Repository URL"
            find_files_with_string "$OLD_REPO_URL" "--exclude-dir=.git"
            ;;
        3)
            print_header "Update References in a Specific File"
            read -p "Enter the path to the file: " file_path
            
            if [ ! -f "$file_path" ]; then
                print_error "File not found: $file_path"
                continue
            fi
            
            echo "1. Update repository name ($OLD_REPO_NAME -> $NEW_REPO_NAME)"
            echo "2. Update repository URL ($OLD_REPO_URL -> $NEW_REPO_URL)"
            echo "3. Update raw URL ($OLD_RAW_URL -> $NEW_RAW_URL)"
            echo "4. All of the above"
            
            read -p "Enter your choice (1-4): " update_choice
            
            case $update_choice in
                1)
                    update_file_references "$file_path" "$OLD_REPO_NAME" "$NEW_REPO_NAME"
                    ;;
                2)
                    update_file_references "$file_path" "$OLD_REPO_URL" "$NEW_REPO_URL"
                    ;;
                3)
                    update_file_references "$file_path" "$OLD_RAW_URL" "$NEW_RAW_URL"
                    ;;
                4)
                    update_file_references "$file_path" "$OLD_REPO_NAME" "$NEW_REPO_NAME"
                    update_file_references "$file_path" "$OLD_REPO_URL" "$NEW_REPO_URL"
                    update_file_references "$file_path" "$OLD_RAW_URL" "$NEW_RAW_URL"
                    ;;
                *)
                    print_error "Invalid choice"
                    ;;
            esac
            ;;
        4)
            print_header "Update All References in the Codebase"
            print_warning "This will update all references to the old repository name and URLs in the codebase."
            read -p "Are you sure you want to continue? (y/n): " confirm
            
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_message "Operation cancelled."
                continue
            fi
            
            # Find all files containing the old repository name or URLs
            print_message "Finding files to update..."
            
            # Create a list of files to update
            files_to_update=$(grep -l -r --include="*.sh" --include="*.md" --include="*.yml" --include="*.yaml" -E "$OLD_REPO_NAME|$OLD_REPO_URL|$OLD_RAW_URL" . --exclude-dir=.git)
            
            if [ -z "$files_to_update" ]; then
                print_message "No files found containing references to the old repository."
                continue
            fi
            
            # Create a backup directory
            backup_dir="backup_$(date +%Y%m%d%H%M%S)"
            mkdir -p "$backup_dir"
            
            # Update each file
            for file in $files_to_update; do
                # Create a backup of the file
                cp "$file" "$backup_dir/$(basename "$file")"
                
                # Update references
                update_file_references "$file" "$OLD_REPO_NAME" "$NEW_REPO_NAME"
                update_file_references "$file" "$OLD_REPO_URL" "$NEW_REPO_URL"
                update_file_references "$file" "$OLD_RAW_URL" "$NEW_RAW_URL"
            done
            
            print_message "All references updated. Backups saved in $backup_dir/"
            ;;
        5)
            print_header "Create a Backup of the Repository"
            backup_file="pipecdn_backup_$(date +%Y%m%d%H%M%S).tar.gz"
            
            print_message "Creating backup of the repository..."
            tar -czf "$backup_file" --exclude=".git" .
            
            if [ $? -eq 0 ]; then
                print_highlight "Backup created: $backup_file"
            else
                print_error "Failed to create backup."
            fi
            ;;
        6)
            print_message "Exiting. Thank you for using the Repository Rename Tool."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please enter a number between 1 and 6."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done 