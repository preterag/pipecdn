# Pipe PoP Node Setup Guide

This guide will walk you through the process of setting up a Pipe PoP node on your system.

## Prerequisites

Before you begin, make sure you have the following:

- A Linux-based operating system (Ubuntu 20.04 or later recommended)
- At least 2GB of RAM
- At least 20GB of free disk space
- A stable internet connection
- Basic knowledge of Linux command line

## Installation Options

You have two options for installing the Pipe PoP node:

1. **Easy Setup (Recommended)**: Using the provided `easy_setup.sh` script
2. **Manual Setup**: Following step-by-step instructions

## Option 1: Easy Setup

The easy setup script automates the entire installation process.

1. Download the PipeNetwork repository:
   ```bash
   git clone https://github.com/pipe-network/pipe-pop.git
   cd pipe-pop
   ```

2. Make the setup script executable:
   ```bash
   chmod +x easy_setup.sh
   ```

3. Run the setup script:
   ```bash
   ./easy_setup.sh
   ```

4. Follow the on-screen instructions to complete the setup.

## Option 2: Manual Setup

If you prefer to set up the node manually, follow these steps:

1. Download the PipeNetwork repository:
   ```bash
   git clone https://github.com/pipe-network/pipe-pop.git
   cd pipe-pop
   ```

2. Install dependencies:
   ```bash
   sudo apt update
   sudo apt install -y curl jq net-tools
   ```

3. Set up the configuration:
   ```bash
   cp config/config.example.json config/config.json
   ```

4. Edit the configuration file to match your requirements:
   ```bash
   nano config/config.json
   ```

5. Make the binary executable:
   ```bash
   chmod +x bin/pipe-pop
   ```

6. Start the node:
   ```bash
   ./bin/pipe-pop --start
   ```

## Setting Up the Global Command

For convenience, you can set up a global `pop` command that allows you to manage your node from anywhere on your system.

### Using the Fixed Installation Script (Recommended)

We've created an improved installation script that properly sets up the global command with correct paths:

1. Make the script executable:
   ```bash
   chmod +x fixed_install_global_pop.sh
   ```

2. Run the script with sudo:
   ```bash
   sudo ./fixed_install_global_pop.sh
   ```

3. Test the installation:
   ```bash
   pop --help
   ```

### Manual Global Command Setup

If you prefer to set up the global command manually:

1. Create a symbolic link to the binary:
   ```bash
   sudo ln -s $(pwd)/bin/pipe-pop /usr/local/bin/pop
   ```

2. Make sure the link is created correctly:
   ```bash
   which pop
   ```

## Verifying the Installation

To verify that your node is running correctly:

1. Check the node status:
   ```bash
   pop --status
   ```

2. Monitor the node:
   ```bash
   pop --monitor
   ```

3. Check the logs:
   ```bash
   pop --logs
   ```

## Setting Up as a Service

To ensure your node runs continuously, even after system reboots, you can set it up as a service:

1. Create a service file:
   ```bash
   sudo nano /etc/systemd/system/pipe-pop.service
   ```

2. Add the following content (replace `/path/to/pipe-pop` with your actual path):
   ```
   [Unit]
   Description=Pipe PoP Node
   After=network.target

   [Service]
   Type=simple
   User=YOUR_USERNAME
   WorkingDirectory=/path/to/pipe-pop
   ExecStart=/path/to/pipe-pop/bin/pipe-pop --start
   Restart=on-failure
   RestartSec=10
   StandardOutput=journal
   StandardError=journal

   [Install]
   WantedBy=multi-user.target
   ```

3. Enable and start the service:
   ```bash
   sudo systemctl enable pipe-pop.service
   sudo systemctl start pipe-pop.service
   ```

4. Check the service status:
   ```bash
   sudo systemctl status pipe-pop.service
   ```

## Troubleshooting

If you encounter any issues during setup:

1. Check the logs:
   ```bash
   pop --logs
   ```

2. Make sure all dependencies are installed:
   ```bash
   sudo apt install -y curl jq net-tools
   ```

3. Verify that the configuration file is correct:
   ```bash
   cat config/config.json
   ```

4. Restart the node:
   ```bash
   pop --restart
   ```

5. For more detailed troubleshooting, refer to the [Troubleshooting Guide](TROUBLESHOOTING.md).

## Next Steps

After setting up your node:

1. Generate a referral code:
   ```bash
   pop --gen-referral-route
   ```

2. Check your points and rewards:
   ```bash
   pop --points-route
   ```

3. Set up regular backups:
   ```bash
   pop --backup
   ```

4. Consider setting up a monitoring system to keep track of your node's performance.

## Additional Resources

- [Documentation](DOCUMENTATION.md): Complete documentation for the Pipe PoP node
- [Troubleshooting Guide](TROUBLESHOOTING.md): Solutions to common issues
- [Development Plan](DEVELOPMENT_PLAN.md): Upcoming features and improvements
- [Global Command Documentation](GLOBAL_COMMAND.md): Detailed information about the global `pop` command

## Support

If you need help with your Pipe PoP node, you can:

1. Check the documentation in the `docs/` directory
2. Visit the [official Pipe Network documentation](https://docs.pipe.network/devnet-2)
3. Contact Surrealine support at [hello@surrealine.com](mailto:hello@surrealine.com)

Thank you for participating in the Pipe Network ecosystem and supporting Surrealine's content delivery infrastructure! 