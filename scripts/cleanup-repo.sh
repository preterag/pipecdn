#!/bin/bash

# Ensure we're in the correct directory
cd "$(dirname "$0")/.." || exit 1

# Remove outdated files
echo "Removing outdated files..."

# Remove old script versions
rm -f fixed_pop_script.sh new_pop_script.sh

# Remove old monitoring scripts
rm -f dashboard.sh port_check.sh double_nat_test.sh external_port_test.sh
rm -f fix_node_registration.sh manual_test.sh manual_test_fixed.sh
rm -f enable_ports.sh privileged_port_fix.sh

# Remove old service files
rm -f new-pipe-pop.service pipe-pop.service updated-pipe-pop.service

# Remove old node registration scripts
rm -f register_node.sh new_node_registration.sh

# Remove old root service script
rm -f root_service.sh

# Remove old version file
rm -f VERSION

# Remove old changelog and release files
rm -f CHANGELOG.md RELEASE_CHECKLIST.md RELEASE_NOTES.md

# Remove old community enhancements file
rm -f COMMUNITY_ENHANCEMENTS.md

# Remove old feature mapping file
rm -f FEATURE_MAPPING.md

# Remove old installation file
rm -f INSTALL

# Remove old start guide
rm -f START_HERE.md

# Remove old node info
rm -f node_info.json

# Remove old configuration
rm -f config_fixed.json

# Remove old monitoring directory if empty
rmdir monitoring 2>/dev/null

# Remove old bin directory contents (except pipe-pop)
echo "Cleaning bin directory..."
cd bin || exit 1
rm -f README.md pop version.txt
rm -f pipe-pop 2>/dev/null

# Remove old backup files
echo "Cleaning backup files..."
find . -name "*.bak" -delete
find . -name "*.old" -delete
find . -name "*.orig" -delete

# Remove temporary files
echo "Cleaning temporary files..."
find . -name "*.tmp" -delete
find . -name "*.swp" -delete
find . -name "*.swo" -delete

# Remove swap files
echo "Cleaning swap files..."
find . -name "*.swp" -delete
find . -name "*.swo" -delete

# Remove backup directories
echo "Cleaning backup directories..."
rm -rf backups/

# Remove cache directories
echo "Cleaning cache directories..."
rm -rf cache/

# Remove data directories
echo "Cleaning data directories..."
rm -rf data/

# Remove log directories
echo "Cleaning log directories..."
rm -rf logs/

# Remove temporary directories
echo "Cleaning temporary directories..."
rm -rf tmp/

# Remove build artifacts
echo "Cleaning build artifacts..."
rm -rf build/

# Remove Python cache
echo "Cleaning Python cache..."
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.py[cod]" -delete

# Remove Node.js cache
echo "Cleaning Node.js cache..."
rm -rf node_modules/

# Remove Python virtual environments
echo "Cleaning Python virtual environments..."
rm -rf venv/ .venv/ env/ .env/

# Remove Python build files
echo "Cleaning Python build files..."
rm -rf dist/ build/ *.egg-info/

# Clean git
echo "Cleaning git..."
rm -rf .git/

# Initialize new git repository
git init

# Add gitignore
git add .gitignore

# Add all files
git add .

# Commit initial state
git commit -m "Initial commit: Clean repository structure"

# Create develop branch
git branch develop

# Switch to develop branch
git checkout develop

echo "Repository cleanup complete!"
echo "You can now push to your remote repository:"
