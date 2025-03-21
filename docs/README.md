# Pipe Network PoP Node Management Tools Documentation

This directory contains the documentation for the Pipe Network PoP Node Management Tools. This is a community-developed enhancement to the official Pipe Network tools provided by the core team.

## Community Enhancement

This documentation and the associated tools represent community work that builds upon and extends the official Pipe Network implementation. We aim to provide additional features, improved usability, and comprehensive documentation to support the broader Pipe Network ecosystem.

## Documentation Structure

The documentation is organized into the following sections:

### User Guides

- [`guides/installation.md`](guides/installation.md) - Complete guide for installing the tools (system and user-level options)
- [`guides/quick_start.md`](guides/quick_start.md) - Get started quickly with a new node
- [`guides/fleet_management.md`](guides/fleet_management.md) - Managing multiple nodes with the Fleet System
- [`guides/node_registration.md`](guides/node_registration.md) - How to register your node
- [`guides/port_forwarding.md`](guides/port_forwarding.md) - How to configure port forwarding
- [`guides/wallet_setup.md`](guides/wallet_setup.md) - Setting up a wallet for your node
- [`guides/security.md`](guides/security.md) - Security best practices
- [`guides/earning.md`](guides/earning.md) - Learn about earning rewards
- [`guides/web_ui.md`](guides/web_ui.md) - Using the Web UI for node management

### Reference

- [`reference/cli.md`](reference/cli.md) - Complete command line reference
- [`reference/configuration.md`](reference/configuration.md) - Configuration file format and options
- [`reference/troubleshooting.md`](reference/troubleshooting.md) - Common issues and solutions
- [`reference/glossary.md`](reference/glossary.md) - Terminology used in the project
- [`reference/api.md`](reference/api.md) - Web UI API reference for developers

### Development

- [`development/architecture.md`](development/architecture.md) - System design and architecture
- [`development/code_structure.md`](development/code_structure.md) - Code organization and module descriptions
- [`development/contributing.md`](development/contributing.md) - How to contribute to the project
- [`development/testing.md`](development/testing.md) - Testing procedures and guidelines
- [`development/design/web_ui_prd.md`](development/design/web_ui_prd.md) - Web UI Product Requirements Document
- [`development/ui_customization.md`](development/ui_customization.md) - Customizing the Web UI

## Reading Order for New Users

If you're new to the Pipe Network, we recommend reading the documentation in this order:

1. [Installation Guide](guides/installation.md)
2. [Quick Start Guide](guides/quick_start.md)
3. [Node Registration](guides/node_registration.md)
4. [Port Forwarding](guides/port_forwarding.md)
5. [Wallet Setup](guides/wallet_setup.md)
6. [Web UI Guide](guides/web_ui.md) (for graphical management)
7. [CLI Reference](reference/cli.md) (for command-line management)
8. [Troubleshooting](reference/troubleshooting.md)
9. [Fleet Management](guides/fleet_management.md) (for managing multiple nodes)

## Key Features

- **Dual Command Formats**: Support for both `--flag` style and subcommand style
- **Installation Options**: System-wide and user-level installation choices
- **Privilege Management**: Intelligent falling back to user privileges when needed
- **Fleet Management**: Tools for managing multiple nodes from a single location
- **Web User Interface**: Browser-based management with installation wizard
- **Comprehensive Documentation**: Detailed guides and references for various user roles

## Reading Order for Developers

If you're a developer looking to contribute, we recommend this reading order:

1. [Architecture](development/architecture.md)
2. [Code Structure](development/code_structure.md)
3. [CLI Reference](reference/cli.md)
4. [Web UI PRD](development/design/web_ui_prd.md)
5. [API Reference](reference/api.md)
6. [UI Customization](development/ui_customization.md)
7. [Contributing Guidelines](development/contributing.md)
8. [Testing Guidelines](development/testing.md)

## Contributing to Documentation

We welcome contributions to improve this documentation. Please follow these guidelines:

1. Keep language simple and clear
2. Update the relevant sections when adding new features
3. Provide examples for complex concepts
4. Follow the established documentation format
5. Submit a pull request with your changes

## Documentation Standards

- Use Markdown for all documentation
- Use relative links to reference other documentation files
- Include code examples using fenced code blocks with language specification
- Document all commands, options, and configuration settings
- Keep documentation up-to-date with the code 