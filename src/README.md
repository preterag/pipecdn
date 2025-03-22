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
