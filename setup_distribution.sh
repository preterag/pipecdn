#!/bin/bash
# pipe-pop Distribution Channels Setup Script v1.0.0
# This script sets up and manages distribution channels for pipe-pop packages

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check for required tools
check_required_tools() {
    print_info "Checking for required tools..."
    
    # Check for GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Required for GitHub Releases."
        print_info "Installation instructions: https://github.com/cli/cli#installation"
        return 1
    fi
    
    # Check for APT repository tools
    if [[ "$1" == "all" || "$1" == "apt" ]]; then
        if ! command -v apt-ftparchive &> /dev/null; then
            print_warning "apt-ftparchive is not installed. Required for APT repository."
            print_info "On Debian/Ubuntu: sudo apt-get install apt-utils"
        fi
    fi
    
    # Check for YUM repository tools
    if [[ "$1" == "all" || "$1" == "yum" ]]; then
        if ! command -v createrepo &> /dev/null; then
            print_warning "createrepo is not installed. Required for YUM repository."
            print_info "On Fedora/CentOS: sudo dnf install createrepo"
        fi
    fi
    
    # Check for AWS CLI (for website uploads)
    if [[ "$1" == "all" || "$1" == "website" ]]; then
        if ! command -v aws &> /dev/null; then
            print_warning "AWS CLI is not installed. Required for website uploads."
            print_info "Installation instructions: https://aws.amazon.com/cli/"
        fi
    fi
    
    print_success "Tool check completed."
    return 0
}

# Create directories
create_directories() {
    print_info "Creating directories for distribution channels..."
    
    # Main release directory
    mkdir -p release
    
    # GitHub Releases directory (same as release)
    
    # APT repository directory
    mkdir -p dist/apt/pool/main
    mkdir -p dist/apt/dists/stable/main/binary-amd64
    
    # YUM repository directory
    mkdir -p dist/yum/packages
    
    # Website downloads directory
    mkdir -p dist/website/downloads
    
    print_success "Directories created successfully."
}

# Set up variables
WORKSPACE_DIR="$(pwd)"
RELEASE_DIR="${WORKSPACE_DIR}/release"
DIST_DIR="${WORKSPACE_DIR}/dist"
APT_DIR="${DIST_DIR}/apt"
YUM_DIR="${DIST_DIR}/yum"
WEBSITE_DIR="${DIST_DIR}/website"

# Package names
APPIMAGE_NAME="pipe-pop-VERSION-amd64.AppImage"
DEB_NAME="pipe-pop_VERSION_amd64.deb"
RPM_NAME="pipe-pop-VERSION-1.x86_64.rpm"
TARBALL_NAME="pipe-pop-VERSION.tar.gz"

# GitHub repository details
GITHUB_REPO="preterag/pipe-pop"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/vVERSION"

# Website details
WEBSITE_URL="https://packages.pipe.network"
WEBSITE_BUCKET="s3://packages.pipe.network"

# Set up GitHub Releases
setup_github_releases() {
    print_info "Setting up GitHub Releases..."
    
    # Check if logged in to GitHub
    if ! gh auth status &> /dev/null; then
        print_warning "Not logged in to GitHub. Please log in:"
        gh auth login
    fi
    
    # Check if the repository exists
    if ! gh repo view "$GITHUB_REPO" &> /dev/null; then
        print_error "Repository $GITHUB_REPO not found or not accessible."
        print_info "Please make sure the repository exists and you have access to it."
        return 1
    fi
    
    print_success "GitHub Releases setup completed."
    print_info "To create a new release, use the create_release.sh script."
    return 0
}

# Set up APT repository
setup_apt_repository() {
    print_info "Setting up APT repository..."
    
    # Check for required tools
    if ! command -v apt-ftparchive &> /dev/null; then
        print_error "apt-ftparchive is not installed. Required for APT repository."
        print_info "On Debian/Ubuntu: sudo apt-get install apt-utils"
        return 1
    fi
    
    # Create APT repository structure
    mkdir -p "${APT_DIR}/pool/main/p/pipe-pop"
    mkdir -p "${APT_DIR}/dists/stable/main/binary-amd64"
    
    # Create APT repository configuration
    cat > "${APT_DIR}/dists/stable/Release" << EOF
Origin: Pipe Network
Label: pipe-pop
Suite: stable
Codename: stable
Architectures: amd64
Components: main
Description: Pipe Network PoP packages
EOF
    
    print_success "APT repository setup completed."
    print_info "To update the APT repository with new packages, run:"
    print_info "  $0 update-apt VERSION"
    return 0
}

# Set up YUM repository
setup_yum_repository() {
    print_info "Setting up YUM repository..."
    
    # Check for required tools
    if ! command -v createrepo &> /dev/null; then
        print_error "createrepo is not installed. Required for YUM repository."
        print_info "On Fedora/CentOS: sudo dnf install createrepo"
        return 1
    fi
    
    # Create YUM repository structure
    mkdir -p "${YUM_DIR}/packages"
    
    # Initialize the repository
    createrepo "${YUM_DIR}"
    
    print_success "YUM repository setup completed."
    print_info "To update the YUM repository with new packages, run:"
    print_info "  $0 update-yum VERSION"
    return 0
}

# Set up website downloads
setup_website_downloads() {
    print_info "Setting up website downloads..."
    
    # Create website downloads structure
    mkdir -p "${WEBSITE_DIR}/downloads"
    
    # Create one-line installer script
    cat > "${WEBSITE_DIR}/downloads/install.sh" << 'EOF'
#!/bin/bash
# pipe-pop One-Line Installer
# This script automatically detects your system and installs pipe-pop

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    VERSION_ID=$(lsb_release -sr)
else
    print_error "Unsupported OS. Cannot detect distribution."
    exit 1
fi

# Get latest version from GitHub
print_info "Detecting latest pipe-pop version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/preterag/pipe-pop/releases/latest | grep -Po '"tag_name": "v\K[^"]*')

if [ -z "$LATEST_VERSION" ]; then
    print_error "Failed to detect latest version. Using fallback version 1.0.0."
    LATEST_VERSION="1.0.0"
fi

print_info "Latest version: $LATEST_VERSION"

# Install based on OS
case $OS in
    debian|ubuntu|linuxmint|pop)
        print_info "Detected Debian/Ubuntu-based system: $OS $VERSION_ID"
        print_info "Installing pipe-pop using DEB package..."
        
        # Download DEB package
        TMP_DEB=$(mktemp)
        curl -L -o "$TMP_DEB" "https://github.com/preterag/pipe-pop/releases/download/v${LATEST_VERSION}/pipe-pop_${LATEST_VERSION}_amd64.deb"
        
        # Install package
        dpkg -i "$TMP_DEB"
        apt-get install -f -y
        
        # Clean up
        rm -f "$TMP_DEB"
        ;;
        
    fedora|centos|rhel|rocky|almalinux)
        print_info "Detected Red Hat-based system: $OS $VERSION_ID"
        print_info "Installing pipe-pop using RPM package..."
        
        # Download RPM package
        TMP_RPM=$(mktemp)
        curl -L -o "$TMP_RPM" "https://github.com/preterag/pipe-pop/releases/download/v${LATEST_VERSION}/pipe-pop-${LATEST_VERSION}-1.x86_64.rpm"
        
        # Install package
        rpm -i "$TMP_RPM"
        
        # Clean up
        rm -f "$TMP_RPM"
        ;;
        
    *)
        print_info "Detected other Linux system: $OS"
        print_info "Installing pipe-pop using AppImage..."
        
        # Download AppImage
        mkdir -p /opt/pipe-pop
        curl -L -o "/opt/pipe-pop/pipe-pop.AppImage" "https://github.com/preterag/pipe-pop/releases/download/v${LATEST_VERSION}/pipe-pop-${LATEST_VERSION}-amd64.AppImage"
        chmod +x "/opt/pipe-pop/pipe-pop.AppImage"
        
        # Create symlink
        ln -sf "/opt/pipe-pop/pipe-pop.AppImage" /usr/local/bin/pop
        
        # Set up service
        cat > /etc/systemd/system/pipe-pop.service << 'EOL'
[Unit]
Description=Pipe Network PoP Node (pipe-pop)
After=network.target

[Service]
ExecStart=/opt/pipe-pop/pipe-pop.AppImage --service
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL
        
        # Enable and start service
        systemctl daemon-reload
        systemctl enable pipe-pop.service
        systemctl start pipe-pop.service
        ;;
esac

print_success "pipe-pop installation completed successfully!"
print_info "To check the status of your pipe-pop node, run: pop --status"
print_info "To view logs, run: pop --logs"
print_info "For more information, visit: https://github.com/preterag/pipe-pop"
EOF
    
    # Make the installer executable
    chmod +x "${WEBSITE_DIR}/downloads/install.sh"
    
    print_success "Website downloads setup completed."
    print_info "To update the website with new packages, run:"
    print_info "  $0 update-website VERSION"
    return 0
}

# Update APT repository
update_apt_repository() {
    VERSION=$1
    
    if [ -z "$VERSION" ]; then
        print_error "No version specified for APT repository update."
        print_info "Usage: $0 update-apt VERSION"
        return 1
    fi
    
    print_info "Updating APT repository with version $VERSION..."
    
    # Check if DEB package exists
    DEB_FILE="${RELEASE_DIR}/pipe-pop_${VERSION}_amd64.deb"
    if [ ! -f "$DEB_FILE" ]; then
        print_error "DEB package not found: $DEB_FILE"
        print_info "Please build the package first using create_packages.sh"
        return 1
    fi
    
    # Copy DEB package to APT repository
    mkdir -p "${APT_DIR}/pool/main/p/pipe-pop"
    cp "$DEB_FILE" "${APT_DIR}/pool/main/p/pipe-pop/"
    
    # Generate Packages file
    cd "${APT_DIR}"
    apt-ftparchive packages pool/main > dists/stable/main/binary-amd64/Packages
    gzip -k -f dists/stable/main/binary-amd64/Packages
    
    # Generate Release file
    apt-ftparchive release dists/stable > dists/stable/Release
    
    # Sign Release file if GPG key is available
    if gpg --list-secret-keys "packages@pipe.network" &> /dev/null; then
        gpg --armor --detach-sign --output dists/stable/Release.gpg dists/stable/Release
        gpg --armor --clearsign --output dists/stable/InRelease dists/stable/Release
    else
        print_warning "GPG key not found. Release file not signed."
        print_info "To sign the Release file, generate a GPG key using installers/generate_gpg_key.sh"
    fi
    
    cd - > /dev/null
    
    print_success "APT repository updated successfully."
    print_info "To upload the APT repository to your server, run:"
    print_info "  $0 upload-apt"
    return 0
}

# Update YUM repository
update_yum_repository() {
    VERSION=$1
    
    if [ -z "$VERSION" ]; then
        print_error "No version specified for YUM repository update."
        print_info "Usage: $0 update-yum VERSION"
        return 1
    fi
    
    print_info "Updating YUM repository with version $VERSION..."
    
    # Check if RPM package exists
    RPM_FILE="${RELEASE_DIR}/pipe-pop-${VERSION}-1.x86_64.rpm"
    if [ ! -f "$RPM_FILE" ]; then
        print_error "RPM package not found: $RPM_FILE"
        print_info "Please build the package first using create_packages.sh"
        return 1
    fi
    
    # Copy RPM package to YUM repository
    mkdir -p "${YUM_DIR}/packages"
    cp "$RPM_FILE" "${YUM_DIR}/packages/"
    
    # Update repository metadata
    createrepo --update "${YUM_DIR}"
    
    # Sign repository metadata if GPG key is available
    if gpg --list-secret-keys "packages@pipe.network" &> /dev/null; then
        gpg --detach-sign --armor "${YUM_DIR}/repodata/repomd.xml"
    else
        print_warning "GPG key not found. Repository metadata not signed."
        print_info "To sign the repository metadata, generate a GPG key using installers/generate_gpg_key.sh"
    fi
    
    print_success "YUM repository updated successfully."
    print_info "To upload the YUM repository to your server, run:"
    print_info "  $0 upload-yum"
    return 0
}

# Update website downloads
update_website_downloads() {
    VERSION=$1
    
    if [ -z "$VERSION" ]; then
        print_error "No version specified for website downloads update."
        print_info "Usage: $0 update-website VERSION"
        return 1
    fi
    
    print_info "Updating website downloads with version $VERSION..."
    
    # Check if packages exist
    APPIMAGE_FILE="${RELEASE_DIR}/pipe-pop-${VERSION}-amd64.AppImage"
    DEB_FILE="${RELEASE_DIR}/pipe-pop_${VERSION}_amd64.deb"
    RPM_FILE="${RELEASE_DIR}/pipe-pop-${VERSION}-1.x86_64.rpm"
    TARBALL_FILE="${RELEASE_DIR}/pipe-pop-${VERSION}.tar.gz"
    
    if [ ! -f "$APPIMAGE_FILE" ] || [ ! -f "$DEB_FILE" ] || [ ! -f "$RPM_FILE" ] || [ ! -f "$TARBALL_FILE" ]; then
        print_warning "Some packages not found. Only copying available packages."
    fi
    
    # Copy packages to website downloads
    mkdir -p "${WEBSITE_DIR}/downloads"
    
    if [ -f "$APPIMAGE_FILE" ]; then
        cp "$APPIMAGE_FILE" "${WEBSITE_DIR}/downloads/"
        # Create latest symlink
        ln -sf "pipe-pop-${VERSION}-amd64.AppImage" "${WEBSITE_DIR}/downloads/pipe-pop-latest-amd64.AppImage"
    fi
    
    if [ -f "$DEB_FILE" ]; then
        cp "$DEB_FILE" "${WEBSITE_DIR}/downloads/"
        # Create latest symlink
        ln -sf "pipe-pop_${VERSION}_amd64.deb" "${WEBSITE_DIR}/downloads/pipe-pop_latest_amd64.deb"
    fi
    
    if [ -f "$RPM_FILE" ]; then
        cp "$RPM_FILE" "${WEBSITE_DIR}/downloads/"
        # Create latest symlink
        ln -sf "pipe-pop-${VERSION}-1.x86_64.rpm" "${WEBSITE_DIR}/downloads/pipe-pop-latest-1.x86_64.rpm"
    fi
    
    if [ -f "$TARBALL_FILE" ]; then
        cp "$TARBALL_FILE" "${WEBSITE_DIR}/downloads/"
        # Create latest symlink
        ln -sf "pipe-pop-${VERSION}.tar.gz" "${WEBSITE_DIR}/downloads/pipe-pop-latest.tar.gz"
    fi
    
    # Update version in installer script
    sed -i "s/LATEST_VERSION=\"[0-9.]*\"/LATEST_VERSION=\"${VERSION}\"/" "${WEBSITE_DIR}/downloads/install.sh"
    
    print_success "Website downloads updated successfully."
    print_info "To upload the website downloads to your server, run:"
    print_info "  $0 upload-website"
    return 0
}

# Upload APT repository
upload_apt_repository() {
    print_info "Uploading APT repository..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Required for uploads."
        print_info "Installation instructions: https://aws.amazon.com/cli/"
        return 1
    fi
    
    # Upload to S3
    aws s3 sync "${APT_DIR}" "${WEBSITE_BUCKET}/apt" --acl public-read
    
    print_success "APT repository uploaded successfully."
    print_info "Repository URL: ${WEBSITE_URL}/apt"
    print_info "To use this repository, run:"
    print_info "  echo \"deb ${WEBSITE_URL}/apt stable main\" | sudo tee /etc/apt/sources.list.d/pipe-pop.list"
    print_info "  curl -fsSL ${WEBSITE_URL}/apt/dists/stable/Release.gpg | sudo apt-key add -"
    print_info "  sudo apt-get update"
    print_info "  sudo apt-get install pipe-pop"
    return 0
}

# Upload YUM repository
upload_yum_repository() {
    print_info "Uploading YUM repository..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Required for uploads."
        print_info "Installation instructions: https://aws.amazon.com/cli/"
        return 1
    fi
    
    # Upload to S3
    aws s3 sync "${YUM_DIR}" "${WEBSITE_BUCKET}/yum" --acl public-read
    
    print_success "YUM repository uploaded successfully."
    print_info "Repository URL: ${WEBSITE_URL}/yum"
    print_info "To use this repository, run:"
    print_info "  sudo tee /etc/yum.repos.d/pipe-pop.repo << EOF"
    print_info "  [pipe-pop]"
    print_info "  name=Pipe Network PoP"
    print_info "  baseurl=${WEBSITE_URL}/yum"
    print_info "  enabled=1"
    print_info "  gpgcheck=1"
    print_info "  gpgkey=${WEBSITE_URL}/yum/repomd.xml.asc"
    print_info "  EOF"
    print_info "  sudo yum install pipe-pop"
    return 0
}

# Upload website downloads
upload_website_downloads() {
    print_info "Uploading website downloads..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Required for uploads."
        print_info "Installation instructions: https://aws.amazon.com/cli/"
        return 1
    fi
    
    # Upload to S3
    aws s3 sync "${WEBSITE_DIR}/downloads" "${WEBSITE_BUCKET}/downloads" --acl public-read
    
    print_success "Website downloads uploaded successfully."
    print_info "Downloads URL: ${WEBSITE_URL}/downloads"
    print_info "One-line installer: curl -fsSL ${WEBSITE_URL}/downloads/install.sh | sudo bash"
    return 0
}

# Display help
display_help() {
    echo "pipe-pop Distribution Channels Setup Script v1.0.0"
    echo "Usage: $0 [command] [options]"
    echo
    echo "Commands:"
    echo "  setup-all                  Set up all distribution channels"
    echo "  setup-github              Set up GitHub Releases"
    echo "  setup-apt                 Set up APT repository"
    echo "  setup-yum                 Set up YUM repository"
    echo "  setup-website             Set up website downloads"
    echo "  update-apt VERSION        Update APT repository with version"
    echo "  update-yum VERSION        Update YUM repository with version"
    echo "  update-website VERSION    Update website downloads with version"
    echo "  upload-apt                Upload APT repository to server"
    echo "  upload-yum                Upload YUM repository to server"
    echo "  upload-website            Upload website downloads to server"
    echo "  upload-all                Upload all distribution channels to server"
    echo "  help                      Display this help message"
    echo
    echo "Examples:"
    echo "  $0 setup-all              # Set up all distribution channels"
    echo "  $0 update-apt 1.0.0       # Update APT repository with version 1.0.0"
    echo "  $0 upload-all             # Upload all distribution channels to server"
}

# Main function
main() {
    # Check if command is provided
    if [ $# -eq 0 ]; then
        display_help
        exit 0
    fi
    
    # Parse command
    COMMAND=$1
    shift
    
    case $COMMAND in
        setup-all)
            check_required_tools "all"
            create_directories
            setup_github_releases
            setup_apt_repository
            setup_yum_repository
            setup_website_downloads
            ;;
            
        setup-github)
            check_required_tools "github"
            create_directories
            setup_github_releases
            ;;
            
        setup-apt)
            check_required_tools "apt"
            create_directories
            setup_apt_repository
            ;;
            
        setup-yum)
            check_required_tools "yum"
            create_directories
            setup_yum_repository
            ;;
            
        setup-website)
            check_required_tools "website"
            create_directories
            setup_website_downloads
            ;;
            
        update-apt)
            check_required_tools "apt"
            update_apt_repository "$1"
            ;;
            
        update-yum)
            check_required_tools "yum"
            update_yum_repository "$1"
            ;;
            
        update-website)
            check_required_tools "website"
            update_website_downloads "$1"
            ;;
            
        upload-apt)
            check_required_tools "apt"
            upload_apt_repository
            ;;
            
        upload-yum)
            check_required_tools "yum"
            upload_yum_repository
            ;;
            
        upload-website)
            check_required_tools "website"
            upload_website_downloads
            ;;
            
        upload-all)
            check_required_tools "all"
            upload_apt_repository
            upload_yum_repository
            upload_website_downloads
            ;;
            
        help)
            display_help
            ;;
            
        *)
            print_error "Unknown command: $COMMAND"
            display_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
