# Release Notes: PipeNetwork v1.0.0

## New Repository Structure

We've completely reorganized the repository for better user experience:

### Core Components
- Simplified entry point with `START_HERE.md` and one-command `INSTALL` script
- Intuitive directory structure focused on user needs
- Global `pop` command for all node management

### Documentation
- New user-friendly guides for installation, wallet setup, security, and earning
- Technical reference for configuration, CLI commands, and troubleshooting
- Concise, readable formatting throughout

### Security Enhancements
- Clear security best practices
- Template-based configuration to avoid exposing sensitive data
- Improved backup and recovery tools

## Upgrade Instructions

For existing users:

1. Backup your node:
   ```
   pop backup
   ```

2. Install the new version:
   ```
   sudo ./INSTALL
   ```

3. Restore your wallet:
   ```
   sudo pop wallet set YOUR_WALLET_ADDRESS
   ``` 