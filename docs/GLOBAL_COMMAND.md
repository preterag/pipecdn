# Global Pop Command

This document explains how to install and use the global `pop` command, which allows you to manage your Pipe PoP node from anywhere on your system without needing to navigate to the PipeNetwork directory.

## Installation

The global `pop` command is installed automatically during the setup process if you use the `easy_setup.sh` script. If you need to install it manually, follow these steps:

1. Navigate to your PipeNetwork directory:
   ```bash
   cd /path/to/your/PipeNetwork
   ```

2. Run the installation script with sudo:
   ```bash
   sudo ./install_global_pop.sh
   ```

3. The script will:
   - Create a global `pop` command in `/usr/local/bin/`
   - Set up a dedicated installation directory at `/opt/pipe-pop/`
   - Copy all necessary files from your PipeNetwork directory
   - Make all scripts executable

## Usage

After installation, you can run the `pop` command from anywhere on your system:

```bash
# Check node status
pop --status

# Monitor node performance
pop --monitor

# Create a backup
pop --backup

# Check for updates
pop --check-update

# Generate a referral code
pop --gen-referral-route

# Check points and rewards
pop --points-route

# View service logs
pop --logs
```

For commands that require root privileges, you'll need to use sudo:

```bash
# Update to the latest version
sudo pop --update

# Restart the service
sudo pop --restart
```

## Available Commands

| Command | Description | Requires Sudo |
|---------|-------------|---------------|
| `--status` | Check node status and reputation | No |
| `--check-update` | Check for available updates | No |
| `--update` | Update to the latest version | Yes |
| `--gen-referral-route` | Generate a referral code | No |
| `--points-route` | Check points and rewards | No |
| `--monitor` | Monitor node status | No |
| `--backup` | Create a backup | No |
| `--restart` | Restart the node service | Yes |
| `--logs` | View service logs | No |
| `--help` | Show help message | No |

## How It Works

The global `pop` command is a wrapper script that:

1. Uses absolute paths to reference the Pipe PoP binary and other scripts
2. Stores all necessary files in a dedicated installation directory (`/opt/pipe-pop/`)
3. Is accessible from anywhere because it's installed in `/usr/local/bin/`, which is in your system PATH

This means you no longer need to navigate to the PipeNetwork directory to manage your node.

## Troubleshooting

If you encounter issues with the global `pop` command:

1. **Command not found**: Make sure the installation script completed successfully and `/usr/local/bin/` is in your PATH.

2. **Permission denied**: For commands that require root privileges, make sure to use `sudo`.

3. **Binary not found**: If the command reports that the binary is not found, try reinstalling the global command:
   ```bash
   sudo ./install_global_pop.sh
   ```

4. **Other issues**: Check the installation directory to ensure all files were copied correctly:
   ```bash
   ls -la /opt/pipe-pop/
   ```

## Updating the Global Command

If you update your Pipe PoP node or make changes to the scripts, you should reinstall the global command to ensure it uses the latest versions:

```bash
cd /path/to/your/PipeNetwork
sudo ./install_global_pop.sh
```

## Uninstalling

If you need to uninstall the global `pop` command:

```bash
sudo rm /usr/local/bin/pop
sudo rm -rf /opt/pipe-pop
```

This will remove the command and the installation directory. 