#!/bin/bash

# Pipe PoP Node Easy Setup Script
# Version: 1.2.0
# pipe-pop Easy Setup Script
# Version: 1.1.0
#
# This script provides a one-command setup for the pipe-pop
#
# NOTE: This is a more user-friendly version of setup.sh that provides
# a guided installation process with interactive prompts. If you prefer
# a non-interactive setup, you can use setup.sh instead.
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

set -e
set -o pipefail
set -x  # Enable debug mode

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define log file with timestamp
LOG_FILE="$GITHUB_WORKSPACE/var/log/pipe-pop-setup_$(date +%Y%m%d_%H%M%S).log"
sudo mkdir -p /var/log/
sudo touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1



# Logging functions
log() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${RED}[ERROR]${NC} $1" >&2; }

# Ensure script is run as root
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

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Display version information
print_message "pipe-pop Easy Setup Tool v1.1.0"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root. Use sudo."
    exit 1
fi

# Cleanup function on exit
cleanup() {
    echo "Cleaning up temporary files..."
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

trap cleanup EXIT


# Display welcome message
clear
log "Pipe PoP Easy Setup Tool v1.2.0"
log "Setting up Pipe PoP node for the Pipe Network decentralized CDN."
print_header "pipe-pop Easy Setup"
echo ""
print_message "Welcome to the pipe-pop Easy Setup!"
print_message "This script will guide you through setting up a pipe-pop for the Pipe Network decentralized CDN."
echo ""
print_message "The setup will:"
echo "  - Install all necessary dependencies"
echo "  - Set up your Solana wallet (or use your existing one)"
echo "  - Download and configure the pipe-pop binary"
echo "  - Set up a systemd service for reliable operation"
echo "  - Configure automatic backups"
echo "  - Apply the Surrealine referral code (optional)"
print_highlight "  - Install the global 'pop' command for easy management from anywhere"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Install dependencies
install_dependencies() {
    log "Installing required packages..."
    local packages=(curl net-tools jq git)
    local to_install=()
    for pkg in "${packages[@]}"; do
        dpkg -s "$pkg" &>/dev/null || to_install+=("$pkg")
    done
    if [ "${#to_install[@]}" -gt 0 ]; then
        apt-get update && apt-get install -y "${to_install[@]}" || { error "Failed to install packages"; exit 1; }
    else
        log "All required packages are already installed."
    fi
}

# Function to setup Pipe PoP Node
setup_pipe_pop() {
    INSTALL_DIR="/opt/pipe-pop"
    log "Setting up Pipe PoP Node..."
    mkdir -p "$INSTALL_DIR"
# Create a temporary directory for the setup
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Step 1: Check system requirements
print_header "Checking System Requirements"

# Check RAM
total_ram=$(free -m | awk '/^Mem:/{print $2}')
available_ram=$(free -m | awk '/^Mem:/{print $7}')

if [ "$available_ram" -lt 2048 ]; then
    print_warning "Available RAM is less than 2GB (${available_ram}MB). This might affect performance."
else
    print_message "RAM check passed: ${available_ram}MB available out of ${total_ram}MB total."
fi

# Check disk space
disk_space=$(df -m . | awk 'NR==2 {print $4}')

if [ "$disk_space" -lt 10240 ]; then
    print_warning "Available disk space is less than 10GB (${disk_space}MB). This might not be enough for long-term operation."
else
    print_message "Disk space check passed: ${disk_space}MB available."
fi

# Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_message "Operating System: $PRETTY_NAME"
else
    print_warning "Could not determine OS version."
fi

# Step 2: Install dependencies
print_header "Installing Dependencies"

print_message "Updating package lists..."
apt-get update

print_message "Installing required packages..."
apt-get install -y curl net-tools jq

# Step 3: Clone the repository
print_header "Setting Up pipe-pop"

print_message "Creating installation directory..."
INSTALL_DIR="/opt/pipe-pop"
mkdir -p "$INSTALL_DIR"

print_message "Downloading pipe-pop files..."
git clone https://github.com/preterag/pipecdn.git "$INSTALL_DIR" || {
    print_message "Repository already exists, updating instead..."
    cd "$INSTALL_DIR"
    if [ -d ".git" ]; then
        log "Updating existing repository..."
        git pull || { error "Failed to update Pipe PoP repository."; exit 1; }
    else
        log "Cloning Pipe PoP repository..."
        git clone https://github.com/preterag/pipecdn.git "$INSTALL_DIR" || { error "Failed to clone repository."; exit 1; }
    fi
}

# Setup Solana Wallet
setup_solana_wallet() {
    log "Installing Solana CLI..."
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)" || { error "Solana CLI installation failed."; exit 1; }
    mkdir -p ~/.config/solana
    read -p "Create a new Solana wallet? (y/n): " create_wallet
    if [[ "$create_wallet" =~ ^[yY]$ ]]; then
        solana-keygen new --no-passphrase
        SOLANA_WALLET=$(solana address)
    else
        read -p "Enter existing Solana wallet address: " SOLANA_WALLET
    fi
    echo "$SOLANA_WALLET" | sudo tee /opt/pipe-pop/wallet.txt > /dev/null
    log "Wallet setup complete."
}

# Function to setup systemd service
setup_systemd_service() {
    log "Setting up systemd service..."
    cat > /etc/systemd/system/pipe-pop.service << EOF
    git pull
}

cd "$INSTALL_DIR"

# Step 4: Set up Solana wallet
print_header "Setting Up Solana Wallet"

print_message "Installing Solana CLI..."
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
echo 'export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc

# Ask if user wants to use an existing wallet or create a new one
echo ""
print_message "Solana wallet setup:"
echo "  1) Create a new wallet"
echo "  2) Use an existing wallet address"
echo ""
read -p "Enter your choice (1/2): " wallet_choice

SOLANA_WALLET=""

if [ "$wallet_choice" = "1" ]; then
    print_message "Creating new Solana wallet..."
    solana-keygen new --no-passphrase
    SOLANA_WALLET=$(solana address)
    print_message "Wallet created with address: $SOLANA_WALLET"
else
    read -p "Enter your Solana wallet address: " SOLANA_WALLET
    print_message "Using wallet address: $SOLANA_WALLET"
fi

# Step 5: Download and configure the pipe-pop binary
print_header "Setting Up pipe-pop Binary"

print_message "Creating directories..."
mkdir -p bin cache config logs backups

print_message "Downloading pipe-pop binary..."
curl -L -o bin/pipe-pop https://dl.pipecdn.app/v0.2.8/pop
chmod +x bin/pipe-pop

print_message "Creating configuration file..."
cat > config/config.json << EOF
{
  "solana_wallet": "$SOLANA_WALLET",
  "cache_dir": "$INSTALL_DIR/cache",
  "log_level": "info",
  "network": {
    "ports": [80, 443, 8003],
    "hostname": "auto"
  }
}
EOF

# Step 6: Ask about referral code
print_header "Referral Code Setup"

echo ""
print_message "Would you like to use the Surrealine referral code?"
echo "Using a referral code helps support the Surrealine platform and benefits your node."
echo ""
read -p "Use Surrealine referral code? (y/n): " use_referral

if [ "$use_referral" = "y" ] || [ "$use_referral" = "Y" ]; then
    print_message "Signing up with Surrealine referral code..."
    ./bin/pipe-pop --signup-by-referral-route 3a069772281d9b1b
    print_message "Referral code applied successfully."
else
    print_message "Skipping referral code."
fi

# Step 7: Set up systemd service
print_header "Setting Up Systemd Service"

print_message "Creating systemd service file..."
cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=pipe-pop Node
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=/opt/pipe-pop
ExecStart=/opt/pipe-pop/bin/pipe-pop --cache-dir /opt/pipe-pop/cache --pubKey $SOLANA_WALLET --enable-80-443
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
ProtectSystem=full
NoNewPrivileges=true
MemoryLimit=512M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now pipe-pop.service
    log "Service started. Checking status..."
    systemctl status pipe-pop --no-pager
}

# Function to install a global command
install_global_command() {
    log "Installing global 'pop' command..."
    cat > /usr/local/bin/pop << 'EOF'
#!/bin/bash

# pipe-pop Management Script
# This script provides a convenient wrapper around the pipe-pop binary

# Installation directory
INSTALL_DIR="/opt/pipe-pop"
"$INSTALL_DIR/bin/pipe-pop" "$@"
EOF
    chmod +x /usr/local/bin/pop
    log "'pop' command installed successfully."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Check if the binary exists
if [ ! -f "${INSTALL_DIR}/bin/pipe-pop" ]; then
    print_error "pipe-pop binary not found. Please check your installation."
    exit 1
fi

# Function to show help
show_help() {
    echo "pipe-pop Node Management Script"
    echo "Usage: pop [OPTION]"
    echo ""
    echo "Options:"
    echo "  --status                Check node status and reputation"
    echo "  --check-update          Check for available updates"
    echo "  --update                Update to the latest version"
    echo "  --gen-referral-route    Generate a referral code"
    echo "  --points-route          Check points and rewards"
    echo "  --enable-80-443         Enable ports 80 and 443 (requires restart)"
    echo "  --monitor               Monitor node status"
    echo "  --backup                Create a backup"
    echo "  --restart               Restart the node service"
    echo "  --logs                  View service logs"
    echo "  --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  pop --status            Check node status"
    echo "  pop --update            Update to the latest version"
}

# Install update command
install_update_command() {
    log "Installing update command 'pop-update'..."
    cat > /usr/local/bin/pop-update << 'EOF'
#!/bin/bash
cd /usr/local/bin && sudo curl -O https://raw.githubusercontent.com/preterag/pipecdn/main/setup.sh
chmod +x /usr/local/bin/setup.sh
EOF
    chmod +x /usr/local/bin/pop-update
    log "'pop-update' command installed successfully."
}

# Execute installation steps
install_dependencies
setup_pipe_pop
setup_solana_wallet
setup_systemd_service
install_global_command
install_update_command

log "✅ Pipe PoP node setup completed successfully. Use 'pop' to manage your node."
# Main execution
case "$1" in
    --status)
        print_message "Checking node status..."
        ${INSTALL_DIR}/bin/pipe-pop --status
        ;;
    --check-update)
        print_message "Checking for updates..."
        ${INSTALL_DIR}/bin/pipe-pop --check-update
        ;;
    --update)
        print_message "Updating to the latest version..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command must be run as root (with sudo)"
            exit 1
        fi
        ${INSTALL_DIR}/bin/pipe-pop --update
        ;;
    --gen-referral-route)
        print_message "Generating referral code..."
        ${INSTALL_DIR}/bin/pipe-pop --gen-referral-route
        ;;
    --points-route)
        print_message "Checking points and rewards..."
        ${INSTALL_DIR}/bin/pipe-pop --points-route
        ;;
    --enable-80-443)
        print_message "Enabling ports 80 and 443..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command must be run as root (with sudo)"
            exit 1
        fi
        
        # Check if the service file already has the flag
        if grep -q -- "--enable-80-443" /etc/systemd/system/pipe-pop.service; then
            print_message "Ports 80 and 443 are already enabled in the service configuration."
        else
            # Update the service file to include the --enable-80-443 flag
            sed -i 's|ExecStart=.*pipe-pop|& --enable-80-443|' /etc/systemd/system/pipe-pop.service
            
            # Reload systemd and restart the service
            systemctl daemon-reload
            systemctl restart pipe-pop.service
            
            print_message "Ports 80 and 443 have been enabled. The service has been restarted."
        fi
        
        # Check if the ports are now in use
        sleep 5
        if netstat -tuln | grep -q ":80 "; then
            print_message "Port 80 is now active and listening."
        else
            print_warning "Port 80 does not appear to be listening. Please check the service logs."
        fi
        
        if netstat -tuln | grep -q ":443 "; then
            print_message "Port 443 is now active and listening."
        else
            print_warning "Port 443 does not appear to be listening. Please check the service logs."
        fi
        ;;
    --monitor)
        print_message "Monitoring node status..."
        ${INSTALL_DIR}/monitor.sh
        ;;
    --backup)
        print_message "Creating backup..."
        ${INSTALL_DIR}/backup.sh
        ;;
    --restart)
        print_message "Restarting node service..."
        if [ "$EUID" -ne 0 ]; then
            print_error "This command must be run as root (with sudo)"
            exit 1
        fi
        sudo systemctl restart pipe-pop.service
        print_message "Service restarted."
        ;;
    --logs)
        print_message "Viewing service logs..."
        journalctl -u pipe-pop.service -n 50
        ;;
    --help|*)
        show_help
        ;;
esac

exit 0
EOF

print_message "Making the command executable..."
chmod +x /usr/local/bin/pop

print_message "Copying necessary scripts to installation directory..."
if [ -f "$INSTALL_DIR/monitor.sh" ]; then
    chmod +x "$INSTALL_DIR/monitor.sh"
fi

if [ -f "$INSTALL_DIR/backup.sh" ]; then
    chmod +x "$INSTALL_DIR/backup.sh"
fi

print_message "Global pop command installed successfully!"
print_highlight "You can now use the 'pop' command from anywhere on your system!"

# Step 10: Final steps
print_header "Setup Complete"

print_message "pipe-pop has been successfully set up!"
print_highlight "You can manage your node using the global 'pop' command from anywhere on your system:"
echo ""
echo "  Check node status:    pop --status"
echo "  Monitor node:         pop --monitor"
echo "  Create backup:        pop --backup"
echo "  Check for updates:    pop --check-update"
echo "  Update node:          sudo pop --update"
echo "  View logs:            pop --logs"
echo ""
print_message "For more information, refer to the documentation in the $INSTALL_DIR/docs directory."
echo ""
print_message "Thank you for joining the Pipe Network ecosystem!"

# Test the global pop command
print_header "Testing Global Pop Command"
print_message "Running a quick test of the global pop command..."
if command -v pop &> /dev/null; then
    print_highlight "Success! The global 'pop' command is installed and accessible."
    echo "Try it now with: pop --help"
else
    print_warning "The global 'pop' command may not be accessible. Please check your PATH settings."
    print_message "You can still use it with the full path: /usr/local/bin/pop"
fi

# Clean up
rm -rf "$TEMP_DIR"

exit 0 