# Pipe PoP Node Setup

This repository contains the setup and configuration for a Pipe PoP (Proof of Participation) node.

## Overview

The Pipe PoP node is a component of the Pipe Network ecosystem. This implementation provides a complete framework for setting up, configuring, and maintaining a Pipe PoP node.

## System Requirements

- **RAM**: Minimum 4GB, recommended 8GB
- **Disk Space**: Minimum 50GB, recommended 100GB+
- **Operating System**: Linux (Ubuntu 20.04 or newer recommended)
- **Network**: Stable internet connection with open ports 80, 443, and 8003
- **Solana Wallet**: Required for node operation and rewards

## Directory Structure

- `bin/`: Contains the Pipe PoP binary
- `cache/`: Stores cache data for the Pipe PoP node
- `config/`: Configuration files for the Pipe PoP node
- `logs/`: Log files for monitoring the node
- `backups/`: Backup archives of important node data

## Scripts

- `setup.sh`: Main setup script for installing the Pipe PoP node
- `run_node.sh`: Script for manually running the node
- `backup.sh`: Script for backing up important node data
- `monitor.sh`: Script for monitoring node status
- `install_service.sh`: Script for managing the systemd service

## Setup Process

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

## Documentation

For more detailed information, please refer to the following documentation files:

- `DOCUMENTATION.md`: Comprehensive documentation
- `SERVICE_README.md`: Systemd service documentation
- `DEVELOPMENT_PLAN.md`: Development tracking
- `IMPLEMENTATION_SUMMARY.md`: Implementation summary

## Maintenance

Regular maintenance tasks:
- Backup of node_info.json: `./backup.sh`
- Monitoring of node status: `./monitor.sh`
- Updating the Pipe PoP binary when new versions are released

## Important Notes

- The node requires ports 80, 443, and 8003 to be open
- A Solana wallet is required for operation
- Cache data should be stored in a location with sufficient disk space

## License

This project is licensed under the [LICENSE INFORMATION]. 