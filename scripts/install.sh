#!/bin/bash
# Community Enhancement: Pipe Network Node Installer
# This script installs and configures the Pipe Network node with community enhancements.

# IMPORTANT: This is a community-created enhancement for Pipe Network.
# It is not part of the official Pipe Network project.
# For official documentation, please refer to the official Pipe Network documentation.

VERSION="community-v0.0.2"

# Color codes for output
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

# Print header
print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        PIPE NETWORK NODE INSTALLER         ║${NC}"
    echo -e "${CYAN}║           Community Enhancement            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo
    echo -e "Version: ${VERSION}"
    echo
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

print_header

# Installation variables
INSTALL_WEB_UI=false
AUTO_LAUNCH_UI=false

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --web-ui)
            INSTALL_WEB_UI=true
            shift
            ;;
        --auto-launch)
            AUTO_LAUNCH_UI=true
            INSTALL_WEB_UI=true
            shift
            ;;
        *)
            # Unknown option
            shift
            ;;
    esac
done

# Installation directory structure
INSTALL_DIR="/opt/pipe-pop"
CONFIG_DIR="${INSTALL_DIR}/config"
SRC_DIR="${INSTALL_DIR}/src"
BIN_DIR="${INSTALL_DIR}/bin"
CACHE_DIR="${INSTALL_DIR}/cache"
METRICS_DIR="${INSTALL_DIR}/metrics"
LOGS_DIR="${INSTALL_DIR}/logs"
BACKUPS_DIR="${INSTALL_DIR}/backups"
TOOLS_DIR="${INSTALL_DIR}/tools"
UI_DIR="${SRC_DIR}/ui"
INSTALLER_DIR="${SRC_DIR}/installer"

# Create directories with proper permissions
print_message "Creating installation directory structure..."
mkdir -p "${INSTALL_DIR}" "${CONFIG_DIR}" "${SRC_DIR}/core" "${SRC_DIR}/utils" "${BIN_DIR}" "${CACHE_DIR}" "${METRICS_DIR}" "${LOGS_DIR}" "${BACKUPS_DIR}" "${TOOLS_DIR}"
if [ "$INSTALL_WEB_UI" = true ]; then
    mkdir -p "${UI_DIR}" "${INSTALLER_DIR}"
fi
chmod 755 "${INSTALL_DIR}" "${BIN_DIR}" "${SRC_DIR}" "${TOOLS_DIR}"
chmod 700 "${CONFIG_DIR}" "${CACHE_DIR}" "${METRICS_DIR}" "${LOGS_DIR}" "${BACKUPS_DIR}"

# Install dependencies
print_message "Installing dependencies..."
apt-get update
apt-get install -y ufw curl jq netstat net-tools

# If Web UI is requested, install Node.js dependencies
if [ "$INSTALL_WEB_UI" = true ]; then
    print_message "Installing Web UI dependencies..."
    
    # Check if nodejs is installed
    if ! command -v node &> /dev/null; then
        print_message "Installing Node.js..."
        curl -sL https://deb.nodesource.com/setup_14.x | bash -
        apt-get install -y nodejs
    fi
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        print_message "Installing npm..."
        apt-get install -y npm
    fi
fi

# Configure firewall
print_message "Configuring firewall..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8003/tcp
if [ "$INSTALL_WEB_UI" = true ]; then
    ufw allow 8585/tcp
fi
ufw --force enable
ufw reload

# Download official binary
print_message "Downloading latest pipe-pop binary..."
# This would normally be downloaded from the official source
# For now, we'll create a placeholder
if [ -f "${BIN_DIR}/pipe-pop" ]; then
    print_message "Binary already exists, skipping download"
else
    print_warning "This is a placeholder for downloading the official binary"
    # In a real implementation, this would download from the official source
    # curl -L "https://github.com/pipe-network/pipe-pop/releases/latest/download/pipe-pop" -o "${BIN_DIR}/pipe-pop"
    touch "${BIN_DIR}/pipe-pop"
    chmod 755 "${BIN_DIR}/pipe-pop"
fi

# Copy community enhancement scripts
print_message "Installing community enhancement scripts..."
# Copy core node management
cp -r "$(dirname "$0")/src/core" "${SRC_DIR}/"
# Copy utility scripts
cp -r "$(dirname "$0")/src/utils" "${SRC_DIR}/"
# Copy configuration templates
cp -r "$(dirname "$0")/src/config" "${SRC_DIR}/"
# Copy the pop command tool
cp "$(dirname "$0")/tools/pop" "${TOOLS_DIR}/"

# Install Web UI components if requested
if [ "$INSTALL_WEB_UI" = true ]; then
    print_message "Installing Web UI components..."
    # Copy browser detection utilities
    cp -r "$(dirname "$0")/src/installer" "${SRC_DIR}/"
    # Copy Web UI files
    cp -r "$(dirname "$0")/src/ui" "${SRC_DIR}/"
    # Copy the pop-ui command tool
    cp "$(dirname "$0")/tools/pop-ui" "${TOOLS_DIR}/"
    
    # Install Node.js dependencies
    print_message "Installing Web UI server dependencies..."
    cd "${SRC_DIR}/ui/server" && npm install --no-audit
    
    # Create symbolic link for global pop-ui command
    print_message "Creating global 'pop-ui' command..."
    ln -sf "${TOOLS_DIR}/pop-ui" /usr/local/bin/pop-ui
    
    # Set correct permissions
    chmod 755 "${TOOLS_DIR}/pop-ui"
    chmod 755 "${SRC_DIR}/installer/browser_detect.sh"
    chmod 755 "${SRC_DIR}/installer/web_installer.sh"
fi

# Set correct permissions
chmod 755 "${SRC_DIR}/core/node.sh"
chmod 755 "${SRC_DIR}/core/monitoring/pulse.sh"
chmod 755 "${SRC_DIR}/utils/backup/backup.sh"
chmod 755 "${SRC_DIR}/utils/security/security_check.sh"
chmod 755 "${TOOLS_DIR}/pop"

# Create configuration from template
print_message "Creating configuration..."
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    cp "$(dirname "$0")/src/config/config.template.json" "${CONFIG_DIR}/config.json"
    chmod 600 "${CONFIG_DIR}/config.json"
    print_message "Created configuration file. Please edit ${CONFIG_DIR}/config.json to set your wallet address."
else
    print_message "Configuration file already exists. Skipping."
fi

# Create systemd service
print_message "Creating systemd service..."
cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=Pipe Network PoP Node
After=network.target

[Service]
Type=simple
User=root
ExecStart=${BIN_DIR}/pipe-pop
Restart=always
RestartSec=10
Environment=PIPE_CONFIG_DIR=${CONFIG_DIR}
Environment=PIPE_CACHE_DIR=${CACHE_DIR}
Environment=PIPE_METRICS_DIR=${METRICS_DIR}
Environment=PIPE_LOGS_DIR=${LOGS_DIR}
StandardOutput=append:${LOGS_DIR}/pipe-pop.log
StandardError=append:${LOGS_DIR}/pipe-pop-error.log

[Install]
WantedBy=multi-user.target
EOF

# Create Web UI systemd service if requested
if [ "$INSTALL_WEB_UI" = true ]; then
    print_message "Creating Web UI systemd service..."
    cat > /etc/systemd/system/pipe-pop-ui.service << EOF
[Unit]
Description=Pipe Network PoP Web UI
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${SRC_DIR}/ui/server
ExecStart=/usr/bin/node ${SRC_DIR}/ui/server/app.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
StandardOutput=append:${LOGS_DIR}/pipe-pop-ui.log
StandardError=append:${LOGS_DIR}/pipe-pop-ui-error.log

[Install]
WantedBy=multi-user.target
EOF

    # Enable the Web UI service if requested
    systemctl daemon-reload
    systemctl enable pipe-pop-ui.service
    
    # Auto-launch Web UI if requested
    if [ "$AUTO_LAUNCH_UI" = true ]; then
        print_message "Auto-launching Web UI..."
        source "${SRC_DIR}/installer/web_installer.sh"
        auto_launch_ui
    fi
fi

# Create symbolic link for global pop command
print_message "Creating global 'pop' command..."
ln -sf "${TOOLS_DIR}/pop" /usr/local/bin/pop

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable pipe-pop.service

print_message "Installation complete!"
print_message "To configure your Solana wallet address:"
echo -e "  ${YELLOW}sudo nano ${CONFIG_DIR}/config.json${NC}"
print_message "To start the node:"
echo -e "  ${YELLOW}pop start${NC}"
print_message "To check node status:"
echo -e "  ${YELLOW}pop status${NC}"
print_message "To monitor in real-time:"
echo -e "  ${YELLOW}pop monitoring pulse${NC}"

if [ "$INSTALL_WEB_UI" = true ]; then
    print_message "To manage the Web UI:"
    echo -e "  ${YELLOW}pop-ui start${NC}  - Start the Web UI server"
    echo -e "  ${YELLOW}pop-ui stop${NC}   - Stop the Web UI server"
    echo -e "  ${YELLOW}pop-ui status${NC} - Check Web UI server status"
    
    # Show URL for accessing Web UI
    if [ "$AUTO_LAUNCH_UI" = true ]; then
        print_message "Web UI is now available at: ${YELLOW}http://localhost:8585${NC}"
    else
        print_message "You can access the Web UI by running: ${YELLOW}pop-ui start --launch${NC}"
    fi
fi

echo
print_warning "This is a community-enhanced installation. For official support, please refer to the official Pipe Network documentation."
echo
print_message "View full documentation in the ${YELLOW}docs/${NC} directory." 