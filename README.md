# 🌐 Pipe Network PoP Node Management Tools

A comprehensive set of tools for managing and monitoring Pipe Network PoP (Point of Presence) nodes.

## 📋 Overview

This repository contains scripts and tools to help you manage your Pipe Network PoP node, including:

- 📊 Node status monitoring with detailed metrics
- 🖥️ Comprehensive dashboard for unified monitoring
- 🏆 Network leaderboard visualization
- 📈 Historical data tracking and visualization
- ⏱️ Automated data collection
- 💾 Backup and recovery tools
- 🔄 Service management and configuration
- 🔐 Authentication and security features
- 🚀 Release management and versioning

## 🚀 Quick Start

### 🔗 Global Command Setup

Make the `pop` command available from anywhere in your system:

```bash
# Create a symbolic link to the pop script in /usr/local/bin
sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
```

### 📊 Monitoring Your Node

Check your node's status with detailed metrics:

```bash
pop --pulse
```

View the comprehensive dashboard:

```bash
pop --dashboard
```

View the network leaderboard:

```bash
pop --leaderboard
```

### 📈 Historical Data Visualization

Track your node's performance over time:

```bash
# Set up automated hourly data collection
./setup_cron.sh --hourly

# View your rank history
pop --history --rank

# View your points history
pop --history --points
```

### 💾 Backup and Recovery

Create a backup of your node data:

```bash
pop --backup
```

## ✨ Features

- 🔧 **Easy Setup**: Simple installation and configuration process
- 🌐 **Global Command**: Manage your node from anywhere in your system
- 📊 **Monitoring Tools**: Real-time monitoring of node status and performance
- 🖥️ **Comprehensive Dashboard**: Unified interface for monitoring all aspects of your node
- 📈 **Historical Data Visualization**: Track your node's performance over time
- ⏱️ **Automated Data Collection**: Schedule regular data collection for historical analysis
- ⏰ **Detailed Uptime Tracking**: Monitor exact node uptime and start time
- 🔄 **Service Management**: Start, stop, and restart your node as a system service
- 💾 **Backup System**: Create and restore backups of essential node data
- 🔐 **Security Features**: Secure authentication and token management
- 🚀 **Release Management**: Tools for creating and publishing releases

### 🖥️ Comprehensive Dashboard

The dashboard provides a unified interface for monitoring all aspects of your node:

```bash
# View the dashboard with auto-refresh
pop --dashboard

# Customize the refresh interval
pop --dashboard --refresh 10

# Export the dashboard to HTML for sharing
pop --dashboard --export HTML
```

The dashboard includes:
- 🔄 Node status and detailed uptime information
- 💻 System resource usage (CPU, RAM, disk)
- 📊 Performance metrics (rank, reputation, points, egress)
- 📈 Historical trends with change indicators
- 🔗 Quick access to common management tasks

### 📊 Pulse Monitoring

The pulse monitoring feature provides real-time information about your node's status:

```bash
# Standard mode (exit with 'q')
pop --pulse

# Interactive mode (exit with any key)
pop --pulse -i

# Continuous mode (exit with Ctrl+C)
pop --pulse -c
```

Features include:
- 🔄 Current status with PID and uptime
- ⏰ Exact uptime with days, hours, minutes, seconds
- 📅 Precise node start time
- 💻 CPU and memory usage
- 📊 Detailed reputation breakdown
- 🔌 Port status (80, 443, 8003)

### 📈 Historical Data Visualization

Track your node's performance over time with historical data visualization:

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

### ⏱️ Automated Data Collection

Set up automated data collection to build a comprehensive history:

```bash
# Hourly collection (recommended)
./setup_cron.sh --hourly

# Daily collection
./setup_cron.sh --daily

# Custom schedule
./setup_cron.sh --custom "0 */2 * * *"  # Every 2 hours
```

### 🔄 Service Management

Manage your node as a system service:

```bash
# Start your node
pop --start

# Stop your node
pop --stop

# Restart your node
pop --restart

# Check service status
pop --status

# View service logs
pop --logs
```

### 💾 Backup and Recovery

Create and restore backups of essential node data:

```bash
# Create a backup
pop --backup

# List available backups
pop --list-backups

# Restore from a backup
pop --restore <backup_file>
```

### 🔌 Port Management

Configure and verify required ports:

```bash
# Enable ports 80 and 443
pop --enable-80-443

# Check port status
pop --pulse  # Port status is shown in the pulse output
```

### 🔗 Referral System

Manage referrals to earn additional rewards:

```bash
# Generate a referral code
pop --gen-referral-route

# Check referral points
pop --points
```

## 📚 Documentation

Detailed documentation is available in the `docs` directory:

- [🌐 Global Command Guide](docs/GLOBAL_COMMAND.md)
- [📊 Pulse Monitoring Guide](docs/PULSE_MONITORING.md)
- [🖥️ Dashboard Guide](docs/DASHBOARD.md)
- [🔄 Referral System Guide](docs/REFERRAL_GUIDE.md)
- [🔐 Authentication Guide](docs/AUTHENTICATION.md)
- [📊 Reputation System Guide](docs/REPUTATION_SYSTEM.md)
- [🔄 Versioning Strategy](docs/VERSION.md)

## 🔧 Requirements

- 🐧 Linux operating system
- 🐚 Bash shell
- 🔍 `jq` for JSON processing
- 🌐 `curl` for API requests
- 📊 `gnuplot` (optional) for enhanced visualization
- 🔌 Open ports: 80, 443, 8003
- 💾 100GB+ recommended disk space for cache directory

## 📥 Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/preterag/pipe-pop.git
   cd pipe-pop
   ```

2. Make scripts executable:
   ```bash
   chmod +x pop backup.sh setup_cron.sh history_view.sh dashboard.sh
   ```

3. Set up the global command:
   ```bash
   sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
   ```

4. Install required dependencies:
   ```bash
   sudo apt-get install jq curl
   ```

5. Optional: Install gnuplot for enhanced visualization:
   ```bash
   sudo apt-get install gnuplot
   ```

6. Configure your node:
   ```bash
   # Edit the configuration file
   nano config/config.json
   
   # Set your Solana wallet address
   pop --set-wallet <your_wallet_address>
   ```

## 🔄 Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **Major version (X.0.0)**: Incompatible API changes
- **Minor version (0.X.0)**: New functionality in a backward compatible manner
- **Patch version (0.0.X)**: Backward compatible bug fixes

Current version: **v1.0.0**

### 🌿 Branch Strategy

- 🚀 **master**: Production-ready code, stable releases only
- 🔧 **development**: Active development branch, features and fixes
- 🧩 **feature/xxx**: Feature-specific branches that merge into development
- 🐛 **bugfix/xxx**: Bug fix branches that merge into development

## 📋 Available Commands

| Category | Command | Description |
|----------|---------|-------------|
| **Monitoring** | `pop --status` | Check if your node is running |
| | `pop --pulse` | View detailed metrics about your node |
| | `pop --dashboard` | View the comprehensive dashboard |
| | `pop --leaderboard` | View the network leaderboard |
| | `pop --history` | View historical data |
| **Service** | `pop --start` | Start your node |
| | `pop --stop` | Stop your node |
| | `pop --restart` | Restart your node |
| | `pop --logs` | View service logs |
| **Backup** | `pop --backup` | Create a backup of your node data |
| | `pop --restore` | Restore a backup |
| | `pop --list-backups` | List available backups |
| **Configuration** | `pop --configure` | Configure your node |
| | `pop --set-wallet` | Set a new wallet address |
| | `pop --enable-80-443` | Enable ports 80 and 443 |
| **Referrals** | `pop --gen-referral-route` | Generate a referral code |
| | `pop --points` | Check points and rewards |
| **Information** | `pop --help` | Show help message |
| | `pop --version` | Show version information |

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Pipe Network team for creating the pipe-pop node software
- Contributors to the project
- The community for feedback and support
