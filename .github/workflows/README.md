# GitHub Actions Workflows

This directory contains GitHub Actions workflow files for automating various tasks in the ppn repository.

## Available Workflows

### 1. `release.yml`

This workflow automates the release process for the ppn repository. It is triggered when a new tag with the format `v*` is pushed to the repository.

**Features:**
- Automatically builds release packages (AppImage, DEB, RPM, and source tarball)
- Creates a GitHub release
- Uploads all packages as release assets

## Token Requirements

To use these workflows, your GitHub Personal Access Token (PAT) must have the `workflow` scope enabled. Without this scope, you will encounter the following error when trying to push workflow files:

```
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
remote: refusing to allow a Personal Access Token to create or update workflow `.github/workflows/release.yml` without `workflow` scope
error: failed to push some refs to 'https://github.com/preterag/ppn.git'
```

### How to Update Your Token

1. Go to GitHub: https://github.com/settings/tokens
2. Create a new token or regenerate an existing one
3. Make sure to check the `workflow` scope
4. Save the token and update your local Git credentials

## Usage

To create a new release:

1. Tag your release:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   ```

2. Push the tag:
   ```bash
   git push origin v1.0.0
   ```

3. The workflow will automatically run and create a release with all packages. 