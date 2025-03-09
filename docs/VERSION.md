# 🔄 Versioning Strategy

## 📋 Overview

This document outlines the versioning strategy for the Pipe PoP Node Management Tools. We follow [Semantic Versioning](https://semver.org/) to ensure clear communication about changes and compatibility.

## 🏷️ Version Numbering

We use the format **MAJOR.MINOR.PATCH** (e.g., 1.2.3):

- 🔴 **MAJOR version (X.0.0)**: Incremented for incompatible API changes or significant architectural changes
- 🟠 **MINOR version (0.X.0)**: Incremented for new functionality added in a backward compatible manner
- 🟢 **PATCH version (0.0.X)**: Incremented for backward compatible bug fixes

## 🌿 Branch Strategy

Our repository uses the following branch structure:

- 🚀 **master**: Production-ready code, stable releases only
- 🔧 **development**: Active development branch, features and fixes
- 🧩 **feature/xxx**: Feature-specific branches that merge into development
- 🐛 **bugfix/xxx**: Bug fix branches that merge into development

## 📦 Release Process

### 1️⃣ Development Phase

- All new features and non-critical fixes are developed in the `development` branch
- Feature branches are created from and merged back to `development`
- Code in `development` may be unstable or incomplete

```bash
# Create a feature branch
git checkout development
git checkout -b feature/new-feature

# Work on the feature...

# Merge back to development
git checkout development
git merge feature/new-feature
```

### 2️⃣ Stabilization Phase

- When ready for release, code is frozen in `development`
- Testing and bug fixing occurs in `development`
- Release candidate tags are created (e.g., `v1.2.0-rc1`)

```bash
# Create a release candidate tag
git tag -a v1.2.0-rc1 -m "Release candidate 1 for version 1.2.0"
git push origin v1.2.0-rc1
```

### 3️⃣ Release Phase

- When stable, `development` is merged into `master`
- A version tag is created in `master` (e.g., `v1.2.0`)
- Release notes are generated
- Packages are built and published

```bash
# Merge to master
git checkout master
git merge development

# Create version tag
git tag -a v1.2.0 -m "Version 1.2.0"
git push origin v1.2.0
git push origin master
```

### 4️⃣ Post-Release

- Critical bug fixes may be applied directly to `master` with patch version increments
- These fixes are also merged back to `development`

```bash
# Fix critical bug in master
git checkout master
git checkout -b hotfix/critical-bug

# Work on the fix...

# Merge to master
git checkout master
git merge hotfix/critical-bug

# Create patch version tag
git tag -a v1.2.1 -m "Version 1.2.1"
git push origin v1.2.1
git push origin master

# Merge back to development
git checkout development
git merge hotfix/critical-bug
git push origin development
```

## 📝 Version History

### Current Version

- **v1.0.0**: Initial stable release with dashboard and global command features
  - Comprehensive dashboard for unified monitoring
  - Global command for easier access
  - Detailed uptime tracking
  - Historical data visualization
  - HTML export functionality

### Previous Versions

- **v0.9.0**: Beta release with core functionality
- **v0.5.0**: Alpha release for testing

## 📋 Version File

The current version is stored in the `VERSION` file at the root of the repository. This file contains only the version number (e.g., `1.0.0`).

## 🔄 Updating the Version

When releasing a new version:

1. Update the `VERSION` file with the new version number
2. Update the version in the README.md file
3. Update the VERSION.md file with the new version details
4. Create a git tag for the new version
5. Push the changes and tag to the repository

```bash
# Example for releasing version 1.1.0
echo "1.1.0" > VERSION
git add VERSION README.md docs/VERSION.md
git commit -m "Bump version to 1.1.0"
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin master
git push origin v1.1.0
```

## 📊 Version Check

Users can check the current version using:

```bash
pop --version
```

This command displays the version number from the `VERSION` file. 