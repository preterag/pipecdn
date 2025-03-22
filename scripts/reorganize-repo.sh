#!/bin/bash

# Ensure we're in the correct directory
cd "$(dirname "$0")/.." || exit 1

# Create new directory structure
mkdir -p docs/{official,community,getting-started,development} \
    src/community/{analytics,referral} \
    src/core/monitoring \
    src/fleet/{admin,core,db,monitoring,operations} \
    src/installer \
    src/monitoring \
    src/python_ui/{static,templates,utils} \
    src/ui/{server,web} \
    src/utils/{backup,security} \
    scripts \
    tools

# Move files to their new locations
echo "Moving files to new locations..."

# Move documentation
mv docs/official/PIPE_NETWORK_DOCUMENTATION.md docs/official/
mv docs/CHANGELOG.md docs/
mv docs/COMMUNITY_ENHANCEMENTS.md docs/
mv docs/CONTRIBUTING.md docs/development/
mv docs/IMPLEMENTATION_TRACKER.md docs/
mv docs/RELEASE_CHECKLIST.md docs/
mv docs/RELEASE_NOTES.md docs/
mv docs/START_HERE.md docs/

# Move community files
mv src/community/analytics.sh src/community/analytics/
mv src/community/referral.sh src/community/referral/

# Move core files
mv src/core/command.sh src/core/
mv src/core/config.sh src/core/
mv src/core/install.sh src/core/
mv src/core/monitoring/monitoring.sh src/core/monitoring/
mv src/core/network.sh src/core/
mv src/core/node.sh src/core/
mv src/core/privilege.sh src/core/
mv src/core/service.sh src/core/

# Move fleet files
mv src/fleet/README.md src/fleet/
mv src/fleet/deploy.sh src/fleet/
mv src/fleet/manager.sh src/fleet/
mv src/fleet/monitor.sh src/fleet/
mv src/fleet/monitoring/monitoring.sh src/fleet/monitoring/
mv src/fleet/ssh.sh src/fleet/

# Move installer files
mv src/installer/browser_detect.sh src/installer/
mv src/installer/web_installer.sh src/installer/

# Move monitoring files
mv src/monitoring/alerts.sh src/monitoring/
mv src/monitoring/dashboard.sh src/monitoring/
mv src/monitoring/history.sh src/monitoring/
mv src/monitoring/metrics.sh src/monitoring/

# Move python_ui files
mv src/python_ui/README.md src/python_ui/
mv src/python_ui/app.py src/python_ui/

# Move ui files
mv src/ui/server src/ui/
mv src/ui/web src/ui/

# Move utils files
mv src/utils/common.sh src/utils/

# Move scripts
echo "Moving scripts to new locations..."
mv scripts/dev_workflow.sh scripts/
mv scripts/install.sh scripts/
mv scripts/install_hooks.sh scripts/
mv scripts/setup.sh scripts/

# Move tools
echo "Moving tools to new locations..."
mv tools/pop tools/
mv tools/pop-ui tools/
mv tools/pop-ui-python tools/
mv tools/test_script.sh tools/
mv tools/create_deb_package.sh tools/

# Update gitignore
echo "Updating .gitignore..."
> .gitignore
cat << 'EOL' >> .gitignore
# Build and package files
build/
dist/
*.deb
*.rpm
*.tar.gz
*.zip

# Operational directories
logs/
data/
cache/
backups/
monitoring/data/
download_cache/

# User configuration
config.json
**/config/*.local.json
.node_info
.pop.env

# Virtual environments
venv/
.venv/
env/
.env/
.python-version

# Runtime files
*.pid
*.sock
*.log
.cache/
sample-metrics.json
sample-metrics.json.prev

# Editor and IDE files
.vscode/
.idea/
.cursor/
*~
*.swp
*.swo

# System files
.DS_Store
Thumbs.db

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Node
node_modules/
package-lock.json
yarn.lock

# Operational scripts that should be generated
new-pipe-pop.service
pipe-pop.service
updated-pipe-pop.service

# Test files
*.test
*.spec
*.tmp
EOL

# Create README files for major directories
echo "Creating README files..."

# Root README
> README.md
cat << 'EOL' >> README.md
# Pipe Network POP Node Management Tool

A community-driven enhancement of the official Pipe Network POP node management tools, providing additional features and improved node management capabilities.

## Repository Structure

```
pipe-pop/
├── .github/                # GitHub workflows and configurations
├── docs/                  # Documentation
├── src/                   # Source code
├── build/                 # DEB package build output
├── scripts/               # Development and setup scripts
├── tools/                 # Build and packaging tools
├── examples/              # Example configurations
└── templates/             # Template files
```

## Getting Started

See [docs/getting-started/installation.md](docs/getting-started/installation.md) for installation instructions.

## Contributing

Please read our [docs/development/contributing.md](docs/development/contributing.md) for detailed guidelines on contributing to this project.

## License

[Insert license information here]
EOL

# Create README for src directory
> src/README.md
cat << 'EOL' >> src/README.md
# Source Code Organization

This directory contains the main source code for the Pipe Network POP Node Management Tool.

## Directory Structure

```
src/
├── community/         # Community-specific features
├── core/              # Core functionality
├── fleet/             # Fleet management
├── installer/         # Installation tools
├── monitoring/        # Monitoring system
├── python_ui/         # Python-based UI
├── ui/               # Web UI
└── utils/            # Utility functions
```

## Development Guidelines

1. **Branch Structure**
   - `main`: Stable releases
   - `develop`: Active development
   - `feature/*`: Feature branches
   - `hotfix/*`: Hotfix branches

2. **Commit Messages**
   Follow conventional commits format:
   - `feat`: New features
   - `fix`: Bug fixes
   - `docs`: Documentation changes
   - `style`: Code style changes
   - `refactor`: Code refactoring
   - `test`: Adding missing tests
   - `chore`: Maintenance tasks

3. **Pull Requests**
   - Create PRs from feature branches to `develop`
   - Include clear description of changes
   - Link to relevant issues
   - Ensure tests pass
EOL

# Create README for docs directory
> docs/README.md
cat << 'EOL' >> docs/README.md
# Documentation

This directory contains all documentation for the Pipe Network POP Node Management Tool.

## Directory Structure

```
docs/
├── official/          # Official Pipe Network documentation
├── community/         # Community-specific documentation
├── getting-started/   # New user guides
└── development/       # Developer documentation
```

## Contributing to Documentation

1. **Documentation Standards**
   - Use markdown format
   - Keep files concise and focused
   - Include examples where applicable

2. **File Naming**
   - Use lowercase with hyphens
   - Be descriptive but concise

3. **Structure**
   - Each major topic gets its own directory
   - Related content is grouped together
EOL

# Create getting-started guides
> docs/getting-started/installation.md
cat << 'EOL' >> docs/getting-started/installation.md
# Installation Guide

## Prerequisites

- Ubuntu 20.04 or later
- Python 3.8 or later
- Node.js 14 or later

## Installation

### Using DEB Package

1. Download the latest DEB package:
```bash
curl -O https://example.com/pipe-pop_latest.deb
```

2. Install the package:
```bash
sudo dpkg -i pipe-pop_latest.deb
```

3. Start the service:
```bash
sudo systemctl start pipe-pop
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/preterag/ppn.git
```

2. Install dependencies:
```bash
cd pipe-pop
./scripts/install.sh
```

3. Configure the service:
```bash
./src/config/config.sh
```

4. Start the service:
```bash
./scripts/install.sh start
```
EOL

# Create contributing guide
> docs/development/contributing.md
cat << 'EOL' >> docs/development/contributing.md
# Contributing Guide

Thank you for considering contributing to the Pipe Network POP Node Management Tool!

## How to Contribute

1. **Fork the Repository**
   - Click the "Fork" button on GitHub
   - Clone your fork locally

2. **Create a Feature Branch**
   ```bash
git checkout -b feature/your-feature-name
```

3. **Make Your Changes**
   - Follow the code style guidelines
   - Write tests for new features
   - Update documentation

4. **Commit Your Changes**
   ```bash
git commit -m "feat: your feature description"
```

5. **Push Your Changes**
   ```bash
git push origin feature/your-feature-name
```

6. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

## Code Style

1. **Naming Conventions**
   - Use lowercase with underscores for variable names
   - Use camelCase for function names
   - Use PascalCase for class names

2. **Documentation**
   - Document all public functions
   - Include examples where applicable
   - Keep comments concise and clear

3. **Testing**
   - Write tests for new features
   - Ensure existing tests pass
   - Use descriptive test names
EOL

echo "Repository reorganization complete!"
echo "Don't forget to commit the changes:"
