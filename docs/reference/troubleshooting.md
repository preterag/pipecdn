# Troubleshooting

## Common Issues

### 1. Service Won't Start

```bash
# Check the logs
pop monitoring logs

# Restart the service
sudo systemctl restart pipe-pop
```

### 2. Port Conflicts

```bash
# Check if ports are in use
sudo netstat -tulpn | grep -E '80|443|8003'

# Stop conflicting services (example: Apache)
sudo systemctl stop apache2
```

### 3. Wallet Issues

```bash
# Verify wallet configuration
pop wallet info

# Update wallet if needed
sudo pop wallet set YOUR_WALLET_ADDRESS
```

### 4. Low Reputation Score

```bash
# Check node uptime
pop status

# Ensure ports are open
pop security check
```

### 5. Update Failed

```bash
# Force manual update
sudo pop update --force
```

### 6. Missing Command

```bash
# Reinstall the command
sudo ln -sf /opt/pipe-pop/tools/pop /usr/local/bin/pop
```

## System Checks

Run a full diagnostic:

```bash
pop security audit
```

## Getting Help

If your issue persists:
- Check the logs: `pop monitoring logs`
- File an issue on GitHub with your logs
- Try a clean reinstall: `sudo ./INSTALL` 