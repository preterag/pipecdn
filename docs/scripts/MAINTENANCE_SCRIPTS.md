# 🛠️ Maintenance Scripts

This document describes the maintenance scripts available in the Pipe Network PoP repository.

## Cleanup Scripts

### cleanup.sh

The `cleanup.sh` script is used to clean up backup files and other unnecessary files in the repository.

**Features:**
- Removes `.bak` files
- Removes generated dashboard HTML files
- Provides a summary of removed files

**Usage:**
```bash
./cleanup.sh
```

### organize_docs.sh

The `organize_docs.sh` script helps organize documentation files by moving them to the appropriate directories in the `docs` folder.

**Features:**
- Creates necessary documentation directories
- Moves naming-related documentation to `docs/naming/`
- Identifies other documentation files in the root directory
- Lists scripts with their descriptions

**Usage:**
```bash
./organize_docs.sh
```

## Naming Scripts

### update_naming.sh

The `update_naming.sh` script updates naming conventions throughout the codebase.

**Features:**
- Finds and replaces instances of old naming conventions
- Makes backups of modified files
- Provides a summary of changes

**Usage:**
```bash
sudo ./update_naming.sh
```

### fix_naming.sh

The `fix_naming.sh` script fixes specific naming issues in the codebase.

**Usage:**
```bash
./fix_naming.sh
```

## Service Scripts

### update_service.sh

The `update_service.sh` script updates the pipe-pop service configuration.

**Usage:**
```bash
sudo ./update_service.sh
```

### start_pipe_pop.sh

The `start_pipe_pop.sh` script starts the pipe-pop service.

**Usage:**
```bash
./start_pipe_pop.sh
```

## Distribution Scripts

### setup_distribution.sh

The `setup_distribution.sh` script sets up distribution channels for pipe-pop packages.

**Features:**
- Sets up GitHub releases
- Sets up APT repository
- Sets up YUM repository
- Sets up website downloads

**Usage:**
```bash
# Set up all distribution channels
./setup_distribution.sh setup-all

# Set up specific channels
./setup_distribution.sh setup-github
./setup_distribution.sh setup-apt
./setup_distribution.sh setup-yum
./setup_distribution.sh setup-website

# Update channels with a new version
./setup_distribution.sh update-apt 1.0.0
./setup_distribution.sh update-yum 1.0.0
./setup_distribution.sh update-website 1.0.0

# Upload to servers
./setup_distribution.sh upload-all
```

## Best Practices

1. Always run cleanup scripts before committing changes to keep the repository clean
2. Use the organize_docs.sh script to ensure documentation is properly organized
3. Keep scripts up to date with the latest naming conventions
4. Document any new scripts in this file 