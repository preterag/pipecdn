![Pipe Network](docs/images/pipe-network-pop.jpeg)

# Getting Started with Pipe Network PoP Node Management Tools

Welcome to the Pipe Network PoP Node Management Tools! This document will help you get up and running quickly with our enhanced node management toolkit.

**Version: v0.0.1 (Development)**

## What is This?

This toolkit provides an enhanced command-line interface for managing and monitoring your Pipe Network Proof of Participation (PoP) node. It offers features like real-time performance monitoring, historical data analysis, alerts, and simplified service management.

## Quick Install

### Prerequisites

- Linux operating system (Ubuntu 20.04+ recommended)
- Basic command line knowledge
- A Pipe Network node already installed

### Installation

```bash
# Clone the repository
git clone https://github.com/username/pipe-pop.git
cd pipe-pop

# Run the installation script
./tools/pop install
```

After installation, you can run `pop` commands from any directory.

## Essential Commands

Here are the most important commands to know:

```bash
# Get help
pop help

# Show node status
pop status

# Launch interactive dashboard
pop dashboard

# View historical performance
pop history

# Configure and check alerts
pop alerts status

# Start/stop your node
pop start
pop stop
```

## What Can You Do?

### 1. Monitor Your Node

```bash
# Basic status
pop status

# Interactive dashboard
pop dashboard

# Historical performance
pop history
```

### 2. Get Alerts & Notifications

```bash
# Check alert configuration
pop alerts status

# Configure email notifications
pop alerts config email.enable
pop alerts config email.from your-email@example.com
pop alerts config email.to admin@example.com

# Test the alert system
pop alerts test
```

### 3. Manage Your Node

```bash
# Start/stop/restart the node
pop start
pop stop
pop restart

# View logs
pop logs
```

### 4. Configure Your Node

```bash
# List configuration
pop config list

# Set configuration values
pop config set wallet.address YOUR_WALLET_ADDRESS
```

## Where to Go From Here?

- **Detailed Documentation**: Check the [docs](docs/) directory for comprehensive guides
- **Command Reference**: See [Command Reference](docs/reference/command-reference.md) for all available commands
- **Troubleshooting**: If you encounter issues, see [Troubleshooting Guide](docs/reference/troubleshooting.md)
- **Implementation Status**: See [Implementation Tracker](IMPLEMENTATION_TRACKER.md) for development status

## Getting Help

For help with specific commands, use:

```bash
pop help [command]
```

For example:
```bash
pop help dashboard
pop help alerts
```

## Important Notes

- This is a community-developed toolkit, not an official Pipe Network product
- Version v0.0.1 is a development release - features may change in future versions
- Always back up your node configuration before making significant changes

## Core Features

### Node Management

```bash
# Start your node
pop start

# Stop your node
pop stop

# Restart your node
pop restart

# View service logs
pop logs
```

### Monitoring

```bash
# Check node status
pop status

# View real-time metrics
pop pulse

# Launch interactive dashboard
pop dashboard

# View historical performance
pop history
```

### Configuration & Network

```bash
# Configure your node
pop configure

# Check and configure ports
pop ports

# Enable privileged ports (80/443)
pop ports --enable-80-443

# Check your wallet information
pop wallet --info
```

### Maintenance

```bash
# Backup your node
pop backup

# Restore from backup
pop restore

# Check for updates
pop update --check

# View comprehensive statistics
pop stats
```

## Fleet Management

For users managing multiple nodes, we offer fleet management capabilities:

```bash
# Add a node to your fleet
pop fleet-add --name=node1 --ip=192.168.1.10

# List all nodes in your fleet
pop fleet-list

# Deploy updates to all nodes
pop fleet-deploy --update

# View aggregated status
pop fleet-status
```

## Documentation & Help

- **Detailed Commands:** [Command Reference](docs/reference/command-reference.md)
- **Getting Started:** [Quick Start Guide](docs/guides/quick-start.md)
- **Network Setup:** [Port Forwarding Guide](docs/guides/port-forwarding.md)
- **Registration:** [Node Registration Guide](docs/guides/node-registration.md)
- **Problems?** [Troubleshooting Guide](docs/guides/troubleshooting.md)
- **Multiple Nodes:** [Fleet Management Guide](docs/guides/fleet-management.md)

## Earning Rewards

Your node earns rewards based on several factors:
- **Uptime** - How long your node is online
- **Egress** - How much data you serve to the network
- **History** - Your node's historical performance

Monitor your earnings and performance using the dashboard:
```bash
pop dashboard
```

---

**Need help?** Join our community on Discord or Telegram for real-time support and discussions.

*This is a community-maintained toolkit that enhances the official Pipe Network software.* 