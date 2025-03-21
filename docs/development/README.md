# Developer Documentation

This directory contains documentation intended for developers who want to contribute to the Pipe Network Community Tools project.

## Development Setup

To set up your development environment:

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/pipe-pop.git`
3. Run the dev setup: `./scripts/dev_workflow.sh setup`

## Development Workflow

The repository uses a structured development workflow:

1. Create a new branch for your feature: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Run tests: `./scripts/dev_workflow.sh test`
4. Submit a pull request

## Directory Structure

- `/src` - Core source code
- `/scripts` - Installation and utility scripts
- `/docs` - Documentation
  - `/docs/guides` - User-facing guides
  - `/docs/reference` - Reference documentation
  - `/docs/development` - Developer documentation
  - `/docs/official` - Official Pipe Network documentation

## Operational vs. Core Files

When developing for this project, it's important to understand the distinction between:

1. **Core Files**: The essential files that are part of the GitHub repository
2. **Operational Files**: Files generated during operation (config files, logs, etc.)

Please ensure that any operational files are properly excluded from Git via the `.gitignore` file.

## Utility Scripts

The repository contains several utility scripts in the root directory:

- `port_check.sh` - Checks port forwarding configuration
- `enable_ports.sh` - Configures port forwarding
- `fix_node_registration.sh` - Fixes node registration issues
- And others...

These scripts are part of the repository and are designed to help users troubleshoot common issues.

## Documentation Guidelines

When adding new features:

1. Update or create user-facing documentation in `/docs/guides`
2. Add technical details to `/docs/reference`
3. Update this developer documentation as needed

## Pull Request Guidelines

Before submitting a pull request:

1. Ensure your code follows the project's coding standards
2. Add appropriate tests
3. Update documentation
4. Ensure the `.gitignore` file excludes any operational files 