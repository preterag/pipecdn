# Pipe Network PoP Command Reference

This document provides a complete reference for all commands available in the Pipe Network PoP Node Management Tools.

## Command Syntax

```
pop [command] [options]
```

## Monitoring Commands

### `pop status`

Check the status of your node.

**Usage:**
```bash
pop status
```

**Options:**
- None

**Example:**
```bash
pop status
```

### `pop pulse`

View real-time metrics of your node.

**Usage:**
```bash
pop pulse [options]
```

**Options:**
- `--compact` - Display metrics in a compact format
- `--refresh=N` - Set refresh interval in seconds (default: 5)

**Example:**
```bash
pop pulse --refresh=3
```

### `pop dashboard`

Launch an interactive dashboard for monitoring your node.

**Usage:**
```bash
pop dashboard [options]
```

**Options:**
- `--web` - Open dashboard in web browser
- `--port=N` - Specify port for web dashboard (default: 3000)

**Example:**
```bash
pop dashboard --web
```

### `pop history`

Display historical performance data.

**Usage:**
```bash
pop history [options]
```

**Options:**
- `--days=N` - Show data for the last N days (default: 7)
- `--metric=TYPE` - Specify metric type (uptime, egress, earnings)

**Example:**
```bash
pop history --days=30 --metric=earnings
```

## Service Management Commands

### `pop start`

Start the node service.

**Usage:**
```bash
pop start
```

**Example:**
```bash
pop start
```

### `pop stop`

Stop the node service.

**Usage:**
```bash
pop stop
```

**Example:**
```bash
pop stop
```

### `pop restart`

Restart the node service.

**Usage:**
```bash
pop restart
```

**Example:**
```bash
pop restart
```

### `pop logs`

View service logs.

**Usage:**
```bash
pop logs [options]
```

**Options:**
- `--lines=N` - Show last N lines (default: 50)
- `--follow` - Follow log output in real-time

**Example:**
```bash
pop logs --follow
```

## Backup & Recovery Commands

### `pop backup`

Create a backup of your node configuration and data.

**Usage:**
```bash
pop backup [options]
```

**Options:**
- `--name=STRING` - Specify a name for the backup
- `--exclude=STRING` - Comma-separated list of data types to exclude

**Example:**
```bash
pop backup --name=pre-update-backup
```

### `pop restore`

Restore from a backup.

**Usage:**
```bash
pop restore [options]
```

**Options:**
- `--name=STRING` - Specify the backup name to restore
- `--list` - List available backups instead of restoring

**Example:**
```bash
pop restore --name=pre-update-backup
```

## Configuration Commands

### `pop configure`

Configure your node settings.

**Usage:**
```bash
pop configure [options]
```

**Options:**
- `--wizard` - Use interactive configuration wizard
- `--set KEY=VALUE` - Set a specific configuration value

**Example:**
```bash
pop configure --wizard
```

### `pop ports`

Configure and check port settings.

**Usage:**
```bash
pop ports [options]
```

**Options:**
- `--check` - Check port accessibility
- `--enable-80-443` - Enable privileged ports 80 and 443
- `--test` - Test connectivity from external network

**Example:**
```bash
pop ports --check
```

### `pop wallet`

Manage wallet settings.

**Usage:**
```bash
pop wallet [options]
```

**Options:**
- `--info` - Show current wallet information
- `--set=ADDRESS` - Set a new wallet address

**Example:**
```bash
pop wallet --info
```

## Update & Maintenance Commands

### `pop update`

Update the PoP Node Management Tools.

**Usage:**
```bash
pop update [options]
```

**Options:**
- `--check` - Check for updates without installing
- `--force` - Force update even if already on latest version

**Example:**
```bash
pop update --check
```

### `pop refresh`

Refresh node registration and tokens.

**Usage:**
```bash
pop refresh
```

**Example:**
```bash
pop refresh
```

## Fleet Management Commands

### `pop fleet-add`

Add a node to your fleet.

**Usage:**
```bash
pop fleet-add [options]
```

**Options:**
- `--name=STRING` - Assign a name to the node
- `--ip=ADDRESS` - Specify the node's IP address
- `--key=PATH` - Path to SSH key for authentication

**Example:**
```bash
pop fleet-add --name=node-east-1 --ip=192.168.1.10
```

### `pop fleet-list`

List all nodes in your fleet.

**Usage:**
```bash
pop fleet-list [options]
```

**Options:**
- `--status` - Include status information
- `--stats` - Include performance statistics

**Example:**
```bash
pop fleet-list --status
```

### `pop fleet-status`

Show aggregated status of all fleet nodes.

**Usage:**
```bash
pop fleet-status [options]
```

**Options:**
- `--compact` - Show compact view
- `--watch` - Watch mode with periodic updates

**Example:**
```bash
pop fleet-status --watch
```

### `pop fleet-deploy`

Deploy configuration or updates to all fleet nodes.

**Usage:**
```bash
pop fleet-deploy [options]
```

**Options:**
- `--config` - Deploy configuration files
- `--update` - Deploy software update
- `--target=STRING` - Comma-separated list of target nodes

**Example:**
```bash
pop fleet-deploy --update
```

## Help & Information Commands

### `pop help`

Show help information.

**Usage:**
```bash
pop help [command]
```

**Example:**
```bash
pop help status
```

### `pop version`

Show version information.

**Usage:**
```bash
pop version
```

**Example:**
```bash
pop version
```

---

## Additional Resources

- [Quick Start Guide](../guides/quick-start.md)
- [Troubleshooting](../guides/troubleshooting.md)
- [Port Forwarding Guide](../guides/port-forwarding.md)
- [Node Registration Guide](../guides/node-registration.md)
- [Fleet Management Guide](../guides/fleet-management.md)

For more detailed information on the Pipe Network, see the [official documentation](../official/PIPE_NETWORK_DOCUMENTATION.md).
