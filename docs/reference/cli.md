![Pipe Network](../images/pipe-network-pop.jpeg)

# CLI Reference

The `pop` command manages your Pipe Network node, supporting both flag-based and traditional command formats.

## Command Format Options

- **Flag format (recommended)**: `pop --command [options]`
  - Example: `pop --status --detailed`
  - More consistent with modern CLI tools

- **Traditional format (compatibility)**: `pop command [options]`
  - Example: `pop status --detailed`
  - Compatible with older scripts

## Quick Command Summary

- **Check status**: `pop --status` or `pop status`
- **Monitor in real-time**: `pop --pulse` or `pop monitoring pulse`
- **View earnings**: `pop --points` or `pop points`
- **Show wallet**: `pop --wallet info` or `pop wallet info`
- **Run security check**: `pop --security check` or `pop security check`
- **Get help**: `pop --help` or `pop help`
- **Pre-authenticate**: `pop --auth` (caches sudo access for 15 minutes)

## Command Reference Table

| Command | Description | Options | Requires Root | Example |
|---------|-------------|---------|---------------|---------|
| **Setup & Basic Commands** |
| `--status` | Check node status and reputation | `--detailed` | No | `pop --status` |
| `--wallet info` | Show current wallet address | | No | `pop --wallet info` |
| `--wallet set ADDRESS` | Set a new wallet address | `ADDRESS`: Solana wallet address | Yes* | `pop --wallet set WALLET_ADDRESS` |
| `--restart` | Restart the node service | | Yes* | `pop --restart` |
| `--help` | Show help message | | No | `pop --help` |
| `--auth` | Pre-authenticate (cache sudo access) | | Yes | `pop --auth` |
| **Monitoring** |
| `--pulse` | Show real-time node pulse | `--once` | Yes* | `pop --pulse` |
| `--logs` | View service logs | `--follow` | No | `pop --logs` |
| `--points` | Show earned points and rewards | | No | `pop --points` |
| `--leaderboard` | Show network leaderboard | | No | `pop --leaderboard` |
| **Security** |
| `--security check` | Run basic security checks | | No | `pop --security check` |
| `--security audit` | Perform full security audit | | Yes* | `pop --security audit` |
| **Updates & Maintenance** |
| `--update` | Update node software | | Yes* | `pop --update` |
| `--backup` | Create a backup | | Yes* | `pop --backup` |
| **Installation** |
| `--install` | Install system-wide | `--force`, `--dir=PATH` | Yes | `pop --install` |
| `--install --user` | Install for current user | `--force` | No | `pop --install --user` |
| `--uninstall` | Remove installation | `--user` | Yes | `pop --uninstall` |

\* *Can run in fallback mode without sudo, but with limited functionality*

![PoP Node Management Tools](../images/PoP-node-management.jpeg)

## Setup and Basic Usage

### Checking Node Status

```bash
# View node status, reputation, and performance
pop --status
# or traditional format
pop status
```

This command displays:
- Current reputation score
- Points earned
- Network statistics
- Uptime information

### Managing Your Wallet

```bash
# Check current wallet
pop --wallet info

# Update wallet address
pop --wallet set YOUR_SOLANA_WALLET_ADDRESS
```

## Monitoring Your Node

### Real-time Monitoring

```bash
# Start real-time monitoring dashboard
pop --pulse

# Collect metrics once without displaying dashboard
pop --pulse --once
```

The dashboard shows:
- Live status updates
- Reputation metrics
- Resource usage
- Port status

Press `Ctrl+C` to exit monitoring.

### Viewing Logs

```bash
# View node logs
pop --logs

# Follow logs in real-time
pop --logs --follow
```

### Checking Earnings

```bash
# View earned points
pop --points
```

## Security Management

```bash
# Run a quick security check
pop --security check

# Perform comprehensive security audit
pop --security audit
```

## Updating Your Node

```bash
# Update to the latest version
pop --update
```

The update process:
1. Creates a backup automatically
2. Downloads the latest binary
3. Verifies installation
4. Restarts the service

## Installation Options

### System-Wide Installation

```bash
# Basic system-wide installation (requires sudo)
./tools/pop --install

# Force reinstallation
./tools/pop --install --force

# Custom installation location
./tools/pop --install --dir=/custom/path
```

### User-Level Installation

```bash
# Install for current user only
./tools/pop --install --user

# Force reinstallation for current user
./tools/pop --install --user --force
```

## Privilege Management

Most monitoring commands will work without sudo access, but some commands require elevated privileges. To minimize password prompts:

```bash
# Pre-authenticate to cache sudo access for 15 minutes
pop --auth
```

## Cross-References

- For wallet setup instructions, see [Wallet Setup Guide](../guides/wallet-setup.md)
- For monitoring details, see [Earning with Pipe Network](../guides/earning.md)
- For installation, see [Installation Guide](../guides/installation.md)
- For troubleshooting, see [Troubleshooting Guide](troubleshooting.md)
- For configuration options, see [Configuration Reference](config.md) 