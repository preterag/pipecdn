# 📦 Distribution Channels

This document describes the distribution channels and scripts for the Pipe Network PoP Node.

## Distribution Channels

The Pipe Network PoP Node is distributed through multiple channels:

1. **GitHub Releases**: Official releases with all package formats
2. **APT Repository**: For Debian/Ubuntu-based systems
3. **YUM Repository**: For Red Hat/Fedora/CentOS-based systems
4. **Website Downloads**: Direct downloads from packages.pipe.network

## Distribution Scripts

### setup_distribution.sh

The `setup_distribution.sh` script sets up and manages distribution channels for pipe-pop packages.

**Features:**
- Sets up GitHub releases
- Sets up APT repository
- Sets up YUM repository
- Sets up website downloads
- Updates channels with new versions
- Uploads packages to servers

**Usage:**
```bash
# Set up all distribution channels
./setup_distribution.sh setup-all

# Set up specific channels
./setup_distribution.sh setup-github
./setup_distribution.sh setup-apt
./setup_distribution.sh setup-yum
./setup_distribution.sh setup-website

# Update channels with a new version
./setup_distribution.sh update-apt 1.0.0
./setup_distribution.sh update-yum 1.0.0
./setup_distribution.sh update-website 1.0.0

# Upload to servers
./setup_distribution.sh upload-all
```

## Available Package Formats

The Pipe Network PoP Node is available in the following formats:

- **AppImage**: Universal Linux format that works on most distributions
- **DEB**: For Debian/Ubuntu-based systems
- **RPM**: For Red Hat/Fedora/CentOS-based systems
- **Source Tarball**: For manual installation on any Linux system

## Setting Up Distribution Channels

### GitHub Releases

To set up GitHub releases:

1. Create a new release on GitHub
2. Upload the packages
3. Add release notes
4. Publish the release

### APT Repository

To set up an APT repository:

1. Create the repository structure
2. Generate the package index
3. Sign the package index
4. Upload to the server

### YUM Repository

To set up a YUM repository:

1. Create the repository structure
2. Generate the package index
3. Sign the package index
4. Upload to the server

### Website Downloads

To set up website downloads:

1. Create the download directory
2. Upload the packages
3. Generate the download page
4. Update the website

## Hosting Your Own Repository

If you want to host your own pipe-pop repository:

1. Set up the distribution channels using the script
2. Configure your web server to serve the repository directories
3. Update the repository URLs in the installation instructions

## Verifying Package Authenticity

All official pipe-pop packages are signed with GPG. To verify a package:

```bash
# Download the signature
wget https://github.com/preterag/pipe-pop/releases/download/v1.0.0/pipe-pop-1.0.0-amd64.AppImage.asc
# Download the public key
wget -O- https://raw.githubusercontent.com/preterag/pipe-pop/main/keys/public.key | gpg --import
# Verify the package
gpg --verify pipe-pop-1.0.0-amd64.AppImage.asc pipe-pop-1.0.0-amd64.AppImage
```

## Future Plans

We're continuously improving our distribution channels. Future plans include:

- Windows and macOS package formats
- Snap and Flatpak packages for Linux
- Docker images for containerized deployment
- Automated update notifications 