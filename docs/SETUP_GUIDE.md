# Pipe PoP Node Setup Guide

## Overview

This guide provides step-by-step instructions for setting up a Pipe PoP node for the [Pipe Network](https://docs.pipe.network/devnet-2) decentralized CDN. Follow these instructions to get your node up and running quickly.

## Prerequisites

Before you begin, ensure your system meets the following requirements:

- **RAM**: Minimum 2GB, recommended 4GB+
- **Disk Space**: Minimum 20GB free, recommended 100GB+
- **Operating System**: Linux (Ubuntu 20.04 or newer recommended)
- **Network**: Stable internet connection with open ports 80, 443, and 8003
- **Solana Wallet**: Optional, can be created during setup

## Setup Methods

### Easy Setup (Recommended)

The easiest way to set up a Pipe PoP node is to use our one-command setup script:

1. Download and run the setup script:
   ```bash
   curl -L https://raw.githubusercontent.com/preterag/pipecdn/master/easy_setup.sh -o easy_setup.sh
   chmod +x easy_setup.sh
   sudo ./easy_setup.sh
   ```

2. Follow the on-screen prompts to complete the setup.

This script will:
- Install all necessary dependencies
- Set up your Solana wallet (or use your existing one)
- Download and configure the Pipe PoP binary
- Set up a systemd service for reliable operation
- Configure automatic backups
- Apply the Surrealine referral code (optional)

### Manual Setup

If you prefer to set up your node manually, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/preterag/pipecdn.git
   cd pipecdn
   ```

2. Install dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y curl net-tools jq
   ```

3. Run the setup script:
   ```bash
   chmod +x setup.sh
   sudo ./setup.sh
   ```

4. Follow the on-screen instructions to complete the setup.

## Step-by-Step Manual Setup Instructions

If you prefer a more detailed walkthrough, follow these steps:

### Step 1: Clone the Repository

```bash
git clone https://github.com/preterag/pipecdn.git
cd pipecdn
```

### Step 2: Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y curl net-tools jq
```

### Step 3: Download the Pipe PoP Binary

```bash
mkdir -p bin
curl -L -o bin/pipe-pop https://dl.pipecdn.app/v0.2.8/pop
chmod +x bin/pipe-pop
```

### Step 4: Set Up Your Solana Wallet

If you already have a Solana wallet:

1. Create a configuration file:
   ```bash
   mkdir -p config
   cat > config/config.json << EOF
   {
     "solana_wallet": "YOUR_WALLET_ADDRESS",
     "cache_dir": "$(pwd)/cache",
     "log_level": "info",
     "network": {
       "ports": [80, 443, 8003],
       "hostname": "auto"
     }
   }
   EOF
   ```

2. Replace `YOUR_WALLET_ADDRESS` with your actual Solana wallet address.

If you don't have a Solana wallet:

1. Install Solana CLI:
   ```bash
   sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
   export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
   ```

2. Create a new wallet:
   ```bash
   solana-keygen new --no-passphrase
   ```

3. Get your wallet address:
   ```bash
   solana address
   ```

4. Create a configuration file with your new wallet address.

### Step 5: Sign Up with Referral Code (Optional)

Using the Surrealine referral code:

```bash
sudo ./bin/pipe-pop --signup-by-referral-route 3a069772281d9b1b
```

### Step 6: Set Up the Systemd Service

1. Create a service file:
   ```bash
   cat > pipe-pop.service << EOF
   [Unit]
   Description=Pipe PoP Node
   After=network.target
   
   [Service]
   User=$(whoami)
   WorkingDirectory=$(pwd)
   ExecStart=$(pwd)/bin/pipe-pop --cache-dir $(pwd)/cache --pubKey $(grep -o '"solana_wallet"[^,}]*' config/config.json | cut -d'"' -f4)
   Restart=on-failure
   RestartSec=10
   LimitNOFILE=65535
   
   [Install]
   WantedBy=multi-user.target
   EOF
   ```

2. Install and start the service:
   ```bash
   sudo cp pipe-pop.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable pipe-pop.service
   sudo systemctl start pipe-pop.service
   ```

### Step 7: Verify Node Status

Check if your node is running correctly:

```bash
./pop --status
```

### Step 8: Set Up Regular Backups

Set up a weekly backup schedule:

```bash
./setup_backup_schedule.sh weekly
```

## Using the Pop Script

The `pop` script provides an easy way to manage your Pipe PoP node:

```bash
# Check node status
./pop --status

# Check for updates
./pop --check-update

# Update to the latest version
sudo ./pop --update

# Generate a referral code
./pop --gen-referral-route

# Check points and rewards
./pop --points-route
```

## Troubleshooting

If you encounter issues during setup:

1. Check if the required ports are open:
   ```bash
   sudo netstat -tulpn | grep -E '80|443|8003'
   ```

2. Verify the service is running:
   ```bash
   systemctl status pipe-pop.service
   ```

3. Check the logs for errors:
   ```bash
   journalctl -u pipe-pop.service -n 100
   ```

4. For more detailed troubleshooting, refer to the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) document.

## Important Notes

- Ports 80, 443, and 8003 must be open and accessible
- A Solana wallet is required to receive rewards
- Sufficient disk space is needed for cache data
- Regular backups of node_info.json are essential

## Next Steps

After setting up your Pipe PoP node:

1. Monitor your node status regularly with `./pop --status`
2. Keep your node updated with `sudo ./pop --update`
3. Back up your node_info.json file regularly
4. Check your reputation score and work to maintain it above 0.7

## Additional Resources

- [Pipe Network Documentation](https://docs.pipe.network/devnet-2)
- [Maintenance Guide](./MAINTENANCE.md)
- [Reputation System Guide](./REPUTATION_SYSTEM.md)
- [Referral Guide](./REFERRAL_GUIDE.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)

## Support

If you need help with your Pipe PoP node, you can:

1. Check the documentation in the `docs/` directory
2. Visit the [official Pipe Network documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com)

Thank you for participating in the Pipe Network ecosystem and supporting Surrealine's content delivery infrastructure! 