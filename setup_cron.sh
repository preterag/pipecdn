#!/bin/bash

# Script to set up automated data collection for Pipe Network PoP node
# This script creates cron jobs to collect historical data for visualization

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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
    echo -e "${CYAN}$1${NC}"
}

# Function to show help message
show_help() {
    print_header "Pipe Network PoP Node - Automated Data Collection Setup"
    echo "This script sets up automated data collection for historical visualization."
    echo
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  --hourly              Set up hourly data collection (recommended)"
    echo "  --daily               Set up daily data collection"
    echo "  --custom SCHEDULE     Set up a custom schedule in cron format"
    echo "  --remove              Remove existing cron jobs"
    echo "  --help                Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --hourly           # Collect data every hour"
    echo "  $0 --daily            # Collect data once a day at midnight"
    echo "  $0 --custom \"0 */2 * * *\"  # Collect data every 2 hours"
    echo "  $0 --remove           # Remove all data collection cron jobs"
    echo
}

# Check if crontab is available
if ! command -v crontab &> /dev/null; then
    print_error "crontab command not found. Please install cron."
    echo "On Debian/Ubuntu: sudo apt-get install cron"
    echo "On CentOS/RHEL: sudo yum install cronie"
    exit 1
fi

# Get the absolute path of the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to add a cron job
add_cron_job() {
    local schedule="$1"
    local comment="$2"
    
    # Check if the cron job already exists
    if crontab -l 2>/dev/null | grep -q "${SCRIPT_DIR}/pop --leaderboard"; then
        print_warning "A data collection cron job already exists."
        echo "Please remove it first with: $0 --remove"
        exit 1
    fi
    
    # Add the new cron job
    (crontab -l 2>/dev/null; echo "# ${comment}"; echo "${schedule} cd ${SCRIPT_DIR} && ./pop --leaderboard > /dev/null 2>&1") | crontab -
    
    print_message "Cron job added successfully."
    print_message "Data will be collected according to the schedule: ${schedule}"
    print_message "Historical data will be stored in: ${SCRIPT_DIR}/history/"
}

# Function to remove cron jobs
remove_cron_jobs() {
    # Remove all cron jobs related to data collection
    crontab -l 2>/dev/null | grep -v "${SCRIPT_DIR}/pop --leaderboard" | crontab -
    
    print_message "All data collection cron jobs have been removed."
}

# Process command line arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    --hourly)
        print_header "Setting up hourly data collection"
        add_cron_job "0 * * * *" "Pipe Network PoP Node - Hourly data collection"
        ;;
    --daily)
        print_header "Setting up daily data collection"
        add_cron_job "0 0 * * *" "Pipe Network PoP Node - Daily data collection"
        ;;
    --custom)
        if [ -z "$2" ]; then
            print_error "Custom schedule not specified."
            echo "Usage: $0 --custom \"CRON_SCHEDULE\""
            exit 1
        fi
        print_header "Setting up custom data collection"
        add_cron_job "$2" "Pipe Network PoP Node - Custom data collection"
        ;;
    --remove)
        print_header "Removing data collection cron jobs"
        remove_cron_jobs
        ;;
    --help)
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

# Create history directory if it doesn't exist
if [ ! -d "${SCRIPT_DIR}/history" ]; then
    mkdir -p "${SCRIPT_DIR}/history"
    print_message "Created history directory: ${SCRIPT_DIR}/history"
fi

# Final instructions
if [ "$1" != "--remove" ] && [ "$1" != "--help" ]; then
    print_message "Setup complete! Historical data will be collected automatically."
    print_message "You can view the data with: ./pop --history"
    print_message "To see your rank history: ./history_view.sh --rank"
    print_message "To see your reputation history: ./history_view.sh --reputation"
fi

exit 0 