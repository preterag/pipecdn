# Global Command Documentation

This document provides information about the global `pop` command, which allows you to manage your Pipe PoP node from anywhere on your system.

## Installation

The global `pop` command is installed using the `fixed_install_global_pop.sh` script. This script creates a global command that can be run from anywhere on your system.

To install the global command:

```bash
# Make the script executable
chmod +x fixed_install_global_pop.sh

# Run the script with sudo
sudo ./fixed_install_global_pop.sh
```

The script will:
1. Create the installation directory at `/opt/pipe-pop`
2. Copy the `pipe-pop` binary to the installation directory
3. Create the necessary scripts (monitor.sh, backup.sh)
4. Create the global `pop` command at `/usr/local/bin/pop`
5. Set the appropriate permissions

## Usage

Once installed, you can use the `pop` command from anywhere on your system:

```bash
pop --help
```

This will display a list of available commands.

## Available Commands

The following commands are available:

| Command | Description |
|---------|-------------|
| `--status` | Check node status and reputation |
| `--check-update` | Check for available updates |
| `--update` | Update to the latest version |
| `--gen-referral-route` | Generate a referral code |
| `--points-route` | Check points and rewards |
| `--monitor` | Monitor node status |
| `--backup` | Create a backup |
| `--restart` | Restart the node service |
| `--logs` | View service logs |
| `--help` | Show this help message |

## Examples

Here are some examples of how to use the `pop` command:

```bash
# Check node status
pop --status

# Monitor node status
pop --monitor

# Create a backup
pop --backup

# Update to the latest version
sudo pop --update
```

## Update Management

The `pop` command includes functionality to check for updates and update your Pipe PoP binary when new versions are available.

### Checking for Updates

To check if a new version of the Pipe PoP binary is available:

```bash
pop --check-update
```

This command:
1. Determines your current version using multiple methods (version flags, binary inspection, version file)
2. Checks for the latest available version from the download server
3. Compares the versions and informs you if an update is available

If you're already running the latest version, you'll see:
```
[INFO] ========================================
[INFO] Your Pipe PoP binary is up to date (vX.Y.Z).
[INFO] ========================================
```

If a new version is available, you'll see:
```
[WARNING] ========================================
[WARNING] A new version is available: vX.Y.Z (you have vA.B.C)
[WARNING] Download URL: https://dl.pipecdn.app/vX.Y.Z/pop
[WARNING] To update, run: sudo ./update_binary.sh vX.Y.Z
[WARNING] Or use the pop script: sudo pop --update
[WARNING] ========================================
```

### Updating the Binary

To update your Pipe PoP binary to the latest version:

```bash
sudo pop --update
```

This command:
1. Checks for the latest available version
2. Creates a backup of your current binary
3. Downloads the new binary
4. Verifies the new binary is valid
5. Replaces the old binary with the new one
6. Restarts the Pipe PoP service
7. Updates the version.txt file with the new version

If you want to update to a specific version or reinstall the same version:

```bash
sudo pop --update vX.Y.Z --force
```

The `--force` flag allows you to reinstall the same version if needed.

## Monitoring

The `--monitor` command provides detailed information about your node, including:

- Node status (running/not running)
- System resources (RAM and disk usage)
- Cache directory size
- Node information
- Port availability

Example:

```bash
pop --monitor
```

## Backup

The `--backup` command creates a backup of your node's important data, including:

- node_info.json
- Solana wallet (if available)
- Configuration files

The backup is stored in the `backups` directory as a compressed archive.

Example:

```bash
pop --backup
```

## Troubleshooting

If you encounter any issues with the global `pop` command, try the following:

1. Make sure the command is installed correctly:
   ```bash
   which pop
   ```
   This should return `/usr/local/bin/pop`.

2. Make sure the command is executable:
   ```bash
   ls -l $(which pop)
   ```
   This should show that the file has execute permissions.

3. If the command is not found, try reinstalling it:
   ```bash
   sudo ./fixed_install_global_pop.sh
   ```

4. If you see errors related to missing files or directories, make sure the installation directory exists:
   ```bash
   ls -l /opt/pipe-pop
   ```

5. If you see errors related to the binary, make sure it exists and is executable:
   ```bash
   ls -l /opt/pipe-pop/bin/pipe-pop
   ```

## Uninstallation

To uninstall the global `pop` command, run the following commands:

```bash
# Remove the global command
sudo rm /usr/local/bin/pop

# Remove the installation directory
sudo rm -rf /opt/pipe-pop
```

## Additional Information

The global `pop` command is a wrapper around the `pipe-pop` binary and provides additional functionality such as monitoring and backup. It uses absolute paths to ensure that it works correctly regardless of your current directory.

If you need to modify the scripts or the global command, you can find them in the following locations:

- Global command: `/usr/local/bin/pop`
- Monitor script: `/opt/pipe-pop/monitor.sh`
- Backup script: `/opt/pipe-pop/backup.sh`
- Binary: `/opt/pipe-pop/bin/pipe-pop` 