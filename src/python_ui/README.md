# Pipe Network PoP - Python Web UI

**IMPORTANT: Development of this Python Web UI has been deferred to a future release. The code is available for preview and testing purposes only.**

A lightweight web interface for managing Pipe Network PoP nodes, built with Python and Flask.

## Features (Planned)

- Dashboard monitoring of node performance
- System metrics visualization
- Node control (start, stop, restart)
- Configuration management
- Log viewer for troubleshooting
- Installation wizard for new nodes
- Automatic browser detection and launch

## Requirements

- Python 3.6 or newer
- Flask web framework

## Installation (Preview Only)

The Python Web UI can be installed for testing purposes using the provided installer script:

```bash
# Install the Python Web UI (for testing only)
tools/pop-ui-python install
```

## Usage (Preview Only)

```bash
# Start the UI server
tools/pop-ui-python start

# Start the UI server and open in browser
tools/pop-ui-python start --launch

# Start the UI server directly (bypass dependency checks)
tools/pop-ui-python direct-start --launch

# Stop the UI server
tools/pop-ui-python stop

# Check if the UI server is running
tools/pop-ui-python status

# Show help information
tools/pop-ui-python help
```

## Architecture

The Python Web UI is designed to be lightweight and efficient, with these key components:

- **Flask Web Server**: Handles HTTP requests and serves the web interface
- **Browser Utility**: Detects and launches the best available browser
- **System Check Utility**: Validates system compatibility
- **Dashboard**: Real-time visualization of node metrics
- **Installation Wizard**: Step-by-step setup for new nodes
- **Configuration Page**: Interface for adjusting node settings

## Development Status

**This Python UI has been deferred to a future release.** Development will continue at a later time, addressing the following issues:

1. Compatibility challenges with various Python environments
2. Flask dependency management across different systems
3. Integration with the main PoP command-line interface

The code remains in the repository for preview and to allow community members to experiment with it, but it should not be used in production environments.

## Directory Structure

```
python_ui/
├── app.py                 # Flask application entry point
├── static/                # Static assets (CSS, JS, images)
│   ├── css/               # Stylesheets
│   ├── js/                # JavaScript files
│   └── img/               # Images
├── templates/             # HTML templates
│   ├── dashboard/         # Dashboard templates
│   ├── wizard/            # Installation wizard templates
│   └── config/            # Configuration templates
├── utils/                 # Utility functions
│   ├── system_check.py    # System compatibility verification
│   ├── browser.py         # Browser detection and launching
│   └── metrics.py         # Metrics collection
└── README.md              # This file
```

## Security

The Web UI is restricted to localhost by default. For remote access, additional authentication is required and must be explicitly enabled.

## Contributing

Contributions to the Python Web UI are welcome, though active development is currently paused. Please follow the existing code style and add tests for new features. 