# Pipe PoP Node Documentation

This directory contains comprehensive documentation for setting up, configuring, and maintaining a Pipe PoP node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## Documentation Index

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

## Quick Links

- [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
- [Surrealine Website](https://www.surrealine.com)
- [Pipe Network Dashboard](https://dashboard.pipenetwork.com)

## Getting Started

If you're new to Pipe PoP nodes, we recommend starting with the [SETUP_GUIDE.md](./SETUP_GUIDE.md) document, which provides a comprehensive guide to setting up your node.

## Port Configuration

The Pipe PoP node requires the following ports to be open:

- **Port 80**: HTTP traffic
- **Port 443**: HTTPS traffic
- **Port 8003**: Pipe PoP node communication

These ports are automatically configured during installation, but you may need to ensure they are properly forwarded in your router if you want your node to be accessible from the internet. The node may not actively listen on all ports until it receives traffic, which is normal behavior.

To check if the ports are properly configured, run:

```bash
pop --monitor
```

## Global Pop Command

The global `pop` command is automatically installed during setup and allows you to manage your node from anywhere on your system without having to navigate to the installation directory.

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup
```

For more details, see the [GLOBAL_COMMAND.md](./GLOBAL_COMMAND.md) document.

## Using the Surrealine Referral Code

When setting up your Pipe PoP node, you can use the Surrealine referral code to earn additional rewards:

```bash
sudo pop --signup-by-referral-route 3a069772281d9b1b
```

## Managing Your Node

After installation, you can manage your node using the global `pop` command from anywhere on your system:

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup
```

For more details, see the [GLOBAL_COMMAND.md](./GLOBAL_COMMAND.md) document.

## Checking for Updates and Updating

The Pipe PoP node includes functionality to check for updates and update the binary when new versions are available:

```bash
# Check for updates
pop --check-update

# Update to the latest version
pop --update
```

When you check for updates:
- If your node is already running the latest version, you'll be informed that no update is needed.
- If a new version is available, you'll be provided with information about the new version and instructions on how to update.

When updating:
- The system automatically creates a backup of your current binary before updating.
- The new binary is verified before replacing the old one.
- The Pipe PoP service is automatically restarted after updating.
- You can force a reinstall of the same version using the `--force` flag if needed.

## Support

If you need help with your Pipe PoP node:

1. Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) document for common issues and solutions
2. Visit the [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com)

## About Pipe Network

The Pipe Network is a decentralized content delivery network (CDN) with several key features: 