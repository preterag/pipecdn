#!/bin/bash

# Script to set up a regular backup schedule for the pipe-pop
# This script will create a cron job to run the backup.sh script at regular intervals

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

# Check if backup.sh exists
if [ ! -f "backup.sh" ]; then
    print_error "backup.sh not found. Please make sure you're in the correct directory."
    exit 1
fi

# Make sure backup.sh is executable
chmod +x backup.sh

# Get the absolute path to the backup.sh script
BACKUP_SCRIPT="$(pwd)/backup.sh"

# Get the current user
CURRENT_USER=$(whoami)

# Function to set up daily backups
setup_daily_backups() {
    print_message "Setting up daily backups..."
    
    # Create a temporary file for the crontab
    TEMP_CRONTAB=$(mktemp)
    
    # Export the current crontab
    crontab -l > "$TEMP_CRONTAB" 2>/dev/null || echo "" > "$TEMP_CRONTAB"
    
    # Check if the backup job already exists
    if grep -q "$BACKUP_SCRIPT" "$TEMP_CRONTAB"; then
        print_warning "Backup job already exists in crontab. Skipping."
    else
        # Add the backup job to run at 2:00 AM every day
        echo "0 2 * * * $BACKUP_SCRIPT > /dev/null 2>&1" >> "$TEMP_CRONTAB"
        
        # Import the updated crontab
        crontab "$TEMP_CRONTAB"
        
        print_message "Daily backup scheduled for 2:00 AM."
    fi
    
    # Remove the temporary file
    rm "$TEMP_CRONTAB"
}

# Function to set up weekly backups
setup_weekly_backups() {
    print_message "Setting up weekly backups..."
    
    # Create a temporary file for the crontab
    TEMP_CRONTAB=$(mktemp)
    
    # Export the current crontab
    crontab -l > "$TEMP_CRONTAB" 2>/dev/null || echo "" > "$TEMP_CRONTAB"
    
    # Check if the backup job already exists
    if grep -q "$BACKUP_SCRIPT" "$TEMP_CRONTAB"; then
        print_warning "Backup job already exists in crontab. Skipping."
    else
        # Add the backup job to run at 2:00 AM every Sunday
        echo "0 2 * * 0 $BACKUP_SCRIPT > /dev/null 2>&1" >> "$TEMP_CRONTAB"
        
        # Import the updated crontab
        crontab "$TEMP_CRONTAB"
        
        print_message "Weekly backup scheduled for 2:00 AM every Sunday."
    fi
    
    # Remove the temporary file
    rm "$TEMP_CRONTAB"
}

# Function to set up monthly backups
setup_monthly_backups() {
    print_message "Setting up monthly backups..."
    
    # Create a temporary file for the crontab
    TEMP_CRONTAB=$(mktemp)
    
    # Export the current crontab
    crontab -l > "$TEMP_CRONTAB" 2>/dev/null || echo "" > "$TEMP_CRONTAB"
    
    # Check if the backup job already exists
    if grep -q "$BACKUP_SCRIPT" "$TEMP_CRONTAB"; then
        print_warning "Backup job already exists in crontab. Skipping."
    else
        # Add the backup job to run at 2:00 AM on the 1st of every month
        echo "0 2 1 * * $BACKUP_SCRIPT > /dev/null 2>&1" >> "$TEMP_CRONTAB"
        
        # Import the updated crontab
        crontab "$TEMP_CRONTAB"
        
        print_message "Monthly backup scheduled for 2:00 AM on the 1st of every month."
    fi
    
    # Remove the temporary file
    rm "$TEMP_CRONTAB"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Set up a regular backup schedule for the pipe-pop."
    echo ""
    echo "Options:"
    echo "  daily     Set up daily backups (at 2:00 AM)"
    echo "  weekly    Set up weekly backups (at 2:00 AM every Sunday)"
    echo "  monthly   Set up monthly backups (at 2:00 AM on the 1st of every month)"
    echo "  help      Show this help message"
}

# Main execution
case "$1" in
    daily)
        setup_daily_backups
        ;;
    weekly)
        setup_weekly_backups
        ;;
    monthly)
        setup_monthly_backups
        ;;
    help|*)
        show_help
        ;;
esac

print_message "To view your current cron jobs, run: crontab -l"
print_message "To edit your cron jobs, run: crontab -e"
