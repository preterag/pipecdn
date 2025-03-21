![Pipe Network](../images/pipe-network-pop.jpeg)

# Installation Guide

## System Requirements

- Ubuntu 20.04+ or Debian 11+
- 2 CPU cores
- 4GB RAM
- 20GB disk space
- Open ports: 80, 443, 8003

## One-Command Installation (Recommended)

The fastest way to install:

```bash
sudo ./INSTALL
```

This will:
1. Install dependencies (curl, jq, ufw)
2. Configure firewall (open required ports)
3. Set up your wallet (you'll be prompted for your address)
4. Create the service
5. Start the node

## Post-Installation Verification

After installation, verify that everything is working:

```bash
# Check node status
pop status

# Verify service is running
systemctl status pipe-pop

# Check open ports
sudo ufw status
```

All three required ports (80, 443, 8003) should show as ALLOW.

## Installation Directory Structure

The node is installed in `/opt/pipe-pop` with the following structure:

- `/opt/pipe-pop/bin` - Binary files
- `/opt/pipe-pop/config` - Configuration files
- `/opt/pipe-pop/cache` - Cache data
- `/opt/pipe-pop/backups` - Backup files
- `/var/log/pipe-pop` - Log files

## Global Command Access

The installation adds the `pop` command to your path, so you can run it from any directory.

## Next Steps

After installation:

1. [Generate a referral code](../reference/cli.md#referrals)
2. [Set up monitoring](../guides/quick-start.md#3-real-time-monitoring)
3. [Review security settings](security.md)

## Uninstalling

To remove:

```bash
sudo systemctl stop pipe-pop
sudo systemctl disable pipe-pop
sudo rm -rf /opt/pipe-pop /etc/systemd/system/pipe-pop.service
sudo systemctl daemon-reload
``` 