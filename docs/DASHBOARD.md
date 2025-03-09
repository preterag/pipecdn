# 🖥️ Dashboard

## 📋 Overview

The Dashboard feature provides a unified interface for monitoring all aspects of your Pipe PoP node, including status information, performance metrics, and historical trends.

## 🚀 Quick Start

To use the Dashboard feature, run:

```bash
pop --dashboard
```

Or, if you haven't set up the global command:

```bash
./dashboard.sh
```

## ✨ Features

- 🔄 **Real-time Status**: View your node's current status, including PID and uptime
- ⏱️ **Detailed Uptime**: See exact uptime with days, hours, minutes, and seconds
- 📅 **Start Time**: View the precise date and time when your node was started
- 💻 **Resource Usage**: Monitor CPU, memory, and disk usage
- 📊 **Performance Metrics**: View rank, reputation, points, and egress
- 📈 **Historical Trends**: Track changes in metrics over time
- 🔌 **Port Status**: Check if required ports (80, 443, 8003) are open and functioning
- 🔗 **Quick Actions**: Access common management tasks

## 🔧 Usage Options

### 🖥️ Standard Mode

```bash
pop --dashboard
```

In standard mode, the dashboard will display your node's status and refresh automatically every 5 seconds.

### ⏱️ Custom Refresh Interval

```bash
pop --dashboard --refresh 10
```

Set a custom refresh interval (in seconds) for the dashboard.

### 📄 Compact View

```bash
pop --dashboard --compact
```

Show a compact view with less details, useful for smaller screens.

### 📊 No History

```bash
pop --dashboard --no-history
```

Don't show historical data in the dashboard.

### 📤 HTML Export

```bash
pop --dashboard --export HTML
```

Export the dashboard to an HTML file for sharing or offline viewing.

## 📊 Dashboard Sections

The dashboard is divided into several sections:

### 🔄 Status Section

```
STATUS
Status: Running (PID: 12345)
Uptime: 15 days, 7 hours, 23 minutes, 45 seconds
Started: 2023-03-01 08:15:30 UTC
Resources: CPU: 2.5% | RAM: 5.0% (512/8192 MB) | Disk: 25% (25/100 GB)
Ports: 80: ✓  443: ✓  8003: ✓
```

- 🟢 **Status**: Shows if your node is running, along with its Process ID (PID)
- ⏱️ **Uptime**: Shows how long your node has been running in days, hours, minutes, and seconds
- 📅 **Started**: Shows the exact date and time when your node was started
- 💻 **Resources**: Shows CPU, RAM, and disk usage
- 🔌 **Ports**: Shows if required ports are open and functioning

### 📊 Performance Metrics Section

```
PERFORMANCE METRICS
Rank: 123 | Reputation: 0.987 | Points: 45,678 | Egress: 123.45 GB
```

- 🏆 **Rank**: Shows your node's current rank in the network
- ⭐ **Reputation**: Shows your node's reputation score
- 🎯 **Points**: Shows your node's accumulated points
- 📤 **Egress**: Shows your node's total egress traffic

### 📈 Historical Trends Section

```
HISTORICAL TRENDS
Reputation: ↑ (+0.002) | Points: ↑ (+1,234) | Egress: ↑ (+5.67 GB) | Rank: ↑ (+5)
```

- ⭐ **Reputation**: Shows the change in reputation since the last check
- 🎯 **Points**: Shows the change in points since the last check
- 📤 **Egress**: Shows the change in egress traffic since the last check
- 🏆 **Rank**: Shows the change in rank since the last check

### 🔗 Actions Section

```
ACTIONS
- View detailed metrics: ./pop --pulse
- View leaderboard: ./pop --leaderboard
- View historical data: ./pop --history --help
- Restart node: ./pop --restart
```

- 📊 **View detailed metrics**: Link to the pulse monitoring feature
- 🏆 **View leaderboard**: Link to the leaderboard feature
- 📈 **View historical data**: Link to the historical data visualization feature
- 🔄 **Restart node**: Link to restart the node

## 📤 HTML Export

The dashboard can be exported to an HTML file for sharing or offline viewing:

```bash
pop --dashboard --export HTML
```

This creates a static HTML file with all the current dashboard information, which can be opened in any web browser.

The HTML export includes:

- 🎨 **Styled Layout**: Clean, responsive design
- 📊 **All Dashboard Sections**: Status, performance metrics, historical trends, and actions
- 📅 **Timestamp**: When the export was created
- 🔗 **Interactive Elements**: Links to documentation and actions

## 🔧 Requirements

To use the Dashboard feature, you need:

- 🔍 **jq**: Required for JSON processing
  ```bash
  sudo apt-get install jq
  ```

- 🔄 **watch**: Required for auto-refresh functionality (optional)
  ```bash
  sudo apt-get install procps
  ```

## 🔄 Integration with Other Features

The dashboard integrates with other features of the Pipe PoP node management tools:

- 📊 **Pulse Monitoring**: Displays data from the pulse monitoring feature
- 🏆 **Leaderboard**: Shows your node's rank from the leaderboard
- 📈 **Historical Data**: Displays trends from the historical data
- 🔌 **Port Checking**: Shows port status from the port checking feature

## 🔧 Troubleshooting

### 🔴 Dashboard Not Refreshing

If the dashboard is not refreshing automatically:

```bash
# Check if watch is installed
which watch

# Install watch if needed
sudo apt-get install procps
```

### 🔴 Missing Data

If some data is missing from the dashboard:

1. 🔍 Check if jq is installed: `which jq`
2. 🔌 Ensure your node is running: `pop --status`
3. 📊 Check if the pulse monitoring feature works: `pop --pulse -i`

### 🔴 HTML Export Fails

If the HTML export fails:

1. 🔍 Check if you have write permissions in the current directory
2. 💾 Ensure you have enough disk space
3. 🔌 Try specifying a different output path: `pop --dashboard --export HTML --output /path/to/file.html`

## 📚 Additional Resources

- [🌐 Global Command Guide](GLOBAL_COMMAND.md)
- [📊 Pulse Monitoring Guide](PULSE_MONITORING.md)
- [🔄 Referral System Guide](REFERRAL_GUIDE.md)
- [🔐 Authentication Guide](AUTHENTICATION.md) 