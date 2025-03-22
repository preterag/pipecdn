# Pipe Network PoP Node Management Tools: Troubleshooting Guide

## Permission Management

The Pipe Network PoP Node Tools can be installed in two modes:

1. **System-Wide Installation** (default)
   - Installed to `/opt/pipe-pop/`
   - Command linked to `/usr/local/bin/pop`
   - Requires sudo rights for installation and certain operations
   - Best for multi-user environments

2. **User-Level Installation**
   - Installed to `~/.local/share/pipe-pop/`
   - Command linked to `~/.local/bin/pop`
   - Minimal sudo requirements
   - Best for single-user or restricted environments

### Sudo Privilege Management

To minimize password prompts, the tools use a sudo cache system:

- By default, sudo is requested once and cached for 15 minutes
- You can pre-authenticate by running: `pop --auth`
- Most regular status commands don't require sudo access

If you see permission errors:

1. Try using `pop --auth` first to grant permissions
2. Check if your sudo rights are working correctly
3. Consider reinstalling with `pop --install --user` for user-level installation

## Command Line Format

The tools accept commands in two formats for maximum flexibility:

1. **Flag format (recommended)**: `pop --command [options]`
   - Example: `pop --status --detailed`
   - More consistent with modern CLI tools

2. **Traditional format (backward compatibility)**: `pop command [options]`
   - Example: `pop status --detailed`
   - Compatible with older scripts

## Installation Options

### System-Wide Installation

```bash
# Basic system-wide installation (requires sudo)
./tools/pop --install

# Force reinstallation
./tools/pop --install --force

# Custom installation location
./tools/pop --install --dir=/custom/path
```

### User-Level Installation

```bash
# Install for current user only
./tools/pop --install --user

# Force reinstallation for current user
./tools/pop --install --user --force
```

### Uninstallation

```bash
# Remove system-wide installation
pop --uninstall

# Remove user installation
pop --uninstall --user
```

## Common Issues and Solutions

### Missing Metrics Data

If you see "No metrics data available" when running commands:

1. Try running `pop --pulse --once` to collect metrics once
2. Check if `/opt/pipe-pop/metrics` (or `~/.local/share/pipe-pop/metrics`) is writable
3. Verify that your system has standard Linux metrics tools installed (e.g., `top`, `free`, `df`)

### Command Not Found

If you get "command not found" when running `pop`:

1. For system installations, check if `/usr/local/bin` is in your PATH
2. For user installations, check if `~/.local/bin` is in your PATH
   - Add with: `export PATH="$PATH:$HOME/.local/bin"`
3. Try calling the command with full path: `/usr/local/bin/pop`

### Cannot Create Directory

If you see errors about directory creation:

1. For system-wide installation, run `pop --auth` first
2. For user-level installations, check if your home directory has sufficient space
3. Verify permissions on parent directories

### Seeing Simulated Data

If you see "Using simulated data" messages:

1. This indicates the system is using fallback data generation when real data isn't available
2. To get real data, try running `pop --pulse --once` first 
3. Check system permissions for data collection

## Data Paths and Customization

The tools store data in the following locations:

**System Installation**:
- Configuration: `/opt/pipe-pop/config/`
- Metrics: `/opt/pipe-pop/metrics/`
- Logs: `/opt/pipe-pop/logs/`

**User Installation**:
- Configuration: `~/.local/share/pipe-pop/config/`
- Metrics: `~/.local/share/pipe-pop/metrics/`
- Logs: `~/.local/share/pipe-pop/logs/`

**Fallback Locations** (when primary locations aren't accessible):
- Temporary metrics: `~/.cache/pipe-pop/metrics/`
- Configuration cache: `~/.cache/pipe-pop/config/`

# Troubleshooting Guide

This guide covers common issues you might encounter with the Pipe Network PoP Node and how to resolve them.

## System-Specific Issues

### Ubuntu 24.04 LTS (Noble Numbat)

This release has been primarily tested on Ubuntu 24.04 LTS. Here are some Ubuntu-specific troubleshooting tips:

#### Permission Issues

If you encounter permission errors when running commands:

```bash
# Check current permissions
ls -la /opt/pipe-pop/

# Fix permissions if needed
sudo chmod +x /opt/pipe-pop/tools/pop
sudo chmod +x /opt/pipe-pop/tools/pop-ui-python
```

#### Service Management

If the service fails to start:

```bash
# Check service status
systemctl status pipe-pop

# View detailed logs
journalctl -u pipe-pop

# Restart service
sudo systemctl restart pipe-pop
```

#### Package Dependencies

Ubuntu 24.04 may require additional packages:

```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y curl jq net-tools
```

## Common Issues

### Installation Problems

#### Error: Command not found after installation

**Symptom**: The `pop` command is not recognized after installation.

**Solution**:
1. Ensure the installation completed successfully
2. Check if the command is in your PATH:
   ```bash
   echo $PATH | grep pipe-pop
   ```
3. Run the installer again:
   ```bash
   /opt/pipe-pop/tools/installer
   ```

#### Error: Installation script fails

**Symptom**: Installation script exits with error.

**Solution**:
1. Check for error messages in the output
2. Verify that you have sufficient permissions:
   ```bash
   sudo ./installer
   ```
3. Check disk space:
   ```bash
   df -h
   ```

### Networking Issues

#### Error: Port conflicts

**Symptom**: Services fail to start due to port conflicts.

**Solution**:
1. Check if ports are already in use:
   ```bash
   sudo netstat -tulpn | grep <PORT>
   ```
2. Configure different ports in the configuration file:
   ```bash
   pop configure --port <NEW_PORT>
   ```

#### Error: Cannot connect to network

**Symptom**: Node cannot connect to the network.

**Solution**:
1. Check your internet connection:
   ```bash
   ping -c 4 google.com
   ```
2. Verify firewall settings:
   ```bash
   sudo ufw status
   ```
3. Ensure required ports are open:
   ```bash
   sudo ufw allow <PORT>/tcp
   ```

### Configuration Issues

#### Error: Configuration file not found

**Symptom**: Error message indicating missing configuration file.

**Solution**:
1. Create a default configuration:
   ```bash
   pop configure --reset
   ```
2. Check file permissions:
   ```bash
   ls -la ~/.config/pipe-pop/
   ```

#### Error: Invalid configuration values

**Symptom**: Service fails to start due to invalid configuration.

**Solution**:
1. Reset to default configuration:
   ```bash
   pop configure --reset
   ```
2. Edit configuration with valid values:
   ```bash
   pop configure
   ```

### Monitoring and Dashboard Issues

#### Error: Dashboard displays no data

**Symptom**: Dashboard shows no metrics or node information.

**Solution**:
1. Check if node is running:
   ```bash
   pop status
   ```
2. Reset metrics collection:
   ```bash
   pop metrics --reset
   ```
3. Restart the node:
   ```bash
   pop restart
   ```

#### Error: High resource usage

**Symptom**: System resources (CPU, memory) usage is abnormally high.

**Solution**:
1. Check which processes are consuming resources:
   ```bash
   top
   ```
2. Analyze node performance:
   ```bash
   pop pulse
   ```
3. Adjust resource limits in configuration:
   ```bash
   pop configure --resource-limit
   ```

### Fleet Management Issues

#### Error: Cannot connect to fleet nodes

**Symptom**: Unable to establish connection with fleet nodes.

**Solution**:
1. Verify SSH key setup:
   ```bash
   pop --fleet verify-keys
   ```
2. Check if the node is properly registered:
   ```bash
   pop --fleet list
   ```
3. Test connectivity:
   ```bash
   pop --fleet test-connection <NODE>
   ```

#### Error: Fleet commands fail

**Symptom**: Fleet commands return errors.

**Solution**:
1. Check node status:
   ```bash
   pop --fleet status
   ```
2. Verify permissions on remote nodes:
   ```bash
   pop --fleet check-permissions
   ```
3. Attempt to re-register the problem node:
   ```bash
   pop --fleet unregister <NODE>
   pop --fleet register <NODE>
   ```

## Logging

For more detailed troubleshooting, check the application logs:

```bash
# View application logs
pop logs

# View more detailed logs
pop logs --verbose

# Check system logs
sudo journalctl -u pipe-pop
```

## Getting Help

If you continue to experience issues after following these troubleshooting steps, please:

1. Check the documentation for any updates
2. Check for software updates:
   ```bash
   pop --check-update
   ```
3. Reach out to the community through the official channels

---

**Note**: For issues related to the Web UI, please defer to a future release where this feature will be fully implemented. 