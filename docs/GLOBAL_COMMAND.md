# 🌐 Global Command

## 📋 Overview

The Global Command feature allows you to manage your Pipe PoP node from anywhere in your system using the `pop` command. This document explains how to set up and use the global command.

## 🚀 Quick Setup

To make the `pop` command available globally, run:

```bash
# Create a symbolic link to the pop script in /usr/local/bin
sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
```

This creates a symbolic link to the `pop` script in `/usr/local/bin`, which is typically in your system's PATH.

## ✨ Features

- 🔧 **Simplified Management**: Manage your node from any directory
- 🔄 **Automatic Updates**: The symbolic link always points to the latest version of the script
- 🛠️ **Full Functionality**: Access all features of the Pipe PoP node management tools
- 📊 **Monitoring Tools**: Quick access to monitoring features
- 🔌 **Service Management**: Start, stop, and restart your node
- 💾 **Backup and Recovery**: Create and restore backups
- 📈 **Historical Data**: Track your node's performance over time

## 🔧 Usage

Once set up, you can use the `pop` command from any directory:

```bash
# Check your node's status
pop --status

# View detailed metrics
pop --pulse

# View the dashboard
pop --dashboard

# View the network leaderboard
pop --leaderboard

# Start your node
pop --start

# Stop your node
pop --stop

# Restart your node
pop --restart

# Create a backup
pop --backup

# View historical data
pop --history --rank
```

## 📚 Available Commands

### 📊 Monitoring Commands

- 🔍 **--status**: Check if your node is running
- 📊 **--pulse**: View detailed metrics about your node
- 🖥️ **--dashboard**: View the comprehensive dashboard
- 🏆 **--leaderboard**: View the network leaderboard
- 📈 **--history**: View historical data

### 🔌 Service Management Commands

- ▶️ **--start**: Start your node
- ⏹️ **--stop**: Stop your node
- 🔄 **--restart**: Restart your node
- 🔍 **--check**: Check if your node is properly configured

### 💾 Backup and Recovery Commands

- 💾 **--backup**: Create a backup of your node data
- 🔄 **--restore**: Restore a backup
- 📋 **--list-backups**: List available backups

### 🔧 Configuration Commands

- ⚙️ **--configure**: Configure your node
- 🔑 **--auth**: Manage authentication
- 🔌 **--ports**: Configure port settings

### 📚 Help and Information Commands

- ❓ **--help**: Show help message
- ℹ️ **--version**: Show version information
- 📋 **--list-commands**: List all available commands

## 🔧 Advanced Usage

### 📊 Pulse Monitoring Options

```bash
# Standard mode (exit with 'q')
pop --pulse

# Interactive mode (exit with any key)
pop --pulse -i

# Continuous mode (exit with Ctrl+C)
pop --pulse -c
```

### 🖥️ Dashboard Options

```bash
# Set refresh interval
pop --dashboard --refresh 10

# Show compact view
pop --dashboard --compact

# Don't show historical data
pop --dashboard --no-history

# Export dashboard to HTML
pop --dashboard --export HTML
```

### 🏆 Leaderboard Options

```bash
# Sort by reputation (default)
pop --leaderboard --reputation

# Sort by points
pop --leaderboard --points

# Sort by egress
pop --leaderboard --egress
```

### 📈 Historical Data Options

```bash
# View rank history
pop --history --rank

# View reputation history
pop --history --reputation

# View points history
pop --history --points

# View egress history
pop --history --egress
```

## 🔧 Troubleshooting

### 🔴 Command Not Found

If you get a "command not found" error:

1. 🔍 Check if the symbolic link was created correctly:
   ```bash
   ls -la /usr/local/bin/pop
   ```

2. 🔍 Check if `/usr/local/bin` is in your PATH:
   ```bash
   echo $PATH | grep "/usr/local/bin"
   ```

3. 🔄 If needed, recreate the symbolic link:
   ```bash
   sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
   ```

### 🔴 Permission Denied

If you get a "permission denied" error:

1. 🔍 Check if the script is executable:
   ```bash
   ls -la pop
   ```

2. 🔧 Make the script executable:
   ```bash
   chmod +x pop
   ```

3. 🔄 Recreate the symbolic link:
   ```bash
   sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
   ```

## 📚 Additional Resources

- [📊 Pulse Monitoring Guide](PULSE_MONITORING.md)
- [🖥️ Dashboard Guide](DASHBOARD.md)
- [🔄 Referral System Guide](REFERRAL_GUIDE.md)
- [🔐 Authentication Guide](AUTHENTICATION.md) 