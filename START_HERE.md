![Pipe Network](docs/images/pipe-network-pop.jpeg)

# Pipe Network PoP Node Management Tools

> Welcome to the Pipe Network PoP Node Management Tools, a comprehensive toolkit for managing Pipe Network nodes efficiently.

## What is Pipe Network?

Pipe Network is a decentralized content delivery network (CDN) that leverages a distributed network of nodes to deliver web content. By running a Point of Presence (PoP) node, you contribute to the network and earn rewards.

For a comprehensive understanding, review the [official Pipe Network documentation](docs/official/PIPE_NETWORK_DOCUMENTATION.md).

## Quick Installation (2 minutes)

1. **Install the software:**
   ```bash
   sudo ./INSTALL
   ```

2. **Enter your Solana wallet address when prompted**
   (Need a wallet? Follow our [wallet setup guide](docs/guides/wallet-setup.md))

3. **Verify your node is running:**
   ```bash
   pop status
   ```

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