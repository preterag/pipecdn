#!/bin/bash
# pipe-pop One-Line Installer v1.0.0
# This script automatically detects your OS and installs pipe-pop using the appropriate method
# Usage: curl -fsSL https://raw.githubusercontent.com/preterag/pipe-pop/main/installers/install.sh | sudo bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

print_info "pipe-pop One-Line Installer v1.0.0"
print_info "Detecting your operating system..."

# Get latest release version from GitHub
print_info "Checking for latest version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/preterag/pipe-pop/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

if [ -z "$LATEST_VERSION" ]; then
    print_warning "Could not determine latest version. Using default version."
    LATEST_VERSION="v1.0.0"
else
    print_info "Latest version: $LATEST_VERSION"
fi

# Remove 'v' prefix if present
VERSION=${LATEST_VERSION#v}

# Detect OS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

print_info "Detected: $OS $VER"

# Determine architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

print_info "Architecture: $ARCH"

# Base URL for GitHub releases
GITHUB_URL="https://github.com/preterag/pipe-pop/releases/download/${LATEST_VERSION}"

# Function to install via direct download
install_direct() {
    print_info "Installing via direct download..."
    
    # Create temp directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Download and install based on package type
    if [ "$1" == "deb" ]; then
        print_info "Downloading DEB package..."
        curl -fsSL "${GITHUB_URL}/pipe-pop_${VERSION}_${ARCH}.deb" -o pipe-pop.deb
        dpkg -i pipe-pop.deb
        apt-get install -f -y # Fix any dependencies
    elif [ "$1" == "rpm" ]; then
        print_info "Downloading RPM package..."
        curl -fsSL "${GITHUB_URL}/pipe-pop-${VERSION}-1.${ARCH}.rpm" -o pipe-pop.rpm
        if command -v dnf &> /dev/null; then
            dnf install -y ./pipe-pop.rpm
        else
            yum install -y ./pipe-pop.rpm
        fi
    elif [ "$1" == "appimage" ]; then
        print_info "Downloading AppImage..."
        curl -fsSL "${GITHUB_URL}/pipe-pop-${VERSION}-${ARCH}.AppImage" -o pipe-pop.AppImage
        chmod +x pipe-pop.AppImage
        
        # Install to /usr/local/bin
        mkdir -p /usr/local/bin
        mv pipe-pop.AppImage /usr/local/bin/pipe-pop
        
        # Create symlink for pop command
        ln -sf /usr/local/bin/pipe-pop /usr/local/bin/pop
        
        # Create systemd service
        cat > /etc/systemd/system/pipe-pop.service << EOF
[Unit]
Description=pipe-pop Service
After=network.target

[Service]
ExecStart=/usr/local/bin/pipe-pop
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
        
        # Enable and start service
        systemctl daemon-reload
        systemctl enable pipe-pop.service
        systemctl start pipe-pop.service
    fi
    
    # Clean up
    cd - > /dev/null
    rm -rf "$TMP_DIR"
    
    print_success "pipe-pop has been successfully installed!"
    print_info "You can now use the 'pop' command to manage your pipe-pop node."
    print_info "Run 'pop --help' for available commands."
}

# Install based on detected OS
case "$OS" in
    *Ubuntu*|*Debian*|*Mint*)
        print_info "Installing DEB package for $OS..."
        install_direct "deb"
        ;;
    *Fedora*|*CentOS*|*RHEL*|*Red\ Hat*|*Rocky*|*AlmaLinux*)
        print_info "Installing RPM package for $OS..."
        install_direct "rpm"
        ;;
    *)
        print_warning "Could not determine package type for $OS"
        print_info "Installing via AppImage as fallback..."
        install_direct "appimage"
        ;;
esac

# Final instructions
print_success "=============================================="
print_success "pipe-pop installation completed successfully!"
print_success "=============================================="
print_info "To start your pipe-pop node: sudo pop start"
print_info "To check status: pop status"
print_info "To view logs: pop logs"
print_info "To get help: pop --help"
print_info ""
print_info "For more information, visit: https://preterag.com/pipe-pop" 