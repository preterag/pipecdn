#!/bin/bash
# Community wrapper for the Pipe Network PoP management tool

VERSION="community-v0.0.1"
NODE_INFO_FILE="$HOME/node_info.json"
WORKSPACE_NODE_INFO_FILE="$HOME/Workspace/pipe-pop/node_info.json"

echo "Pipe Network Community Node Management v$VERSION loaded"

display_help() {
    cat << EOF
Pipe Network PoP Node Management Tool v$VERSION

Usage: pop [options]

Options:
  --status             Display the status of the node
  --register           Register a new node
  --help               Display this help message and exit
  --version            Display version information and exit
  --dashboard          Launch the node monitoring dashboard

For official documentation, visit: https://docs.pipe.network
EOF
}

display_version() {
    echo "Pipe Network PoP Node Management Tool v$VERSION"
}

# Check if both node_info.json files exist and use the one that exists
# If both exist, use the one in Workspace
check_node_info() {
    if [ -f "$WORKSPACE_NODE_INFO_FILE" ]; then
        echo "Using existing node_info.json located at $WORKSPACE_NODE_INFO_FILE"
        NODE_INFO_FILE="$WORKSPACE_NODE_INFO_FILE"
    elif [ -f "$NODE_INFO_FILE" ]; then
        echo "Using existing node_info.json located at $NODE_INFO_FILE"
    else
        echo "No node_info.json found."
        return 1
    fi
    return 0
}

display_status() {
    check_node_info
    if [ $? -eq 0 ]; then
        # Parse the node_id from node_info.json
        NODE_ID=$(grep -o '"node_id": "[^"]*' "$NODE_INFO_FILE" | cut -d'"' -f4)
        IS_REGISTERED=$(grep -o '"registered": [^,]*' "$NODE_INFO_FILE" | cut -d' ' -f2)
        
        echo "Node ID: $NODE_ID"
        if [ "$IS_REGISTERED" == "true" ]; then
            echo "Registration status: Registered"
        else
            echo "Registration status: Not registered"
        fi
        
        # Check if metrics are available
        if [ -f "/opt/pipe-pop/metrics/current.json" ]; then
            echo "Metrics: Available (view with pop --dashboard)"
        else
            echo "Metrics: No metrics available yet. Run the node for a while to generate metrics."
        fi
    fi
}

register_node() {
    # Forward to the official register command
    /opt/pipe-pop/bin/pipe-pop --register
}

launch_dashboard() {
    # Launch the custom dashboard script
    /home/karo/Workspace/pipe-pop/dashboard.sh
}

# Main logic
if [ "$1" == "--help" ]; then
    display_help
elif [ "$1" == "--version" ]; then
    display_version
elif [ "$1" == "--status" ]; then
    display_status
elif [ "$1" == "--register" ]; then
    register_node
elif [ "$1" == "--dashboard" ]; then
    launch_dashboard
else
    # Forward other commands to the official binary
    /opt/pipe-pop/bin/pipe-pop "$@"
fi 