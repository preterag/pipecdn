# Pipe PoP Node Maintenance Guide

## Overview

This document provides comprehensive guidance on maintaining and operating your Pipe PoP node for optimal performance and reliability.

## Regular Maintenance Tasks

### 1. Checking Node Status

Regularly check the status of your node to ensure it's running properly and maintaining a good reputation score:

```bash
./pop --status
```

This command will display:
- Node ID and registration status
- Reputation metrics (uptime, egress, historical, and total scores)
- Current node status

### 2. Updating the Binary

#### Automatic Updates (Recommended)

The easiest way to check for and apply updates:

```bash
# Check if an update is available
./pop --check-update

# Update to the latest version
sudo ./pop --update
```

The update process will:
1. Check for available updates
2. Download the latest version
3. Install it automatically
4. Restart the service if it's running

#### Manual Updates

If you need to manually update the binary:

```bash
./update_binary.sh <BINARY_URL>
```

Replace `<BINARY_URL>` with the URL of the new binary. The script will:
1. Create a backup of the current binary
2. Download the new binary
3. Test the new binary
4. Replace the old binary with the new one
5. Restart the service if it's running

### 3. Backing Up Node Data

Regular backups are essential to protect your node data, especially the `node_info.json` file which is linked to your IP address and not recoverable if lost.

#### Manual Backup

To create a manual backup:

```bash
./backup.sh
```

This will create a timestamped backup in the `backups/` directory.

#### Automated Backup Schedule

Set up regular automated backups:

```bash
./setup_backup_schedule.sh [daily|weekly|monthly]
```

This creates a cron job to run the backup script at the specified interval:
- `daily`: Every day at 2:00 AM
- `weekly`: Every Sunday at 2:00 AM
- `monthly`: On the 1st of every month at 2:00 AM

### 4. Monitoring Node Performance

Use the monitoring script to check your node's performance:

```bash
./monitor.sh
```

This script provides information about:
- Node status
- System resources (CPU, memory, disk usage)
- Network connectivity
- Port availability
- Service status

## Managing the Systemd Service

### Checking Service Status

```bash
systemctl status pipe-pop.service
```

### Starting/Stopping the Service

```bash
# Start the service
sudo systemctl start pipe-pop.service

# Stop the service
sudo systemctl stop pipe-pop.service

# Restart the service
sudo systemctl restart pipe-pop.service
```

### Viewing Service Logs

```bash
# View the most recent logs
journalctl -u pipe-pop.service -n 50

# Follow logs in real-time
journalctl -u pipe-pop.service -f
```

## Maintaining a Good Reputation Score

Your node's reputation score is crucial for earning rewards and participating in the network. The score is calculated based on:

1. **Uptime Score (40%)**: How consistently your node is online
2. **Historical Score (30%)**: How many days out of the last 7 had good coverage
3. **Egress Score (30%)**: How much data your node has transferred

### Tips for a High Reputation Score

1. **Ensure Consistent Uptime**:
   - Use a reliable internet connection
   - Consider using a UPS for power backup
   - Run the node on a dedicated machine if possible

2. **Plan Maintenance Carefully**:
   - Schedule maintenance during low-traffic periods
   - Keep maintenance windows under 6 hours
   - Try to perform maintenance at the same time each day/week

3. **Monitor Your Node Regularly**:
   - Use the monitoring script to check system resources
   - Address any issues promptly

4. **Optimize Network Performance**:
   - Ensure ports 80, 443, and 8003 are open and properly forwarded
   - Use a wired connection rather than Wi-Fi if possible
   - Consider bandwidth allocation to prioritize the Pipe PoP node

## Troubleshooting Common Issues

### Node Won't Start

1. Check if the service is running:
   ```bash
   systemctl status pipe-pop.service
   ```

2. Check for errors in the logs:
   ```bash
   journalctl -u pipe-pop.service -n 100
   ```

3. Verify the binary is executable:
   ```bash
   ls -la bin/pipe-pop
   ```

### Low Reputation Score

1. Check your node's status:
   ```bash
   ./pop --status
   ```

2. Ensure your node has consistent uptime
3. Verify that ports 80, 443, and 8003 are open and accessible
4. Check your internet connection stability

### Port Conflicts

If another service is using the required ports:

1. Identify the conflicting service:
   ```bash
   sudo netstat -tulpn | grep -E '80|443|8003'
   ```

2. Either stop the conflicting service or reconfigure it to use different ports

## Important Notes

- Ports 80, 443, and 8003 must be open and accessible
- A Solana wallet is required to receive rewards
- Sufficient disk space is needed for cache data
- Regular backups of node_info.json are essential

## Additional Resources

- [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
- [Pipe Network Dashboard](https://dashboard.pipenetwork.com)
- [Reputation System Guide](./REPUTATION_SYSTEM.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md) 