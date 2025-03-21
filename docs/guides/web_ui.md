# Pipe Network Web UI Guide

## Overview

The Pipe Network PoP Web UI provides a browser-based graphical interface for managing your Pipe Network nodes. It offers all the functionality of the command-line interface in an intuitive visual format, making it easier to monitor, configure, and manage your nodes.

## Key Features

- **Installation Wizard**: Guided setup for new nodes
- **Dashboard**: Real-time monitoring of node performance
- **Configuration Management**: Visual interface for all settings
- **Fleet Management**: Manage multiple nodes from a single interface
- **Community Features**: Track performance and network statistics

## Getting Started

### Installation

The Web UI can be installed in two ways:

1. **Automatic Installation with Auto-Launch** (recommended):
   
   When running the standard installation script, you can enable automatic launch of the Web UI:

   ```bash
   curl -s https://setup.pipe-network.example/install.sh | bash -s -- --with-ui --launch-ui
   ```

   This command:
   - Installs all required dependencies
   - Sets up the core node management tools
   - Installs the Web UI components
   - Automatically launches your default browser
   - Opens the installation wizard immediately after installation completes
   
   This provides the most seamless experience, as you can complete the entire setup process through the visual interface without returning to the command line.

2. **Standard Automatic Installation**:
   
   If you prefer not to auto-launch the browser:

   ```bash
   curl -s https://setup.pipe-network.example/install.sh | bash -s -- --with-ui
   ```

   The Web UI will be installed but not automatically launched.

3. **Manual Installation**:

   If you already have the Pipe Network PoP Node Management Tools installed, you can add the Web UI:

   ```bash
   pop --ui install
   ```

### Launching the Web UI

To start the Web UI server:

```bash
pop --ui start
```

This will start the server on port 8585 (default) and automatically open your default browser to `http://localhost:8585`.

You can also manually navigate to `http://localhost:8585` in any browser.

### First-Time Setup

If this is your first time using the Pipe Network node, the Web UI will guide you through the setup process with an installation wizard. The wizard includes:

1. **Welcome**: Introduction to the setup process
2. **System Check**: Validation of system requirements
3. **Configuration**: Setting up your node parameters
4. **Installation**: Installing the necessary components
5. **Network Setup**: Configuring network connectivity
6. **Completion**: Confirming successful installation

## Main Dashboard

After setup, you'll see the main dashboard with five primary tabs:

### Node Tab

The Node tab provides core node management:

- **Status**: Current state of your node (running/stopped)
- **Controls**: Buttons to start, stop, or restart your node
- **Performance**: Key metrics like CPU, memory, and network usage
- **Logs**: Recent system logs
- **Quick Actions**: Common tasks like backup and update

### Monitor Tab

The Monitor tab offers detailed performance monitoring:

- **Performance Graphs**: Visual representation of system metrics
- **Timeline Controls**: Select different time periods to view
- **System Logs**: Complete log access with filtering options
- **Alerts**: Configure and view system alerts
- **Export**: Download metrics data for external analysis

### Fleet Tab

If you're managing multiple nodes, the Fleet tab provides:

- **Node Overview**: Summary of all nodes in your fleet
- **Node Groups**: Organize nodes into functional groups
- **Batch Operations**: Execute commands across multiple nodes
- **Deployment**: Push configuration or files to nodes
- **Status Dashboard**: Aggregated view of fleet health

### Community Tab

The Community tab connects you to the wider Pipe Network:

- **Leaderboard**: See your ranking in the network
- **Performance**: Compare your node to network averages
- **Referrals**: Manage your referral program
- **Achievements**: Track your milestones
- **Network Stats**: View overall network metrics

### Config Tab

The Config tab gives you control over all system settings:

- **Node Configuration**: Core node settings
- **Network Settings**: Connection and port configurations
- **Wallet**: Manage your wallet information
- **Security**: Access control and security settings
- **Backup**: Create and restore system backups

## Advanced Features

### Remote Access

By default, the Web UI is only accessible from the local machine. To enable remote access:

```bash
pop --ui config --remote-access=true
```

For security, remote access requires password authentication:

```bash
pop --ui config --set-password
```

### Custom Port

To run the Web UI on a different port:

```bash
pop --ui config --port=8080
```

### Auto-Start

To configure the Web UI to start automatically with your node:

```bash
pop --ui config --auto-start=true
```

## Troubleshooting

### Common Issues

**Web UI won't start**
- Check if the port is already in use: `netstat -tuln | grep 8585`
- Verify Node.js is installed: `node --version`
- Check logs: `pop --ui logs`

**Can't connect to Web UI**
- Ensure the server is running: `pop --ui status`
- Check if you're using the correct port
- Verify firewall settings if accessing remotely

**Slow performance**
- Check system resources with `top` or `htop`
- Reduce the metrics collection frequency: `pop --ui config --metrics-interval=30`

### Getting Help

If you encounter problems not covered here:

1. Check the full documentation at `docs/reference/troubleshooting.md`
2. Run the diagnostic tool: `pop --ui diagnose`
3. Submit an issue on GitHub with the diagnostic report

## Uninstalling

To remove the Web UI but keep the core node tools:

```bash
pop --ui uninstall
```

## Additional Resources

- [API Documentation](../reference/api.md) - For developers building on the Web UI API
- [UI Customization](../development/ui_customization.md) - For customizing the Web UI appearance
- [CLI Reference](../reference/cli.md) - Complete command reference including UI-related commands 