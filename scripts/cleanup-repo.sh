#!/bin/bash

# Ensure we're in the correct directory
cd "$(dirname "$0")/.." || exit 1

# Remove operational directories
rm -rf logs data cache backups monitoring/data download_cache

# Remove operational files
rm -f config.json node_info.json .pop.env
rm -f new-pipe-pop.service pipe-pop.service updated-pipe-pop.service

# Remove runtime files
rm -f *.pid *.sock *.log .cache/* sample-metrics.json sample-metrics.json.prev

# Clean up Python environment
rm -rf venv .venv env .env

# Clean up build files
rm -rf build dist *.deb *.rpm *.tar.gz *.zip

# Clean up temporary files
rm -f *~ *.swp *.swo

# Clean up Node.js files
rm -f package-lock.json yarn.lock

# Clean up Python cache
find . -name "__pycache__" -type d -exec rm -rf {} +
find . -name "*.py[cod]" -type f -delete
find . -name "*.so" -type f -delete

# Clean up Node.js cache
rm -rf node_modules

# Clean up test files
find . -name "*.test" -type f -delete
find . -name "*.spec" -type f -delete
find . -name "*.tmp" -type f -delete

# Clean up git
rm -rf .git

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
