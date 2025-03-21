![Pipe Network](docs/images/pipe-network-pop.jpeg)

# Pipe Network Community Tools

A community-maintained toolkit for running a Pipe Network node and earning rewards.

> **IMPORTANT**: This is a community-maintained project and is not an official Pipe Network repository.
> The tools provided here are designed to complement the official Pipe Network software, not replace it.

## 📋 New User? Start Here

**First time setting up?** → [Start Here](START_HERE.md)

## Features

This repository provides the following community-created tools and enhancements:

- **Simple Installation**: One command to set up everything
- **Complete Monitoring**: Track your node's performance in real-time
- **Secure by Default**: Automatic firewall and security configuration
- **Easy Management**: Simple commands for all common tasks
- **Port Forwarding Tools**: Verify and configure network ports properly
- **Node Registration Helpers**: Ensure your node is properly registered

See [COMMUNITY_ENHANCEMENTS.md](COMMUNITY_ENHANCEMENTS.md) for a complete list.

## Quick Commands

```bash
pop status              # Check node status
pop monitoring pulse    # Real-time monitoring
pop wallet info         # Show wallet address
pop security check      # Verify security settings
```

## Utility Scripts

We provide several helper scripts to assist with common tasks:

- `port_check.sh`: Verifies if ports are properly forwarded
- `enable_ports.sh`: Configures port capabilities for ports 80 and 443
- `fix_node_registration.sh`: Ensures consistent node registration
- `register_node.sh`: Registers or re-registers your node

## Documentation

- [Quick Start Guide](docs/guides/quick-start.md) - Get up and running in minutes
- [Port Forwarding Guide](docs/guides/port_forwarding.md) - Configure your network
- [Node Registration Guide](docs/guides/node_registration.md) - Register your node
- [Scoring & Rewards](docs/guides/scoring.md) - Understand how rewards work
- [Command Reference](docs/reference/cli.md) - All available commands
- [Troubleshooting](docs/reference/troubleshooting.md) - Solve common issues

## Installation

One-command installation:

```bash
sudo ./INSTALL
```

## Support

Report issues via GitHub or check the [troubleshooting guide](docs/reference/troubleshooting.md).

## Version Compatibility

The community enhancements in this repository are compatible with Pipe Network DevNet 2.

## For Developers

If you want to contribute to this project, please check [Developer Documentation](docs/development/README.md).

---

*This is a community enhancement of the official Pipe Network node software.*
