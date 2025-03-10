#!/bin/bash

# Script to update all references from "pipe-pop" to "pipe-pop" in the codebase
# This ensures consistent naming across all scripts and documentation

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

print_message "Starting the naming update process..."

# List of files to update (excluding binary files, .git directory, etc.)
print_message "Finding files to update..."
FILES=$(find . -type f -not -path "*/\.*" -not -path "*/bin/*" -not -path "*/cache/*" -not -path "*/backups/*" | grep -v "\.git" | grep -v "\.jpg" | grep -v "\.png" | grep -v "\.pdf" | grep -v "\.zip" | grep -v "\.tar.gz")

# Counter for updated files
UPDATED_FILES=0

# Update references in each file
for file in $FILES; do
    # Skip binary files
    if file "$file" | grep -q "binary"; then
        continue
    fi
    
    # Check if file contains "pipe-pop" (case sensitive)
    if grep -q "pipe-pop" "$file"; then
        print_message "Updating references in $file..."
        
        # Make a backup of the file
        cp "$file" "${file}.bak"
        
        # Replace "pipe-pop" with "pipe-pop" in the file
        # We're careful to preserve case where appropriate
        # 1. Replace "pipe-pop" with "pipe-pop" (all uppercase to lowercase-with-hyphen)
        # 2. Replace "Pipe-pop" with "Pipe-pop" (title case to title case)
        # 3. Replace "pipe-pop" with "pipe-pop" (all lowercase to lowercase-with-hyphen)
        sed -i 's/pipe-pop/pipe-pop/g' "$file"
        sed -i 's/Pipe-pop/Pipe-pop/g' "$file"
        sed -i 's/pipe-pop/pipe-pop/g' "$file"
        
        # Special case for "Pipe Network PoP" -> "Pipe Network PoP"
        sed -i 's/Pipe Network PoP/Pipe Network PoP/g' "$file"
        
        # Increment counter
        UPDATED_FILES=$((UPDATED_FILES + 1))
    fi
done

print_message "Naming update process completed."
print_message "Updated $UPDATED_FILES files."
print_message ""
print_warning "Note: Some manual review may still be needed for special cases."
print_message "You can compare the original files (*.bak) with the updated ones if needed."
print_message ""
print_message "To remove backup files after verification, run:"
print_message "find . -name \"*.bak\" -delete" 