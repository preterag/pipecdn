# Pipe Network PoP Node Management Tools - Command Reference

This document provides a complete reference for all available commands in the Pipe Network PoP Node Management Tools.

## Basic Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `pop help` | Display help information | `pop help [command]` |
| `pop version` | Display version information | `pop version` |
| `pop status` | Show node status and performance metrics | `pop status [--detailed]` |

## Installation and Updates

| Command | Description | Usage |
|---------|-------------|-------|
| `pop install` | Install the tool globally | `pop install [--dir=PATH] [--force]` |
| `pop uninstall` | Uninstall the tool | `pop uninstall [--keep-data]` |
| `pop update` | Update to the latest version | `pop update [--force]` |

## Service Management

| Command | Description | Usage |
|---------|-------------|-------|
| `pop start` | Start the node service | `pop start` |
| `pop stop` | Stop the node service | `pop stop` |
| `pop restart` | Restart the node service | `pop restart` |
| `pop enable` | Enable node service to start on boot | `pop enable` |
| `pop disable` | Disable node service autostart | `pop disable` |
| `pop logs` | Show node service logs | `pop logs [--lines=N] [--follow]` |

## Configuration

| Command | Description | Usage |
|---------|-------------|-------|
| `pop config list` | List all configuration settings | `pop config list [--all]` |
| `pop config get` | Get a specific configuration value | `pop config get KEY` |
| `pop config set` | Set a specific configuration value | `pop config set KEY VALUE` |
| `pop config import` | Import configuration from a file | `pop config import FILE` |
| `pop config export` | Export configuration to a file | `pop config export [FILE]` |

## Monitoring

| Command | Description | Usage |
|---------|-------------|-------|
| `pop status` | Show current node status | `pop status [--detailed]` |
| `pop pulse` | Collect and update metrics one time | `pop pulse` |
| `pop dashboard` | Interactive real-time dashboard | `pop dashboard [--compact] [--refresh=SECONDS]` |
| `pop history` | View historical performance data | `pop history [METRIC] [PERIOD]` |
| `pop history --detailed` | Detailed history for a metric | `pop history --detailed [METRIC] [PERIOD]` |
| `pop history --list` | List all historical data files | `pop history --list` |

## Alerts and Notifications

| Command | Description | Usage |
|---------|-------------|-------|
| `pop alerts status` | Show alert system status | `pop alerts status` |
| `pop alerts check` | Run a one-time check against thresholds | `pop alerts check` |
| `pop alerts daemon` | Run alert system in daemon mode | `pop alerts daemon` |
| `pop alerts log` | Show alert notification log | `pop alerts log [N]` |
| `pop alerts test` | Test alert notifications | `pop alerts test [LEVEL]` |
| `pop alerts reset` | Reset alert cooldown periods | `pop alerts reset` |
| `pop alerts config` | Configure alert settings | `pop alerts config SETTING [VALUE]` |

### Alert Configuration Options

| Setting | Description | Example |
|---------|-------------|---------|
| `enable/disable` | Enable or disable alerts | `pop alerts config enable` |
| `email.enable/email.disable` | Email notifications | `pop alerts config email.enable` |
| `email.server` | Set SMTP server | `pop alerts config email.server smtp.example.com` |
| `email.from` | Set sender address | `pop alerts config email.from mynode@gmail.com` |
| `email.to` | Set recipient address | `pop alerts config email.to admin@example.com` |
| `threshold.METRIC.TYPE` | Set alert threshold | `pop alerts config threshold.cpu_usage.max 90` |
| `interval` | Set check interval (minutes) | `pop alerts config interval 30` |
| `cooldown` | Set alert cooldown (hours) | `pop alerts config cooldown 6` |

## Examples

**Show node status:**
```
pop status
```

**View an interactive dashboard with 5-second refresh:**
```
pop dashboard --refresh=5
```

**Check historical uptime score for the last 30 days:**
```
pop history uptime_score 30d
```

**Enable email notifications:**
```
pop alerts config email.enable
pop alerts config email.server smtp.gmail.com
pop alerts config email.from mynode@gmail.com
pop alerts config email.to admin@example.com
```

**Run the alert daemon to continuously monitor your node:**
```
pop alerts daemon
```

## Additional Resources

- [Quick Start Guide](../guides/quick-start.md)
- [Troubleshooting](../guides/troubleshooting.md)
- [Port Forwarding Guide](../guides/port-forwarding.md)
- [Node Registration Guide](../guides/node-registration.md)
- [Fleet Management Guide](../guides/fleet-management.md)

For more detailed information on the Pipe Network, see the [official documentation](../official/PIPE_NETWORK_DOCUMENTATION.md).
