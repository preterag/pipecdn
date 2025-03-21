# Pipe Network Fleet Management System

> **IMPORTANT**: This is a community-created enhancement for Pipe Network.
> It is not part of the official Pipe Network project.

## Overview

The Fleet Management System enables centralized management and monitoring of multiple Pipe Network nodes from a single interface. It uses SSH-based polling to securely collect metrics and execute commands across your node infrastructure.

## Features

- **Centralized Management**: Control multiple nodes from a single dashboard
- **Secure SSH Communication**: Restricted SSH keys with command limitations
- **Metrics Collection**: Automated collection of performance metrics
- **Command Execution**: Run commands across your entire fleet
- **Node Registration**: Simple node inventory management
- **Dashboard Visualization**: See fleet-wide metrics in one place

## System Components

```
src/fleet/
  ├── core/
  │   ├── ssh.sh            # SSH key and connection management
  │   └── registration.sh   # Node registration and inventory
  ├── monitoring/
  │   ├── collector.sh      # Metrics collection
  │   └── dashboard.sh      # Fleet visualization dashboard
  ├── operations/
  │   ├── commands.sh       # Command execution framework
  │   └── batch.sh          # Batch operations across nodes
  ├── admin/
  │   ├── config.sh         # Configuration management
  │   └── updates.sh        # Update deployment
  └── db/
      ├── metrics.sh        # Metrics storage
      └── nodes.sh          # Node database management
```

## Quick Start

### 1. Initialize the Fleet System

```bash
pop --fleet init
```

This will:
- Create necessary directories
- Set up the SSH key for node connections
- Initialize the node database

### 2. Register a Node

```bash
pop --fleet register <name> <ip> <username> [port]
```

Example:
```bash
pop --fleet register node-1 192.168.1.100 ubuntu 22
```

### 3. Add SSH Key to Nodes

On each node, add the restricted SSH key displayed during initialization to the `~/.ssh/authorized_keys` file:

```
command="./tools/pop --status; ./tools/pop --pulse --export json",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3N...
```

### 4. Test Connection

```bash
pop --fleet test <name>
```

### 5. Collect Metrics

```bash
pop --fleet collect
```

### 6. View Fleet Dashboard

```bash
pop --fleet dashboard
```

## Advanced Usage

### Scheduled Metrics Collection

Start automated metrics collection:

```bash
pop --fleet collector start 15  # Collect every 15 minutes
```

Check status:

```bash
pop --fleet collector status
```

Stop collection:

```bash
pop --fleet collector stop
```

### Execute Commands on Nodes

Run a command on a specific node:

```bash
pop --fleet exec <node> <command>
```

Run a command on all nodes:

```bash
pop --fleet exec-all <command>
```

### Node Management

List all nodes:

```bash
pop --fleet list
```

View node details:

```bash
pop --fleet details <name>
```

Update node information:

```bash
pop --fleet update <name> <field> <value>
```

Remove a node:

```bash
pop --fleet unregister <name>
```

## Requirements

- `jq` for JSON processing
- `ssh` and `sshpass` for secure connections
- `bc` for calculations

## Security Notes

- Always use restricted SSH keys with command limitations
- Store keys in a secure location with proper permissions (700 for directories, 600 for key files)
- Regularly rotate SSH keys for enhanced security

## Troubleshooting

If you encounter connection issues:

1. Verify the SSH key has been properly added to the target node
2. Ensure the command restriction is correctly formatted
3. Check that the required tools (pop, jq) are installed on the target node
4. Verify network connectivity and firewall rules

## Further Reading

For more details, see:
- [Development Roadmap](../../docs/development/roadmap.md)
- [Fleet Architecture Guide](../../docs/development/fleet-architecture.md)
- [Command Reference](../../docs/guides/fleet-commands.md) 