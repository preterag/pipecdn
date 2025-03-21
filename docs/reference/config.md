# Configuration Reference

Your Pipe Network node is configured through a JSON file at `/opt/pipe-pop/config/config.json`.

## Basic Configuration

A minimal configuration requires:

```json
{
  "node": {
    "wallet_address": "YOUR_SOLANA_WALLET_ADDRESS",
    "cache_dir": "/opt/pipe-pop/cache",
    "log_level": "info"
  },
  "network": {
    "ports": {
      "http": 80,
      "https": 443,
      "api": 8003
    },
    "hostname": "auto"
  }
}
```

## Configuration Options

### Node Settings

| Option | Description | Default |
|--------|-------------|---------|
| `wallet_address` | Your Solana wallet address | *Required* |
| `cache_dir` | Directory to store node data | `/opt/pipe-pop/cache` |
| `log_level` | Logging detail level | `info` |

### Network Settings

| Option | Description | Default |
|--------|-------------|---------|
| `ports.http` | HTTP port | `80` |
| `ports.https` | HTTPS port | `443` |
| `ports.api` | API port | `8003` |
| `hostname` | Node hostname | `auto` |

## Using Environment Variables

You can use environment variables in your config:

```json
{
  "node": {
    "wallet_address": "${PIPE_WALLET_ADDRESS}"
  }
}
```

Set variables in `/etc/pipe-pop.env`:
```
PIPE_WALLET_ADDRESS=YOUR_WALLET_ADDRESS
```

## Security Best Practices

- Set secure file permissions: `chmod 600 config.json`
- Use environment variables for sensitive data
- Never share your configuration with others 