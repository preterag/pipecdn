#!/bin/bash
# Privilege Helper Module for Pipe Network PoP Node Management Tools
# This module provides functions to manage privilege escalation and permissions.

# Default sudo timeout (minutes)
SUDO_TIMEOUT=15

# Directory for sudo timestamp storage
SUDO_DIR="${HOME}/.cache/pipe-pop/sudo"

# File to track sudo status
SUDO_STATUS_FILE="${SUDO_DIR}/sudo_granted"

# =====================
# Privilege Helper Functions
# =====================

# Initialize sudo status directory
init_sudo_dir() {
  if [[ ! -d "$SUDO_DIR" ]]; then
    mkdir -p "$SUDO_DIR"
    chmod 700 "$SUDO_DIR"
  fi
}

# Check if sudo is currently active
is_sudo_active() {
  sudo -n true 2>/dev/null
  return $?
}

# Request sudo privileges once with custom timeout
request_sudo_once() {
  init_sudo_dir
  
  # Check if we already have sudo privileges
  if is_sudo_active; then
    # Update timestamp file
    touch "$SUDO_STATUS_FILE"
    return 0
  fi
  
  # Check if we've already shown the message
  if [[ ! -f "$SUDO_STATUS_FILE" || $(($(date +%s) - $(stat -c %Y "$SUDO_STATUS_FILE"))) -gt 300 ]]; then
    echo -e "\n${YELLOW}Requesting elevated privileges for system operations${NC}"
    echo -e "This will be cached for ${SUDO_TIMEOUT} minutes to avoid repeated prompts."
    echo -e "You can also run: ${CYAN}sudo pop --auth${NC} at any time.\n"
  fi
  
  # Request sudo permission and set timeout
  sudo -v -p "Please enter your password (will be cached for ${SUDO_TIMEOUT} minutes): " 
  local status=$?
  
  if [[ $status -eq 0 ]]; then
    # Set sudo timeout and mark as granted
    sudo sh -c "echo 'Defaults timestamp_timeout=${SUDO_TIMEOUT}' > /etc/sudoers.d/pipe-pop-timeout"
    touch "$SUDO_STATUS_FILE"
    return 0
  else
    return 1
  fi
}

# Run a command with privilege escalation if needed
run_with_privilege() {
  local cmd="$1"
  shift
  
  # Try to ensure we have sudo access
  request_sudo_once || return 1
  
  # Execute the command with sudo
  sudo "$cmd" "$@"
  return $?
}

# Create a directory with proper permissions, using sudo only if necessary
create_directory() {
  local dir="$1"
  local mode="${2:-755}"
  
  # If parent directory is writable, don't use sudo
  if [[ -w "$(dirname "$dir")" ]]; then
    mkdir -p "$dir"
    chmod "$mode" "$dir"
  else
    request_sudo_once || return 1
    sudo mkdir -p "$dir"
    sudo chmod "$mode" "$dir"
  fi
  
  return $?
}

# Determine if path requires sudo for write access
path_requires_sudo() {
  local path="$1"
  
  # Check if path exists and is writable
  if [[ -e "$path" ]]; then
    [[ ! -w "$path" ]]
    return $?
  fi
  
  # Check if parent directory is writable
  local parent_dir="$(dirname "$path")"
  [[ ! -w "$parent_dir" ]]
  return $?
}

# Grant appropriate permissions to a path
set_appropriate_permissions() {
  local path="$1"
  local is_user_install="$2"
  
  if [[ "$is_user_install" == "true" ]]; then
    # User installation, make sure current user owns it
    if path_requires_sudo "$path"; then
      run_with_privilege chown -R "$(id -u):$(id -g)" "$path"
    fi
    chmod -R u+rw "$path"
  else
    # System installation, ensure wide read permissions
    if path_requires_sudo "$path"; then
      run_with_privilege chmod -R 755 "$path"
    else
      chmod -R 755 "$path"
    fi
  fi
}

# Refresh sudo timestamp
refresh_sudo() {
  if [[ -f "$SUDO_STATUS_FILE" ]]; then
    sudo -v 2>/dev/null
    return $?
  else
    return 1
  fi
}

# Explicitly authenticate and cache sudo credentials
auth_sudo() {
  echo -e "Authenticating sudo privileges for ${CYAN}${SUDO_TIMEOUT}${NC} minutes..."
  request_sudo_once
  
  if is_sudo_active; then
    echo -e "${GREEN}Authentication successful!${NC} Sudo privileges granted for ${SUDO_TIMEOUT} minutes."
    echo -e "You won't be prompted for sudo password during this time."
    return 0
  else
    echo -e "${RED}Authentication failed!${NC} Unable to obtain sudo privileges."
    return 1
  fi
} 