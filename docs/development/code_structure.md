# Code Structure Documentation

This document provides an overview of the Pipe Network Community Tools codebase structure for developers who want to contribute to the project.

## Directory Structure

```
pipe-pop/
├── bin/                     # Executables and binaries
├── cache/                   # Cache directory (not in Git)
├── config/                  # Configuration files
│   └── examples/            # Example configuration files
├── docs/                    # Documentation
│   ├── development/         # Developer documentation
│   ├── guides/              # User guides
│   ├── official/            # Official Pipe Network documentation
│   ├── reference/           # Reference documentation
│   └── images/              # Images for documentation
├── logs/                    # Log files (not in Git)
├── scripts/                 # Installation and utility scripts
│   ├── dev/                 # Development scripts
│   ├── install/             # Installation scripts
│   └── tools/               # Utility tools
├── src/                     # Source code
│   ├── config/              # Configuration handling
│   ├── core/                # Core functionality
│   ├── fleet/               # Fleet management
│   └── utils/               # Utility functions
└── tools/                   # Additional tools and utilities
```

## Core Components

### Installation and Setup

- `INSTALL` - Symlink to the main installation script
- `scripts/install.sh` - Main installation script
- `scripts/setup.sh` - Setup script for configuring the node

### Core Functionality

- `src/core/` - Contains the core functionality of the node
- `src/fleet/` - Handles fleet management and node coordination
- `src/config/` - Configuration handling and validation

### Utility Scripts

Utility scripts in the root directory:

- `port_check.sh` - Checks port forwarding configuration
- `enable_ports.sh` - Configures port forwarding for privileged ports
- `fix_node_registration.sh` - Ensures consistent node registration
- `register_node.sh` - Registers or re-registers your node
- `dashboard.sh` - Launches the monitoring dashboard

## Development Workflow

The development workflow is managed through:

- `scripts/dev_workflow.sh` - Handles development environment setup
- `scripts/dev/` - Contains development-specific scripts

## Service Configuration

- `pipe-pop.service` - Systemd service file template
- `scripts/tools/` - Contains scripts for service management

## Documentation Structure

- `docs/guides/` - User-focused guides on how to use the system
- `docs/reference/` - Technical reference documentation
- `docs/development/` - Developer-focused documentation

## Git Structure

The Git repository is structured to exclude operational files:

- Excluded: Logs, cache, node_info.json, backups, configuration with sensitive data
- Included: Source code, utility scripts, installation scripts, documentation

## Adding New Features

When adding new features:

1. Add source code to the appropriate directory in `src/`
2. Add utility scripts to the appropriate directory in `scripts/`
3. Add user documentation in `docs/guides/` and reference in `docs/reference/`
4. Add developer documentation in `docs/development/` 