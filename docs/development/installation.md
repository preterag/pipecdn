# Development Installation Guide

> **IMPORTANT**: This is a community-created guide for Pipe Network node tools development.
> It is not part of the official Pipe Network documentation.

This guide explains how to set up a development environment for working on the Pipe Network community tools.

## Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Git
- Bash shell
- Basic development tools (jq, curl, net-tools)

## Setting Up the Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/[username]/pipe-pop.git
cd pipe-pop
```

### 2. Install Dependencies

```bash
sudo apt-get update
sudo apt-get install -y jq curl net-tools netstat ufw
```

### 3. Repository Structure

The repository follows this structure:

- `docs/` - Documentation
  - `official/` - Official Pipe Network documentation
  - `guides/` - Community guides
  - `reference/` - Reference documentation
  - `development/` - Development guides
- `src/` - Source code
  - `core/` - Core functionality
  - `utils/` - Utility functions
  - `config/` - Configuration templates
- `scripts/` - Installation and maintenance scripts
- `tools/` - Compiled/executable tools
- `examples/` - Example configurations
- `templates/` - Operational file templates

### 4. Development Setup (Without Installation)

To work on the code without installing it:

```bash
# Make scripts executable
chmod +x tools/pop src/core/node.sh src/core/monitoring/pulse.sh src/utils/backup/backup.sh src/utils/security/security_check.sh
```

You can then run the tools directly:

```bash
./tools/pop --help
./src/core/monitoring/pulse.sh
./src/utils/security/security_check.sh
```

### 5. Development Installation (System-Wide)

If you want to test your changes with a system-wide installation:

```bash
sudo ./INSTALL
```

This will:
1. Create directories in `/opt/pipe-pop/`
2. Copy all scripts to their respective locations
3. Create a system service
4. Set up the global `pop` command

### 6. Testing Your Changes

After making changes to the code:

1. If you're working without installation, run the scripts directly
2. If you've installed system-wide, copy your updated scripts to the installation directory:

```bash
sudo cp src/core/node.sh /opt/pipe-pop/src/core/
# Restart the service if needed
sudo systemctl restart pipe-pop
```

### 7. Development Workflow

1. Create a feature branch: `git checkout -b feature/new-feature`
2. Make your changes
3. Test thoroughly
4. Update documentation
5. Commit and push your changes
6. Create a pull request

## Adding New Features

### Adding a New Command

To add a new command to the `pop` tool:

1. Edit `tools/pop` and add your command processing in the main function
2. Add the command to the help text
3. If needed, create new script files in the appropriate directories
4. Update documentation in `docs/reference/cli.md`

### Adding New Scripts

When adding new utility scripts:

1. Place them in the appropriate directory under `src/`
2. Follow the community enhancement header convention
3. Make them executable
4. Update the INSTALL script if needed

## Contribution Guidelines

Please follow these guidelines when contributing:

1. Always add the community enhancement header to new files
2. Maintain clear separation between official and community content
3. Update documentation for any changes
4. Test thoroughly before submitting pull requests

For more details, see [CONTRIBUTING.md](../../CONTRIBUTING.md). 