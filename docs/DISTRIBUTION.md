# pipe-pop Distribution Channels

This document explains the distribution channels available for Pipe Network PoP packages and how to use them.

## Overview

pipe-pop packages are distributed through multiple channels to make installation easy across different Linux distributions:

1. **GitHub Releases**: Official releases with all package formats
2. **APT Repository**: For Debian/Ubuntu-based systems
3. **YUM Repository**: For Red Hat/Fedora/CentOS-based systems
4. **Website Downloads**: Direct downloads from packages.pipe.network
5. **One-Line Installer**: Simple installation script that detects your system

## Available Package Formats

pipe-pop is available in the following formats:

- **AppImage**: Universal Linux format that works on most distributions
- **DEB**: For Debian/Ubuntu-based systems
- **RPM**: For Red Hat/Fedora/CentOS-based systems
- **Source Tarball**: For manual installation on any Linux system

## Installation Methods

### 1. One-Line Installer (Recommended)

Install pipe-pop with a single command:

```bash
curl -fsSL https://packages.pipe.network/downloads/install.sh | sudo bash
```

This script automatically:
- Detects your operating system and architecture
- Downloads the appropriate package
- Installs the package and sets up the service
- Creates the necessary symlinks and configuration

### 2. APT Repository (Debian/Ubuntu)

Add the pipe-pop repository and install:

```bash
# Add the repository
echo "deb https://packages.pipe.network/apt stable main" | sudo tee /etc/apt/sources.list.d/pipe-pop.list
# Add the GPG key
curl -fsSL https://packages.pipe.network/apt/dists/stable/Release.gpg | sudo apt-key add -
# Update package lists
sudo apt-get update
# Install pipe-pop
sudo apt-get install pipe-pop
```

### 3. YUM Repository (Fedora/CentOS)

Add the pipe-pop repository and install:

```bash
# Add the repository
sudo tee /etc/yum.repos.d/pipe-pop.repo << EOF
[pipe-pop]
name=Pipe Network PoP
baseurl=https://packages.pipe.network/yum
enabled=1
gpgcheck=1
gpgkey=https://packages.pipe.network/yum/repomd.xml.asc
EOF
# Install pipe-pop
sudo yum install pipe-pop
```

### 4. Direct Downloads

Download the appropriate package for your system:

```bash
# AppImage (Universal)
wget https://packages.pipe.network/downloads/pipe-pop-latest-amd64.AppImage
chmod +x pipe-pop-latest-amd64.AppImage
sudo ./pipe-pop-latest-amd64.AppImage --install

# DEB Package (Debian/Ubuntu)
wget https://packages.pipe.network/downloads/pipe-pop_latest_amd64.deb
sudo dpkg -i pipe-pop_latest_amd64.deb
sudo apt-get install -f

# RPM Package (Fedora/CentOS)
wget https://packages.pipe.network/downloads/pipe-pop-latest-1.x86_64.rpm
sudo rpm -i pipe-pop-latest-1.x86_64.rpm

# Source Tarball
wget https://packages.pipe.network/downloads/pipe-pop-latest.tar.gz
tar -xzf pipe-pop-latest.tar.gz
cd pipe-pop-*
sudo ./setup.sh
```

### 5. GitHub Releases

The latest releases are available on GitHub:

```bash
# Get the latest version
VERSION=$(curl -s https://api.github.com/repos/preterag/pipe-pop/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
# Download the appropriate package
wget https://github.com/preterag/pipe-pop/releases/download/v${VERSION}/pipe-pop-${VERSION}-amd64.AppImage
# Make it executable
chmod +x pipe-pop-${VERSION}-amd64.AppImage
# Run it
sudo ./pipe-pop-${VERSION}-amd64.AppImage
```

You can find all releases at: https://github.com/preterag/pipe-pop/releases

## Setting Up Distribution Channels

For developers who want to set up distribution channels for pipe-pop packages, a script is provided:

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

## Hosting Your Own pipe-pop Repository

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

## Troubleshooting

If you encounter issues with package installation:

1. **Missing Dependencies**: Install required dependencies using your package manager
2. **Permission Issues**: Make sure you're running installation commands with sudo
3. **Download Issues**: Check your internet connection or try a different installation method
4. **Package Conflicts**: Remove conflicting packages before installation

For more help, visit [packages.pipe.network](https://packages.pipe.network) or open an issue on GitHub.

## Future Plans

We're continuously improving our distribution channels. Future plans include:

- Windows and macOS package formats
- Snap and Flatpak packages for Linux
- Docker images for containerized deployment
- Automated update notifications 