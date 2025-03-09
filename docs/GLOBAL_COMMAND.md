# 🌐 Global Command Documentation

This document provides information about the global `pop` command, which allows you to manage your Pipe Network PoP node from anywhere on your system.

## 🔧 Installation

The global `pop` command can be installed in two ways:

### Method 1: Using the Installation Script

```bash
# Make the script executable
chmod +x install_global_pop.sh

# Run the script with sudo
sudo ./install_global_pop.sh
```

The script will:
1. Create the installation directory at `/opt/pipe-pop`
2. Copy the `pipe-pop` binary to the installation directory
3. Create the necessary scripts (monitor.sh, backup.sh)
4. Create the global `pop` command at `/usr/local/bin/pop`
5. Set the appropriate permissions

### Method 2: Manual Symbolic Link

If you prefer a simpler approach that doesn't copy files to system directories:

```bash
# Create a symbolic link to the pop script in /usr/local/bin
sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
```

This creates a symbolic link that points to your current pop script, making it accessible globally while keeping all files in your project directory.

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

# Show the version of the pipe-pop binary
pop --version

# Fetch node's uptime stats
pop --stats

# Perform a quick egress test
pop --egress-test

# Display the current wallet address connected to the node
pop --wallet-info
```

### Monitoring and Visualization

```bash
# Monitor node status
pop --monitor

# Show pulse monitoring (node status)
pop --pulse                   # Standard mode (exit with 'q')
pop --pulse -i                # Interactive mode (exit with any key)
pop --pulse -c                # Continuous mode (exit with Ctrl+C)

# Show comprehensive dashboard
pop --dashboard               # Full dashboard with auto-refresh
pop --dashboard --refresh 10  # Refresh every 10 seconds
pop --dashboard --compact     # Compact view with less details
pop --dashboard --export HTML # Export dashboard to HTML file

# Show network leaderboard
pop --leaderboard             # Sort by reputation (default)
pop --leaderboard --points    # Sort by points
pop --leaderboard --egress    # Sort by egress data

# Run the history visualization tool
pop --history
pop --history --rank          # Show rank history
pop --history --reputation    # Show reputation history
pop --history --points        # Show points history
pop --history --egress        # Show egress history
```

### Updates and Maintenance

```bash
# Check for updates to the pipe-pop binary
pop --check-update

# Update the pipe-pop binary to the latest version (requires sudo)
sudo pop --update

# Update to a specific version with force option (requires sudo)
sudo pop --update vX.Y.Z --force

# Check for upgrades and refresh token (requires sudo)
sudo pop --refresh
```

### Configuration

```bash
# Enable ports 80 and 443 (requires sudo)
sudo pop --enable-80-443

# Set a new wallet address for the node (requires sudo)
sudo pop --set-wallet <address>
```

### Service Management

```bash
# Restart the node service (requires sudo)
sudo pop --restart

# View service logs
pop --logs
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

### Using the Dashboard

To view the comprehensive dashboard:

```bash
pop --dashboard
```

To export the dashboard to an HTML file for sharing:

```bash
pop --dashboard --export HTML
```

### Monitoring Node Performance

To monitor your node's performance with real-time updates:

```bash
pop --pulse
```

For continuous monitoring with detailed metrics:

```bash
pop --pulse -c
```

### Viewing Historical Data

To visualize your node's rank history:

```bash
pop --history --rank
```

To visualize your node's points history:

```bash
pop --history --points
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

### Managing Wallet Configuration

To check your current wallet address:

```bash
pop --wallet-info
```

To set a new wallet address:

```bash
sudo pop --set-wallet H6sA2GwmppUTWHW7NAhw66NBDi9Bh7LvmGTJ6CUQU5e8
```

## ❓ Troubleshooting

If you encounter issues with the global `pop` command, try the following:

1. **Command not found**: Ensure the command was installed correctly:
   ```bash
   which pop
   ```

2. **Permission denied**: Make sure you're using `sudo` for commands that require it:
   ```bash
   sudo pop --update
   ```

3. **Binary not found**: Check if the binary exists in the installation directory:
   ```bash
   ls -la /opt/pipe-pop/bin/pipe-pop
   ```
   
   Or if using the symbolic link method:
   ```bash
   ls -la $(which pop)
   ```

4. **Broken symbolic link**: If you used the symbolic link method and moved your project directory:
   ```bash
   # Update the symbolic link
   sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
   ```

5. **Dashboard or pulse monitoring not working**: Ensure you have the required dependencies:
   ```bash
   sudo apt-get install jq procps
   ```

## 🗑️ Uninstallation

If you need to uninstall the global `pop` command:

### For Method 1 (Installation Script):

```bash
sudo rm /usr/local/bin/pop
sudo rm -rf /opt/pipe-pop
```

### For Method 2 (Symbolic Link):

```bash
sudo rm /usr/local/bin/pop
```

Note that this will not uninstall the Pipe Network PoP node itself, only the global command. 