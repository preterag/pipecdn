# Community Enhancement: Installation Guide

> **IMPORTANT**: This is a community-created enhancement for Pipe Network. 
> It is not part of the official Pipe Network project.
> For official documentation, please refer to [Official Pipe Network Documentation](../official/PIPE_NETWORK_DOCUMENTATION.md).

![Pipe Network](../images/pipe-network-pop.jpeg)

This guide walks you through installing the Pipe Network node management tools with community enhancements.

## System Requirements

- Linux operating system (Ubuntu 20.04+ or Debian 11+ recommended)
- At least 2GB RAM
- At least 20GB free disk space
- Stable internet connection
- Open ports (80, 443, 8003)

## Installation Options

The Pipe Network PoP Management Tools support two installation modes:

### System-Wide Installation (Default)

Best for multi-user environments and systems where you have sudo access.

```bash
# Download the package (if you haven't already)
git clone https://github.com/pipe-network/pop-tools.git
cd pop-tools

# Run the installer
./tools/pop --install
```

This will:
1. Install all required dependencies
2. Configure system paths
3. Set up the node as a system service
4. Install the global `pop` command to `/usr/local/bin/pop`
5. Create all necessary configuration files in `/opt/pipe-pop/`

### User-Level Installation (No Sudo Required)

Best for single-user environments or systems where you don't have sudo access.

```bash
# Download the package (if you haven't already)
git clone https://github.com/pipe-network/pop-tools.git
cd pop-tools

# Run the user-level installer
./tools/pop --install --user
```

This will:
1. Install required user-level dependencies
2. Configure user paths
3. Install the `pop` command to `~/.local/bin/pop`
4. Create all necessary configuration files in `~/.local/share/pipe-pop/`

## Post-Installation Setup

After installation, you need to configure your Solana wallet address:

```bash
# For system-wide installation
pop --wallet set YOUR_SOLANA_WALLET_ADDRESS

# For user-level installation
pop --wallet set YOUR_SOLANA_WALLET_ADDRESS
```

## Starting Your Node

Start your node with:

```bash
pop --start
```

Check that it's running with:

```bash
pop --status
```

## Verifying Installation

To verify everything is working correctly:

1. Check node status: `pop --status`
2. Run real-time monitoring: `pop --pulse`
3. Check security settings: `pop --security check`

## Custom Installation Options

You can customize your installation:

```bash
# Force reinstallation
./tools/pop --install --force

# Install to a custom location
./tools/pop --install --dir=/custom/path

# User-level installation with force option
./tools/pop --install --user --force
```

## Privilege Management

Most monitoring commands will work without sudo access, but some commands require elevated privileges. To minimize password prompts:

```bash
# Pre-authenticate to cache sudo access for 15 minutes
pop --auth
```

This will prompt for your password once, and then cache sudo access for 15 minutes, reducing the need for password prompts for subsequent commands.

## Troubleshooting

If you encounter issues:

- Check the logs: `pop --logs`
- Verify configuration: `pop --config show`
- See the [Troubleshooting Guide](../reference/troubleshooting.md)

## Next Steps

Now that your node is installed:

- [Configure your wallet](wallet-setup.md)
- [Learn about earning rewards](earning.md)
- [See the complete command reference](../reference/cli.md)

## Uninstalling

To remove:

```bash
# Remove system-wide installation
pop --uninstall

# Remove user-level installation
pop --uninstall --user
``` 