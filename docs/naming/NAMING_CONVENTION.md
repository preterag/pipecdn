# Naming Convention for Pipe Network PoP Node

This document outlines the naming convention used in this repository for the Pipe Network PoP (Point of Presence) Node.

## Official Naming

The official name for the node binary and service is **pipe-pop**. This name is used consistently throughout the codebase for:

- Binary name: `pipe-pop`
- Service name: `pipe-pop.service`
- Start script: `start_pipe_pop.sh`
- Repository references

## Command Alias

For user convenience, we provide a simplified command alias:

- Command alias: `pop`

This alias provides a user-friendly way to interact with the node while maintaining the official naming in the underlying implementation.

## Terminology

When referring to the node in documentation and comments:

- **Pipe Network PoP Node**: The full, formal name
- **pipe-pop**: The binary/service name (lowercase with hyphen)
- **Pipe-pop**: When used at the beginning of a sentence (title case with hyphen)

## Historical Context

Previously, the node was sometimes referred to as "pipe-pop" (an acronym for Pipe Network PoP Node). To maintain consistency with upstream updates and avoid confusion, we have standardized on using "pipe-pop" throughout the codebase.

## Updating Scripts

If you're developing new scripts or modifying existing ones, please follow these guidelines:

1. Use `pipe-pop` for the binary and service name
2. Use `pop` for the user-facing command
3. Refer to the node as "Pipe Network PoP Node" in documentation
4. Avoid using the acronym "pipe-pop" in new code or documentation

## Automatic Naming Updates

We provide a script to automatically update naming conventions in the codebase:

```bash
sudo ./update_naming.sh
```

This script will find and replace instances of "pipe-pop" with "pipe-pop" throughout the codebase, making backups of modified files.

## Service Management

To manage the pipe-pop service:

```bash
# Start the service
sudo systemctl start pipe-pop.service

# Stop the service
sudo systemctl stop pipe-pop.service

# Check status
sudo systemctl status pipe-pop.service

# View logs
sudo journalctl -u pipe-pop.service -f
``` 