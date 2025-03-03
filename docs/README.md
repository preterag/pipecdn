# 📚 Pipe PoP Node Documentation

This directory contains comprehensive documentation for setting up, configuring, and maintaining a Pipe PoP node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## 📑 Documentation Index

### Setup and Installation
- [**SETUP_GUIDE.md**](./SETUP_GUIDE.md): Step-by-step instructions for setting up a Pipe PoP node
- [**REFERRAL_GUIDE.md**](./REFERRAL_GUIDE.md): Information about the referral system and how to use referral codes
- [**GLOBAL_COMMAND.md**](./GLOBAL_COMMAND.md): Guide to installing and using the global `pop` command

### Operation and Maintenance
- [**MAINTENANCE.md**](./MAINTENANCE.md): Guide for maintaining and operating your Pipe PoP node
- [**REPUTATION_SYSTEM.md**](./REPUTATION_SYSTEM.md): Explanation of the reputation system and how to maintain a high score
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

If you're new to Pipe PoP nodes, we recommend starting with the [SETUP_GUIDE.md](./SETUP_GUIDE.md) document, which provides a comprehensive guide to setting up your node.

## 🔌 Port Configuration

The Pipe PoP node requires ports 80, 443, and 8003 to be open. For detailed information about port configuration, see the main [README.md](../README.md#-port-configuration).

## 🌐 Global Command Overview

The global `pop` command allows you to manage your node from anywhere on your system. For a complete list of available commands and usage examples, see [GLOBAL_COMMAND.md](./GLOBAL_COMMAND.md).

## 🔄 Checking for Updates and Updating

The Pipe PoP node includes functionality to check for updates and update the binary when new versions are available:

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
- The Pipe PoP service is automatically restarted after updating.
- You can force a reinstall of the same version using the `--force` flag if needed.

## ❓ Support

If you need help with your Pipe PoP node:

1. Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) document for common issues and solutions
2. Visit the [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com)

## 🔮 Future Directions

We're continuously improving the Pipe PoP node implementation. For details about our planned enhancements, see the [Future Directions](../README.md#-future-directions) section in the main README. 