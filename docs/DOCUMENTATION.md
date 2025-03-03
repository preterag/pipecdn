# Pipe PoP Node Documentation

## Overview

The Pipe PoP (Proof of Participation) node is a component of the Pipe Network ecosystem. This documentation provides detailed information about setting up, configuring, and maintaining a Pipe PoP node.

## System Requirements

- **RAM**: Minimum 4GB, recommended 8GB
- **Disk Space**: Minimum 50GB, recommended 100GB+
- **Operating System**: Linux (Ubuntu 20.04 or newer recommended)
- **Network**: Stable internet connection with open ports 80, 443, and 8003
- **Solana Wallet**: Required for node operation and rewards

## Installation

### Prerequisites

1. Ensure your system meets the minimum requirements
2. Open ports 80, 443, and 8003 in your firewall
3. Create a Solana wallet if you don't have one

### Setup Process

1. Clone this repository or download the setup files
2. Run the setup script: `./setup.sh`
3. Follow the prompts to complete the installation
4. Configure the node with your Solana wallet address
5. Install the global `pop` command: `sudo ./install_global_pop.sh`

### Quick Setup

For a faster setup, you can use the one-command setup script:

```bash
curl -L https://raw.githubusercontent.com/preterag/pipecdn/master/easy_setup.sh -o easy_setup.sh
chmod +x easy_setup.sh
sudo ./easy_setup.sh
```

This script will handle all the setup steps, including installing the global `pop` command, which allows you to manage your node from anywhere on your system.

## Configuration

The Pipe PoP node configuration is stored in the `config` directory. The main configuration parameters include:

- **Solana Wallet Address**: Your public key for receiving rewards. It's recommended to use your own wallet address to receive rewards directly.
- **Cache Directory**: Location for storing cache data
- **Log Level**: Verbosity of logging (info, debug, warn, error)
- **Network Settings**: Configuration for network connectivity

## Running the Node

### As a Systemd Service (Recommended)

The setup script creates a systemd service file that can be installed with:

```bash
sudo cp pipe-pop.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pipe-pop.service
sudo systemctl start pipe-pop.service
```

To check the status of the service:

```bash
sudo systemctl status pipe-pop.service
```

Or using the global `pop` command (available from anywhere on your system):

```bash
pop --status
```

### Manually

To run the node manually:

```bash
./run_node.sh
```

This will start the node in the foreground with logs displayed in the terminal.

## Global Pop Command

The global `pop` command is automatically installed during setup and allows you to manage your node from anywhere on your system without having to navigate to the installation directory.

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup
```

This command is available system-wide, so you can run it from any directory.

## Managing Your Node

After installation, you can manage your node using the global `pop` command from anywhere on your system:

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup

# Check for updates
pop --check-update

# Generate a referral code
pop --gen-referral-route

# Check points and rewards
pop --points-route

# View service logs
pop --logs
```

For commands that require root privileges:

```bash
# Update to the latest version
sudo pop --update

# Restart the service
sudo pop --restart
```

## Monitoring

You can monitor your node using the global `pop` command:

```bash
pop --monitor
```

This will display:
- Node running status
- System resource usage
- Cache directory size
- Node information status
- Port availability

## Backup

Regular backups are essential for node recovery. Create backups using the global `pop` command:

```bash
pop --backup
```

This will create a compressed archive in the `backups` directory containing:
- node_info.json
- Solana wallet backup
- Configuration files

## Troubleshooting

### Common Issues

1. **Node not starting**
   - Check system resources
   - Verify port availability
   - Check logs with `pop --logs`

2. **Connection issues**
   - Verify firewall settings
   - Check network connectivity
   - Ensure ports 80, 443, and 8003 are open

3. **Performance problems**
   - Monitor RAM and disk usage with `pop --monitor`
   - Check for competing processes
   - Consider upgrading hardware if consistently at capacity

4. **Global command not working**
   - Ensure the installation script completed successfully
   - Check if `/usr/local/bin/` is in your PATH
   - Try reinstalling the global command: `sudo ./install_global_pop.sh`

### Logs

View logs using the global `pop` command:

```bash
pop --logs
```

Or filter logs for errors:

```bash
pop --logs | grep ERROR
```

## Maintenance

### Regular Tasks

1. **Monitor node status**: Run `pop --status` regularly
2. **Create backups**: Run `pop --backup` weekly
3. **Check for updates**: Run `pop --check-update`
4. **Clean cache**: If cache size grows too large, consider cleaning older data

### Updating

When a new version is released:

```bash
# Check for updates
pop --check-update

# Update to the latest version
sudo pop --update

# Restart the service if needed
sudo pop --restart
```

## Security Considerations

1. **Wallet Security**: Keep your Solana wallet secure
2. **Server Hardening**: Follow standard server security practices
3. **Regular Updates**: Keep your system and the Pipe PoP node updated
4. **Firewall Rules**: Only open the necessary ports

## Support

For support, visit the official Pipe Network community channels:

- Website: [https://pipe.network](https://pipe.network)
- Discord: [Pipe Network Discord](https://discord.gg/pipe-network)
- Twitter: [@PipeNetwork](https://twitter.com/PipeNetwork)

For Surrealine-specific support:
- Email: support@surrealine.com
- Website: [https://surrealine.com](https://surrealine.com)
- Twitter: [@Surrealine](https://twitter.com/Surrealine) 