#!/bin/bash

# organize_docs.sh - Script to organize documentation files by moving them to the docs directory
# Created: $(date)

echo "📚 Organizing documentation files..."

# Create necessary directories
mkdir -p docs/naming
mkdir -p docs/scripts
mkdir -p docs/services
mkdir -p docs/installation

# Move naming-related documentation
if [ -f NAMING_CONVENTION.md ]; then
    echo "Moving NAMING_CONVENTION.md to docs/naming/"
    cp NAMING_CONVENTION.md docs/naming/
fi

if [ -f NAMING_UPDATE_SUMMARY.md ]; then
    echo "Moving NAMING_UPDATE_SUMMARY.md to docs/naming/"
    cp NAMING_UPDATE_SUMMARY.md docs/naming/
fi

# Check for other documentation files in the root directory
for file in *.md; do
    if [ "$file" != "README.md" ] && [ -f "$file" ]; then
        echo "Found documentation file in root directory: $file"
        echo "Consider moving it to the appropriate docs subdirectory"
    fi
done

# Check for script documentation
for script in *.sh; do
    if [ -f "$script" ]; then
        # Extract the first line of comments from the script
        DESCRIPTION=$(grep -m 1 "^# " "$script" | sed 's/^# //')
        if [ ! -z "$DESCRIPTION" ]; then
            echo "Script: $script - $DESCRIPTION"
        else
            echo "Script: $script - No description found"
        fi
    fi
done

echo "✅ Documentation organization complete!"
echo ""
echo "You may want to commit these changes with:"
echo "git add docs/"
echo "git commit -m \"📚 Organize documentation files\""
echo "git push"
echo ""
echo "Remember to update references to moved documentation files in your code and other documentation." 