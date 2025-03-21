# Pipe Network Fleet Management Guide

This guide explains how to set up and use the Pipe Network Fleet Management system to manage multiple PoP nodes from a central location.

## Overview

The Fleet Management system allows you to:

- Register and manage multiple Pipe Network nodes
- Group nodes for easier management
- Collect metrics from all nodes in a single view
- Execute commands across multiple nodes
- Deploy files to multiple nodes simultaneously
- Monitor node health and status across your fleet

## Prerequisites

- Pipe Network PoP Management Tools (v0.0.1 or later)
- SSH access to each node you want to manage
- Each node should have the Pipe Network tools installed

## Setup

### Initialize Fleet Management

Before registering any nodes, initialize the fleet management system:

```bash
pop --fleet init
```

This command will:
1. Create the necessary configuration directories
2. Generate SSH keys for secure node communication
3. Initialize the node registration database
4. Initialize the node grouping system

After initialization, you should see an SSH public key displayed. You will need to add this key to the `~/.ssh/authorized_keys` file on each node you want to manage.

### Registering Nodes

To register a node with the fleet management system:

```bash
pop --fleet register <node_name> <ip_address> <username> [port]
```

Example:
```bash
pop --fleet register node1 192.168.1.100 ubuntu 22
```

This will register a node named "node1" with the specified connection details.

### Testing Node Connections

After registering a node, test the connection:

```bash
pop --fleet test <node_name>
```

If successful, this confirms that the SSH key is properly set up and the node is accessible.

## Managing Nodes

### Listing Registered Nodes

To see all registered nodes:

```bash
pop --fleet list
```

This displays a table of all nodes with their connection status and basic information.

### Unregistering a Node

To remove a node from management:

```bash
pop --fleet unregister <node_name>
```

## Node Grouping

The fleet management system allows you to organize nodes into logical groups for easier management.

### Creating Groups

To create a new group:

```bash
pop --fleet group create <group_name> [description]
```

Example:
```bash
pop --fleet group create production "Production environment nodes"
```

### Adding Nodes to Groups

Add an existing node to a group:

```bash
pop --fleet group add-node <node_name> <group_name>
```

Example:
```bash
pop --fleet group add-node node1 production
```

### Listing Groups

To see all defined groups:

```bash
pop --fleet group list
```

### Viewing Group Details

To see details about a specific group, including its members:

```bash
pop --fleet group show <group_name>
```

### Removing Nodes from Groups

To remove a node from a group:

```bash
pop --fleet group remove-node <node_name> <group_name>
```

### Deleting Groups

To delete a group (this doesn't affect the nodes):

```bash
pop --fleet group delete <group_name>
```

## Fleet Operations

### Executing Commands

Execute a command on a specific node:

```bash
pop --fleet exec <node_name> <command>
```

Execute a command on all nodes in a group:

```bash
pop --fleet group exec <group_name> <command>
```

Execute a command on all registered nodes:

```bash
pop --fleet exec-all <command>
```

### Deploying Files

Deploy files to one or more nodes:

```bash
pop --fleet deploy <source_file> <destination_path> [node1 node2...]
```

If no nodes are specified, the file will be deployed to all registered nodes.

## Metrics Collection

### Manual Collection

Collect metrics from all nodes:

```bash
pop --fleet collect
```

Collect metrics from a specific node:

```bash
pop --fleet collect <node_name>
```

### Automated Collection

Start an automated metrics collector that runs at regular intervals:

```bash
pop --fleet collector start [interval_minutes]
```

The default interval is 15 minutes if not specified.

Check the status of the collector:

```bash
pop --fleet collector status
```

Stop the automated collector:

```bash
pop --fleet collector stop
```

### Viewing Metrics Dashboard

View a dashboard of all collected metrics:

```bash
pop --fleet dashboard
```

## Fleet Status

Get a summary of your fleet status:

```bash
pop --fleet status
```

This shows total nodes, online/offline counts, and any issues detected.

## Best Practices

1. **Use meaningful node names** that help identify the purpose or location of each node
2. **Create logical groups** based on environment, purpose, or geographic location
3. **Regularly collect metrics** to monitor the health of your fleet
4. **Secure your SSH keys** - the fleet management key has access to all your nodes
5. **Add descriptive information** when registering nodes to make management easier

## Troubleshooting

### Connection Issues

If you can't connect to a node:
1. Verify the node is online and reachable via SSH manually
2. Check that the SSH key has been properly added to the node's authorized_keys file
3. Ensure the node's SSH service is running and properly configured
4. Test the connection with verbose logging: `ssh -v -i ~/.local/share/pipe-pop/fleet/ssh/fleet_rsa user@node_ip`

### Command Execution Problems

If commands fail to execute:
1. Ensure the node has the Pipe Network tools installed and properly configured
2. Check that the user you're connecting as has the necessary permissions
3. Try executing a simple command like `echo "test"` to verify basic connectivity

## Advanced Configuration

For advanced configuration options, refer to the fleet configuration files in:
- `~/.local/share/pipe-pop/config/fleet/` (user installation)
- `/opt/pipe-pop/config/fleet/` (system-wide installation)

## Next Steps

After setting up your fleet management system, consider:

1. Creating a regular backup of your fleet configuration
2. Setting up alerting based on collected metrics
3. Creating automation scripts that leverage the fleet management commands
4. Contributing to the Pipe Network community by sharing your experiences and enhancements 