#!/bin/bash

# cleanup.sh - Script to clean up backup files and other unnecessary files
# Created: $(date)

echo "🧹 Cleaning up backup files and other unnecessary files..."

# Count files before cleanup
TOTAL_BAK_FILES=$(find . -name "*.bak" | wc -l)
TOTAL_DASHBOARD_FILES=$(find . -name "pipe_network_dashboard_*.html" | wc -l)

echo "Found $TOTAL_BAK_FILES .bak files and $TOTAL_DASHBOARD_FILES dashboard HTML files"

# Ask for confirmation
read -p "Do you want to proceed with cleanup? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Remove .bak files
echo "Removing .bak files..."
find . -name "*.bak" -print -delete

# Remove dashboard HTML files
echo "Removing dashboard HTML files..."
find . -name "pipe_network_dashboard_*.html" -print -delete

# Count files after cleanup
REMAINING_BAK_FILES=$(find . -name "*.bak" | wc -l)
REMAINING_DASHBOARD_FILES=$(find . -name "pipe_network_dashboard_*.html" | wc -l)

echo "✅ Cleanup complete!"
echo "Removed $(($TOTAL_BAK_FILES - $REMAINING_BAK_FILES)) .bak files"
echo "Removed $(($TOTAL_DASHBOARD_FILES - $REMAINING_DASHBOARD_FILES)) dashboard HTML files"

echo "You may want to commit these changes with:"
echo "git add .gitignore docs/naming/NAMING_CONVENTION.md docs/naming/NAMING_UPDATE_SUMMARY.md docs/AUTHENTICATION.md docs/DISTRIBUTION.md docs/articles/ppn_implementation_v1.0.md"
echo "git commit -m \"🧹 Clean up repository and organize documentation\""
echo "git push" 