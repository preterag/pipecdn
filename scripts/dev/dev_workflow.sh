#!/bin/bash

# Development Workflow Script for Pipe Network
# This script helps manage the development workflow when adding new features to the toolkit

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${BLUE}=== $1 ===${NC}"; }

# Define paths
REPO_DIR="$(pwd)"
RUNTIME_DIR="$HOME/pipe-pop-runtime"
BACKUP_DIR="$RUNTIME_DIR/backups/$(date +%Y%m%d_%H%M%S)"

# Function to sync repository changes to runtime directory
sync_to_runtime() {
    print_header "Syncing Repository to Runtime"
    
    # Create backup of current runtime
    print_message "Creating backup of current runtime environment..."
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$RUNTIME_DIR" ]; then
        cp -r "$RUNTIME_DIR/config" "$BACKUP_DIR/" 2>/dev/null || true
        cp -r "$RUNTIME_DIR/cache" "$BACKUP_DIR/" 2>/dev/null || true
        cp -r "$RUNTIME_DIR/logs" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    
    # Sync scripts
    print_message "Syncing scripts..."
    mkdir -p "$RUNTIME_DIR/scripts"
    rsync -av --exclude="dev_workflow.sh" "$REPO_DIR/scripts/" "$RUNTIME_DIR/scripts/"
    
    # Sync tools
    print_message "Syncing tools..."
    mkdir -p "$RUNTIME_DIR/tools"
    rsync -av "$REPO_DIR/tools/" "$RUNTIME_DIR/tools/"
    
    # Sync config templates (but not actual configs)
    print_message "Syncing configuration templates..."
    mkdir -p "$RUNTIME_DIR/config/examples"
    rsync -av "$REPO_DIR/config/config.template.json" "$RUNTIME_DIR/config/"
    rsync -av "$REPO_DIR/config/examples/" "$RUNTIME_DIR/config/examples/"
    
    # Sync documentation
    print_message "Syncing documentation..."
    mkdir -p "$RUNTIME_DIR/docs"
    rsync -av "$REPO_DIR/docs/" "$RUNTIME_DIR/docs/"
    
    # Sync README files
    cp "$REPO_DIR/README.md" "$RUNTIME_DIR/README.repo.md" 2>/dev/null || true
    cp "$REPO_DIR/START_HERE.md" "$RUNTIME_DIR/" 2>/dev/null || true
    
    # Copy the runtime README
    cp "$REPO_DIR/scripts/runtime_readme.md" "$RUNTIME_DIR/README.md" 2>/dev/null || true
    
    # Create necessary directories
    mkdir -p "$RUNTIME_DIR/logs"
    mkdir -p "$RUNTIME_DIR/cache"
    mkdir -p "$RUNTIME_DIR/backups"
    
    # Copy INSTALL symlink
    if [ -L "$REPO_DIR/INSTALL" ]; then
        ln -sf "$RUNTIME_DIR/scripts/install.sh" "$RUNTIME_DIR/INSTALL"
    fi
    
    print_message "Sync completed successfully!"
}

# Function to stage changes from runtime to repository
stage_runtime_changes() {
    print_header "Staging Runtime Changes to Repository"
    
    # Check if we have runtime changes
    if [ ! -d "$RUNTIME_DIR" ]; then
        print_error "Runtime directory not found!"
        exit 1
    fi
    
    # Create temporary directory for processed files
    TEMP_DIR=$(mktemp -d)
    
    # Check for script changes
    print_message "Checking for script changes..."
    for file in $(find "$RUNTIME_DIR/scripts" -type f -name "*.sh"); do
        FILENAME=$(basename "$file")
        if [ "$FILENAME" != "dev_workflow.sh" ]; then
            REPO_FILE="$REPO_DIR/scripts/$FILENAME"
            # Check if file exists and is different
            if [ -f "$REPO_FILE" ]; then
                if ! diff -q "$file" "$REPO_FILE" >/dev/null; then
                    cp "$file" "$TEMP_DIR/$FILENAME"
                    print_message "Found changes in: $FILENAME"
                fi
            else
                cp "$file" "$TEMP_DIR/$FILENAME"
                print_message "Found new script: $FILENAME"
            fi
        fi
    done
    
    # Check for tool changes
    print_message "Checking for tool changes..."
    for file in $(find "$RUNTIME_DIR/tools" -type f); do
        REL_PATH=${file#$RUNTIME_DIR/tools/}
        REPO_FILE="$REPO_DIR/tools/$REL_PATH"
        # Check if file exists and is different
        if [ -f "$REPO_FILE" ]; then
            if ! diff -q "$file" "$REPO_FILE" >/dev/null; then
                mkdir -p "$TEMP_DIR/tools/$(dirname "$REL_PATH")"
                cp "$file" "$TEMP_DIR/tools/$REL_PATH"
                print_message "Found changes in tool: $REL_PATH"
            fi
        else
            mkdir -p "$TEMP_DIR/tools/$(dirname "$REL_PATH")"
            cp "$file" "$TEMP_DIR/tools/$REL_PATH"
            print_message "Found new tool: $REL_PATH"
        fi
    done
    
    # Show changes
    if [ "$(ls -A "$TEMP_DIR")" ]; then
        print_header "Found Changes"
        for file in $(find "$TEMP_DIR" -type f); do
            REL_PATH=${file#$TEMP_DIR/}
            echo " - $REL_PATH"
        done
        
        # Ask if user wants to copy changes back to repository
        read -p "Do you want to copy these changes back to the repository? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Copy changes back to repository
            for file in $(find "$TEMP_DIR" -type f); do
                REL_PATH=${file#$TEMP_DIR/}
                if [[ "$REL_PATH" == tools/* ]]; then
                    mkdir -p "$REPO_DIR/$(dirname "$REL_PATH")"
                    cp "$file" "$REPO_DIR/$REL_PATH"
                else
                    cp "$file" "$REPO_DIR/scripts/$(basename "$REL_PATH")"
                fi
                print_message "Copied: $REL_PATH to repository"
            done
        fi
    else
        print_message "No changes found in runtime environment."
    fi
    
    # Clean up
    rm -rf "$TEMP_DIR"
}

# Function to check git status
check_git_status() {
    print_header "Git Status"
    cd "$REPO_DIR"
    git status
}

# Display menu
print_header "Pipe Network Development Workflow"
echo "1. Sync repository changes to runtime directory"
echo "2. Check for changes in runtime and stage to repository"
echo "3. Check git status"
echo "4. Exit"
echo

read -p "Select an option (1-4): " option

case $option in
    1)
        sync_to_runtime
        ;;
    2)
        stage_runtime_changes
        ;;
    3)
        check_git_status
        ;;
    4)
        exit 0
        ;;
    *)
        print_error "Invalid option!"
        exit 1
        ;;
esac

print_header "Operation Completed" 