#!/bin/bash
# web_installer.sh - Handles auto-launching the Web UI during installation

# Source common utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
if [ -f "$SCRIPT_DIR/../utils/common.sh" ]; then
    source "$SCRIPT_DIR/../utils/common.sh"
else
    # Define minimal logging functions if common.sh is not available
    log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
    log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
    log_debug() { echo -e "\033[0;34m[DEBUG]\033[0m $1"; }
fi

# Source browser detection utilities
if [ -f "$SCRIPT_DIR/browser_detect.sh" ]; then
    source "$SCRIPT_DIR/browser_detect.sh"
else
    log_error "Browser detection utilities not found"
    exit 1
fi

# Default port for the Web UI
DEFAULT_UI_PORT=8585

# Default timeout in seconds to wait for server to start
DEFAULT_TIMEOUT=30

# Function to check if Node.js is installed and meets requirements
# Returns 0 if Node.js is available and meets requirements, 1 otherwise
check_nodejs() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 14.x or higher."
        return 1
    fi
    
    # Check Node.js version
    local node_version
    node_version=$(node -v | cut -d 'v' -f 2)
    local major_version
    major_version=$(echo "$node_version" | cut -d '.' -f 1)
    
    if [ "$major_version" -lt 14 ]; then
        log_error "Node.js version $node_version is not supported. Please install Node.js 14.x or higher."
        return 1
    fi
    
    log_info "Node.js version $node_version found."
    return 0
}

# Function to check if npm is installed
# Returns 0 if npm is available, 1 otherwise
check_npm() {
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install npm."
        return 1
    fi
    
    local npm_version
    npm_version=$(npm -v)
    log_info "npm version $npm_version found."
    return 0
}

# Function to start the Web UI server
# Usage: start_ui_server [port]
start_ui_server() {
    local port=${1:-$DEFAULT_UI_PORT}
    local ui_server_script="$SCRIPT_DIR/../ui/server/app.js"
    
    # Check if the server script exists
    if [ ! -f "$ui_server_script" ]; then
        log_error "UI server script not found at $ui_server_script"
        return 1
    fi
    
    # Check if port is available, find another if not
    if ! is_port_available "$port"; then
        log_warn "Port $port is already in use."
        port=$(find_available_port "$((port + 1))")
        if [ $? -ne 0 ]; then
            log_error "Failed to find an available port."
            return 1
        fi
        log_info "Using alternative port: $port"
    fi
    
    # Start the server
    log_info "Starting Web UI server on port $port..."
    
    # Create the PID file directory if it doesn't exist
    mkdir -p ~/.local/share/pipe-pop/
    
    # Start server as a background process
    node "$ui_server_script" --port="$port" &> ~/.local/share/pipe-pop/ui-server.log &
    local server_pid=$!
    
    # Save PID for later management
    echo "$server_pid" > ~/.local/share/pipe-pop/ui-server.pid
    
    # Wait for server to start (check if port becomes unavailable)
    local timeout=$DEFAULT_TIMEOUT
    local elapsed=0
    while is_port_available "$port" && [ "$elapsed" -lt "$timeout" ]; do
        sleep 1
        elapsed=$((elapsed + 1))
        log_debug "Waiting for server to start... ($elapsed/$timeout)"
    done
    
    # Check if server started successfully
    if is_port_available "$port"; then
        log_error "Timed out waiting for server to start."
        return 1
    else
        log_info "Web UI server started successfully on port $port (PID: $server_pid)"
        echo "$port"
        return 0
    fi
}

# Function to auto-launch the Web UI in the browser
# Usage: launch_ui_wizard [port]
launch_ui_wizard() {
    local port=${1:-$DEFAULT_UI_PORT}
    local url="http://localhost:$port"
    
    log_info "Launching Web UI Installation Wizard..."
    
    # Generate a one-time token for wizard authentication
    local token
    token=$(openssl rand -hex 16 2>/dev/null || date +%s%N | sha256sum | head -c 32)
    
    # Save token for verification
    echo "$token" > ~/.local/share/pipe-pop/wizard-token.tmp
    
    # Append token to URL
    url="${url}/wizard?token=${token}"
    
    # Launch browser with URL
    launch_browser "$url"
    return $?
}

# Main function for auto-launching the Web UI
# Usage: auto_launch_ui [port]
auto_launch_ui() {
    local port=${1:-$DEFAULT_UI_PORT}
    
    # Check requirements
    check_nodejs || return 1
    check_npm || return 1
    
    # Start server
    local server_port
    server_port=$(start_ui_server "$port")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Launch browser
    launch_ui_wizard "$server_port"
    return $?
}

# Function to stop the UI server
stop_ui_server() {
    local pid_file=~/.local/share/pipe-pop/ui-server.pid
    
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file")
        
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping Web UI server (PID: $pid)..."
            kill "$pid"
            rm -f "$pid_file"
            log_info "Web UI server stopped."
            return 0
        else
            log_warn "Web UI server not running (PID: $pid)."
            rm -f "$pid_file"
            return 0
        fi
    else
        log_warn "No Web UI server PID file found."
        return 1
    fi
}

# Run the appropriate function based on command line arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        --auto-launch)
            port=${2:-$DEFAULT_UI_PORT}
            auto_launch_ui "$port"
            ;;
        --start-server)
            port=${2:-$DEFAULT_UI_PORT}
            start_ui_server "$port"
            ;;
        --launch-browser)
            port=${2:-$DEFAULT_UI_PORT}
            launch_ui_wizard "$port"
            ;;
        --stop)
            stop_ui_server
            ;;
        *)
            log_info "Usage: $0 [--auto-launch [port] | --start-server [port] | --launch-browser [port] | --stop]"
            log_info "  --auto-launch: Start server and launch browser"
            log_info "  --start-server: Start the UI server only"
            log_info "  --launch-browser: Launch browser only"
            log_info "  --stop: Stop the UI server"
            ;;
    esac
fi 