# 📚 Pipe Network PoP Documentation

This directory contains comprehensive documentation for setting up, configuring, and maintaining a pipe-pop for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## 📑 Documentation Index

### Setup and Installation
- [**SETUP_GUIDE.md**](./SETUP_GUIDE.md): Step-by-step instructions for setting up a pipe-pop
- [**REFERRAL_GUIDE.md**](./REFERRAL_GUIDE.md): Information about the referral system and how to use referral codes
- [**GLOBAL_COMMAND.md**](./GLOBAL_COMMAND.md): Guide to installing and using the global `pop` command
- [**DISTRIBUTION.md**](./DISTRIBUTION.md): Information about distribution channels and installation options

### Operation and Monitoring
- [**MAINTENANCE.md**](./MAINTENANCE.md): Guide for maintaining and operating your pipe-pop
- [**REPUTATION_SYSTEM.md**](./REPUTATION_SYSTEM.md): Explanation of the reputation system and how to maintain a high score
- [**PULSE_MONITORING.md**](./PULSE_MONITORING.md): Real-time monitoring of your node's status and performance
- [**DASHBOARD.md**](./DASHBOARD.md): Comprehensive dashboard for unified node monitoring
- [**TROUBLESHOOTING.md**](./TROUBLESHOOTING.md): Common issues and their solutions

### Development and Technical Information
- [**DEVELOPMENT.md**](./DEVELOPMENT.md): Development information and implementation details
- [**DEVELOPMENT_PLAN.md**](./DEVELOPMENT_PLAN.md): Development roadmap and progress tracking
- [**IMPLEMENTATION_SUMMARY.md**](./IMPLEMENTATION_SUMMARY.md): Summary of the implementation details

### Articles and Implementation Journey
- [**articles/**](./articles/): Detailed articles about our implementation journey and future directions

## 🔗 Quick Links

- [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
- [Surrealine Website](https://www.surrealine.com)
- [Pipe Network Dashboard](https://dashboard.pipenetwork.com)

## 🚀 Getting Started

If you're new to pipe-pop, we recommend starting with the [SETUP_GUIDE.md](./SETUP_GUIDE.md) document, which provides a comprehensive guide to setting up your system.

## 🔌 Port Configuration

The pipe-pop requires ports 80, 443, and 8003 to be open. For detailed information about port configuration, see the main [README.md](../README.md#-port-configuration).

## 🔌 Global Command

The global `pop` command allows you to manage your node from anywhere on your system. It can be installed in two ways:

```bash
# Method 1: Create a symbolic link (recommended)
sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop

# Method 2: Use the installation script
sudo ./install_global_pop.sh
```

For a complete list of available commands and usage examples, see [GLOBAL_COMMAND.md](./GLOBAL_COMMAND.md).

## 📦 Installation Options

pipe-pop can be installed through multiple distribution channels:

1. **One-Line Installer**: `curl -fsSL https://packages.pipe.network/downloads/install.sh | sudo bash`
2. **APT Repository**: For Debian/Ubuntu systems
3. **YUM Repository**: For Fedora/CentOS systems
4. **Direct Downloads**: AppImage, DEB, RPM, and source packages
5. **GitHub Releases**: All package formats available on GitHub

For detailed information about installation options, see [DISTRIBUTION.md](./DISTRIBUTION.md).

## 🔄 Checking for Updates and Updating

The pipe-pop includes functionality to check for updates and update the binary when new versions are available:

```bash
# Check for updates
pop --check-update

# Update to the latest version
sudo pop --update

# Force reinstall a specific version
sudo pop --update vX.Y.Z --force
```

When you check for updates:
- If your node is already running the latest version, you'll be informed that no update is needed.
- If a new version is available, you'll be provided with information about the new version and instructions on how to update.

When updating:
- The system automatically creates a backup of your current binary before updating.
- The new binary is verified before replacing the old one.
- The pipe-pop service is automatically restarted after updating.
- You can force a reinstall of the same version using the `--force` flag if needed.

## 📊 Monitoring Your Node

The pipe-pop includes several tools for monitoring your node:

```bash
# Check node status
pop --status

# View detailed uptime statistics
pop --stats

# Real-time pulse monitoring with different modes
pop --pulse                   # Standard mode (exit with 'q')
pop --pulse -i                # Interactive mode (exit with any key)
pop --pulse -c                # Continuous mode (exit with Ctrl+C)

# Comprehensive dashboard
pop --dashboard               # Full dashboard with auto-refresh
pop --dashboard --refresh 10  # Refresh every 10 seconds
pop --dashboard --export HTML # Export dashboard to HTML file
```

For detailed information about the monitoring features:
- [Pulse Monitoring Guide](./PULSE_MONITORING.md)
- [Dashboard Guide](./DASHBOARD.md)

## 🆘 Support

If you need help with your pipe-pop:

1. Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) document for common issues and solutions
2. Visit the [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com)

## 🔮 Future Directions

We're continuously improving the pipe-pop implementation. For details about our planned enhancements, see the [Future Directions](../README.md#-future-directions) section in the main README. 