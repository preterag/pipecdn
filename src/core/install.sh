#!/bin/bash
# Installation Management Module for Pipe Network PoP Node Management Tools
# This module handles installation, path management, and global command access.

# Define installation paths
DEFAULT_INSTALL_DIR="/opt/pipe-pop"
GLOBAL_BIN_DIR="/usr/local/bin"

# =====================
# Installation Functions
# =====================

# Install the pop command globally
install_global_command() {
  local force=false
  local custom_dir=""
  
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
      *)
        shift
        ;;
    esac
  done
  
  # Set install directory
  local install_dir="${custom_dir:-$DEFAULT_INSTALL_DIR}"
  
  print_header "INSTALLING PIPE POP COMMAND"
  
  # Check if already installed
  if [[ -f "$GLOBAL_BIN_DIR/pop" && "$force" != "true" ]]; then
    echo -e "${YELLOW}pop command is already installed.${NC}"
    echo -e "Use --force to reinstall."
    return 1
  fi
  
  echo -e "Installing Pipe Network PoP Node Management Tools..."
  echo -e "Installation directory: ${CYAN}$install_dir${NC}"
  echo -e "Global command: ${CYAN}$GLOBAL_BIN_DIR/pop${NC}"
  echo
  
  # Ensure installation directory exists
  if [[ ! -d "$install_dir" ]]; then
    echo -e "Creating installation directory..."
    sudo mkdir -p "$install_dir"
    sudo chmod 755 "$install_dir"
  fi
  
  # Create required subdirectories
  for subdir in config logs metrics bin src tools; do
    if [[ ! -d "$install_dir/$subdir" ]]; then
      sudo mkdir -p "$install_dir/$subdir"
      sudo chmod 755 "$install_dir/$subdir"
    fi
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
  
  echo -e "Copying files from: ${CYAN}$source_dir${NC}"
  
  # Copy source files
  sudo cp -r "$source_dir/src"/* "$install_dir/src/"
  sudo cp -r "$source_dir/tools"/* "$install_dir/tools/"
  sudo cp -r "$source_dir/bin"/* "$install_dir/bin/"
  
  # Copy configuration templates
  if [[ -d "$source_dir/config" ]]; then
    sudo cp -r "$source_dir/config" "$install_dir/"
  fi
  
  # Create the global command wrapper
  echo -e "Creating global command wrapper..."
  
  # Create wrapper script
  cat > /tmp/pop-wrapper << 'EOF'
#!/bin/bash
# Pipe Network PoP Node Management Tools - Global Command Wrapper

# Determine installation directory
INSTALL_DIR="##INSTALL_DIR##"

# Ensure the directory exists
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Error: Installation directory not found at $INSTALL_DIR"
  echo "Please reinstall the Pipe Network PoP Node Management Tools."
  exit 1
fi

# Define paths
export ROOT_DIR="$INSTALL_DIR"
export PATH="$INSTALL_DIR/bin:$PATH"

# Execute the main script with all arguments
"$INSTALL_DIR/tools/pop" "$@"
EOF

  # Replace placeholder with actual install directory
  sed -i "s|##INSTALL_DIR##|$install_dir|g" /tmp/pop-wrapper
  
  # Install wrapper script to global bin directory
  sudo cp /tmp/pop-wrapper "$GLOBAL_BIN_DIR/pop"
  sudo chmod +x "$GLOBAL_BIN_DIR/pop"
  rm /tmp/pop-wrapper
  
  # Verify installation
  if [[ -f "$GLOBAL_BIN_DIR/pop" ]]; then
    echo -e "${GREEN}Installation complete.${NC}"
    echo -e "You can now run the 'pop' command from any directory."
    echo
    echo -e "Try running: ${CYAN}pop --help${NC}"
  else
    log_error "Installation failed."
    return 1
  fi
  
  return 0
}

# Uninstall the pop command and cleanup
uninstall_global_command() {
  local keep_data=false
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --keep-data)
        keep_data=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  
  print_header "UNINSTALLING PIPE POP COMMAND"
  
  # Check if installed
  if [[ ! -f "$GLOBAL_BIN_DIR/pop" ]]; then
    echo -e "${YELLOW}pop command is not installed.${NC}"
    return 1
  fi
  
  # Determine installation directory from wrapper
  local install_dir=$(grep -oP 'INSTALL_DIR="\K[^"]+' "$GLOBAL_BIN_DIR/pop" 2>/dev/null)
  if [[ -z "$install_dir" ]]; then
    install_dir="$DEFAULT_INSTALL_DIR"
  fi
  
  echo -e "Removing Pipe Network PoP Node Management Tools..."
  echo -e "Installation directory: ${CYAN}$install_dir${NC}"
  echo -e "Global command: ${CYAN}$GLOBAL_BIN_DIR/pop${NC}"
  echo
  
  # Remove global command
  echo -e "Removing global command..."
  sudo rm -f "$GLOBAL_BIN_DIR/pop"
  
  # Remove installation directory
  if [[ -d "$install_dir" && "$keep_data" != "true" ]]; then
    echo -e "Removing installation directory..."
    sudo rm -rf "$install_dir"
  elif [[ -d "$install_dir" && "$keep_data" == "true" ]]; then
    # Only remove code but keep data
    echo -e "Removing code files but keeping data..."
    sudo rm -rf "$install_dir/src" "$install_dir/tools" "$install_dir/bin"
  fi
  
  echo -e "${GREEN}Uninstallation complete.${NC}"
  
  if [[ "$keep_data" == "true" ]]; then
    echo -e "Data files in ${CYAN}$install_dir${NC} have been preserved."
  fi
  
  return 0
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
    install_dir="$DEFAULT_INSTALL_DIR"
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
  echo -e "  ${CYAN}--uninstall --keep-data${NC} Remove but keep configuration"
  echo
  echo -e "  ${CYAN}--update${NC}               Update an existing installation"
  echo
  echo -e "Example:"
  echo -e "  ${CYAN}pop --install${NC}"
  echo -e "  ${CYAN}pop --install --dir=/opt/my-custom-dir${NC}"
  
  return 0
} 