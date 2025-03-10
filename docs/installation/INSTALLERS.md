# 📦 Installers

This document describes the installers available for the Pipe Network PoP Node.

## Available Installers

### install.sh

The `install.sh` script is the main installer for the Pipe Network PoP Node.

**Features:**
- Detects the operating system and architecture
- Downloads the appropriate package
- Installs the package and sets up the service
- Creates necessary symlinks and configuration

**Usage:**
```bash
curl -fsSL https://packages.pipe.network/downloads/install.sh | sudo bash
```

Or if you have downloaded the script:

```bash
sudo ./install.sh
```

### generate_gpg_key.sh

The `generate_gpg_key.sh` script generates GPG keys for signing packages.

**Features:**
- Generates a GPG key pair
- Exports the public key for distribution
- Secures the private key

**Usage:**
```bash
./generate_gpg_key.sh
```

## Installation Methods

### One-Line Installer (Recommended)

Install pipe-pop with a single command:

```bash
curl -fsSL https://packages.pipe.network/downloads/install.sh | sudo bash
```

### APT Repository (Debian/Ubuntu)

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

### YUM Repository (Fedora/CentOS)

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

### Direct Downloads

Download the appropriate package for your system from:
- https://packages.pipe.network/downloads/
- https://github.com/preterag/pipe-pop/releases

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