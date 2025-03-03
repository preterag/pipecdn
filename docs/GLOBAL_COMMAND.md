# 🌐 Global Command Documentation

This document provides information about the global `pop` command, which allows you to manage your Pipe PoP node from anywhere on your system.

## 🔧 Installation

The global `pop` command is installed using the `fixed_install_global_pop.sh` script. This script creates a global command that can be run from anywhere on your system.

To install the global command:

```bash
# Make the script executable
chmod +x fixed_install_global_pop.sh

# Run the script with sudo
sudo ./fixed_install_global_pop.sh
```

The script will:
1. Create the installation directory at `/opt/pipe-pop`
2. Copy the `pipe-pop` binary to the installation directory
3. Create the necessary scripts (monitor.sh, backup.sh)
4. Create the global `pop` command at `/usr/local/bin/pop`
5. Set the appropriate permissions

## 🚀 Usage

Once installed, you can use the `pop` command from anywhere on your system:

```bash
# Check node status
pop --status

# View available commands
pop --help
```

## 📋 Available Commands

The global `pop` command provides the following functionality:

### Status and Information

```bash
# Check node status and reputation
pop --status

# Show the version of the Pipe PoP binary
pop --version

# Fetch node's uptime stats
pop --stats

# Perform a quick egress test
pop --egress-test
```

### Updates and Maintenance

```bash
# Check for updates to the Pipe PoP binary
pop --check-update

# Update the Pipe PoP binary to the latest version (requires sudo)
sudo pop --update

# Update to a specific version with force option (requires sudo)
sudo pop --update vX.Y.Z --force

# Check for upgrades and refresh token (requires sudo)
sudo pop --refresh
```

### Monitoring and Logs

```bash
# Monitor node status
pop --monitor

# View service logs
pop --logs
```

### Service Management

```bash
# Restart the node service (requires sudo)
sudo pop --restart
```

### Backup and Recovery

```bash
# Create a backup
pop --backup
```

### Referrals and Rewards

```bash
# Generate a referral code
pop --gen-referral-route

# Check points and rewards
pop --points
```

### Help

```bash
# Show help message
pop --help
```

## 💡 Examples

Here are some common usage examples:

### Checking Node Status

To check the status of your node, including reputation score and other metrics:

```bash
pop --status
```

### Monitoring Node Performance

To monitor your node's performance, including resource usage and port configuration:

```bash
pop --monitor
```

### Updating Your Node

To check for updates:

```bash
pop --check-update
```

To update to the latest version:

```bash
sudo pop --update
```

### Creating a Backup

To create a backup of your node's important data:

```bash
pop --backup
```

### Viewing Logs

To view the service logs:

```bash
pop --logs
```

## ❓ Troubleshooting

If you encounter issues with the global `pop` command, try the following:

1. **Command not found**: Ensure the command was installed correctly:
   ```bash
   ls -la /usr/local/bin/pop
   ```

2. **Permission denied**: Make sure you're using `sudo` for commands that require it:
   ```bash
   sudo pop --update
   ```

3. **Binary not found**: Check if the binary exists in the installation directory:
   ```bash
   ls -la /opt/pipe-pop/bin/pipe-pop
   ```

4. **Reinstall the command**: If needed, reinstall the global command:
   ```bash
   sudo ./fixed_install_global_pop.sh
   ```

## 🗑️ Uninstallation

If you need to uninstall the global `pop` command:

```bash
sudo rm /usr/local/bin/pop
sudo rm -rf /opt/pipe-pop
```

Note that this will not uninstall the Pipe PoP node itself, only the global command. 