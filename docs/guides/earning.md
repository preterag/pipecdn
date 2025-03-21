# Earning with Pipe Network

Your Pipe Network node earns rewards by sharing network resources.

## Checking Earnings

View your current earnings:

```bash
pop points
```

## Reputation System

Your node's reputation affects earnings:

```bash
pop status
```

The output shows:
- Overall reputation score
- Uptime score (40% weight)
- Historical score (30% weight)
- Egress score (30% weight)

## Maximizing Earnings

1. **Maintain High Uptime**
   - Keep your node running 24/7
   - Use a reliable internet connection

2. **Optimize Network Settings**
   - Ensure ports 80, 443, and 8003 are open
   - Configure your firewall correctly

3. **Refer Others**
   - Generate a referral code:
     ```bash
     pop referral generate
     ```
   - Share your code to earn additional rewards

## Monitoring Performance

Track real-time performance:

```bash
pop monitoring pulse
```

## Leaderboard

See how your node ranks:

```bash
pop --leaderboard
```

## Rewards Collection

Rewards are sent directly to your connected Solana wallet.

Check your wallet info:
```bash
pop wallet info
``` 