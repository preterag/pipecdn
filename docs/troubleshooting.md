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