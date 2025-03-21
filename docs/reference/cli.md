![Pipe Network](../images/pipe-network-pop.jpeg)

# CLI Reference

The `pop` command manages your Pipe Network node.

## Quick Command Summary

- **Check status**: `pop status`
- **Monitor in real-time**: `pop monitoring pulse`
- **View earnings**: `pop points`
- **Show wallet**: `pop wallet info`
- **Run security check**: `pop security check`
- **Get help**: `pop help`

## Command Reference Table

| Command | Description | Options | Requires Root | Example |
|---------|-------------|---------|---------------|---------|
| **Setup & Basic Commands** |
| `status` | Check node status and reputation | | No | `pop status` |
| `wallet info` | Show current wallet address | | No | `pop wallet info` |
| `wallet set ADDRESS` | Set a new wallet address | `ADDRESS`: Solana wallet address | Yes | `sudo pop wallet set WALLET_ADDRESS` |
| `restart` | Restart the node service | | Yes | `sudo pop restart` |
| `help` | Show help message | | No | `pop help` |
| **Monitoring** |
| `monitoring pulse` | Show real-time node pulse | | No | `pop monitoring pulse` |
| `monitoring logs` | View service logs | | No | `pop monitoring logs` |
| `points` | Show earned points and rewards | | No | `pop points` |
| `leaderboard` | Show network leaderboard | | No | `pop --leaderboard` |
| **Security** |
| `security check` | Run basic security checks | | No | `pop security check` |
| `security audit` | Perform full security audit | | Yes | `sudo pop security audit` |
| **Updates & Maintenance** |
| `update` | Update node software | | Yes | `sudo pop update` |
| `backup` | Create a backup | | Yes | `sudo pop backup` |
| **Referrals** |
| `referral code` | Show your referral code | | No | `pop referral code` |
| `referral generate` | Generate a new referral code | | No | `pop referral generate` |

![PoP Node Management Tools](../images/PoP-node-management.jpeg)

## Setup and Basic Usage

### Checking Node Status

```bash
# View node status, reputation, and performance
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
pop wallet info

# Update wallet address
sudo pop wallet set YOUR_SOLANA_WALLET_ADDRESS
```

## Monitoring Your Node

### Real-time Monitoring

```bash
# Start real-time monitoring dashboard
pop monitoring pulse
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
pop monitoring logs
```

### Checking Earnings

```bash
# View earned points
pop points
```

## Security Management

```bash
# Run a quick security check
pop security check

# Perform comprehensive security audit
sudo pop security audit
```

## Updating Your Node

```bash
# Update to the latest version
sudo pop update
```

The update process:
1. Creates a backup automatically
2. Downloads the latest binary
3. Verifies installation
4. Restarts the service

## Cross-References

- For wallet setup instructions, see [Wallet Setup Guide](../guides/wallet-setup.md)
- For monitoring details, see [Earning with Pipe Network](../guides/earning.md)
- For installation, see [Installation Guide](../guides/installation.md)
- For troubleshooting, see [Troubleshooting Guide](troubleshooting.md)
- For configuration options, see [Configuration Reference](config.md) 