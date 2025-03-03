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

## Configuration

The Pipe PoP node configuration is stored in the `config` directory. The main configuration parameters include:

- **Solana Wallet Address**: Your public key for receiving rewards
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

### Manually

To run the node manually:

```bash
./run_node.sh
```

This will start the node in the foreground with logs displayed in the terminal.

## Monitoring

The `monitor.sh` script provides basic monitoring of the node:

```bash
./monitor.sh
```

This will display:
- Node running status
- System resource usage
- Cache directory size
- Node information status
- Port availability

## Backup

Regular backups are essential for node recovery. The `backup.sh` script creates backups of critical node data:

```bash
./backup.sh
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
   - Check logs for errors

2. **Connection issues**
   - Verify firewall settings
   - Check network connectivity
   - Ensure ports 80, 443, and 8003 are open

3. **Performance problems**
   - Monitor RAM and disk usage
   - Check for competing processes
   - Consider upgrading hardware if consistently at capacity

### Logs

Logs are stored in the `logs` directory. To view the latest logs:

```bash
tail -f logs/pipe-pop_*.log | grep ERROR
```

## Maintenance

### Regular Tasks

1. **Monitor node status**: Run `./monitor.sh` regularly
2. **Create backups**: Run `./backup.sh` weekly
3. **Check for updates**: Visit the official Pipe Network website
4. **Clean cache**: If cache size grows too large, consider cleaning older data

### Updating

When a new version is released:

1. Stop the node: `sudo systemctl stop pipe-pop.service`
2. Download the new binary
3. Replace the old binary in the `bin` directory
4. Start the node: `sudo systemctl start pipe-pop.service`

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

## License

The Pipe PoP node is licensed under [LICENSE INFORMATION]. 