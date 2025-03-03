#!/bin/bash

# Pipe PoP Node Multi-Format Packaging Script
# Version: 1.0.0
#
# This script creates distributable packages for the Pipe PoP node in multiple formats:
# - AppImage (universal Linux format)
# - DEB package (Debian/Ubuntu)
# - RPM package (Red Hat/Fedora/CentOS)
# - Source tarball
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
print_message "Pipe PoP Multi-Format Packaging Tool v1.0.0"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_warning "This script is not running as root. Some operations may fail."
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        print_message "Exiting. Please run with sudo if you encounter permission issues."
        exit 0
    fi
fi

# Check for required tools
print_header "Checking Required Tools"

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_warning "$1 is not installed. $2"
        return 1
    else
        print_message "$1 is installed."
        return 0
    fi
}

# Check for tools needed for all package types
check_command "tar" "Required for creating source packages."

# Check for AppImage tools
APPIMAGE_AVAILABLE=false
if check_command "appimagetool" "Required for creating AppImage packages."; then
    APPIMAGE_AVAILABLE=true
else
    print_warning "AppImage packaging will be skipped."
    print_message "To install appimagetool, visit: https://github.com/AppImage/AppImageKit/releases"
fi

# Check for DEB packaging tools
DEB_AVAILABLE=false
if check_command "dpkg-deb" "Required for creating DEB packages."; then
    DEB_AVAILABLE=true
else
    print_warning "DEB packaging will be skipped."
    print_message "To install dpkg-deb, run: sudo apt-get install dpkg-dev"
fi

# Check for RPM packaging tools
RPM_AVAILABLE=false
if check_command "rpmbuild" "Required for creating RPM packages."; then
    RPM_AVAILABLE=true
else
    print_warning "RPM packaging will be skipped."
    print_message "To install rpmbuild, run: sudo apt-get install rpm or sudo dnf install rpm-build"
fi

# Set variables
WORKSPACE_DIR="$(pwd)"
BUILD_DIR="${WORKSPACE_DIR}/build"
PACKAGE_DIR="${BUILD_DIR}/package"
RELEASE_DIR="${WORKSPACE_DIR}/installers/v1.0.0"
VERSION="1.0.0"
PACKAGE_NAME="ppn"
FULL_PACKAGE_NAME="${PACKAGE_NAME}-${VERSION}"

# Create directories
print_header "Creating Package Structure"
print_message "Creating package directories..."
mkdir -p "${BUILD_DIR}"
mkdir -p "${PACKAGE_DIR}"
mkdir -p "${RELEASE_DIR}"

# Clean up any previous packaging attempts
print_message "Cleaning up previous packaging attempts..."
rm -rf "${BUILD_DIR:?}/"*

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

# Create directory structure for bin
mkdir -p "${PACKAGE_DIR}/bin"
mkdir -p "${PACKAGE_DIR}/cache"
mkdir -p "${PACKAGE_DIR}/logs"
mkdir -p "${PACKAGE_DIR}/backups"

# Create README files for empty directories
echo "# Pipe PoP Binary Directory" > "${PACKAGE_DIR}/bin/README.md"
echo "This directory will contain the Pipe PoP binary after installation." >> "${PACKAGE_DIR}/bin/README.md"

echo "# Pipe PoP Cache Directory" > "${PACKAGE_DIR}/cache/README.md"
echo "This directory will store cache data for the Pipe PoP node." >> "${PACKAGE_DIR}/cache/README.md"

echo "# Pipe PoP Logs Directory" > "${PACKAGE_DIR}/logs/README.md"
echo "This directory will store log files for the Pipe PoP node." >> "${PACKAGE_DIR}/logs/README.md"

echo "# Pipe PoP Backups Directory" > "${PACKAGE_DIR}/backups/README.md"
echo "This directory will store backups of essential Pipe PoP node data." >> "${PACKAGE_DIR}/backups/README.md"

# Create source package
print_header "Creating Source Package"
print_message "Creating source tarball..."
cd "${WORKSPACE_DIR}"
tar -czf "${RELEASE_DIR}/${FULL_PACKAGE_NAME}-source.tar.gz" -C "${PACKAGE_DIR}" .
print_message "Source package created: ${RELEASE_DIR}/${FULL_PACKAGE_NAME}-source.tar.gz"

# Create AppImage package
if [ "$APPIMAGE_AVAILABLE" = true ]; then
    print_header "Creating AppImage Package"
    print_message "Setting up AppDir structure..."
    
    APPDIR="${BUILD_DIR}/AppDir"
    mkdir -p "${APPDIR}/usr/bin"
    mkdir -p "${APPDIR}/usr/share/applications"
    mkdir -p "${APPDIR}/usr/share/icons/hicolor/256x256/apps"
    mkdir -p "${APPDIR}/usr/share/pipe-pop"
    
    # Copy files to AppDir
    cp -r "${PACKAGE_DIR}/"* "${APPDIR}/usr/share/pipe-pop/"
    
    # Create AppRun script
    cat > "${APPDIR}/AppRun" << 'EOF'
#!/bin/bash
SELF_DIR=$(dirname "$(readlink -f "$0")")
export PATH="${SELF_DIR}/usr/bin:${PATH}"
cd "${SELF_DIR}/usr/share/pipe-pop"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This application must be run as root (with sudo)"
    echo "Please run: sudo $0 $@"
    exit 1
fi

# If no arguments, run the installer
if [ $# -eq 0 ]; then
    ./easy_setup.sh
else
    # Otherwise, pass arguments to the pop command
    ./pop "$@"
fi
EOF
    chmod +x "${APPDIR}/AppRun"
    
    # Create symlink to pop command
    ln -sf "../share/pipe-pop/pop" "${APPDIR}/usr/bin/pipe-pop"
    
    # Create desktop file
    cat > "${APPDIR}/usr/share/applications/pipe-pop.desktop" << EOF
[Desktop Entry]
Name=Pipe PoP Node
Comment=Pipe Network Point of Presence Node
Exec=pipe-pop
Icon=pipe-pop
Terminal=true
Type=Application
Categories=Network;
EOF
    
    # Create a simple icon (placeholder)
    # In a real scenario, you would use a proper icon file
    convert -size 256x256 xc:none -fill blue -draw "circle 128,128 128,64" -fill white -draw "text 70,140 'Pipe PoP'" "${APPDIR}/usr/share/icons/hicolor/256x256/apps/pipe-pop.png" || {
        print_warning "Could not create icon. Using a placeholder."
        # Create a simple placeholder icon
        echo "P" > "${APPDIR}/usr/share/icons/hicolor/256x256/apps/pipe-pop.png"
    }
    
    # Copy desktop and icon files to AppDir root
    cp "${APPDIR}/usr/share/applications/pipe-pop.desktop" "${APPDIR}/"
    cp "${APPDIR}/usr/share/icons/hicolor/256x256/apps/pipe-pop.png" "${APPDIR}/"
    
    # Build AppImage
    print_message "Building AppImage..."
    cd "${BUILD_DIR}"
    ARCH=$(uname -m) appimagetool "${APPDIR}" "${RELEASE_DIR}/${FULL_PACKAGE_NAME}-${ARCH}.AppImage"
    print_message "AppImage created: ${RELEASE_DIR}/${FULL_PACKAGE_NAME}-${ARCH}.AppImage"
else
    print_warning "Skipping AppImage creation due to missing tools."
fi

# Create DEB package
if [ "$DEB_AVAILABLE" = true ]; then
    print_header "Creating DEB Package"
    print_message "Setting up DEB package structure..."
    
    DEB_DIR="${BUILD_DIR}/deb"
    DEB_PACKAGE_DIR="${DEB_DIR}/${PACKAGE_NAME}_${VERSION}_amd64"
    mkdir -p "${DEB_PACKAGE_DIR}/DEBIAN"
    mkdir -p "${DEB_PACKAGE_DIR}/opt/ppn"
    mkdir -p "${DEB_PACKAGE_DIR}/usr/bin"
    
    # Copy files to package directory
    cp -r "${PACKAGE_DIR}/"* "${DEB_PACKAGE_DIR}/opt/ppn/"
    
    # Create control file
    cat > "${DEB_PACKAGE_DIR}/DEBIAN/control" << EOF
Package: ppn
Version: ${VERSION}
Section: net
Priority: optional
Architecture: amd64
Depends: bash, curl, jq, solana-cli
Maintainer: Preterag <hello@preterag.com>
Description: Pipe PoP Node for the Pipe Network decentralized CDN
 A complete implementation for setting up and managing a Pipe PoP node
 for the Pipe Network decentralized CDN. This package provides scripts
 and tools for easy deployment, monitoring, and maintenance of a Pipe
 PoP node.
EOF
    
    # Create postinst script
    cat > "${DEB_PACKAGE_DIR}/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Create symlink for global pop command
ln -sf /opt/ppn/pop /usr/bin/pop

# Set permissions
chmod +x /opt/ppn/*.sh
chmod +x /opt/ppn/pop

echo "Pipe PoP Node has been installed."
echo "To set up your node, run: sudo pop --setup"

exit 0
EOF
    chmod 755 "${DEB_PACKAGE_DIR}/DEBIAN/postinst"
    
    # Create postrm script
    cat > "${DEB_PACKAGE_DIR}/DEBIAN/postrm" << 'EOF'
#!/bin/bash
set -e

# Remove symlink for global pop command
if [ -L /usr/bin/pop ]; then
    rm -f /usr/bin/pop
fi

# If purge, remove configuration
if [ "$1" = "purge" ]; then
    rm -rf /opt/ppn/config
fi

exit 0
EOF
    chmod 755 "${DEB_PACKAGE_DIR}/DEBIAN/postrm"
    
    # Build DEB package
    print_message "Building DEB package..."
    cd "${DEB_DIR}"
    dpkg-deb --build "${DEB_PACKAGE_DIR}"
    mv "${DEB_DIR}/${PACKAGE_NAME}_${VERSION}_amd64.deb" "${RELEASE_DIR}/"
    print_message "DEB package created: ${RELEASE_DIR}/${PACKAGE_NAME}_${VERSION}_amd64.deb"
else
    print_warning "Skipping DEB package creation due to missing tools."
fi

# Create RPM package
if [ "$RPM_AVAILABLE" = true ]; then
    print_header "Creating RPM Package"
    print_message "Setting up RPM package structure..."
    
    RPM_DIR="${BUILD_DIR}/rpm"
    mkdir -p "${RPM_DIR}/SPECS"
    mkdir -p "${RPM_DIR}/SOURCES"
    mkdir -p "${RPM_DIR}/BUILD"
    mkdir -p "${RPM_DIR}/RPMS"
    mkdir -p "${RPM_DIR}/SRPMS"
    
    # Create tarball for RPM
    tar -czf "${RPM_DIR}/SOURCES/${FULL_PACKAGE_NAME}.tar.gz" -C "${PACKAGE_DIR}" .
    
    # Create spec file
    cat > "${RPM_DIR}/SPECS/${PACKAGE_NAME}.spec" << EOF
Name:           ppn
Version:        ${VERSION}
Release:        1%{?dist}
Summary:        Pipe PoP Node for the Pipe Network decentralized CDN

License:        MIT
URL:            https://github.com/preterag/ppn
Source0:        %{name}-%{version}.tar.gz

Requires:       bash curl jq

%description
A complete implementation for setting up and managing a Pipe PoP node
for the Pipe Network decentralized CDN. This package provides scripts
and tools for easy deployment, monitoring, and maintenance of a Pipe
PoP node.

%prep
%setup -q -n ${FULL_PACKAGE_NAME}

%install
mkdir -p %{buildroot}/opt/ppn
mkdir -p %{buildroot}/usr/bin
cp -r * %{buildroot}/opt/ppn/
ln -sf /opt/ppn/pop %{buildroot}/usr/bin/pop

%files
/opt/ppn
/usr/bin/pop

%post
chmod +x /opt/ppn/*.sh
chmod +x /opt/ppn/pop
echo "Pipe PoP Node has been installed."
echo "To complete the setup, run: sudo pop --setup"
echo "For more information, see the documentation in /opt/ppn/docs"

%postun
if [ \$1 -eq 0 ]; then
    # This is an uninstallation, not an upgrade
    if [ -L /usr/bin/pop ]; then
        rm /usr/bin/pop
    fi
fi

%changelog
* $(date +"%a %b %d %Y") Preterag <hello@preterag.com> - ${VERSION}-1
- Initial package
EOF
    
    # Build RPM package
    print_message "Building RPM package..."
    cd "${RPM_DIR}"
    rpmbuild --define "_topdir $(pwd)" -ba SPECS/${PACKAGE_NAME}.spec
    
    # Copy RPM to release directory
    find "${RPM_DIR}/RPMS" -name "*.rpm" -exec cp {} "${RELEASE_DIR}/" \;
    RPM_FILE=$(find "${RPM_DIR}/RPMS" -name "*.rpm" | head -1)
    if [ -n "$RPM_FILE" ]; then
        print_message "RPM package created: ${RELEASE_DIR}/$(basename "$RPM_FILE")"
    else
        print_error "Failed to create RPM package."
    fi
else
    print_warning "Skipping RPM package creation due to missing tools."
fi

# Create installation instructions
print_header "Creating Installation Instructions"
print_message "Creating README file..."

cat > "${RELEASE_DIR}/README.md" << EOF
# Pipe PoP Node ${VERSION} Installation Packages

This directory contains installation packages for the Pipe PoP node for the Pipe Network decentralized CDN.

## Available Packages

### Universal Linux Package (AppImage)
- \`${FULL_PACKAGE_NAME}-x86_64.AppImage\`: Run anywhere without installation
- Usage: \`sudo ./${FULL_PACKAGE_NAME}-x86_64.AppImage\`

### Debian/Ubuntu Package (DEB)
- \`${PACKAGE_NAME}_${VERSION}_amd64.deb\`: For Debian-based distributions
- Installation: \`sudo apt install ./${PACKAGE_NAME}_${VERSION}_amd64.deb\`

### Red Hat/Fedora/CentOS Package (RPM)
- \`${PACKAGE_NAME}-${VERSION}-1.x86_64.rpm\`: For Red Hat-based distributions
- Installation: \`sudo dnf install ./${PACKAGE_NAME}-${VERSION}-1.x86_64.rpm\`

### Source Package
- \`${FULL_PACKAGE_NAME}-source.tar.gz\`: Source code for manual installation
- Installation:
  \`\`\`
  tar -xzf ${FULL_PACKAGE_NAME}-source.tar.gz
  cd ${FULL_PACKAGE_NAME}
  sudo ./easy_setup.sh
  \`\`\`

## Post-Installation

After installation, you can use the \`pop\` command to manage your Pipe PoP node:

- Check status: \`pop --status\`
- Monitor node: \`pop --monitor\`
- Create backup: \`pop --backup\`
- Check for updates: \`pop --check-update\`
- Update node: \`sudo pop --update\`
- View logs: \`pop --logs\`

For more information, refer to the documentation in \`/opt/ppn/docs\` or run \`pop --help\`.

## System Requirements

- Linux operating system (Debian, Ubuntu, Fedora, CentOS, etc.)
- 2GB RAM minimum (4GB recommended)
- 10GB disk space minimum (100GB recommended)
- Ports 80, 443, and 8003 available
- Root/sudo access

## Support

If you need help with your Pipe PoP node:

1. Check the documentation in \`/opt/ppn/docs\`
2. Visit the [Pipe Network Documentation](https://docs.pipe.network)
3. Contact Preterag support at [hello@preterag.com](mailto:hello@preterag.com)
EOF

# Final message
print_header "Packaging Complete"
print_message "Packaging complete! The following files have been created in ${RELEASE_DIR}:"

# List created files
find "${RELEASE_DIR}" -type f | while read file; do
    print_highlight "  - $(basename "$file")"
done

echo ""
print_message "You can distribute these files to users for easy installation of the Pipe PoP node."
echo ""
print_message "To test the packages:"
print_message "  - AppImage: sudo ${RELEASE_DIR}/${FULL_PACKAGE_NAME}-*.AppImage"
print_message "  - DEB: sudo apt install ${RELEASE_DIR}/${PACKAGE_NAME}_${VERSION}_amd64.deb"
print_message "  - RPM: sudo dnf install ${RELEASE_DIR}/${PACKAGE_NAME}-${VERSION}-*.rpm"
print_message "  - Source: tar -xzf ${RELEASE_DIR}/${FULL_PACKAGE_NAME}-source.tar.gz && cd ${FULL_PACKAGE_NAME} && sudo ./easy_setup.sh" 