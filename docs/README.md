# Pipe Network PoP Documentation

This directory contains comprehensive documentation for the Pipe Network PoP Node Management Tools.

## Documentation Structure

### [Official Documentation](official/)
- **[PIPE_NETWORK_DOCUMENTATION.md](official/PIPE_NETWORK_DOCUMENTATION.md)**: The official Pipe Network technical documentation provided by the core team.

### [User Guides](guides/)
- **[installation.md](guides/installation.md)**: Complete installation guide with system and user-level options
- **[quick-start.md](guides/quick-start.md)**: Step-by-step guide to get started with your node
- **[node-registration.md](guides/node-registration.md)**: How to register your node with the Pipe Network
- **[port-forwarding.md](guides/port-forwarding.md)**: Setting up port forwarding for optimal performance
- **[wallet-setup.md](guides/wallet-setup.md)**: Setting up a wallet for your Pipe Network node
- **[fleet-management.md](guides/fleet-management.md)**: Managing multiple nodes as a fleet

### [Reference](reference/)
- **[cli.md](reference/cli.md)**: Complete reference for all available commands
- **[troubleshooting.md](reference/troubleshooting.md)**: Technical troubleshooting guide
- **[config.md](reference/config.md)**: Configuration options and formats

### [Development](development/)
- **[architecture.md](development/architecture.md)**: Architectural overview of the PoP Node Management Tools
- **[code_structure.md](development/code_structure.md)**: Code organization and module descriptions
- **[roadmap.md](development/roadmap.md)**: Development roadmap and feature timeline

## Reading Order for New Users

1. Start with the **[installation.md](guides/installation.md)** guide to set up your node
2. Continue with the **[quick-start.md](guides/quick-start.md)** guide to get started quickly
3. Read **[node-registration.md](guides/node-registration.md)** to ensure proper registration
4. Follow **[port-forwarding.md](guides/port-forwarding.md)** to optimize connectivity
5. Refer to **[cli.md](reference/cli.md)** as needed for specific commands
6. If you encounter issues, check **[troubleshooting.md](reference/troubleshooting.md)**

## Key Features

- **Dual Command Format**: Supports both flag-based commands (`pop --command`) and traditional format (`pop command`)
- **Installation Options**: System-wide or user-level installation to accommodate different environments
- **Privilege Management**: Minimized sudo requirements with command-specific fallbacks
- **Intelligent Fallbacks**: Graceful degradation when privileges are unavailable
- **User Documentation**: Complete guides covering all aspects of node operation

## Reading Order for Developers

1. Review the **[architecture.md](development/architecture.md)** document
2. Understand the code organization in **[code_structure.md](development/code_structure.md)**
3. Check the current status and plans in **[roadmap.md](development/roadmap.md)**
4. Reference the **[cli.md](reference/cli.md)** for implementation details

## Contributing to Documentation

When contributing to the documentation:

1. Follow the established directory structure
2. Use Markdown for all documentation files
3. Include code examples where appropriate
4. Maintain cross-references between related documents
5. Keep the official documentation in the `official/` directory unchanged

## Documentation Standards

- Use heading levels appropriately (# for title, ## for sections, etc.)
- Include a table of contents for longer documents
- Provide examples for commands and configuration
- Use code blocks with appropriate language tags
- Keep explanations clear and concise
- Include troubleshooting tips where applicable 