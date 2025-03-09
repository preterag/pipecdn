# Pipe Network PoP Node Management Tools

A comprehensive set of tools for managing and monitoring Pipe Network PoP (Point of Presence) nodes.

## Overview

This repository contains scripts and tools to help you manage your Pipe Network PoP node, including:

- Node status monitoring with detailed metrics
- Comprehensive dashboard for unified monitoring
- Network leaderboard visualization
- Historical data tracking and visualization
- Automated data collection
- Backup and recovery tools

## Quick Start

### Global Command Setup

Make the `pop` command available from anywhere in your system:

```bash
# Create a symbolic link to the pop script in /usr/local/bin
sudo ln -sf "$(pwd)/pop" /usr/local/bin/pop
```

### Monitoring Your Node

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

### Historical Data Visualization

Track your node's performance over time:

```bash
# Set up automated hourly data collection
./setup_cron.sh --hourly

# View your rank history
pop --history --rank

# View your points history
pop --history --points
```

### Backup and Recovery

Create a backup of your node data:

```bash
pop --backup
```

## Features

- **Easy Setup**: Simple installation and configuration process
- **Global Command**: Manage your node from anywhere in your system
- **Monitoring Tools**: Real-time monitoring of node status and performance
- **Comprehensive Dashboard**: Unified interface for monitoring all aspects of your node
- **Historical Data Visualization**: Track your node's performance over time
- **Automated Data Collection**: Schedule regular data collection for historical analysis
- **Detailed Uptime Tracking**: Monitor exact node uptime and start time

### Comprehensive Dashboard

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
- Node status and detailed uptime information
- System resource usage (CPU, RAM, disk)
- Performance metrics (rank, reputation, points, egress)
- Historical trends with change indicators
- Quick access to common management tasks

### Pulse Monitoring

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
- Current status with PID and uptime
- Exact uptime with days, hours, minutes, seconds
- Precise node start time
- CPU and memory usage
- Detailed reputation breakdown
- Port status (80, 443, 8003)

### Historical Data Visualization

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

### Automated Data Collection

Set up automated data collection to build a comprehensive history:

```bash
# Hourly collection (recommended)
./setup_cron.sh --hourly

# Daily collection
./setup_cron.sh --daily

# Custom schedule
./setup_cron.sh --custom "0 */2 * * *"  # Every 2 hours
```

## Documentation

Detailed documentation is available in the `docs` directory:

- [Global Command Guide](docs/GLOBAL_COMMAND.md)
- [Pulse Monitoring Guide](docs/PULSE_MONITORING.md)
- [Referral System Guide](docs/REFERRAL_GUIDE.md)
- [Authentication Guide](docs/AUTHENTICATION.md)

## Requirements

- Linux operating system
- Bash shell
- `jq` for JSON processing
- `curl` for API requests
- `gnuplot` (optional) for enhanced visualization

## Installation

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Pipe Network team for creating the pipe-pop node software
- Contributors to the project
- The community for feedback and support
