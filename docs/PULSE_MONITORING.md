# 📊 pipe-pop Pulse Monitoring

The pipe-pop Pulse Monitoring feature provides real-time information about your node's status, performance, and metrics. This document explains how to use the pulse monitoring feature and the different modes available.

## Overview

The pulse monitoring feature displays key information about your pipe-pop node, including:

- Current status (running/not running)
- Runtime duration
- CPU and memory usage
- Port status (80, 443, 8003)
- Uptime statistics
- Reputation score with detailed breakdown
- Points earned
- Egress data transferred
- Referral statistics

This information is updated in real-time, allowing you to monitor your node's health and performance at a glance.

## Usage

The pulse monitoring feature can be accessed using the global `pop` command:

```bash
pop --pulse
```

### Available Modes

The pulse monitoring feature offers three different modes to suit your preferences:

#### 1. Standard Mode (Default)

```bash
pop --pulse
```

- Updates every 2 seconds
- Press 'q' to exit
- Uses the `watch` command for display
- Automatically falls back to continuous mode if `watch` is not available

#### 2. Interactive Mode

```bash
pop --pulse -i
```

- Shows a single update
- Press any key to exit
- Useful for quick checks or when you want to capture the output

#### 3. Continuous Mode

```bash
pop --pulse -c
```

- Updates every 2 seconds
- Press Ctrl+C to exit
- Runs directly in your terminal without using `watch`
- Useful when `watch` is not available or when you want to redirect output

## Network Leaderboard

In addition to monitoring your own node, you can view a network-wide leaderboard to see how your node compares to others:

```bash
pop --leaderboard
```

The leaderboard shows the top 12 nodes in the network, sorted by reputation by default. Your node will be highlighted if it appears in the list. If your node is not in the top 12, its position will be shown separately at the bottom.

### Sorting Options

You can sort the leaderboard by different metrics:

```bash
pop --leaderboard --reputation  # Default, sort by reputation score
pop --leaderboard --points      # Sort by points earned
pop --leaderboard --egress      # Sort by egress data transferred
```

### Error Handling

The leaderboard feature includes robust error handling:
- Automatic retries (up to 3 attempts) if the API connection fails
- Detailed error messages and troubleshooting steps
- Network connectivity testing to help diagnose issues

### Historical Data

The leaderboard feature automatically saves historical data for future visualization:
- Data is stored in the `history` directory
- Each leaderboard snapshot is saved with a timestamp
- Historical data is automatically pruned after 30 days

## Example Output

### Pulse Monitoring

```
╔═══════════════════════════════════════════════════════════════════╗
║                      PIPE NETWORK POP NODE PULSE                  ║
╠═══════════════════════════════════════════════════════════════════╣
║ Time: 2025-03-09 10:32:40
║ Node ID: abc123def456ghi789jkl012mno345pqr678stu
╠═══════════════════════════════════════════════════════════════════╣
║ STATUS
║ Status:     Running (PID: 12345)
║ Uptime:     4 days, 23:37:14
║ Started:    Tue Mar 4 10:55:24 2025
║ CPU Usage:  1.2%
║ Mem Usage:  3.5%
║ Ports:      80: ✓  |  443: ✓  |  8003: ✓
╠═══════════════════════════════════════════════════════════════════╣
║ REPUTATION BREAKDOWN
║ Overall:     Reputation: 0.95
║ Uptime Score: 0.98 (40% weight)
║ Historical Score: 0.92 (30% weight)
║ Egress Score: 0.94 (30% weight)
╠═══════════════════════════════════════════════════════════════════╣
║ PERFORMANCE METRICS
║ Uptime: 99.8% (last 7 days)
║ Points: 1250
║ Egress: 1.2 TB
╠═══════════════════════════════════════════════════════════════════╣
║ REFERRAL STATISTICS
║ Referral Count: 3
║ Referral Points: 150
╚═══════════════════════════════════════════════════════════════════╝
```

### Leaderboard

```
╔════════════════════════════════════════════════════════════════════════════╗
║                        PIPE NETWORK NODE LEADERBOARD                       ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Rank  Node ID                       Reputation    Points    Egress         ║
╠════════════════════════════════════════════════════════════════════════════╣
║ 1     abc123def456ghi789jkl012mno   0.99          5432      3.2 TB         ║
║ 2     def456ghi789jkl012mno345pqr   0.98          4987      2.9 TB         ║
║ 3     ghi789jkl012mno345pqr678stu   0.97          4521      2.7 TB         ║
║ ...
║ 12    vwxyz234abc567def890ghi123j   0.85          1234      0.8 TB         ║
╠════════════════════════════════════════════════════════════════════════════╣
║ Your Node:                                                                 ║
║ 42    abc123def456ghi789jkl012mno   0.82          987       0.6 TB         ║
╚════════════════════════════════════════════════════════════════════════════╝
```

## Troubleshooting

If you encounter issues with the pulse monitoring feature:

1. **Missing `watch` command**: The standard mode requires the `watch` command. If it's not installed, the script will attempt to install it automatically (requires root privileges). Alternatively, you can use the `--continuous` mode which doesn't require `watch`.

2. **Missing `jq` or `curl` commands**: The leaderboard feature requires these tools. The script will attempt to install them automatically if they're missing (requires root privileges).

3. **No data displayed**: If no data is displayed, ensure your node is properly configured and the `pipe-pop` binary is in the correct location.

4. **Incorrect port status**: If ports show as closed (✗) when they should be open, check your firewall settings and ensure the ports are properly forwarded if you're behind a router.

5. **Performance issues**: If the pulse monitoring itself causes high CPU usage, try using the `--interactive` mode for occasional checks rather than continuous monitoring.

6. **API connection errors**: If the leaderboard feature fails to connect to the Pipe Network API, the script will automatically retry up to 3 times. If it still fails, it will provide detailed troubleshooting steps. Common issues include:
   - Network connectivity problems
   - Temporary API service outages
   - DNS resolution issues
   - Firewall blocking outbound connections

## Integration with Monitoring Systems

The pulse monitoring feature can be integrated with external monitoring systems:

```bash
# Capture a single pulse check to a file
pop --pulse -i > pulse_check.txt

# Use in a cron job for regular checks
* * * * * /usr/local/bin/pop --pulse -i > /var/log/pipe-pop_pulse/$(date +\%Y\%m\%d_\%H\%M\%S).log 2>&1

# Capture leaderboard data for tracking
0 * * * * /usr/local/bin/pop --leaderboard > /var/log/pipe-pop_leaderboard/$(date +\%Y\%m\%d_\%H).log 2>&1
```

## Understanding the Reputation System

The node's reputation score (0-1) is calculated based on the last 7 days of node operation, using three main components:

1. **Uptime Score (40% of total)**
   - Reports are first grouped by hour to prevent over-weighting from frequent reporting
   - A day is considered to have "good coverage" if it has at least 75% of hours reported (18+ hours)
   - For days with good coverage, the average uptime is weighted by how complete the day's coverage was
   - The final uptime score is the weighted average daily uptime divided by seconds in a day (capped at 100%)

2. **Historical Score (30% of total)**
   - Based on how many days out of the last 7 had good coverage
   - Example: If 6 out of 7 days had good coverage, the historical score would be 0.857 (86%)
   - This rewards consistent reporting over time

3. **Egress Score (30% of total)**
   - Based on total data transferred over the 7-day period
   - Normalized against a target of 1TB per day
   - Capped at 100%

### Score Interpretation

- **90%+ (0.9+)**: Excellent reliability
- **80-90% (0.8-0.9)**: Good reliability
- **70-80% (0.7-0.8)**: Fair reliability
- **<70% (<0.7)**: Needs improvement

### Benefits of High Reputation

- Priority for P2P transfers (score > 0.7)
- Eligibility for referral rewards (score > 0.5)
- Future: Higher earnings potential

## Historical Data Visualization

The Pipe Network PoP node includes a powerful historical data visualization feature that allows you to track your node's performance over time. This feature helps you understand trends in your node's reputation, rank, points, and egress data.

### Requirements

- **jq**: Required for JSON processing
  ```bash
  sudo apt-get install jq
  ```

- **gnuplot** (optional): For enhanced graphical visualization
  ```bash
  sudo apt-get install gnuplot
  ```

### Automated Data Collection

To build a comprehensive history of your node's performance, you need to collect data regularly. The `setup_cron.sh` script makes this easy by setting up automated data collection:

```bash
./setup_cron.sh [OPTION]
```

Available options:
- `--hourly`: Set up hourly data collection (recommended)
- `--daily`: Set up daily data collection
- `--custom SCHEDULE`: Set up a custom schedule in cron format
- `--remove`: Remove existing cron jobs
- `--help`: Show help message

Examples:
```bash
./setup_cron.sh --hourly           # Collect data every hour
./setup_cron.sh --daily            # Collect data once a day at midnight
./setup_cron.sh --custom "0 */2 * * *"  # Collect data every 2 hours
```

The script will automatically add a cron job to your system to run the leaderboard command at the specified intervals, building historical data over time.

### Viewing Historical Data

Once you have collected data over time, you can visualize it using the `history_view.sh` script:

```bash
./history_view.sh [OPTION]
```

Available options:
- `--rank`: Show rank history for your node
- `--reputation`: Show reputation history for your node
- `--points`: Show points history for your node
- `--egress`: Show egress history for your node
- `--top-nodes [COUNT]`: Show history for top N nodes (default: 5)
- `--days [DAYS]`: Number of days to show (default: 7)

Examples:
```bash
./history_view.sh --rank           # Show your node's rank history
./history_view.sh --reputation     # Show your node's reputation history
./history_view.sh --points         # Show your node's points history
./history_view.sh --egress         # Show your node's egress history
./history_view.sh --top-nodes 3    # Show history for top 3 nodes
./history_view.sh --days 14 --rank # Show rank history for the last 14 days
```

### Example Output

#### Rank History
```
Rank History for Your Node
=========================
Date                Rank
----                ----
2025-03-03 08:00     35
2025-03-04 08:00     42

Rank Trend (lower is better)
==========================
2025-03-03 08:00     35
2025-03-04 08:00     42   from 35: ↓ Declined
```

#### Reputation History
```
Reputation History for Your Node
==============================
Date                Reputation
----                ----------
2025-03-03 08:00     0.83
2025-03-04 08:00     0.82

Reputation Trend (higher is better)
=================================
2025-03-03 08:00     0.83
2025-03-04 08:00     0.82       from 0.83: ↓ Declined
```

#### Points History
```
Points History for Your Node
==========================
Date                Points
----                ------
2025-03-03 08:00     950
2025-03-04 08:00     987

Points Trend (higher is better)
==============================
2025-03-03 08:00     950
2025-03-04 08:00     987     from 950: ↑ Increased (+37)
```

#### Egress History
```
Egress History for Your Node
==========================
Date                Egress
----                ------
2025-03-03 08:00     0.55 TB
2025-03-04 08:00     0.60 TB

Egress Trend (higher is better)
=============================
2025-03-03 08:00     0.55 TB
2025-03-04 08:00     0.60 TB    from 0.55 TB: ↑ Increased (+0.05)
```

### Troubleshooting

If you encounter issues with the historical data visualization:

1. **No data displayed**: Ensure you have collected data using the leaderboard command or automated collection.
2. **Missing jq**: Install jq using `sudo apt-get install jq`.
3. **ASCII visualization instead of graphs**: Install gnuplot for better visualization using `sudo apt-get install gnuplot`.
4. **Incorrect trends**: Check that your system's date and time are correct.
5. **Missing history files**: Verify that the `history` directory exists and contains JSON files.

### Future Enhancements

Future versions of the historical data visualization feature may include:

1. **Web-based visualization**: Interactive charts and graphs in a web interface
2. **Performance predictions**: AI-based predictions of future performance
3. **Comparative analysis**: Compare your node against network averages
4. **Export capabilities**: Export data to CSV or other formats for external analysis
5. **Alert thresholds**: Set alerts for significant changes in metrics

## Comprehensive Dashboard

For a more comprehensive view of your node's status and performance, you can use the dashboard feature:

```bash
pop --dashboard
```

The dashboard combines pulse monitoring data with historical trends and additional metrics in a unified interface. For detailed information about the dashboard feature, see [DASHBOARD.md](./DASHBOARD.md).

## Future Enhancements

The following enhancements are planned for future releases:

- ✅ **Historical Data Visualization**: Track your node's performance over time with graphs and trend analysis
- ✅ **Comprehensive Dashboard**: A unified interface for monitoring all aspects of your node
- **Alert Thresholds**: Set custom thresholds for critical metrics and receive notifications
- **Network Traffic Graphs**: Visualize network traffic patterns and identify optimization opportunities
- **Integration with Notification Systems**: Receive alerts via email, SMS, or messaging platforms
- **Custom Display Formats**: Configure the display format to show only the metrics you care about
- **More Detailed Leaderboard Statistics**: Additional metrics and comparison features
- **Performance Trend Analysis**: Advanced analytics to predict future performance based on historical data

## Comprehensive Dashboard

The Pipe Network PoP node includes a powerful dashboard feature that provides a unified interface for monitoring all aspects of your node. The dashboard combines real-time status information, performance metrics, and historical trends in a single view.

### Usage

The dashboard can be accessed using the `pop` command with the `--dashboard` option:

```bash
pop --dashboard
```

### Available Options

The dashboard offers several options to customize the display:

```bash
pop --dashboard --refresh 10      # Refresh every 10 seconds (default: 5)
pop --dashboard --compact         # Show compact view with less details
pop --dashboard --no-history      # Don't show historical data
pop --dashboard --export HTML     # Export dashboard to HTML file
```

### Features

The dashboard includes the following sections:

1. **Status Information**
   - Node running status with PID
   - Detailed uptime information (days, hours, minutes, seconds)
   - Exact start time of the node
   - System resource usage (CPU, RAM, disk)
   - Port status (80, 443, 8003)

2. **Performance Metrics**
   - Current rank in the network
   - Reputation score
   - Points earned
   - Egress data transferred

3. **Historical Trends**
   - Changes in reputation, points, egress, and rank
   - Trend indicators (increasing, decreasing, or unchanged)

4. **Quick Actions**
   - Links to common management tasks

### HTML Export

The dashboard can be exported to an HTML file for sharing or offline viewing:

```bash
pop --dashboard --export HTML
```

This creates a static HTML file with all the current dashboard information, which can be opened in any web browser.

### Requirements

- **jq**: Required for JSON processing
  ```bash
  sudo apt-get install jq
  ```

- **watch**: Required for auto-refresh functionality (optional)
  ```bash
  sudo apt-get install procps
  ```

### Example Output

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
  - View detailed metrics: ./pop --pulse
  - View leaderboard: ./pop --leaderboard
  - View historical data: ./history_view.sh --help
  - Restart node: ./pop --restart

Press Ctrl+C to exit
``` 