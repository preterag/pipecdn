#!/bin/bash
# 🚀 Pipe PoP Node Release Script
# This script helps create and publish new releases

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if version is provided
if [ $# -ne 1 ]; then
    print_error "Usage: $0 <version>"
    echo "Example: $0 1.1.0"
    exit 1
fi

VERSION=$1

# Validate version format (X.Y.Z)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format. Please use X.Y.Z (e.g., 1.1.0)"
    exit 1
fi

# Check if we're on the development branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "development" ]; then
    print_warning "You are not on the development branch. Current branch: $CURRENT_BRANCH"
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        print_message "Aborting release process."
        exit 0
    fi
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes."
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        print_message "Aborting release process."
        exit 0
    fi
fi

print_header "🚀 Creating release v$VERSION"

# Update VERSION file
print_message "Updating VERSION file..."
echo "$VERSION" > VERSION

# Update version in README.md
print_message "Updating version in README.md..."
sed -i "s/Current version: \*\*v[0-9]\+\.[0-9]\+\.[0-9]\+\*\*/Current version: \*\*v$VERSION\*\*/" README.md

# Update version in VERSION.md
print_message "Updating version in docs/VERSION.md..."
sed -i "s/- \*\*v[0-9]\+\.[0-9]\+\.[0-9]\+\*\*: Initial stable release/- \*\*v$VERSION\*\*: Latest release/" docs/VERSION.md

# Commit changes
print_message "Committing changes..."
git add VERSION README.md docs/VERSION.md
git commit -m "🔖 Bump version to $VERSION"

# Create release candidate tag
RC_TAG="v${VERSION}-rc1"
print_message "Creating release candidate tag $RC_TAG..."
git tag -a "$RC_TAG" -m "Release candidate 1 for version $VERSION"

# Push changes and tag
print_message "Pushing changes and tag to development branch..."
git push origin development
git push origin "$RC_TAG"

print_header "🧪 Testing Phase"
print_message "Please test the release candidate thoroughly."
print_message "When ready to release, run the following commands:"
echo ""
echo "  # Merge to master"
echo "  git checkout master"
echo "  git merge development"
echo ""
echo "  # Create version tag"
echo "  git tag -a v$VERSION -m \"Version $VERSION\""
echo ""
echo "  # Push changes and tag"
echo "  git push origin master"
echo "  git push origin v$VERSION"
echo ""
echo "  # Switch back to development"
echo "  git checkout development"
echo ""

print_header "✅ Release candidate created successfully!"
print_message "RC Tag: $RC_TAG"
print_message "Version: $VERSION" 