# Pipe Network Reputation System

## Overview

The Pipe Network uses a reputation system to evaluate the reliability and performance of nodes in the network. This document explains how the reputation score is calculated and how to maintain a high score.

## Reputation Score Calculation

According to the [official Pipe Network documentation](https://docs.pipe.network/devnet-2), the node's reputation score (0-1) is calculated based on the last 7 days of node operation, using three main components:

### 1. Uptime Score (40% of total)

- Reports are first grouped by hour to prevent over-weighting from frequent reporting
- A day is considered to have "good coverage" if it has at least 75% of hours reported (18+ hours)
- For days with good coverage, the average uptime is weighted by how complete the day's coverage was
- The final uptime score is the weighted average daily uptime divided by seconds in a day (capped at 100%)

### 2. Historical Score (30% of total)

- Based on how many days out of the last 7 had good coverage
- Example: If 6 out of 7 days had good coverage, the historical score would be 0.857 (86%)
- This rewards consistent reporting over time

### 3. Egress Score (30% of total)

- Based on total data transferred over the 7-day period
- Normalized against a target of 1TB per day
- Capped at 100%

## Example Calculation

If a node has:

```
Day 1: 24 hours reported (100% coverage)
Day 2: 22 hours reported (92% coverage)
Day 3: 23 hours reported (96% coverage)
Day 4: 24 hours reported (100% coverage)
Day 5: 20 hours reported (83% coverage)
Day 6: 12 hours reported (50% coverage - not counted)
Day 7: 24 hours reported (100% coverage)
```

Then:

- 6 days have good coverage (>75% of hours)
- Historical score would be 6/7 = 0.857
- Uptime score would be based on the weighted average of those 6 days
- The day with only 50% coverage is not counted in the uptime calculation

## Important Notes

1. **Maintenance Windows**:
   - Short gaps (< 4 hours) don't significantly impact the score
   - A day needs only 75% coverage to count, allowing for maintenance
   - Restarts don't reset your progress

2. **Score Recovery**:
   - Scores are calculated over a rolling 7-day window
   - Poor performance drops out of the calculation after 7 days
   - New nodes can build up their score within a week of good operation

3. **Best Practices**:
   - Regular reporting (at least hourly)
   - Plan maintenance during the same 6-hour window each day
   - Keep total downtime under 6 hours per day when possible

4. **Score Interpretation**:
   - 90%+ : Excellent reliability
   - 80-90%: Good reliability
   - 70-80%: Fair reliability
   - <70%: Needs improvement

## Benefits of High Reputation

- Priority for P2P transfers (score > 0.7)
- Eligibility for referral rewards (score > 0.5)
- Future: Higher earnings potential

## Viewing Your Reputation

To view your node's reputation score and detailed metrics:

```bash
./bin/pipe-pop --status
```

This will display a breakdown of your reputation metrics and overall score.

## Tips for Maintaining a High Reputation Score

1. **Ensure Consistent Uptime**:
   - Use a reliable internet connection
   - Consider using a UPS for power backup
   - Run the node on a dedicated machine if possible

2. **Plan Maintenance Carefully**:
   - Schedule maintenance during low-traffic periods
   - Keep maintenance windows under 6 hours
   - Try to perform maintenance at the same time each day/week

3. **Monitor Your Node Regularly**:
   - Use the provided monitoring script: `./monitor.sh`
   - Check system resources to prevent performance issues
   - Address any issues promptly

4. **Optimize Network Performance**:
   - Ensure ports 80, 443, and 8003 are open and properly forwarded
   - Use a wired connection rather than Wi-Fi if possible
   - Consider bandwidth allocation to prioritize the Pipe PoP node

5. **Regular Updates**:
   - Keep the Pipe PoP binary updated to the latest version
   - Update your system regularly for security and performance improvements 