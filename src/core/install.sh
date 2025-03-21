#!/bin/bash
# Installation Management Module for Pipe Network PoP Node Management Tools
# This module handles installation, path management, and global command access.

# Set debug mode if requested
DEBUG="false"
QUIET="false"

# Load common functions
source "${SRC_DIR}/core/command.sh"

# Define installation paths
DEFAULT_SYSTEM_INSTALL_DIR="/opt/pipe-pop"
DEFAULT_USER_INSTALL_DIR="${HOME}/.local/share/pipe-pop"
GLOBAL_BIN_DIR="/usr/local/bin"
USER_BIN_DIR="${HOME}/.local/bin"

# XDG paths for configuration
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Load privilege helper
if [[ -f "${SRC_DIR}/core/privilege.sh" ]]; then
  source "${SRC_DIR}/core/privilege.sh"
fi

# =====================
# Installation Functions
# =====================

# Determine if this is a user-level installation
is_user_install() {
  local install_dir="$1"
  
  # Check if path is within user home directory
  if [[ "$install_dir" == "$HOME"* ]]; then
    return 0
  else
    return 1
  fi
}

# Get the appropriate bin directory based on installation type
get_bin_directory() {
  local install_dir="$1"
  
  if is_user_install "$install_dir"; then
    echo "$USER_BIN_DIR"
  else
    echo "$GLOBAL_BIN_DIR"
  fi
}

# Install the pop command globally
install_global_command() {
  local force=false
  local custom_dir=""
  local user_install=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force)
        force=true
        shift
        ;;
      --dir=*)
        custom_dir="${1#*=}"
        shift
        ;;
      --dir)
        if [[ -n "$2" ]]; then
          custom_dir="$2"
          shift 2
        else
          log_error "Missing directory for --dir"
          return 1
        fi
        ;;
      --user)
        user_install=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Set install directory based on installation type
  local install_dir=""
  if [[ -n "$custom_dir" ]]; then
    install_dir="$custom_dir"
  elif [[ "$user_install" == "true" ]]; then
    install_dir="$DEFAULT_USER_INSTALL_DIR"
  else
    install_dir="$DEFAULT_SYSTEM_INSTALL_DIR"
  fi
  
  # Determine if this is a user installation based on the path
  if is_user_install "$install_dir"; then
    user_install=true
  fi
  
  # Determine bin directory based on installation type
  local bin_dir=$(get_bin_directory "$install_dir")
  
  print_header "INSTALLING PIPE POP COMMAND"
  
  # Check if already installed
  if [[ -f "$bin_dir/pop" && "$force" != "true" ]]; then
    echo -e "${YELLOW}pop command is already installed.${NC}"
    echo -e "Use --force to reinstall."
    return 1
  fi
  
  # Show installation information
  local install_type="system-wide"
  if [[ "$user_install" == "true" ]]; then
    install_type="user-level"
  fi
  
  echo -e "Installing Pipe Network PoP Node Management Tools (${CYAN}${install_type}${NC})..."
  echo -e "Installation directory: ${CYAN}$install_dir${NC}"
  echo -e "Command location: ${CYAN}$bin_dir/pop${NC}"
  echo
  
  # Ensure the bin directory exists for user installations
  if [[ "$user_install" == "true" && ! -d "$bin_dir" ]]; then
    mkdir -p "$bin_dir"
  fi
  
  # Ensure installation directory exists
  if [[ ! -d "$install_dir" ]]; then
    echo -e "Creating installation directory..."
    create_directory "$install_dir"
  fi
  
  # Create required subdirectories
  for subdir in config logs metrics bin src tools; do
    if [[ ! -d "$install_dir/$subdir" ]]; then
      create_directory "$install_dir/$subdir"
    fi
  done
  
  # Create data directories with proper permissions
  for data_dir in "$install_dir/metrics/history" "$install_dir/metrics/alerts"; do
    create_directory "$data_dir"
  done
  
  # Determine source directory
  local source_dir=""
  
  # Use the repository root if we can find it
  if [[ -n "$ROOT_DIR" && -d "$ROOT_DIR" ]]; then
    source_dir="$ROOT_DIR"
  else
    # Try to determine from current script location
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "$script_dir/../../src" && -d "$script_dir/../../tools" ]]; then
      source_dir="$(cd "$script_dir/../.." && pwd)"
    else
      log_error "Could not determine source directory."
      return 1
    fi
  fi
  
  # Copy files using the appropriate method (sudo or direct)
  echo -e "Copying files to installation directory..."
  
  copy_files() {
    local src="$1"
    local dest="$2"
    
    if path_requires_sudo "$dest"; then
      run_with_privilege cp -r "$src" "$dest"
    else
      cp -r "$src" "$dest"
    fi
  }
  
  # Copy source files
  copy_files "$source_dir/src"/* "$install_dir/src/"
  copy_files "$source_dir/tools"/* "$install_dir/tools/"
  copy_files "$source_dir/bin"/* "$install_dir/bin/"
  
  # Copy config if it exists
  if [[ -d "$source_dir/config" ]]; then
    copy_files "$source_dir/config" "$install_dir/"
  fi
  
  # Set appropriate permissions for the installation directory
  set_appropriate_permissions "$install_dir" "$user_install"
  
  # Create wrapper script
  echo -e "Creating command wrapper..."
  cat > /tmp/pop-wrapper << EOF
#!/bin/bash
# Wrapper for Pipe Network PoP Node Management Tools

# Set installation directory
export INSTALL_DIR="$install_dir"
export ROOT_DIR="$install_dir"

# Execute the main script
exec "$install_dir/tools/pop" "\$@"
EOF
  
  chmod +x /tmp/pop-wrapper
  
  # Install the wrapper to the appropriate bin directory
  if path_requires_sudo "$bin_dir"; then
    run_with_privilege cp /tmp/pop-wrapper "$bin_dir/pop"
    run_with_privilege chmod +x "$bin_dir/pop"
  else
    cp /tmp/pop-wrapper "$bin_dir/pop"
    chmod +x "$bin_dir/pop"
  fi
  
  # Clean up
  rm -f /tmp/pop-wrapper
  
  echo -e "${GREEN}Installation complete!${NC}"
  
  # Add to path if necessary for user installations
  if [[ "$user_install" == "true" && "$PATH" != *"$bin_dir"* ]]; then
    echo -e "\nNOTE: To use the pop command, you may need to add this to your ~/.bashrc:"
    echo -e "${CYAN}export PATH=\"\$PATH:$bin_dir\"${NC}"
    echo -e "Then restart your terminal or run: ${CYAN}source ~/.bashrc${NC}"
  fi
  
  return 0
}

# Uninstall the pop command
uninstall_global_command() {
  local custom_dir=""
  local user_install=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dir=*)
        custom_dir="${1#*=}"
        shift
        ;;
      --dir)
        if [[ -n "$2" ]]; then
          custom_dir="$2"
          shift 2
        else
          log_error "Missing directory for --dir"
          return 1
        fi
        ;;
      --user)
        user_install=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Set install directory based on installation type
  local install_dir=""
  if [[ -n "$custom_dir" ]]; then
    install_dir="$custom_dir"
  elif [[ "$user_install" == "true" ]]; then
    install_dir="$DEFAULT_USER_INSTALL_DIR"
  else
    install_dir="$DEFAULT_SYSTEM_INSTALL_DIR"
  fi
  
  # Determine if this is a user installation based on the path
  if is_user_install "$install_dir"; then
    user_install=true
  fi
  
  # Determine bin directory based on installation type
  local bin_dir=$(get_bin_directory "$install_dir")
  
  print_header "UNINSTALLING PIPE POP COMMAND"
  
  # Confirm uninstallation
  echo -e "This will uninstall the Pipe Network PoP Node Management Tools."
  echo -e "Installation directory: ${CYAN}$install_dir${NC}"
  echo -e "Command location: ${CYAN}$bin_dir/pop${NC}"
  echo
  read -p "Are you sure you want to proceed? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "Uninstallation cancelled."
    return 1
  fi
  
  # Remove the command wrapper
  echo -e "Removing command wrapper..."
  if [[ -f "$bin_dir/pop" ]]; then
    if path_requires_sudo "$bin_dir/pop"; then
      run_with_privilege rm -f "$bin_dir/pop"
    else
      rm -f "$bin_dir/pop"
    fi
  fi
  
  # Remove installation directory
  if [[ -d "$install_dir" ]]; then
    echo -e "Removing installation directory..."
    if path_requires_sudo "$install_dir"; then
      run_with_privilege rm -rf "$install_dir"
    else
      rm -rf "$install_dir"
    fi
  fi
  
  # Clean up sudo timeout file if it exists
  if [[ -f "/etc/sudoers.d/pipe-pop-timeout" ]]; then
    run_with_privilege rm -f "/etc/sudoers.d/pipe-pop-timeout"
  fi
  
  echo -e "${GREEN}Uninstallation complete!${NC}"
  return 0
}

# Get the installation directory
get_install_dir() {
  # Check environment variable first
  if [[ -n "$INSTALL_DIR" ]]; then
    echo "$INSTALL_DIR"
    return 0
  fi
  
  # Check common locations
  local locations=(
    "$DEFAULT_SYSTEM_INSTALL_DIR"
    "$DEFAULT_USER_INSTALL_DIR"
  )
  
  for dir in "${locations[@]}"; do
    if [[ -d "$dir" && -f "$dir/tools/pop" ]]; then
      echo "$dir"
      return 0
    fi
  done
  
  # Default to current directory's parent if we're in src/core
  local current_dir="$(pwd)"
  if [[ "$current_dir" == *"/src/core" ]]; then
    echo "$(cd "../.." && pwd)"
    return 0
  fi
  
  # Return the repository root if available
  if [[ -n "$ROOT_DIR" ]]; then
    echo "$ROOT_DIR"
    return 0
  fi
  
  # If all else fails, use the system default
  echo "$DEFAULT_SYSTEM_INSTALL_DIR"
  return 1
}

# Update the installed pop command
update_global_command() {
  local source_dir=""
  
  # Determine source directory (same logic as install_global_command)
  if [[ -n "$ROOT_DIR" && -d "$ROOT_DIR" ]]; then
    source_dir="$ROOT_DIR"
  else
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "$script_dir/../../src" && -d "$script_dir/../../tools" ]]; then
      source_dir="$(cd "$script_dir/../.." && pwd)"
    else
      log_error "Could not determine source directory."
      return 1
    fi
  fi
  
  # Check if installed
  if [[ ! -f "$GLOBAL_BIN_DIR/pop" ]]; then
    echo -e "${YELLOW}pop command is not installed. Installing now...${NC}"
    install_global_command
    return $?
  fi
  
  # Determine installation directory from wrapper
  local install_dir=$(grep -oP 'INSTALL_DIR="\K[^"]+' "$GLOBAL_BIN_DIR/pop" 2>/dev/null)
  if [[ -z "$install_dir" ]]; then
    install_dir="$DEFAULT_SYSTEM_INSTALL_DIR"
  fi
  
  print_header "UPDATING PIPE POP COMMAND"
  echo -e "Updating Pipe Network PoP Node Management Tools..."
  echo -e "Installation directory: ${CYAN}$install_dir${NC}"
  echo
  
  # Update source files
  echo -e "Updating source files..."
  sudo cp -r "$source_dir/src"/* "$install_dir/src/"
  sudo cp -r "$source_dir/tools"/* "$install_dir/tools/"
  sudo cp -r "$source_dir/bin"/* "$install_dir/bin/"
  
  # Update wrapper script if needed
  echo -e "Updating global command wrapper..."
  sudo sed -i "s|INSTALL_DIR=.*|INSTALL_DIR=\"$install_dir\"|" "$GLOBAL_BIN_DIR/pop"
  
  echo -e "${GREEN}Update complete.${NC}"
  echo -e "Current version: ${CYAN}$(pop --version 2>/dev/null || echo "Unknown")${NC}"
  
  return 0
}

# Help function for installation
show_install_help() {
  print_header "INSTALLATION HELP"
  echo -e "Installation Commands:"
  echo -e "  ${CYAN}--install${NC}              Install pop command globally"
  echo -e "  ${CYAN}--install --force${NC}      Reinstall pop command globally"
  echo -e "  ${CYAN}--install --dir=PATH${NC}   Install to a custom directory"
  echo
  echo -e "  ${CYAN}--uninstall${NC}            Remove pop command and all files"
  echo -e "  ${CYAN}--uninstall --dir=PATH${NC} Remove but keep configuration"
  echo
  echo -e "  ${CYAN}--update${NC}               Update an existing installation"
  echo
  echo -e "Example:"
  echo -e "  ${CYAN}pop --install${NC}"
  echo -e "  ${CYAN}pop --install --dir=/opt/my-custom-dir${NC}"
  
  return 0
} 