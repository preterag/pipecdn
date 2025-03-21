# Community Enhancement: Installation Guide

> **IMPORTANT**: This is a community-created enhancement for Pipe Network. 
> It is not part of the official Pipe Network project.
> For official documentation, please refer to [Official Pipe Network Documentation](../official/PIPE_NETWORK_DOCUMENTATION.md).

![Pipe Network](../images/pipe-network-pop.jpeg)

This guide walks you through installing the Pipe Network node with community enhancements.

## System Requirements

- Linux operating system (Ubuntu 20.04+ or Debian 11+ recommended)
- At least 2GB RAM
- At least 20GB free disk space
- Stable internet connection
- Open ports (80, 443, 8003)

## One-Command Installation

The easiest way to install is with our one-command installer:

```bash
sudo ./INSTALL
```

This will:
1. Install all required dependencies
2. Configure your firewall automatically
3. Set up the node as a system service
4. Install the global `pop` command
5. Create all necessary configuration files

## Post-Installation Setup

After installation, you need to configure your Solana wallet address:

```bash
sudo nano /opt/pipe-pop/config/config.json
```

Find the `wallet_address` field and replace `<YOUR_SOLANA_WALLET_ADDRESS>` with your actual Solana wallet address.

## Starting Your Node

Start your node with:

```bash
pop start
```

Check that it's running with:

```bash
pop status
```

## Verifying Installation

To verify everything is working correctly:

1. Check node status: `pop status`
2. Run real-time monitoring: `pop monitoring pulse`
3. Check security settings: `pop security check`

## Manual Installation (Advanced)

If you prefer to install manually:

1. Create the directory structure:
   ```bash
   sudo mkdir -p /opt/pipe-pop/{bin,config,src,tools,logs,metrics,backups}
   ```

2. Copy the configuration file:
   ```bash
   sudo cp src/config/config.template.json /opt/pipe-pop/config/config.json
   ```

3. Install scripts and utilities:
   ```bash
   sudo cp -r src/* /opt/pipe-pop/src/
   sudo cp tools/pop /opt/pipe-pop/tools/
   ```

4. Create system service:
   ```bash
   sudo cp examples/pipe-pop.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable pipe-pop.service
   ```

5. Create global command:
   ```bash
   sudo ln -sf /opt/pipe-pop/tools/pop /usr/local/bin/pop
   ```

## Troubleshooting

If you encounter issues:

- Check the logs: `pop monitoring logs`
- Verify configuration: `pop config show`
- See the [Troubleshooting Guide](../reference/troubleshooting.md)

## Next Steps

Now that your node is installed:

- [Configure your wallet](wallet-setup.md)
- [Learn about earning rewards](earning.md)
- [See the complete command reference](../reference/cli.md)

## Uninstalling

To remove:

```bash
sudo systemctl stop pipe-pop
sudo systemctl disable pipe-pop
sudo rm -rf /opt/pipe-pop /etc/systemd/system/pipe-pop.service
sudo systemctl daemon-reload
``` 