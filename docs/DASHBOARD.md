# 📊 Pipe Network PoP Node Dashboard

The Pipe Network PoP Node Dashboard provides a comprehensive, unified interface for monitoring all aspects of your node. This document explains how to use the dashboard and its features.

## Overview

The dashboard combines real-time status information, performance metrics, and historical trends in a single view, making it easy to monitor your node's health and performance at a glance.

Key features include:
- Real-time node status with detailed uptime information
- System resource usage monitoring (CPU, RAM, disk)
- Port status checking
- Performance metrics display
- Historical trend visualization
- HTML export for sharing

## Usage

The dashboard can be accessed using the global `pop` command:

```bash
pop --dashboard
```

### Available Options

The dashboard offers several options to customize the display:

```bash
# Set refresh interval in seconds (default: 5)
pop --dashboard --refresh 10

# Show compact view with less details
pop --dashboard --compact

# Show full view with all details (default)
pop --dashboard --full

# Don't show historical data
pop --dashboard --no-history

# Export dashboard to HTML file
pop --dashboard --export HTML
```

## Dashboard Sections

### 1. Status Information

This section provides real-time information about your node's status:

- **Node Running Status**: Whether the node is running or not
- **Process ID (PID)**: The process ID of the running node
- **Uptime**: Detailed uptime information in days, hours, minutes, and seconds
- **Start Time**: The exact date and time when the node was started
- **System Resources**: CPU, RAM, and disk usage
- **Port Status**: Status of required ports (80, 443, 8003)

### 2. Performance Metrics

This section displays key performance metrics for your node:

- **Network Rank**: Your node's current rank in the network
- **Reputation Score**: Your node's reputation score (0-1)
- **Points**: Total points earned by your node
- **Egress**: Total data transferred by your node

### 3. Historical Trends

This section shows how your node's metrics have changed over time:

- **Reputation Trend**: Whether your reputation is increasing, decreasing, or unchanged
- **Points Trend**: Changes in points with exact values
- **Egress Trend**: Changes in data transfer with exact values
- **Rank Trend**: Changes in network rank with exact values

### 4. Quick Actions

This section provides quick access to common management tasks:

- View detailed metrics
- View network leaderboard
- View historical data
- Restart node

## HTML Export

The dashboard can be exported to an HTML file for sharing or offline viewing:

```bash
pop --dashboard --export HTML
```

This creates a static HTML file with all the current dashboard information, which can be opened in any web browser. The file is named with a timestamp (e.g., `pipe_network_dashboard_20250309_103230.html`).

## Requirements

The dashboard requires the following dependencies:

- **jq**: Required for JSON processing
  ```bash
  sudo apt-get install jq
  ```

- **watch**: Required for auto-refresh functionality (optional)
  ```bash
  sudo apt-get install procps
  ```

## Troubleshooting

If you encounter issues with the dashboard:

1. **Missing dependencies**: Ensure you have installed jq and procps
2. **No data displayed**: Make sure your node is properly configured and running
3. **Historical trends not showing**: Run `pop --leaderboard` multiple times to collect historical data
4. **HTML export not working**: Check if you have write permissions in the current directory

## Example Output

```
╔═════════════════════════════════════════════════════════════════════════╗
║                    PIPE NETWORK POP NODE DASHBOARD                      ║
╚═════════════════════════════════════════════════════════════════════════╝
  Time: 2025-03-09 10:32:40
  Node ID: d058ae47-05c5-44d9-b642-53f11719d474
╔═════════════════════════════════════════════════════════════════════════╗
║ STATUS                                                                  ║
╚═════════════════════════════════════════════════════════════════════════╝
  Status: Running (PID: 238033)
  Uptime: 4 days, 23:37:14
  Started: Tue Mar 4 10:55:24 2025
  Resources: CPU: 1.2% | RAM: 3.5% (350/8192 MB) | Disk: 15% (10/100 GB)
  Ports: 80: ✓  443: ✓  8003: ✓  

╔═════════════════════════════════════════════════════════════════════════╗
║ PERFORMANCE METRICS                                                     ║
╚═════════════════════════════════════════════════════════════════════════╝
  Rank: 42 | Reputation: 0.82 | Points: 987 | Egress: 0.6 TB

╔═════════════════════════════════════════════════════════════════════════╗
║ HISTORICAL TRENDS                                                       ║
╚═════════════════════════════════════════════════════════════════════════╝
  Reputation: → | Points: ↑ (+37) | Egress: ↑ (+0.05 TB) | Rank: ↓ (-7)

╔═════════════════════════════════════════════════════════════════════════╗
║ ACTIONS                                                                 ║
╚═════════════════════════════════════════════════════════════════════════╝
  - View detailed metrics: pop --pulse
  - View leaderboard: pop --leaderboard
  - View historical data: pop --history
  - Restart node: pop --restart

Press Ctrl+C to exit
```

## Integration with Other Tools

The dashboard integrates seamlessly with other Pipe Network PoP Node tools:

- **Pulse Monitoring**: For more detailed real-time status information
- **Leaderboard**: For comparing your node with others in the network
- **Historical Data Visualization**: For detailed historical trends
- **Service Management**: For restarting or managing your node

## Future Enhancements

Planned enhancements for the dashboard include:

- Web-based interface with interactive charts
- Alert notifications for critical metrics
- Custom dashboard layouts
- Mobile-friendly design
- Multi-node dashboard for managing multiple nodes 