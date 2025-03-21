# Understanding Pipe Network Scoring and Rewards

The Pipe Network rewards node operators based on a sophisticated scoring system that evaluates your node's performance. Understanding this system helps you maximize your rewards.

## Scoring Components

Your node's total score consists of three main components:

### 1. Uptime Score (40% of total)

**What it measures:** The percentage of time your node is online and responsive.

**How to maximize:**
- Ensure your node runs 24/7
- Use a reliable internet connection
- Consider a UPS (uninterruptible power supply) for power outages

### 2. Historical Score (30% of total)

**What it measures:** How long your node has been participating in the network.

**How to maximize:**
- Keep your node running continuously
- Avoid frequent restarts or reregistration
- Maintain the same node ID over time

### 3. Egress Score (30% of total)

**What it measures:** How much data your node has actively transferred to the network.

**How to maximize:**
- Ensure proper port forwarding (ports 80, 443, and 8003)
- Use a connection with good upstream bandwidth
- Verify external accessibility using `./port_check.sh`

## Checking Your Score

To check your current score:

```bash
pop status
```

This will display your total score and individual component scores.

## Score Interpretation

| Score Range | Performance Level |
|-------------|-------------------|
| 0.9 - 1.0   | Excellent         |
| 0.7 - 0.89  | Good              |
| 0.5 - 0.69  | Average           |
| 0.3 - 0.49  | Below Average     |
| 0.0 - 0.29  | Poor              |

## Rewards and Earnings

Rewards are distributed based on your node's score relative to other nodes in the network. The higher your score, the greater your rewards.

### Reward Distribution

Rewards are typically distributed on a regular schedule. You can check your rewards by:

```bash
pop earnings
```

## Common Issues Affecting Scores

1. **Low Uptime:** Frequent restarts or service interruptions
2. **Poor Connectivity:** Network issues or firewall restrictions
3. **Insufficient Resources:** Inadequate CPU, RAM, or disk space
4. **Port Forwarding Issues:** Inability to accept incoming connections

## Monitoring Your Score Over Time

Use the dashboard to track your score trends:

```bash
pop monitoring pulse
```

For more detailed performance analysis, check the [performance monitoring guide](performance_monitoring.md). 