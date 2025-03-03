# Pipe PoP Node

A complete implementation for setting up and managing a Pipe PoP (Points of Presence) node for the Pipe Network decentralized CDN.

## Quick Start (One-Command Setup)

The easiest way to set up a Pipe PoP node is to use our automated setup script:

```bash
# Download the setup script
curl -L -o easy_setup.sh https://raw.githubusercontent.com/e3o8o/pipecdn/master/easy_setup.sh
chmod +x easy_setup.sh

# Run the setup script (requires sudo)
sudo ./easy_setup.sh
```

This script will:
1. Install all required dependencies
2. Download the Pipe PoP binary and supporting scripts
3. Help you set up a Solana wallet (or use your existing one)
4. Apply the Surrealine referral code (with your permission)
5. Configure and start the node as a system service
6. Set up automated backups

Just follow the prompts and your node will be up and running in minutes!

## Manual Setup

If you prefer to set up your node manually, follow these steps:

# Pipe PoP Node Setup

This repository contains the setup and configuration for a Pipe PoP (Points of Presence) node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## About Pipe Network

Pipe Network is a decentralized, permissionless content delivery network (CDN) built on the Solana blockchain. It addresses the limitations of traditional centralized CDNs through a distributed network of hyperlocal Pipe PoP (Points of Presence) nodes strategically deployed in underserved areas.

### Key Features and Benefits:

- **Decentralized Architecture**: Anyone can operate nodes, creating a truly global and resilient network
- **Hyperlocal Focus**: Pipe PoP nodes are distributed in underserved regions to dramatically reduce latency
- **Blockchain-Powered**: Built on Solana for transparent, secure operations, and fair compensation
- **Cost-Efficient**: Reduces operational costs compared to traditional CDNs
- **Equitable Access**: Improves content delivery in regions traditionally underserved by centralized CDNs
- **Flexible Payment Structure**: Uses Pipe Credits and Data Credits to align incentives between users and node operators
- **Enhanced Security**: Includes DDoS protection, dynamic IP/geographical blocking, and DMCA complaint handling

By participating in the Pipe Network ecosystem through running a Pipe PoP node, you help expand this revolutionary approach to content delivery while earning rewards for your contribution.

## About Surrealine

[Surrealine](https://www.surrealine.com) is a streaming platform that utilizes the Pipe Network decentralized CDN for content delivery. By setting up a Pipe PoP node using this repository, you can participate in the Pipe Network ecosystem and help propagate Surrealine content globally, while earning rewards for your contribution.

### Contact Surrealine

- **Website**: [www.surrealine.com](https://www.surrealine.com)
- **Email**: [hello@surrealine.com](mailto:hello@surrealine.com)
- **Twitter**: [@surrealine](https://twitter.com/surrealine)

## Overview

The Pipe PoP (Points of Presence) node is a component of the Pipe Network ecosystem. This implementation provides a complete framework for setting up, configuring, and maintaining a Pipe PoP node.

## System Requirements

- **RAM**: Minimum 4GB, recommended 8GB
- **Disk Space**: Minimum 50GB, recommended 100GB+
- **Operating System**: Linux (Ubuntu 20.04 or newer recommended)
- **Network**: Stable internet connection with open ports 80, 443, and 8003
- **Solana Wallet**: Required for node operation and rewards

## Directory Structure

- `bin/`: Contains the Pipe PoP binary (v0.2.8)
- `cache/`: Stores cache data for the Pipe PoP node
- `config/`: Configuration files for the Pipe PoP node
- `logs/`: Log files for monitoring the node
- `backups/`: Backup archives of important node data
- `docs/`: Documentation files

## Scripts

- `setup.sh`: Main setup script for installing the Pipe PoP (Points of Presence) node
- `run_node.sh`: Script for manually running the node
- `backup.sh`: Script for backing up important node data
- `monitor.sh`: Script for monitoring node status
- `install_service.sh`: Script for managing the systemd service
- `update_binary.sh`: Script for updating the Pipe PoP binary
- `setup_backup_schedule.sh`: Script for setting up regular backup schedules

## Setup Process

### Standard Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/e3o8o/pipecdn.git
   cd pipecdn
   ```

2. Install dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl net-tools
   ```

3. Run the setup script:
   ```bash
   ./setup.sh
   ```

4. Install the systemd service:
   ```bash
   sudo ./install_service.sh all
   ```

### Quick Start

For a faster way to start your Pipe PoP node, you can use the quick start script:

```bash
sudo ./pop
```

This script will:
1. Check if the Pipe PoP service is already running
2. Start the service if it's installed but not running
3. Run the node in foreground mode if the service is not installed
4. Automatically use your configured Solana wallet address

You can also use the script to check node status and metrics:

```bash
./pop --status       # View node status, reputation, and metrics
./pop --points-route # Check points and rewards (when available)
```

Check for and install updates easily:

```bash
./pop --check-update  # Check if a new version is available (no sudo required)
sudo ./pop --update   # Automatically download and install the latest version
```

Generate your own referral code:

```bash
./pop --gen-referral-route
```

The script supports passing any arguments directly to the Pipe PoP binary, making it the simplest way to interact with your node!

### Using Surrealine Referral Code

When setting up your Pipe PoP node, you can use our referral code to earn additional rewards:

1. After installing the Pipe PoP binary, use our referral code to sign up:
   ```bash
   sudo ./bin/pipe-pop --signup-by-referral-route 3a069772281d9b1b
   ```

2. Continue with the standard setup process.

### For Cursor Agent Users

If you're using Cursor AI agent, you can automate the entire setup process:

1. Clone this repository
2. Open the repository in Cursor
3. Ask the Cursor agent to "Set up a Pipe PoP node using the Surrealine referral code"
4. The agent will guide you through the process, executing the necessary commands and explaining each step

## Current Status

The Pipe PoP (Points of Presence) node is fully operational with the following configuration:
- Running Pipe PoP binary v0.2.8
- Configured to use your own Solana wallet address for direct rewards
- Running as a systemd service
- Monitoring and backup scripts in place
- Weekly backup schedule set up (Sundays at 2:00 AM)
- Improved port usage monitoring

## Updating the Binary

When a new version of the Pipe PoP (Points of Presence) binary is available, you can update it using one of these methods:

### Easy Method (Recommended)

```bash
# Check if an update is available
./pop --check-update

# Update to the latest version
sudo ./pop --update
```

This will automatically check for updates, download the latest version, and restart the service if needed.

### Manual Method

```bash
./update_binary.sh BINARY_URL
```

Replace `BINARY_URL` with the URL of the new binary. The script will:
1. Create a backup of the current binary
2. Download the new binary
3. Test the new binary
4. Replace the old binary with the new one
5. Restart the service if it's running

## Setting Up Backup Schedules

You can set up regular backup schedules using the setup_backup_schedule.sh script:

```bash
./setup_backup_schedule.sh [daily|weekly|monthly]
```

This will create a cron job to run the backup.sh script at the specified interval:
- `daily`: Every day at 2:00 AM
- `weekly`: Every Sunday at 2:00 AM
- `monthly`: On the 1st of every month at 2:00 AM

## Generating Your Own Referral Code

Once your Pipe PoP (Points of Presence) node is running successfully, you can generate your own referral code to share with others:

```bash
./bin/pipe-pop --gen-referral-route
```

Share this code with others to earn additional rewards when they set up their nodes using your referral code.

## Documentation

For more detailed information, please refer to the following documentation files:

- `docs/DOCUMENTATION.md`: Comprehensive documentation
- `docs/SERVICE_README.md`: Systemd service documentation
- `docs/DEVELOPMENT_PLAN.md`: Development tracking
- `docs/IMPLEMENTATION_SUMMARY.md`: Implementation summary
- `docs/REFERRAL_GUIDE.md`: Guide to the referral system
- `docs/REPUTATION_SYSTEM.md`: Explanation of the reputation system
- `docs/PIPE_POP_SETUP_GUIDE.md`: Step-by-step setup guide

## Key Features of Pipe Network

Pipe Network offers several advantages over traditional centralized CDNs:

- **Hyperlocal Content Delivery**: Strategic deployment of Pipe PoP nodes in underserved areas optimizes latency and ensures faster content delivery
- **Blockchain Integration**: Built on the Solana blockchain for transparent operations, secure transactions, and fair compensation
- **Economic Model**: Uses Pipe Credits and Data Credits to create flexible, transparent payment structures that align incentives between users and node operators
- **Permissionless Participation**: Anyone with the necessary hardware can contribute to the network, eliminating central points of control
- **Cost Efficiency**: Decentralized infrastructure reduces operational costs compared to traditional CDNs
- **Advanced Security**: Features include DDoS protection, dynamic IP/geographical blocking, DMCA complaint handling, and access to rolling logs
- **Reputation System**: Nodes earn reputation based on uptime, historical performance, and egress data
- **Referral System**: Earn rewards by referring new nodes to the network
- **Automatic Updates**: Nodes check for updates on startup
- **Geographic Distribution**: Intelligent peer selection based on geographic location

For more information, visit the [official documentation](https://docs.pipe.network/devnet-2).

## Maintenance

Regular maintenance tasks:
- Backup of node_info.json: `./backup.sh`
- Monitoring of node status: `./monitor.sh`
- Updating the Pipe PoP binary when new versions are released: `./update_binary.sh BINARY_URL`

## Important Notes

- The node requires ports 80, 443, and 8003 to be open
- A Solana wallet is required for operation
- Cache data should be stored in a location with sufficient disk space
- Backup your node_info.json file regularly, as it's linked to your IP address and not recoverable if lost

## Why Decentralized CDNs Matter

Traditional centralized CDNs face several limitations in today's rapidly evolving digital landscape:

- **Geographic Limitations**: Centralized CDNs are primarily concentrated in urban or high-traffic areas, leading to slower speeds in remote or underserved locations
- **High Capital Investment**: Traditional CDNs require significant infrastructure investment, creating barriers for smaller businesses
- **Proprietary Systems**: Many CDNs operate within closed ecosystems, limiting accessibility and flexibility
- **Centralized Bottlenecks**: Single points of failure can impact content delivery across entire regions

Pipe Network addresses these challenges through its decentralized, permissionless model that:
- Expands content delivery to underserved regions through hyperlocal Pipe PoP nodes
- Reduces costs through shared infrastructure and blockchain-based incentives
- Creates an open ecosystem where anyone can participate
- Eliminates central points of failure for greater resilience

By running a Pipe PoP node, you're contributing to a more equitable, efficient, and resilient internet infrastructure.
