#!/bin/bash

# Pipe PoP Node Packaging Script
# Version: 1.0.0
#
# This script creates a distributable package for the Pipe PoP node
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Display version information
print_message "Pipe PoP Packaging Tool v1.0.0"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_warning "This script is not running as root. Some operations may fail."
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        print_message "Exiting. Please run with sudo if you encounter permission issues."
        exit 0
    fi
fi

# Set variables
WORKSPACE_DIR="$(pwd)"
PACKAGE_DIR="${WORKSPACE_DIR}/package"
RELEASE_DIR="${WORKSPACE_DIR}/release"
VERSION="1.0.0"
PACKAGE_NAME="pipe-pop-node-${VERSION}"
INSTALLER_NAME="install_pipe_pop.sh"

# Create directories
print_header "Creating Package Structure"
print_message "Creating package directories..."
mkdir -p "${PACKAGE_DIR}"
mkdir -p "${RELEASE_DIR}"

# Clean up any previous packaging attempts
print_message "Cleaning up previous packaging attempts..."
rm -rf "${PACKAGE_DIR:?}/"*
rm -rf "${RELEASE_DIR:?}/"*

# Copy essential files
print_header "Copying Essential Files"
print_message "Copying scripts and configuration files..."

# Scripts
cp "${WORKSPACE_DIR}/setup.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/easy_setup.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/run_node.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/backup.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/monitor.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/install_service.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/update_binary.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/setup_backup_schedule.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/install_global_pop.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/fix_ports.sh" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/pop" "${PACKAGE_DIR}/"

# Documentation
print_message "Copying documentation..."
mkdir -p "${PACKAGE_DIR}/docs"
mkdir -p "${PACKAGE_DIR}/docs/articles"
cp "${WORKSPACE_DIR}/README.md" "${PACKAGE_DIR}/"
cp "${WORKSPACE_DIR}/docs/"*.md "${PACKAGE_DIR}/docs/"
cp "${WORKSPACE_DIR}/docs/articles/"*.md "${PACKAGE_DIR}/docs/articles/"

# Configuration templates
print_message "Copying configuration templates..."
mkdir -p "${PACKAGE_DIR}/config"
if [ -f "${WORKSPACE_DIR}/config/config.json.template" ]; then
    cp "${WORKSPACE_DIR}/config/config.json.template" "${PACKAGE_DIR}/config/"
else
    print_warning "config.json.template not found. Creating a basic template..."
    cat > "${PACKAGE_DIR}/config/config.json.template" << EOF
{
    "network": {
        "ports": [80, 443, 8003]
    },
    "wallet": {
        "address": "YOUR_SOLANA_WALLET_ADDRESS"
    },
    "cache": {
        "directory": "./cache",
        "maxSize": 10240
    }
}
EOF
fi

# Create installer script
print_header "Creating Installer Script"
print_message "Creating the installer script..."

cat > "${PACKAGE_DIR}/${INSTALLER_NAME}" << 'EOF'
#!/bin/bash

# Pipe PoP Node Installer
# Version: 1.0.0
#
# This script installs the Pipe PoP node from the packaged distribution
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}==== $1 ====${NC}"
}

print_highlight() {
    echo -e "${CYAN}$1${NC}"
}

# Display version information
print_message "Pipe PoP Node Installer v1.0.0"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (with sudo)"
    exit 1
fi

# Welcome message
clear
print_header "Pipe PoP Node Installer"
echo ""
print_message "Welcome to the Pipe PoP Node Installer!"
print_message "This script will install a Pipe PoP node for the Pipe Network decentralized CDN."
echo ""
print_message "Installation options:"
echo "  1. Quick Install (Automated with default settings)"
echo "  2. Guided Install (Interactive with customization options)"
echo "  3. Manual Install (Extract files only, no installation)"
echo "  4. Exit"
echo ""

read -p "Please select an option (1-4): " install_option

case $install_option in
    1)
        print_header "Quick Install"
        print_message "Installing with default settings..."
        
        # Extract to /opt/pipe-pop
        INSTALL_DIR="/opt/pipe-pop"
        mkdir -p "$INSTALL_DIR"
        
        # Copy all files from the current directory to the installation directory
        print_message "Copying files to $INSTALL_DIR..."
        cp -r ./* "$INSTALL_DIR/"
        
        # Make scripts executable
        print_message "Setting executable permissions..."
        chmod +x "$INSTALL_DIR"/*.sh
        chmod +x "$INSTALL_DIR/pop"
        
        # Run the easy setup script
        print_message "Running easy setup script..."
        cd "$INSTALL_DIR"
        ./easy_setup.sh
        ;;
    2)
        print_header "Guided Install"
        print_message "Starting guided installation..."
        
        # Ask for installation directory
        read -p "Enter installation directory [/opt/pipe-pop]: " user_install_dir
        INSTALL_DIR=${user_install_dir:-/opt/pipe-pop}
        
        # Create the installation directory
        mkdir -p "$INSTALL_DIR"
        
        # Copy all files from the current directory to the installation directory
        print_message "Copying files to $INSTALL_DIR..."
        cp -r ./* "$INSTALL_DIR/"
        
        # Make scripts executable
        print_message "Setting executable permissions..."
        chmod +x "$INSTALL_DIR"/*.sh
        chmod +x "$INSTALL_DIR/pop"
        
        # Ask if user wants to run the setup now
        read -p "Do you want to run the setup now? (y/n): " run_setup
        if [[ "$run_setup" =~ ^[Yy]$ ]]; then
            cd "$INSTALL_DIR"
            ./easy_setup.sh
        else
            print_message "You can run the setup later with: sudo $INSTALL_DIR/easy_setup.sh"
        fi
        ;;
    3)
        print_header "Manual Install"
        print_message "Extracting files only..."
        
        # Ask for extraction directory
        read -p "Enter extraction directory [./pipe-pop]: " extract_dir
        EXTRACT_DIR=${extract_dir:-./pipe-pop}
        
        # Create the extraction directory
        mkdir -p "$EXTRACT_DIR"
        
        # Copy all files from the current directory to the extraction directory
        print_message "Copying files to $EXTRACT_DIR..."
        cp -r ./* "$EXTRACT_DIR/"
        
        # Make scripts executable
        print_message "Setting executable permissions..."
        chmod +x "$EXTRACT_DIR"/*.sh
        chmod +x "$EXTRACT_DIR/pop"
        
        print_message "Files extracted to $EXTRACT_DIR"
        print_message "You can run the setup manually with: sudo $EXTRACT_DIR/setup.sh"
        print_message "Or use the guided setup with: sudo $EXTRACT_DIR/easy_setup.sh"
        ;;
    4)
        print_message "Exiting installer."
        exit 0
        ;;
    *)
        print_error "Invalid option. Exiting."
        exit 1
        ;;
esac

print_header "Installation Complete"
print_message "Thank you for installing the Pipe PoP node!"
print_message "For more information, refer to the documentation in the docs directory."
EOF

# Make the installer executable
chmod +x "${PACKAGE_DIR}/${INSTALLER_NAME}"

# Create the package
print_header "Creating Package"
print_message "Creating tarball package..."
cd "${WORKSPACE_DIR}"
tar -czf "${RELEASE_DIR}/${PACKAGE_NAME}.tar.gz" -C "${PACKAGE_DIR}" .

# Create self-extracting installer
print_header "Creating Self-Extracting Installer"
print_message "Creating self-extracting installer..."

cat > "${RELEASE_DIR}/${PACKAGE_NAME}-installer.sh" << EOF
#!/bin/bash
# Self-extracting installer for Pipe PoP Node ${VERSION}
# To extract without installing, run with --extract-only

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "\${GREEN}[INFO]\${NC} \$1"
}

print_warning() {
    echo -e "\${YELLOW}[WARNING]\${NC} \$1"
}

print_error() {
    echo -e "\${RED}[ERROR]\${NC} \$1"
}

print_header() {
    echo -e "\${BLUE}==== \$1 ====\${NC}"
}

# Check for extract-only flag
if [ "\$1" = "--extract-only" ]; then
    EXTRACT_DIR="\${2:-./pipe-pop-extracted}"
    mkdir -p "\$EXTRACT_DIR"
    print_message "Extracting to \$EXTRACT_DIR..."
    ARCHIVE=\`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' \$0\`
    tail -n+\$ARCHIVE \$0 | tar -xz -C "\$EXTRACT_DIR"
    print_message "Extraction complete. Files are in \$EXTRACT_DIR"
    exit 0
fi

# Create temporary directory
TEMP_DIR=\$(mktemp -d)
print_message "Extracting installer to temporary directory..."

# Extract the archive to the temporary directory
ARCHIVE=\`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' \$0\`
tail -n+\$ARCHIVE \$0 | tar -xz -C "\$TEMP_DIR"

# Run the installer
cd "\$TEMP_DIR"
print_message "Running installer..."
chmod +x ${INSTALLER_NAME}
./\${INSTALLER_NAME}

# Clean up
print_message "Cleaning up temporary files..."
rm -rf "\$TEMP_DIR"

exit 0

__ARCHIVE_BELOW__
EOF

# Append the tarball to the self-extracting installer
cat "${RELEASE_DIR}/${PACKAGE_NAME}.tar.gz" >> "${RELEASE_DIR}/${PACKAGE_NAME}-installer.sh"
chmod +x "${RELEASE_DIR}/${PACKAGE_NAME}-installer.sh"

# Create a simple README for the release
cat > "${RELEASE_DIR}/README.txt" << EOF
Pipe PoP Node ${VERSION} Installation Package
=============================================

This package contains the Pipe PoP node software for the Pipe Network decentralized CDN.

Installation Options:
--------------------

1. Self-extracting installer (recommended):
   - Run: sudo ./${PACKAGE_NAME}-installer.sh
   - This will guide you through the installation process

2. Manual installation from tarball:
   - Extract: tar -xzf ${PACKAGE_NAME}.tar.gz
   - Navigate to the extracted directory
   - Run: sudo ./install_pipe_pop.sh

3. Extract only (no installation):
   - Run: ./${PACKAGE_NAME}-installer.sh --extract-only [destination_directory]

For more information, please refer to the documentation in the docs directory
after installation or extraction.

Thank you for joining the Pipe Network ecosystem!
EOF

# Final message
print_header "Packaging Complete"
print_message "Packaging complete! The following files have been created:"
print_highlight "  - ${RELEASE_DIR}/${PACKAGE_NAME}.tar.gz (Tarball package)"
print_highlight "  - ${RELEASE_DIR}/${PACKAGE_NAME}-installer.sh (Self-extracting installer)"
print_highlight "  - ${RELEASE_DIR}/README.txt (Installation instructions)"
echo ""
print_message "You can distribute these files to users for easy installation of the Pipe PoP node."
print_message "Users can install with: sudo ./${PACKAGE_NAME}-installer.sh"
echo ""
print_message "To test the installer, run: sudo ${RELEASE_DIR}/${PACKAGE_NAME}-installer.sh" 