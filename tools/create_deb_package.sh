#!/bin/bash
# create_deb_package.sh - Create a .deb package for Pipe Network PoP Node
# For Ubuntu 24.04 LTS

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get the project root directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=$(cat "$ROOT_DIR/VERSION")
PACKAGE_NAME="pipe-pop"
PACKAGE_VERSION="$VERSION"
ARCHITECTURE="all"
MAINTAINER="Pipe Network Team <support@example.com>"
DESCRIPTION="Pipe Network PoP Node Management Tools"

# Check if required tools are installed
if ! command -v dpkg-deb &> /dev/null; then
    log_error "dpkg-deb command not found. Please install the dpkg-dev package."
    exit 1
fi

# Create the package directory structure
PACKAGE_DIR="$ROOT_DIR/build/${PACKAGE_NAME}_${PACKAGE_VERSION}"
mkdir -p "$PACKAGE_DIR/DEBIAN"
mkdir -p "$PACKAGE_DIR/opt/pipe-pop"
mkdir -p "$PACKAGE_DIR/usr/bin"
mkdir -p "$PACKAGE_DIR/etc/pipe-pop"
mkdir -p "$PACKAGE_DIR/var/lib/pipe-pop"
mkdir -p "$PACKAGE_DIR/usr/share/doc/pipe-pop"

# Create control file
cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION
Section: net
Priority: optional
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 A tool for managing Pipe Network PoP nodes.
 This package provides command-line utilities for installation,
 configuration, monitoring, and fleet management of nodes.
Depends: bash (>= 4.0), curl, jq
Homepage: https://example.com/pipe-pop
EOF

# Create postinst script
cat > "$PACKAGE_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Create symbolic link for the main command
ln -sf /opt/pipe-pop/tools/pop /usr/bin/pop

# Set file permissions
chmod +x /opt/pipe-pop/tools/pop
chmod +x /opt/pipe-pop/tools/installer
chmod +x /opt/pipe-pop/tools/pop-ui-python
chmod +x /opt/pipe-pop/tools/test_script.sh

echo "Pipe Network PoP Node Management Tools have been installed successfully."
echo "Type 'pop --help' to get started."

exit 0
EOF
chmod 755 "$PACKAGE_DIR/DEBIAN/postinst"

# Create postrm script
cat > "$PACKAGE_DIR/DEBIAN/postrm" << 'EOF'
#!/bin/bash
set -e

if [ "$1" = "purge" ] || [ "$1" = "remove" ]; then
    # Remove symbolic link
    rm -f /usr/bin/pop
    
    # Remove log and cache directories if empty
    rmdir /var/lib/pipe-pop 2>/dev/null || true
    rmdir /etc/pipe-pop 2>/dev/null || true
fi

exit 0
EOF
chmod 755 "$PACKAGE_DIR/DEBIAN/postrm"

# Copy files to the package directory
log_info "Copying files to package directory..."

# Copy binaries and scripts
cp -r "$ROOT_DIR/bin" "$PACKAGE_DIR/opt/pipe-pop/"
cp -r "$ROOT_DIR/tools" "$PACKAGE_DIR/opt/pipe-pop/"

# Copy source files
mkdir -p "$PACKAGE_DIR/opt/pipe-pop/src"
[ -d "$ROOT_DIR/src/core" ] && cp -r "$ROOT_DIR/src/core" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/fleet" ] && cp -r "$ROOT_DIR/src/fleet" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/maintenance" ] && cp -r "$ROOT_DIR/src/maintenance" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/community" ] && cp -r "$ROOT_DIR/src/community" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/monitoring" ] && cp -r "$ROOT_DIR/src/monitoring" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/config" ] && cp -r "$ROOT_DIR/src/config" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/utils" ] && cp -r "$ROOT_DIR/src/utils" "$PACKAGE_DIR/opt/pipe-pop/src/"
[ -d "$ROOT_DIR/src/installer" ] && cp -r "$ROOT_DIR/src/installer" "$PACKAGE_DIR/opt/pipe-pop/src/"

# Create symlinks from src to root for backward compatibility
mkdir -p "$PACKAGE_DIR/opt/pipe-pop/core"
ln -sf "$PACKAGE_DIR/opt/pipe-pop/src/core" "$PACKAGE_DIR/opt/pipe-pop/core"
ln -sf "$PACKAGE_DIR/opt/pipe-pop/src/fleet" "$PACKAGE_DIR/opt/pipe-pop/fleet"
ln -sf "$PACKAGE_DIR/opt/pipe-pop/src/maintenance" "$PACKAGE_DIR/opt/pipe-pop/maintenance"
ln -sf "$PACKAGE_DIR/opt/pipe-pop/src/community" "$PACKAGE_DIR/opt/pipe-pop/community"

# Copy documentation
cp "$ROOT_DIR/README.md" "$PACKAGE_DIR/usr/share/doc/pipe-pop/"
cp "$ROOT_DIR/CHANGELOG.md" "$PACKAGE_DIR/usr/share/doc/pipe-pop/"
cp "$ROOT_DIR/VERSION" "$PACKAGE_DIR/usr/share/doc/pipe-pop/"
cp "$ROOT_DIR/RELEASE_NOTES.md" "$PACKAGE_DIR/usr/share/doc/pipe-pop/"
[ -d "$ROOT_DIR/docs" ] && cp -r "$ROOT_DIR/docs" "$PACKAGE_DIR/usr/share/doc/pipe-pop/"

# Create default configuration
mkdir -p "$PACKAGE_DIR/etc/pipe-pop"
touch "$PACKAGE_DIR/etc/pipe-pop/config.json"

# Create the package
log_info "Building .deb package..."
dpkg-deb --build "$PACKAGE_DIR"

if [ $? -eq 0 ]; then
    log_info "Package created: ${PACKAGE_DIR}.deb"
    
    # Generate checksum
    cd "$ROOT_DIR/build"
    CHECKSUM=$(sha256sum "${PACKAGE_NAME}_${PACKAGE_VERSION}.deb" | awk '{print $1}')
    echo "$CHECKSUM  ${PACKAGE_NAME}_${PACKAGE_VERSION}.deb" > "${PACKAGE_NAME}_${PACKAGE_VERSION}.deb.sha256"
    log_info "Checksum generated: ${PACKAGE_NAME}_${PACKAGE_VERSION}.deb.sha256"
    
    log_info "Package size: $(du -h "${PACKAGE_NAME}_${PACKAGE_VERSION}.deb" | awk '{print $1}')"
    log_info "Package is ready for distribution"
else
    log_error "Failed to create package"
    exit 1
fi

exit 0 