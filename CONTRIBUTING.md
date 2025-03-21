# Contributing to PipeNetwork Toolkit

Thank you for your interest in contributing to the PipeNetwork Toolkit! This document provides guidelines and workflows to ensure smooth collaboration.

## Development Workflow

### Separating Runtime from Repository

To avoid mixing runtime files with repository code, we use a two-directory approach:

1. **Repository Directory**: Contains the clean codebase that gets pushed to GitHub
2. **Runtime Directory**: Contains the actual running node with all its runtime data

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/[your-username]/pipe-pop.git
cd pipe-pop

# Run the dev workflow script to set up runtime directory
./scripts/dev_workflow.sh
# Select option 1 to sync repository to runtime directory
```

### Making Changes

Always make changes in the runtime directory first to test, then use the workflow script to stage them for commit:

1. Make and test your changes in `~/pipe-pop-runtime/`
2. Use `./scripts/dev_workflow.sh` (option 2) to detect changes and stage them to the repository
3. Review changes with `git diff` before committing

### What to Commit vs. What Not to Commit

**DO Commit:**
- Script improvements/fixes (*.sh)
- Tool enhancements (pop command)
- Documentation updates
- Configuration templates (not actual configs)
- Example files
- Useful utility scripts

**DO NOT Commit:**
- Your personal wallet address
- Node runtime data (cache, logs)
- Private keys or sensitive data
- Large log files or data dumps
- System-specific configuration
- Node_info.json with your node ID
- Database files

## Referral Code Management

We use a single referral code (`6ee148015d530fb0`) for all installations through this toolkit. This allows us to track installations and provide support to users. Please don't modify this code without discussion.

## Code Style

- Use shellcheck for shell scripts
- Indent with 4 spaces
- Include descriptive comments
- Add clear error handling
- Use color-coded output for user feedback

## Testing

Before submitting a pull request:

1. Test your changes with a fresh install
2. Verify that no sensitive data is included
3. Ensure compatibility with supported platforms (Ubuntu 20.04+, Debian 11+)
4. Test all affected features

## Pull Request Process

1. Update documentation reflecting your changes
2. Run the workflow script to ensure clean separation of runtime and repo code
3. Create a pull request with a clear description of changes
4. Reference any related issues

Thank you for contributing to making PipeNetwork easier to use for everyone! 