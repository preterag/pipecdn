# Pipe PoP Node Setup

This repository contains the setup and configuration for a Pipe PoP (Proof of Participation) node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN.

## About Surrealine

[Surrealine](https://www.surrealine.com) is a streaming platform that utilizes the Pipe Network decentralized CDN for content delivery. By setting up a Pipe PoP node using this repository, you can participate in the Pipe Network ecosystem and help propagate Surrealine content globally, while earning rewards for your contribution.

## Overview

The Pipe PoP node is a component of the Pipe Network ecosystem. This implementation provides a complete framework for setting up, configuring, and maintaining a Pipe PoP node.

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

- `setup.sh`: Main setup script for installing the Pipe PoP node
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

### Using Surrealine Referral Code

When setting up your Pipe PoP node, you can use our referral code to earn additional rewards:

1. After installing the Pipe PoP binary, use our referral code to sign up:
   ```bash
   sudo ./bin/pipe-pop --signup-by-referral-route 6ae5e9a2e5063d8
   ```

2. Continue with the standard setup process.

### For Cursor Agent Users

If you're using Cursor AI agent, you can automate the entire setup process:

1. Clone this repository
2. Open the repository in Cursor
3. Ask the Cursor agent to "Set up a Pipe PoP node using the Surrealine referral code"
4. The agent will guide you through the process, executing the necessary commands and explaining each step

## Current Status

The Pipe PoP node is fully operational with the following configuration:
- Running Pipe PoP binary v0.2.8
- Configured with Solana wallet address: 2kyMcRZfVaks8JV8KFhYRXhGnhGxropmHohAxFwWAG1W
- Running as a systemd service
- Monitoring and backup scripts in place
- Weekly backup schedule set up (Sundays at 2:00 AM)
- Improved port usage monitoring

## Updating the Binary

When a new version of the Pipe PoP binary is available, you can update it using the update_binary.sh script:

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

Once your node is running successfully, you can generate your own referral code to share with others:

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

From the [official documentation](https://docs.pipe.network/devnet-2):

- **High Performance**: Optimized for efficient file distribution and caching
- **Reputation System**: Nodes earn reputation based on uptime, historical performance, and egress data
- **Referral System**: Earn rewards by referring new nodes to the network
- **Automatic Updates**: Nodes check for updates on startup
- **Geographic Distribution**: Intelligent peer selection based on geographic location
- **Security**: IP-based rate limiting, node ID verification, and geographic distribution tracking

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

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2023 Surrealine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 