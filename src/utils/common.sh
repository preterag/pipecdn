#!/bin/bash
# Pipe Network PoP Node Management Tools
# Common Utilities and Helper Functions

# Import color definitions and logging functions from command.sh
UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$UTILS_DIR")")"
source "${ROOT_DIR}/src/core/command.sh"

# =====================
# Helper Functions
# =====================

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if a directory exists and is writable
check_dir_writable() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    return 1
  fi
  if [[ ! -w "$dir" ]]; then
    return 2
  fi
  return 0
}

# Check if a file exists and is readable
check_file_readable() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  if [[ ! -r "$file" ]]; then
    return 2
  fi
  return 0
}

# Confirm action with the user
confirm_action() {
  local message="$1"
  local default="${2:-y}"
  
  local prompt
  if [[ "$default" == "y" ]]; then
    prompt="${message} [Y/n]: "
  else
    prompt="${message} [y/N]: "
  fi
  
  read -r -p "$prompt" response
  response=${response,,} # Convert to lowercase
  
  if [[ -z "$response" ]]; then
    response="$default"
  fi
  
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    return 0
  else
    return 1
  fi
}

# Format a timestamp in a human-readable format
format_timestamp() {
  local timestamp="$1"
  local format="${2:-%Y-%m-%d %H:%M:%S}"
  
  date -d "@$timestamp" +"$format" 2>/dev/null || \
  date -r "$timestamp" +"$format" 2>/dev/null || \
  echo "Invalid timestamp"
}

# Format bytes to human-readable size
format_bytes() {
  local bytes="$1"
  local precision="${2:-2}"
  
  if [[ $bytes -lt 1024 ]]; then
    echo "${bytes} B"
  elif [[ $bytes -lt 1048576 ]]; then
    echo "$(printf "%.${precision}f" "$(echo "scale=$precision; $bytes/1024" | bc)") KB"
  elif [[ $bytes -lt 1073741824 ]]; then
    echo "$(printf "%.${precision}f" "$(echo "scale=$precision; $bytes/1048576" | bc)") MB"
  else
    echo "$(printf "%.${precision}f" "$(echo "scale=$precision; $bytes/1073741824" | bc)") GB"
  fi
}

# Get absolute path from a relative path
get_absolute_path() {
  local path="$1"
  if [[ -d "$path" ]]; then
    (cd "$path" && pwd)
  elif [[ -f "$path" ]]; then
    local dir=$(dirname "$path")
    local file=$(basename "$path")
    echo "$(cd "$dir" && pwd)/$file"
  else
    echo "$path" # Return as is if neither file nor directory
  fi
}

# JSON helper to check if a key exists
json_key_exists() {
  local json="$1"
  local key="$2"
  
  if command_exists jq; then
    echo "$json" | jq -e ".$key" >/dev/null
    return $?
  else
    return 2 # No jq installed
  fi
}

# JSON helper to get a value from a key
json_get_value() {
  local json="$1"
  local key="$2"
  local default="$3"
  
  if command_exists jq; then
    local value=$(echo "$json" | jq -r ".$key")
    if [[ "$value" == "null" && -n "$default" ]]; then
      echo "$default"
    else
      echo "$value"
    fi
  else
    echo "$default"
  fi
}

# Safe way to delete files (with confirmation for important ones)
safe_delete() {
  local path="$1"
  local force="${2:-false}"
  
  if [[ ! -e "$path" ]]; then
    log_debug "File/directory doesn't exist: $path"
    return 0
  fi
  
  # Check if this is an important system file
  if [[ "$path" == /etc/* || "$path" == /usr/* || "$path" == /bin/* || "$path" == /sbin/* ]]; then
    if [[ "$force" != "true" ]]; then
      log_error "Refusing to delete system file: $path"
      log_info "Use force=true to override this safety check"
      return 1
    else
      log_warn "Forcing deletion of system file: $path"
    fi
  fi
  
  # Delete with appropriate command
  if [[ -d "$path" && ! -L "$path" ]]; then
    rm -rf "$path"
  else
    rm -f "$path"
  fi
  
  log_debug "Deleted: $path"
  return $?
}

# Create a backup of a file
backup_file() {
  local file="$1"
  local backup="${2:-${file}.bak}"
  
  if [[ ! -f "$file" ]]; then
    log_error "Cannot backup non-existent file: $file"
    return 1
  fi
  
  cp -f "$file" "$backup"
  if [[ $? -eq 0 ]]; then
    log_debug "Created backup: $file -> $backup"
    return 0
  else
    log_error "Failed to create backup of $file"
    return 1
  fi
}

# If script is sourced, export functions
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  export -f command_exists
  export -f check_dir_writable
  export -f check_file_readable
  export -f confirm_action
  export -f format_timestamp
  export -f format_bytes
  export -f get_absolute_path
  export -f json_key_exists
  export -f json_get_value
  export -f safe_delete
  export -f backup_file
fi 