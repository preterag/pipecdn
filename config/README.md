# Pipe PoP Configuration Directory

This directory contains configuration files for the Pipe PoP node.

## Contents

- `config.json`: Main configuration file for the Pipe PoP node

## Configuration Options

The `config.json` file contains the following configuration options:

```json
{
  "solana_wallet": "YOUR_SOLANA_WALLET_ADDRESS",
  "cache_dir": "/path/to/cache/directory",
  "log_level": "info",
  "network": {
    "ports": [80, 443, 8003],
    "hostname": "auto"
  }
}
```

### Options Explained

- `solana_wallet`: Your Solana wallet public address where rewards will be sent
- `cache_dir`: Directory where the node will store cache data
- `log_level`: Verbosity of logging (options: debug, info, warn, error)
- `network.ports`: Ports that the node will use (default: 80, 443, 8003)
- `network.hostname`: Hostname configuration (auto or specific hostname)

## Important Notes

- Always use your own Solana wallet address to receive rewards directly
- Ensure the cache directory has sufficient disk space
- Do not change the ports unless you know what you're doing
- The configuration file is automatically created by the setup scripts 