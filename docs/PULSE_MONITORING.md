# 📊 Pulse Monitoring

## 📋 Overview

The Pulse Monitoring feature provides real-time information about your Pipe PoP node's status, including uptime, performance metrics, and system resource usage.

## 🚀 Quick Start

To use the Pulse Monitoring feature, run:

```bash
pop --pulse
```

Or, if you haven't set up the global command:

```bash
./pop --pulse
```

## ✨ Features

- 🔄 **Real-time Status**: View your node's current status, including PID and uptime
- ⏱️ **Detailed Uptime**: See exact uptime with days, hours, minutes, and seconds
- 📅 **Start Time**: View the precise date and time when your node was started
- 💻 **Resource Usage**: Monitor CPU and memory usage
- 📊 **Reputation Metrics**: View detailed reputation breakdown
- 🔌 **Port Status**: Check if required ports (80, 443, 8003) are open and functioning
- 📈 **Historical Data**: Track performance over time with historical data visualization

## 🔧 Usage Options

### 📊 Standard Mode

```bash
pop --pulse
```

In standard mode, the pulse monitor will display your node's status and wait for you to press 'q' to exit.

### 🔄 Interactive Mode

```bash
pop --pulse -i
```

In interactive mode, the pulse monitor will display your node's status and exit immediately after any key press.

### ⏱️ Continuous Mode

```bash
pop --pulse -c
```

In continuous mode, the pulse monitor will continuously update your node's status until you press Ctrl+C to exit.

### 📈 Historical Data Visualization

Track your node's performance over time:

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

## 📊 Output Explanation

The pulse monitor output includes:

### 🔄 Status Section

```
STATUS: Running (PID: 12345)
Uptime: 15 days, 7 hours, 23 minutes, 45 seconds
Started: 2023-03-01 08:15:30 UTC
```

- 🟢 **STATUS**: Shows if your node is running, along with its Process ID (PID)
- ⏱️ **Uptime**: Shows how long your node has been running in days, hours, minutes, and seconds
- 📅 **Started**: Shows the exact date and time when your node was started

### 💻 System Resources Section

```
CPU: 2.5%
Memory: 512MB (5.0%)
```

- 🔄 **CPU**: Shows the current CPU usage percentage of your node
- 💾 **Memory**: Shows the memory usage in MB and as a percentage of total system memory

### 📊 Performance Metrics Section

```
Rank: 123 (↑5)
Reputation: 98.7% (↑0.2%)
Points: 45,678 (↑1,234)
Egress: 123.45 GB (↑5.67 GB)
```

- 🏆 **Rank**: Shows your node's current rank in the network and the change since last check
- ⭐ **Reputation**: Shows your node's reputation score and the change since last check
- 🎯 **Points**: Shows your node's accumulated points and the change since last check
- 📤 **Egress**: Shows your node's total egress traffic and the change since last check

### 🔌 Port Status Section

```
Port 80: OPEN
Port 443: OPEN
Port 8003: OPEN
```

- 🟢 **OPEN**: Indicates that the port is open and functioning correctly
- 🔴 **CLOSED**: Indicates that the port is closed or not functioning correctly

## 📈 Historical Data Visualization

The historical data visualization feature allows you to track your node's performance over time. This feature requires:

- 🔍 `jq` for JSON processing
- 📊 `gnuplot` for generating graphs

### 🔧 Requirements

To use the historical data visualization feature, you need to install:

```bash
# Install jq
sudo apt-get install jq

# Install gnuplot
sudo apt-get install gnuplot
```

### ⏱️ Automated Data Collection

To collect data automatically, set up a cron job using the provided script:

```bash
# Set up hourly data collection
./setup_cron.sh --hourly

# Set up daily data collection
./setup_cron.sh --daily

# Set up custom schedule
./setup_cron.sh --custom "0 */2 * * *"  # Every 2 hours
```

The script will create a cron job that runs the data collection script at the specified interval.

### 📊 Viewing Historical Data

To view historical data, use the following commands:

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

### 📁 Data Storage

Historical data is stored in JSON format in the `history` directory:

- `history/daily.json`: Contains daily snapshots of your node's performance
- `history/hourly.json`: Contains hourly snapshots of your node's performance

### 📊 Sample Output

```
Rank History (Last 7 Days)
Date       Rank  Change
2023-03-01  150     -
2023-03-02  145    ↑5
2023-03-03  140    ↑5
2023-03-04  138    ↑2
2023-03-05  135    ↑3
2023-03-06  130    ↑5
2023-03-07  125    ↑5

Overall Change: ↑25 (16.7% improvement)
```

## 🔄 Integration with Dashboard

The pulse monitoring data is also integrated into the comprehensive dashboard:

```bash
# View the dashboard
pop --dashboard
```

The dashboard provides a unified interface for monitoring all aspects of your node, including pulse monitoring data.

## 🔧 Troubleshooting

### 🔴 Node Not Running

If the pulse monitor shows that your node is not running, you can start it with:

```bash
pop --start
```

### 🔴 Port Closed

If the pulse monitor shows that a port is closed, check your firewall settings:

```bash
# Check if the port is allowed through the firewall
sudo ufw status

# Allow the port if needed
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8003
```

### 🔴 Low Reputation

If your reputation is low, check the following:

1. 🔌 Ensure all required ports are open
2. 💻 Check your system resources to ensure your node has enough CPU and memory
3. 🌐 Check your network connection for stability and bandwidth
4. ⏱️ Ensure your node has been running consistently without interruptions

## 📚 Additional Resources

- [🌐 Global Command Guide](GLOBAL_COMMAND.md)
- [🖥️ Dashboard Guide](DASHBOARD.md)
- [🔄 Referral System Guide](REFERRAL_GUIDE.md)
- [🔐 Authentication Guide](AUTHENTICATION.md) 