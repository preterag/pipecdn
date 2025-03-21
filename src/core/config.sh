#!/bin/bash
# Configuration Management Module for Pipe Network PoP Node Management Tools
# This module handles configuration loading, saving, and management.

# =====================
# Configuration Paths
# =====================

# If these aren't already set by the parent script
if [[ -z "$INSTALL_DIR" ]]; then
  INSTALL_DIR="/opt/pipe-pop"
fi

if [[ -z "$CONFIG_DIR" ]]; then
  CONFIG_DIR="${INSTALL_DIR}/config"
fi

if [[ -z "$CONFIG_FILE" ]]; then
  CONFIG_FILE="${CONFIG_DIR}/config.json"
fi

if [[ -z "$LOCAL_CONFIG_FILE" ]]; then
  LOCAL_CONFIG_FILE="./config.json"
fi

# Templates
CONFIG_TEMPLATE="${ROOT_DIR}/config/config.template.json"
CONFIG_EXAMPLE="${ROOT_DIR}/config/examples/config.example.json"

# =====================
# Configuration Functions
# =====================

# Ensure config directory exists
ensure_config_dir() {
  if [[ ! -d "$CONFIG_DIR" ]]; then
    sudo mkdir -p "$CONFIG_DIR"
    sudo chmod 755 "$CONFIG_DIR"
    log_info "Created config directory: $CONFIG_DIR"
  fi
}

# Load configuration from file
load_config() {
  local config_file=""
  
  # Determine which config file to use
  if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
    config_file="$LOCAL_CONFIG_FILE"
    log_debug "Using local config file: $LOCAL_CONFIG_FILE"
  elif [[ -f "$CONFIG_FILE" ]]; then
    config_file="$CONFIG_FILE"
    log_debug "Using system config file: $CONFIG_FILE"
  else
    log_warn "No configuration file found."
    return 1
  fi
  
  # Validate config file
  if ! jq empty "$config_file" 2>/dev/null; then
    log_error "Invalid JSON in config file: $config_file"
    return 1
  fi
  
  log_debug "Configuration loaded successfully from: $config_file"
  return 0
}

# Save configuration to file
save_config() {
  local config_data="$1"
  local target_file="$2"
  
  # Validate input
  if [[ -z "$config_data" ]]; then
    log_error "No configuration data provided."
    return 1
  fi
  
  if [[ -z "$target_file" ]]; then
    # Default to system config file
    target_file="$CONFIG_FILE"
    ensure_config_dir
  fi
  
  # Validate JSON
  if ! echo "$config_data" | jq empty 2>/dev/null; then
    log_error "Invalid JSON data."
    return 1
  fi
  
  # Create parent directory if needed
  local parent_dir=$(dirname "$target_file")
  if [[ ! -d "$parent_dir" ]]; then
    mkdir -p "$parent_dir"
  fi
  
  # Write config
  echo "$config_data" > "$target_file"
  if [[ $? -ne 0 ]]; then
    log_error "Failed to write config to: $target_file"
    return 1
  fi
  
  log_debug "Configuration saved to: $target_file"
  return 0
}

# Get a value from the config
get_config_value() {
  local key="$1"
  local default_value="$2"
  local config_file=""
  
  # Determine which config file to use
  if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
    config_file="$LOCAL_CONFIG_FILE"
  elif [[ -f "$CONFIG_FILE" ]]; then
    config_file="$CONFIG_FILE"
  else
    echo "$default_value"
    return 1
  fi
  
  # Extract value
  local value=$(jq -r "$key" "$config_file" 2>/dev/null)
  
  # Check if value exists and is not null
  if [[ $? -ne 0 || "$value" == "null" ]]; then
    echo "$default_value"
    return 1
  fi
  
  echo "$value"
  return 0
}

# Set a value in the config
set_config_value() {
  local key="$1"
  local value="$2"
  local config_file="$3"
  
  # Determine which config file to use
  if [[ -z "$config_file" ]]; then
    if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
      config_file="$LOCAL_CONFIG_FILE"
    elif [[ -f "$CONFIG_FILE" ]]; then
      config_file="$CONFIG_FILE"
    else
      # Create a new config file
      if [[ -f "$CONFIG_TEMPLATE" ]]; then
        cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"
        config_file="$CONFIG_FILE"
        ensure_config_dir
      else
        log_error "No config file exists and no template available."
        return 1
      fi
    fi
  fi
  
  # Read current config
  local config_data=$(cat "$config_file")
  if [[ $? -ne 0 ]]; then
    log_error "Failed to read config file: $config_file"
    return 1
  fi
  
  # Update value
  local new_config=$(echo "$config_data" | jq "$key = $value" 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    log_error "Failed to update config value."
    return 1
  fi
  
  # Save updated config
  save_config "$new_config" "$config_file"
  return $?
}

# =====================
# Configuration UI
# =====================

# Configure node with interactive wizard
configure_node() {
  local use_wizard=false
  local key_to_set=""
  local value_to_set=""
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --wizard)
        use_wizard=true
        shift
        ;;
      --set)
        # Format: --set KEY=VALUE
        if [[ -n "$2" && "$2" =~ ^([^=]+)=(.*)$ ]]; then
          key_to_set="${BASH_REMATCH[1]}"
          value_to_set="${BASH_REMATCH[2]}"
          shift 2
        else
          log_error "Invalid --set format. Use --set KEY=VALUE"
          return 1
        fi
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Handle direct key=value setting
  if [[ -n "$key_to_set" && -n "$value_to_set" ]]; then
    log_info "Setting configuration: $key_to_set = $value_to_set"
    set_config_value "$key_to_set" "$value_to_set"
    return $?
  fi
  
  # Interactive wizard
  if [[ "$use_wizard" == "true" ]]; then
    print_header "CONFIGURATION WIZARD"
    echo -e "This wizard will guide you through configuring your Pipe Network node."
    echo
    
    # Check if config file exists
    local config_exists=false
    local config_file=""
    
    if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
      config_exists=true
      config_file="$LOCAL_CONFIG_FILE"
    elif [[ -f "$CONFIG_FILE" ]]; then
      config_exists=true
      config_file="$CONFIG_FILE"
    fi
    
    if [[ "$config_exists" == "true" ]]; then
      echo -e "Found existing configuration at: $config_file"
      echo -e "This wizard will update the existing configuration."
    else
      echo -e "No existing configuration found. Creating new configuration."
      
      # Create new config from template
      if [[ -f "$CONFIG_TEMPLATE" ]]; then
        ensure_config_dir
        cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"
        config_file="$CONFIG_FILE"
      else
        log_error "Configuration template not found."
        return 1
      fi
    fi
    
    echo
    
    # Collect wallet address
    local current_wallet=$(get_wallet_address)
    if [[ "$current_wallet" == "No wallet configured" ]]; then
      current_wallet=""
    fi
    
    local new_wallet=""
    echo -e "Wallet Configuration"
    echo -e "------------------"
    if [[ -n "$current_wallet" ]]; then
      echo -e "Current wallet: $current_wallet"
      echo -ne "Enter new wallet address (or press Enter to keep current): "
    else
      echo -e "No wallet configured."
      echo -ne "Enter wallet address: "
    fi
    read new_wallet
    
    if [[ -n "$new_wallet" ]]; then
      # Validate wallet format (basic check)
      if [[ ! "$new_wallet" =~ ^[a-zA-Z0-9]{32,44}$ ]]; then
        log_warn "Wallet address format may be invalid."
        echo -ne "Continue anyway? (y/n): "
        read confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          log_info "Configuration cancelled."
          return 1
        fi
      fi
      
      # Update wallet
      if set_config_value '.node.wallet' "\"$new_wallet\"" "$config_file"; then
        log_info "Wallet address updated."
      else
        log_error "Failed to update wallet address."
        return 1
      fi
    fi
    
    echo
    echo -e "${GREEN}Configuration saved successfully.${NC}"
    return 0
  fi
  
  # Default behavior: show current config
  print_header "CONFIGURATION"
  
  if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
    echo -e "Local configuration file: $LOCAL_CONFIG_FILE"
    echo
    cat "$LOCAL_CONFIG_FILE" | jq
  elif [[ -f "$CONFIG_FILE" ]]; then
    echo -e "System configuration file: $CONFIG_FILE"
    echo
    cat "$CONFIG_FILE" | jq
  else
    echo -e "No configuration file found."
    echo -e "Run 'pop configure --wizard' to create a configuration."
  fi
  
  return 0
}

# Wallet management
manage_wallet() {
  local show_info=false
  local new_wallet=""
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --info)
        show_info=true
        shift
        ;;
      --set|--set=*)
        if [[ "$1" == "--set" ]]; then
          if [[ -n "$2" ]]; then
            new_wallet="$2"
            shift 2
          else
            log_error "Missing wallet address for --set"
            return 1
          fi
        else
          new_wallet="${1#*=}"
          shift
        fi
        ;;
      *)
        shift
        ;;
    esac
  done
  
  # Set new wallet
  if [[ -n "$new_wallet" ]]; then
    print_header "SET WALLET"
    
    # Validate wallet format (basic check)
    if [[ ! "$new_wallet" =~ ^[a-zA-Z0-9]{32,44}$ ]]; then
      log_warn "Wallet address format may be invalid."
      echo -ne "Continue anyway? (y/n): "
      read confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Wallet update cancelled."
        return 1
      fi
    fi
    
    # Determine config file to use
    local config_file=""
    if [[ -f "$LOCAL_CONFIG_FILE" ]]; then
      config_file="$LOCAL_CONFIG_FILE"
    elif [[ -f "$CONFIG_FILE" ]]; then
      config_file="$CONFIG_FILE"
    else
      # Create new config
      ensure_config_dir
      echo '{"node":{"wallet":"'"$new_wallet"'"}}' > "$CONFIG_FILE"
      config_file="$CONFIG_FILE"
    fi
    
    # Update wallet in existing config
    if [[ -f "$config_file" ]]; then
      if set_config_value '.node.wallet' "\"$new_wallet\"" "$config_file"; then
        echo -e "${GREEN}Wallet address updated successfully.${NC}"
        return 0
      else
        log_error "Failed to update wallet address."
        return 1
      fi
    fi
    
    return 0
  fi
  
  # Show wallet info (default)
  print_header "WALLET INFO"
  
  local wallet=$(get_wallet_address)
  if [[ "$wallet" != "No wallet configured" ]]; then
    echo -e "Wallet Address: ${CYAN}$wallet${NC}"
    
    # TODO: Get additional wallet info from API if available
    # echo -e "Balance: ${CYAN}$balance${NC}"
    # echo -e "Earnings (7 days): ${CYAN}$earnings${NC}"
  else
    echo -e "${YELLOW}No wallet configured.${NC}"
    echo -e "Use 'pop wallet --set ADDRESS' to set a wallet address."
  fi
  
  return 0
}

# Show wallet info (legacy command)
show_wallet_info() {
  manage_wallet --info
}
