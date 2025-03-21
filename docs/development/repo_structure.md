# Pipe Network PoP Repository Structure

This document provides a reference for the repository structure of the Pipe Network PoP Node Management Tools, including the Web UI components.

## Directory Structure

```
pipe-pop/
├── tools/
│   ├── pop                      # Main CLI entry point
│   └── pop-ui                   # UI launcher script
├── src/
│   ├── core/                    # Core functionality
│   │   ├── command.sh           # Command parsing and basic utilities
│   │   ├── node.sh              # Node management
│   │   ├── privilege.sh         # Privilege handling
│   │   ├── service.sh           # Service management
│   │   ├── config.sh            # Configuration handling
│   │   └── install.sh           # Installation procedures
│   ├── utils/                   # Utility modules
│   │   ├── common.sh            # Common utilities and helpers
│   │   ├── security/            # Security-related utilities
│   │   └── backup/              # Backup utilities
│   ├── fleet/                   # Fleet management
│   │   ├── manager.sh           # Node registration and management
│   │   ├── ssh.sh               # Remote command execution
│   │   ├── deploy.sh            # File deployment
│   │   └── monitor.sh           # Metrics collection
│   ├── community/               # Community features
│   │   ├── referral.sh          # Referral system
│   │   └── analytics.sh         # Network analytics
│   ├── maintenance/             # Maintenance tools
│   │   └── maintenance.sh       # Backup, restore, cleanup
│   ├── ui/                      # Web UI components
│   │   ├── server/              # Server-side components
│   │   │   ├── app.js           # Main server application
│   │   │   ├── routes/          # API routes
│   │   │   │   ├── api.js       # API endpoints
│   │   │   │   └── ui.js        # UI routes
│   │   │   ├── services/        # Backend services
│   │   │   │   ├── command.js   # Command execution
│   │   │   │   ├── config.js    # Configuration management
│   │   │   │   └── monitor.js   # System monitoring
│   │   │   └── utils/           # Server utilities
│   │   └── web/                 # Frontend components
│   │       ├── index.html       # Main application page
│   │       ├── wizard/          # Installation wizard pages
│   │       ├── css/             # Stylesheets
│   │       ├── js/              # Client-side scripts
│   │       │   ├── app.js       # Main application logic
│   │       │   ├── api.js       # API client
│   │       │   └── components/  # UI components
│   │       └── assets/          # Images and other assets
│   └── installer/               # Installation components
│       ├── web_installer.sh     # Web UI auto-launch during install
│       └── browser_detect.sh    # Browser detection utilities
├── config/                      # Configuration files
├── data/                        # Data storage
└── docs/                        # Documentation
    ├── guides/                  # User guides
    ├── reference/               # Reference documentation
    └── development/             # Developer documentation
        └── repo_structure.md    # This file
```

## Component Descriptions

### CLI Components

- **tools/pop**: The main command-line interface entry point script
- **src/core/**: Core modules that provide the foundation for all functionality
- **src/utils/**: Utility functions and helpers used throughout the codebase
- **src/fleet/**: Fleet management components for managing multiple nodes
- **src/community/**: Community-related features like referrals and analytics
- **src/maintenance/**: Tools for maintenance tasks like backup and security

### Web UI Components

- **tools/pop-ui**: Dedicated launcher script for the Web UI
- **src/ui/server/**: Server-side Node.js application with Express
  - **app.js**: Main server application
  - **routes/**: API and UI route handlers
  - **services/**: Services that connect UI to the underlying system
- **src/ui/web/**: Frontend web application
  - **index.html**: Main application page
  - **wizard/**: Installation wizard UI components
  - **css/**: Stylesheets for the web interface
  - **js/**: JavaScript code for the frontend application
  - **assets/**: Images, icons, and other static assets

### Installation Components

- **src/installer/**: Scripts for the installation process
  - **web_installer.sh**: Handles auto-launching the Web UI during installation
  - **browser_detect.sh**: Utilities for detecting the user's browser

## File Dependencies

The system follows a structured dependency hierarchy:

1. **Base Layer**: Core utilities (command.sh)
2. **Utility Layer**: Common utilities (common.sh)
3. **Functional Modules**: All domain-specific modules
4. **UI Layer**: Web interface connecting to the functional modules

The Web UI components connect to the existing system through an API layer that maps UI interactions to CLI commands, ensuring consistency between the two interfaces.

## Integration Points

- **API Layer**: The server's API endpoints map directly to CLI commands
- **Web Installer**: Integrates with the standard installation script
- **Browser Auto-Launch**: Hooks into the installation process to launch the user's default browser
- **Command Execution**: Services that translate UI actions to system commands

This structure supports both CLI and Web UI interfaces while maintaining a clear separation of concerns and preventing circular dependencies. 