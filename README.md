# 🚀 Pipe PoP Node

A complete implementation for setting up and managing a Pipe PoP node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## ✨ Features

- **🔄 Complete Setup Framework**: One-command setup script for easy deployment
- **🛠️ Production-Ready Implementation**: Systemd service integration for reliable operation
- **🧰 Comprehensive Management Tools**: Scripts for monitoring, updating, and maintaining your node
- **🌐 Global Command Access**: Manage your node from anywhere with the global `pop` command
- **📚 Detailed Documentation**: Step-by-step guides and reference materials
- **🔗 Surrealine Integration**: Pre-configured with Surrealine referral code
- **⚡ Optimized Performance**: Tuned for efficient operation
- **🔮 Future-Proof Design**: Easy updates and maintenance
- **📦 Multi-Format Packaging**: Available as AppImage, DEB, and RPM packages for easy installation

## 🚦 Quick Start

The easiest way to set up a Pipe PoP node is to use our one-command setup script:

```bash
# Download and run the setup script
curl -L https://raw.githubusercontent.com/preterag/pipecdn/master/easy_setup.sh -o easy_setup.sh
chmod +x easy_setup.sh
sudo ./easy_setup.sh
```

This script will:
1. Install all necessary dependencies
2. Set up your Solana wallet (or use your existing one)
3. Download and configure the Pipe PoP binary
4. Set up a systemd service for reliable operation
5. Configure automatic backups
6. Apply the Surrealine referral code (optional)
7. Install the global `pop` command for easy management from anywhere

After installation, you can immediately use the global `pop` command from anywhere on your system:

```bash
# Check your node status
pop --status

# View available commands
pop --help
```

## 📦 Installation Packages

We provide multiple installation formats to suit different Linux distributions:

### Universal Linux Package (AppImage)

AppImage runs on virtually any Linux distribution without installation:

```bash
# Download the AppImage
wget https://github.com/preterag/pipecdn/releases/download/v1.0.0/pipe-pop-node-1.0.0-x86_64.AppImage

# Make it executable
chmod +x pipe-pop-node-1.0.0-x86_64.AppImage

# Run it (requires sudo)
sudo ./pipe-pop-node-1.0.0-x86_64.AppImage
```

### Debian/Ubuntu Package (DEB)

For Debian-based distributions (Ubuntu, Mint, etc.):

```bash
# Download the DEB package
wget https://github.com/preterag/pipecdn/releases/download/v1.0.0/pipe-pop-node_1.0.0_amd64.deb

# Install it
sudo apt install ./pipe-pop-node_1.0.0_amd64.deb

# Run the setup
sudo pop --setup
```

### Red Hat/Fedora/CentOS Package (RPM)

For Red Hat-based distributions (Fedora, CentOS, RHEL, etc.):

```bash
# Download the RPM package
wget https://github.com/preterag/pipecdn/releases/download/v1.0.0/pipe-pop-node-1.0.0-1.x86_64.rpm

# Install it
sudo dnf install ./pipe-pop-node-1.0.0-1.x86_64.rpm

# Run the setup
sudo pop --setup
```

### Source Package

For manual installation from source:

```bash
# Download the source package
wget https://github.com/preterag/pipecdn/releases/download/v1.0.0/pipe-pop-node-1.0.0-source.tar.gz

# Extract it
tar -xzf pipe-pop-node-1.0.0-source.tar.gz
cd pipe-pop-node-1.0.0

# Run the setup script
sudo ./easy_setup.sh
```

## 📋 Manual Setup Instructions

If you prefer to set up your node manually, follow these steps:

1. Clone this repository:
   ```bash
   git clone https://github.com/preterag/pipecdn.git
   cd pipecdn
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   sudo ./setup.sh
   ```

3. Follow the on-screen instructions to complete the setup.

4. Install the global `pop` command:
   ```bash
   sudo ./install_global_pop.sh
   ```

## 🌐 About Pipe Network

The Pipe Network is a decentralized content delivery network (CDN) with several key features:

- **🔄 Decentralized Architecture**: Distributed network of nodes for content delivery
- **📍 Hyperlocal Focus**: Content delivered from the closest geographical point
- **⛓️ Blockchain-Powered**: Built on Solana for transparent operations
- **💰 Cost Efficiency**: Lower costs compared to traditional CDNs
- **⚖️ Equitable Access**: Fair compensation for node operators
- **💳 Flexible Payment Structure**: Pay-as-you-go model
- **🔒 Enhanced Security**: Distributed architecture reduces single points of failure
- **⭐ Reputation System**: Rewards reliable nodes
- **👥 Referral System**: Earn rewards for referring new nodes
- **🔄 Automatic Updates**: Easy to keep your node up-to-date
- **🌎 Geographic Distribution**: Global network of nodes
- **🔓 Permissionless Participation**: Anyone can run a node

## 🔌 Port Configuration

The Pipe PoP node requires the following ports to be open:

- **Port 80**: HTTP traffic
- **Port 443**: HTTPS traffic
- **Port 8003**: Pipe PoP node communication

These ports are automatically configured during installation, but you may need to ensure they are properly forwarded in your router if you want your node to be accessible from the internet. The node may not actively listen on all ports until it receives traffic, which is normal behavior.

To check if the ports are properly configured, run:

```bash
pop --monitor
```

## 🎬 About Surrealine

[Surrealine](https://www.surrealine.com) is a streaming platform that utilizes the Pipe Network for content delivery. By using our referral code during setup, you support the Surrealine platform.

**Contact Surrealine**:
- 📧 Email: [hello@surrealine.com](mailto:hello@surrealine.com)
- 🐦 Twitter: [@surrealine](https://twitter.com/surrealine)

## 🎮 Managing Your Node

After setting up your Pipe PoP node, you can manage it using the global `pop` command from anywhere on your system:

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup

# Check for updates
pop --check-update

# Update to the latest version (requires sudo)
sudo pop --update

# View service logs
pop --logs

# Restart the service (requires sudo)
sudo pop --restart

# Generate a referral code
pop --gen-referral-route

# Check points and rewards
pop --points
```

## 💻 System Requirements

- **Minimum**: 2GB RAM, 20GB free disk space, stable internet connection
- **Recommended**: 4GB+ RAM, 100GB+ free disk space, 100Mbps+ internet connection

## 📁 Directory Structure

- `bin/`: Contains the Pipe PoP binary
- `cache/`: Stores cache data
- `config/`: Holds configuration files
- `docs/`: Contains detailed documentation
- `logs/`: Contains log files
- `backups/`: Stores backup archives
- `*.sh`: Various utility scripts for management

## 📚 Documentation

For more detailed information, please refer to the following documentation:

- [📑 Documentation Index](docs/README.md): Overview of all documentation
- [🔧 Setup Guide](docs/SETUP_GUIDE.md): Detailed setup instructions
- [🛠️ Maintenance Guide](docs/MAINTENANCE.md): Maintenance and operation guide
- [❓ Troubleshooting Guide](docs/TROUBLESHOOTING.md): Common issues and solutions
- [👥 Referral Guide](docs/REFERRAL_GUIDE.md): Information about the referral system
- [⭐ Reputation System](docs/REPUTATION_SYSTEM.md): Explanation of the reputation system
- [💻 Development Information](docs/DEVELOPMENT.md): Development details and implementation
- [🌐 Global Command Guide](docs/GLOBAL_COMMAND.md): Guide to using the global `pop` command
- [📝 Articles](docs/articles/): Detailed articles about our implementation journey

## 🛠️ Maintenance

Regular maintenance tasks:

1. **💾 Backup**: Regularly backup your node_info.json file with `pop --backup`
2. **📊 Monitor**: Check your node status with `pop --status`
3. **🔄 Update**: Keep your Pipe PoP binary updated with `sudo pop --update`

## ⚠️ Important Notes

- A Solana wallet is required to receive rewards
- Sufficient disk space is needed for cache data
- Regular backups of node_info.json are essential

## 🌟 Why Decentralized CDNs Matter

Traditional CDNs face challenges with centralization, high costs, and limited geographic coverage. The Pipe Network's decentralized approach addresses these challenges by:

- Democratizing content delivery infrastructure
- Enabling anyone to participate in the network
- Creating a more resilient and distributed system

## 🔜 Future Directions

We're continuously improving the Pipe PoP node implementation. Future enhancements include:

1. **🖥️ Web-Based Dashboard**: A user-friendly web interface for monitoring and managing nodes
2. **📊 Enhanced Analytics**: More detailed performance analytics for node operators
3. **⚙️ Automated Optimization**: Intelligent optimization of node configuration
4. **📱 Mobile Notifications**: Alerts and notifications for important node events
5. **🔄 Multi-Node Management**: Tools for managing multiple nodes from a single interface
6. **💻 Cross-Platform Support**: Extending support beyond Linux to Windows and macOS systems

## Scripts and Tools

The Pipe PoP node comes with several scripts to help you set up and manage your node:

| Script | Version | Description |
|--------|---------|-------------|
| `easy_setup.sh` | v1.1.0 | Interactive setup script with guided installation |
| `setup.sh` | v1.0.0 | Non-interactive setup script for automated deployments |
| `fix_ports.sh` | v1.2.0 | Comprehensive port configuration and troubleshooting |
| `backup.sh` | v1.0.0 | Creates backups of important node data |
| `install_global_pop.sh` | v1.0.0 | Installs the global `pop` command for easy management |
| `monitor.sh` | v1.0.0 | Monitors the node's performance and status |
| `check_updates.sh` | v1.0.0 | Checks for updates to the Pipe PoP node |
| `update_binary.sh` | v1.0.0 | Updates the Pipe PoP binary to the latest version |
| `create_packages.sh` | v1.0.0 | Creates multi-format installation packages (AppImage, DEB, RPM) |

> Note: Some scripts may be deprecated in favor of more comprehensive alternatives. Always use the recommended script for each task.

## Contributing

👋 **Welcome Contributors!** We're excited that you're interested in improving the Pipe PoP node implementation. Your contributions help make this project better for everyone in the community. Whether you're fixing bugs, adding features, or improving documentation, your help is greatly appreciated!

We welcome contributions from the community! If you'd like to contribute to the Pipe PoP node implementation, please follow these guidelines:

### How to Contribute

1. **Fork the Repository**: Create your own fork of the repository on GitHub.
2. **Create a Branch**: Create a branch for your feature or bugfix.
3. **Make Changes**: Implement your changes, following the coding style and guidelines.
4. **Add Tests**: If applicable, add tests for your changes.
5. **Update Documentation**: Update the documentation to reflect your changes.
6. **Submit a Pull Request**: Submit a pull request to the main repository.

### Coding Guidelines

- Follow the existing coding style and conventions.
- Add appropriate comments to explain complex logic.
- Include version information in all scripts (e.g., `# Version: 1.0.0`).
- Update the version number when making significant changes.
- Add your name to the contributors section of the script.

### Versioning

We use semantic versioning for all scripts:

- **MAJOR**: Incompatible API changes
- **MINOR**: Added functionality in a backward-compatible manner
- **PATCH**: Backward-compatible bug fixes

### Getting Help

If you need help with contributing, please open an issue on GitHub or contact the Preterag team.
