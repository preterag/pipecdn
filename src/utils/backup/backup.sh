#!/bin/bash
# Community Enhancement: Node Backup Utility
# This script provides backup functionality for Pipe Network nodes.

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

# Constants
VERSION="community-v0.0.1"
BACKUP_DIR="/opt/pipe-pop/backups"
NODE_DIR="/opt/pipe-pop/PipeNetwork"
CONFIG_DIR="/opt/pipe-pop/config"
DEFAULT_RETENTION=7

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if the required directories exist
check_directories() {
  if [[ ! -d "$NODE_DIR" ]]; then
    echo -e "${RED}Error: Node directory ($NODE_DIR) not found.${NC}"
    return 1
  fi
  
  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo -e "${YELLOW}Backup directory not found. Creating it...${NC}"
    mkdir -p "$BACKUP_DIR"
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}Error: Failed to create backup directory.${NC}"
      return 1
    fi
  fi
  
  return 0
}

# Create a backup of the node
create_backup() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_file="${BACKUP_DIR}/PipeNetwork_backup_${timestamp}.tar.gz"
  
  echo -e "${BLUE}Creating backup of Pipe Network node...${NC}"
  
  # Stop the node service before backup (optional)
  if [[ "$1" == "--stop-service" ]]; then
    echo -e "${YELLOW}Stopping node service for backup...${NC}"
    systemctl stop pipe-pop
    local service_was_stopped=true
  fi
  
  # Create the backup archive
  tar -czf "$backup_file" -C "$(dirname $NODE_DIR)" "$(basename $NODE_DIR)" "$CONFIG_DIR" 2>/dev/null
  
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Backup created successfully: $backup_file${NC}"
    
    # Restart the service if it was stopped
    if [[ "$service_was_stopped" == "true" ]]; then
      echo -e "${YELLOW}Restarting node service...${NC}"
      systemctl start pipe-pop
    fi
    
    # Return the backup filename
    echo "$backup_file"
  else
    echo -e "${RED}Error: Failed to create backup.${NC}"
    
    # Restart the service if it was stopped
    if [[ "$service_was_stopped" == "true" ]]; then
      echo -e "${YELLOW}Restarting node service...${NC}"
      systemctl start pipe-pop
    fi
    
    return 1
  fi
}

# Restore a backup
restore_backup() {
  local backup_file="$1"
  
  if [[ ! -f "$backup_file" ]]; then
    echo -e "${RED}Error: Backup file not found: $backup_file${NC}"
    return 1
  fi
  
  echo -e "${BLUE}Restoring Pipe Network node from backup...${NC}"
  
  # Stop the node service
  echo -e "${YELLOW}Stopping node service for restore...${NC}"
  systemctl stop pipe-pop
  
  # Backup current node directories before restoring
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local pre_restore_backup="${BACKUP_DIR}/pre_restore_${timestamp}.tar.gz"
  
  echo -e "${YELLOW}Creating safety backup before restore...${NC}"
  tar -czf "$pre_restore_backup" -C "$(dirname $NODE_DIR)" "$(basename $NODE_DIR)" "$CONFIG_DIR" 2>/dev/null
  
  # Remove current node directory
  echo -e "${YELLOW}Removing current node files...${NC}"
  rm -rf "$NODE_DIR" "$CONFIG_DIR"
  
  # Extract the backup
  echo -e "${YELLOW}Extracting backup...${NC}"
  tar -xzf "$backup_file" -C "/"
  
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Backup restored successfully.${NC}"
    
    # Restart the node service
    echo -e "${YELLOW}Restarting node service...${NC}"
    systemctl start pipe-pop
    return 0
  else
    echo -e "${RED}Error: Failed to restore backup.${NC}"
    
    # Try to restore from pre-restore backup
    echo -e "${YELLOW}Attempting to restore from safety backup...${NC}"
    tar -xzf "$pre_restore_backup" -C "/"
    
    # Restart the node service
    echo -e "${YELLOW}Restarting node service...${NC}"
    systemctl start pipe-pop
    return 1
  fi
}

# List available backups
list_backups() {
  echo -e "${BLUE}Available Pipe Network node backups:${NC}"
  
  local backups=($(ls -t "$BACKUP_DIR"/PipeNetwork_backup_*.tar.gz 2>/dev/null))
  
  if [[ ${#backups[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No backups found.${NC}"
    return 0
  fi
  
  printf "%-5s %-25s %-15s\n" "No." "Date" "Size"
  echo "---------------------------------------------------------"
  
  for i in "${!backups[@]}"; do
    local file="${backups[$i]}"
    local filename=$(basename "$file")
    local date_part=$(echo "$filename" | grep -o "[0-9]\{8\}_[0-9]\{6\}")
    local formatted_date=$(date -d "$(echo $date_part | sed 's/_/ /')" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    local size=$(du -h "$file" | cut -f1)
    
    printf "%-5s %-25s %-15s %s\n" "$((i+1))" "$formatted_date" "$size" "$file"
  done
  
  return 0
}

# Clean up old backups
cleanup_backups() {
  local retention=${1:-$DEFAULT_RETENTION}
  
  echo -e "${BLUE}Cleaning up old backups (keeping last $retention)...${NC}"
  
  local backups=($(ls -t "$BACKUP_DIR"/PipeNetwork_backup_*.tar.gz 2>/dev/null))
  
  if [[ ${#backups[@]} -le $retention ]]; then
    echo -e "${GREEN}No backups to clean up (total: ${#backups[@]}).${NC}"
    return 0
  fi
  
  local to_delete=$((${#backups[@]} - $retention))
  echo -e "${YELLOW}Removing $to_delete old backups...${NC}"
  
  for i in $(seq $retention $((${#backups[@]} - 1))); do
    echo "Removing: ${backups[$i]}"
    rm "${backups[$i]}"
  done
  
  echo -e "${GREEN}Cleanup complete.${NC}"
  return 0
}

# Print usage information
print_usage() {
  echo -e "${CYAN}Pipe Network Node Backup Utility (Community Enhancement)${NC}"
  echo -e "${CYAN}Version: ${VERSION}${NC}"
  echo
  echo "Usage: $0 [command] [options]"
  echo
  echo "Commands:"
  echo "  create         Create a new backup"
  echo "  restore FILE   Restore from backup FILE"
  echo "  list           List available backups"
  echo "  cleanup [N]    Remove old backups, keeping last N (default: $DEFAULT_RETENTION)"
  echo
  echo "Options for 'create':"
  echo "  --stop-service  Stop the node service during backup"
  echo
}

# Main function
main() {
  # Check for required directories
  check_directories || exit 1
  
  # Process commands
  case "$1" in
    create)
      shift
      create_backup "$@"
      ;;
    restore)
      if [[ -z "$2" ]]; then
        echo -e "${RED}Error: Backup file not specified.${NC}"
        print_usage
        exit 1
      fi
      restore_backup "$2"
      ;;
    list)
      list_backups
      ;;
    cleanup)
      cleanup_backups "$2"
      ;;
    help|--help|-h)
      print_usage
      ;;
    *)
      print_usage
      exit 1
      ;;
  esac
}

# If called directly, run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi 