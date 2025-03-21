#!/bin/bash
# browser_detect.sh - Utility for detecting and launching browsers

# Source the common utilities if they exist
if [ -f "$(dirname "${BASH_SOURCE[0]}")/../utils/common.sh" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../utils/common.sh"
else
    # Define minimal logging functions if common.sh is not available
    log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
    log_warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
    log_debug() { echo -e "\033[0;34m[DEBUG]\033[0m $1"; }
fi

# Detect available browsers
# Returns the command to use for opening a URL
detect_browser() {
    local browser_cmd=""
    
    # Check for the default system browser command
    if command -v xdg-open &> /dev/null; then
        browser_cmd="xdg-open"
        log_debug "Found browser launcher: xdg-open (Linux default)"
    elif command -v open &> /dev/null; then
        browser_cmd="open"
        log_debug "Found browser launcher: open (macOS default)"
    else
        # Check for specific browsers
        if command -v google-chrome &> /dev/null; then
            browser_cmd="google-chrome"
            log_debug "Found browser: Google Chrome"
        elif command -v chromium-browser &> /dev/null; then
            browser_cmd="chromium-browser"
            log_debug "Found browser: Chromium"
        elif command -v firefox &> /dev/null; then
            browser_cmd="firefox"
            log_debug "Found browser: Firefox"
        elif command -v brave-browser &> /dev/null; then
            browser_cmd="brave-browser"
            log_debug "Found browser: Brave"
        elif command -v microsoft-edge &> /dev/null; then
            browser_cmd="microsoft-edge"
            log_debug "Found browser: Microsoft Edge"
        elif command -v opera &> /dev/null; then
            browser_cmd="opera"
            log_debug "Found browser: Opera"
        elif command -v safari &> /dev/null; then
            browser_cmd="safari"
            log_debug "Found browser: Safari"
        fi
    fi
    
    echo "$browser_cmd"
}

# Launch browser with URL
# Usage: launch_browser <url>
launch_browser() {
    local url="$1"
    local browser_cmd
    
    # Get browser command
    browser_cmd=$(detect_browser)
    
    if [ -z "$browser_cmd" ]; then
        log_error "No web browser found. Please open the URL manually: $url"
        return 1
    else
        log_info "Launching browser: $browser_cmd"
        # Launch browser in background and discard output
        "$browser_cmd" "$url" &> /dev/null &
        
        # Check if browser launched successfully
        if [ $? -eq 0 ]; then
            log_info "Browser launched successfully. Opening: $url"
            return 0
        else
            log_error "Failed to launch browser. Please open the URL manually: $url"
            return 1
        fi
    fi
}

# Function to check if a port is available
# Usage: is_port_available <port>
is_port_available() {
    local port="$1"
    if command -v nc &> /dev/null; then
        nc -z localhost "$port" &> /dev/null
        if [ $? -eq 0 ]; then
            # Port is in use
            return 1
        else
            # Port is available
            return 0
        fi
    elif command -v lsof &> /dev/null; then
        lsof -i:"$port" &> /dev/null
        if [ $? -eq 0 ]; then
            # Port is in use
            return 1
        else
            # Port is available
            return 0
        fi
    else
        # Can't check, assume it's available
        log_warn "Cannot check if port $port is available. Assuming it is."
        return 0
    fi
}

# Find an available port starting from the given port
# Usage: find_available_port <start_port>
find_available_port() {
    local port="$1"
    local max_tries=10
    local tries=0
    
    while [ "$tries" -lt "$max_tries" ]; do
        if is_port_available "$port"; then
            echo "$port"
            return 0
        fi
        port=$((port + 1))
        tries=$((tries + 1))
    done
    
    log_error "Could not find an available port after $max_tries attempts"
    return 1
}

# Main function for testing browser detection
# Usage: test_browser_detection
test_browser_detection() {
    local browser_cmd
    
    browser_cmd=$(detect_browser)
    if [ -z "$browser_cmd" ]; then
        log_error "No browser detected"
        return 1
    else
        log_info "Detected browser command: $browser_cmd"
        return 0
    fi
}

# If script is run directly (not sourced), run the test function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$1" == "--test" ]; then
        test_browser_detection
    elif [ "$1" == "--launch" ] && [ -n "$2" ]; then
        launch_browser "$2"
    else
        log_info "Usage: $0 [--test | --launch <url>]"
        log_info "  --test: Test browser detection"
        log_info "  --launch <url>: Launch browser with the specified URL"
    fi
fi 