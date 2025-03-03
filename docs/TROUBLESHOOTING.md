# Pipe PoP Node Troubleshooting Guide

## Overview

This guide provides solutions to common issues you might encounter when setting up, running, or maintaining your Pipe PoP node. If you're experiencing problems, follow the relevant section below to diagnose and resolve the issue.

## Installation Issues

### Dependencies Installation Fails

**Symptoms:**
- Error messages during `apt-get install` commands
- Missing packages after installation attempt

**Solutions:**
1. Update your package lists:
   ```bash
   sudo apt-get update
   ```

2. Try installing dependencies individually:
   ```bash
   sudo apt-get install -y curl
   sudo apt-get install -y net-tools
   sudo apt-get install -y jq
   ```

3. Check for system-specific issues:
   ```bash
   sudo apt-get -f install
   ```

### Binary Download Fails

**Symptoms:**
- Error messages when downloading the Pipe PoP binary
- Incomplete or corrupted binary file

**Solutions:**
1. Check your internet connection:
   ```bash
   ping -c 4 google.com
   ```

2. Verify the download URL is correct:
   ```bash
   curl -I https://dl.pipecdn.app/v0.2.8/pop
   ```

3. Try downloading with a different method:
   ```bash
   wget -O bin/pipe-pop https://dl.pipecdn.app/v0.2.8/pop
   ```

4. If using a proxy, configure it properly:
   ```bash
   export http_proxy=http://your-proxy:port
   export https_proxy=http://your-proxy:port
   ```

## Startup Issues

### Service Won't Start

**Symptoms:**
- `systemctl status pipe-pop.service` shows "failed" or "inactive"
- Error messages in service logs

**Solutions:**
1. Check the service status for detailed error messages:
   ```bash
   systemctl status pipe-pop.service
   ```

2. View the service logs:
   ```bash
   journalctl -u pipe-pop.service -n 50
   ```

3. Verify the service file is correctly configured:
   ```bash
   cat /etc/systemd/system/pipe-pop.service
   ```

4. Ensure the binary path in the service file is correct:
   ```bash
   ls -la /path/to/bin/pipe-pop
   ```

5. Try starting the service manually:
   ```bash
   sudo systemctl start pipe-pop.service
   ```

### Permission Issues

**Symptoms:**
- "Permission denied" errors in logs
- Service fails to start with permission-related messages

**Solutions:**
1. Check file permissions:
   ```bash
   ls -la bin/pipe-pop
   ```

2. Set correct permissions:
   ```bash
   chmod +x bin/pipe-pop
   ```

3. Check directory permissions:
   ```bash
   ls -la cache/
   ls -la config/
   ```

4. Fix ownership if needed:
   ```bash
   sudo chown -R $(whoami):$(whoami) .
   ```

## Network Issues

### Port Conflicts

**Symptoms:**
- Node can't bind to required ports
- Error messages about ports already in use

**Solutions:**
1. Check which processes are using the required ports:
   ```bash
   sudo netstat -tulpn | grep -E '80|443|8003'
   ```

2. Identify conflicting services:
   ```bash
   sudo lsof -i :80
   sudo lsof -i :443
   sudo lsof -i :8003
   ```

3. Stop conflicting services:
   ```bash
   sudo systemctl stop apache2    # Example for Apache web server
   sudo systemctl stop nginx      # Example for Nginx web server
   ```

4. Disable conflicting services if not needed:
   ```bash
   sudo systemctl disable apache2
   ```

### Firewall Issues

**Symptoms:**
- Node appears to be running but isn't accessible
- Connection timeouts when trying to access the node

**Solutions:**
1. Check firewall status:
   ```bash
   sudo ufw status
   ```

2. Allow required ports:
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 8003/tcp
   ```

3. For iptables:
   ```bash
   sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
   sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
   sudo iptables -A INPUT -p tcp --dport 8003 -j ACCEPT
   ```

4. Check if your cloud provider or hosting service has additional firewall settings that need to be configured.

## Reputation Issues

### Low Reputation Score

**Symptoms:**
- Reputation score below 0.7 in status output
- Not receiving expected rewards

**Solutions:**
1. Check your node status:
   ```bash
   ./pop --status
   ```

2. Ensure your node has consistent uptime:
   - Minimize planned downtime
   - Schedule maintenance during off-peak hours
   - Use a reliable internet connection

3. Verify all required ports are open and accessible:
   ```bash
   sudo netstat -tulpn | grep -E '80|443|8003'
   ```

4. Monitor your node regularly:
   ```bash
   ./monitor.sh
   ```

5. Remember that reputation is calculated over a 7-day rolling window, so it may take time to improve.

### Uptime Score Issues

**Symptoms:**
- Low uptime score despite node appearing to be running
- Inconsistent reporting in status

**Solutions:**
1. Check system stability:
   ```bash
   uptime
   dmesg | tail
   ```

2. Monitor system resources:
   ```bash
   top
   free -m
   df -h
   ```

3. Ensure your internet connection is stable:
   ```bash
   ping -c 100 google.com
   ```

4. Consider using a UPS for power backup to prevent unexpected shutdowns.

## Update Issues

### Update Fails

**Symptoms:**
- Error messages during update process
- Binary not updating to the latest version

**Solutions:**
1. Check update logs:
   ```bash
   ./pop --check-update
   ```

2. Try manual update:
   ```bash
   ./update_binary.sh https://dl.pipecdn.app/latest/pop
   ```

3. If the update fails, restore from backup:
   ```bash
   cp backups/bin/pipe-pop_TIMESTAMP bin/pipe-pop
   chmod +x bin/pipe-pop
   sudo systemctl restart pipe-pop.service
   ```

## Configuration Issues

### Solana Wallet Issues

**Symptoms:**
- Errors related to Solana wallet in logs
- Not receiving rewards despite good reputation

**Solutions:**
1. Verify your wallet address in the configuration:
   ```bash
   cat config/config.json | grep solana_wallet
   ```

2. Ensure the Solana CLI is installed correctly:
   ```bash
   solana --version
   ```

3. Check your wallet balance:
   ```bash
   solana balance
   ```

4. Verify the wallet path if using a local wallet:
   ```bash
   ls -la ~/.config/solana/id.json
   ```

### Cache Directory Issues

**Symptoms:**
- Errors related to cache directory
- Node not storing or retrieving data correctly

**Solutions:**
1. Check if the cache directory exists:
   ```bash
   ls -la cache/
   ```

2. Verify permissions:
   ```bash
   ls -la cache/
   ```

3. Check disk space:
   ```bash
   df -h .
   ```

4. Create the directory if it doesn't exist:
   ```bash
   mkdir -p cache
   ```

## Backup and Recovery

### Backup Creation Fails

**Symptoms:**
- Backup script errors
- Missing backup files

**Solutions:**
1. Check if the backup directory exists:
   ```bash
   ls -la backups/
   ```

2. Create the directory if needed:
   ```bash
   mkdir -p backups
   ```

3. Verify permissions:
   ```bash
   ls -la backups/
   ```

4. Run the backup manually:
   ```bash
   ./backup.sh
   ```

### Node Info Recovery

**Symptoms:**
- Lost or corrupted node_info.json
- Node not starting after reinstallation

**Solutions:**
1. Check if you have a backup:
   ```bash
   ls -la backups/
   ```

2. Restore from the most recent backup:
   ```bash
   tar -xzf backups/backup_TIMESTAMP.tar.gz -C /tmp/
   cp /tmp/backup_TIMESTAMP/node_info.json cache/
   ```

3. If no backup is available, you may need to re-register your node:
   ```bash
   sudo ./bin/pipe-pop --signup-by-referral-route 3a069772281d9b1b
   ```

## Getting Additional Help

If you've tried the solutions above and are still experiencing issues:

1. Check the [Pipe Network Documentation](https://docs.pipe.network/devnet-2) for updated information.

2. Visit the [Pipe Network Dashboard](https://dashboard.pipenetwork.com) to check your node status from the network perspective.

3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com) for assistance.

4. Join the Pipe Network community channels for peer support.

## Common Error Messages and Solutions

| Error Message | Possible Cause | Solution |
|---------------|----------------|----------|
| "Failed to bind to address" | Port conflict | Check for other services using the required ports |
| "Permission denied" | Insufficient permissions | Check file and directory permissions |
| "Connection refused" | Firewall blocking | Check firewall settings and open required ports |
| "No space left on device" | Disk full | Free up disk space or expand storage |
| "Cannot open node_info.json" | Missing or corrupted file | Restore from backup or re-register node |
| "Invalid wallet address" | Misconfigured wallet | Check wallet address in config.json |

Remember that most issues can be resolved by checking logs, ensuring proper permissions, verifying network connectivity, and maintaining sufficient system resources. 