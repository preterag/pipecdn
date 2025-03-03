# Pipe PoP Node Setup Guide

This guide provides step-by-step instructions for setting up a Pipe PoP (Points of Presence) node using the Surrealine referral code. By following these instructions, you'll be able to participate in the Pipe Network decentralized CDN and help propagate content globally while earning rewards.

## Prerequisites

Before you begin, ensure your system meets the following requirements:

- **RAM**: Minimum 4GB, recommended 8GB
- **Disk Space**: Minimum 50GB, recommended 100GB+
- **Operating System**: Linux (Ubuntu 20.04 or newer recommended)
- **Network**: Stable internet connection with open ports 80, 443, and 8003
- **Solana Wallet**: Required for node operation and rewards

## Step 1: Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/e3o8o/pipecdn.git
cd pipecdn
```

## Step 2: Install Dependencies

Install the necessary dependencies:

```bash
sudo apt-get update
sudo apt-get install -y curl net-tools
```

## Step 3: Download the Pipe PoP Binary

Download the latest Pipe PoP binary:

```bash
# download the compiled pop binary
curl -L -o bin/pipe-pop "https://dl.pipecdn.app/v0.2.8/pop"
# assign executable permission to pop binary
chmod +x bin/pipe-pop
# create folder to be used for download cache
mkdir -p cache
```

## Step 4: Sign Up with Surrealine Referral Code

Use the Surrealine referral code to sign up your Pipe PoP node:

```bash
sudo ./bin/pipe-pop --signup-by-referral-route 6ae5e9a2e5063d8
```

This step registers your node with the Pipe Network using the Surrealine referral code, which helps support the Surrealine platform while also benefiting your node.

## Step 5: Configure Your Node

Create a configuration file for your Pipe PoP node:

```bash
mkdir -p config
```

Create a file named `config/config.json` with the following content (replace the Solana wallet address with your own):

```json
{
  "solana_wallet": "YOUR_SOLANA_WALLET_ADDRESS",
  "cache_dir": "$(pwd)/cache",
  "log_level": "info",
  "network": {
    "ports": [80, 443, 8003],
    "hostname": "auto"
  }
}
```

## Step 6: Set Up the Systemd Service

Create a systemd service file to run the Pipe PoP node as a service:

```bash
sudo ./install_service.sh all
```

This will:
1. Install the service
2. Enable it to start on boot
3. Start the service
4. Show the service status

## Step 7: Verify Your Node is Running

Check the status of your Pipe PoP node:

```bash
./monitor.sh
```

This will display information about your node's status, including whether it's running, system resource usage, and port availability.

## Step 8: Set Up Regular Backups

Set up a regular backup schedule to ensure your node data is safe:

```bash
./setup_backup_schedule.sh weekly
```

This will create a cron job to run the backup script every Sunday at 2:00 AM.

## Step 9: Monitor Your Node

Regularly monitor your node to ensure it's running properly:

```bash
./monitor.sh
```

You can also check your node's reputation score and points:

```bash
./bin/pipe-pop --status
```

## Step 10: Update Your Node When Needed

When a new version of the Pipe PoP binary is available, update it using:

```bash
./update_binary.sh BINARY_URL
```

Replace `BINARY_URL` with the URL of the new binary.

## Troubleshooting

If you encounter issues with your node, check the following:

1. **Node not starting**:
   - Check system resources
   - Verify port availability
   - Check logs for errors

2. **Connection issues**:
   - Verify firewall settings
   - Check network connectivity
   - Ensure ports 80, 443, and 8003 are open

3. **Performance problems**:
   - Monitor RAM and disk usage
   - Check for competing processes
   - Consider upgrading hardware if consistently at capacity

## Important Notes

- The node requires ports 80, 443, and 8003 to be open
- A Solana wallet is required for operation
- Cache data should be stored in a location with sufficient disk space
- Backup your node_info.json file regularly, as it's linked to your IP address and not recoverable if lost

## Additional Resources

- [Official Pipe Network Documentation](https://docs.pipe.network/devnet-2)
- [Surrealine Website](https://www.surrealine.com)
- [Pipe Network Dashboard](https://dashboard.pipenetwork.com)

## Support

If you need help with your Pipe PoP node, you can:

1. Check the documentation in the `docs/` directory
2. Visit the [official Pipe Network documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support for assistance

Thank you for participating in the Pipe Network ecosystem and supporting Surrealine's content delivery infrastructure! 