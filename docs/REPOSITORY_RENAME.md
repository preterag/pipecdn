# Repository Rename Recommendations

## Overview

This document outlines recommendations for renaming the repository before public release. A well-chosen repository name is crucial for discoverability, branding, and conveying the purpose of the project.

## Current Repository Name

The current repository name is `pipecdn`, which is hosted at `https://github.com/preterag/pipecdn`.

## Rename Considerations

When renaming a repository, consider the following factors:

1. **Branding Alignment**: The name should align with the Pipe Network branding.
2. **Descriptiveness**: The name should clearly indicate the purpose of the repository.
3. **Discoverability**: The name should be easily searchable and memorable.
4. **Uniqueness**: The name should be unique enough to avoid confusion with other projects.
5. **Brevity**: The name should be concise while still being descriptive.
6. **URL-Friendliness**: The name should work well as part of a URL.

## Recommended Names

Here are some recommended names for the repository, along with their rationales:

### 1. `pipe-pop-node`

- **Rationale**: Directly describes the project as a Pipe Point of Presence (PoP) node.
- **Pros**: Clear, descriptive, aligns with current documentation.
- **Cons**: Slightly longer than the current name.

### 2. `pipe-node`

- **Rationale**: Simpler version that still conveys the purpose.
- **Pros**: Shorter, easier to remember.
- **Cons**: Less specific about the PoP aspect.

### 3. `pipe-cdn-node`

- **Rationale**: Emphasizes the CDN aspect of the Pipe Network.
- **Pros**: Clearly indicates the CDN functionality.
- **Cons**: Might be confused with other CDN projects.

### 4. `pipe-network-node`

- **Rationale**: Explicitly includes "network" to emphasize the decentralized network aspect.
- **Pros**: Comprehensive description of the project.
- **Cons**: Longer name.

## Primary Recommendation

Based on the considerations above, the primary recommendation is to rename the repository to:

**`pipe-pop-node`**

This name:
- Clearly describes the project as a Pipe PoP node
- Aligns with the terminology used in the documentation
- Is specific enough to avoid confusion with other projects
- Is reasonably concise while still being descriptive

## Implementation Plan

To rename the repository:

1. **Backup**: Create a full backup of the repository, including all branches, tags, and releases.
2. **Update References**: Update all internal references to the repository name in documentation, scripts, and code.
3. **Rename on GitHub**: Use GitHub's repository settings to rename the repository.
4. **Update Remote URLs**: Update remote URLs in local clones of the repository.
5. **Redirect Setup**: Ensure GitHub's automatic redirects are working correctly.
6. **Announce Change**: Inform users and contributors about the name change.

## Code Changes Required

The following files will need to be updated with the new repository name:

1. **README.md**: Update all references to the repository name and URLs.
2. **Installation scripts**: Update any hardcoded repository URLs.
3. **Documentation**: Update repository references in all documentation files.
4. **GitHub Actions workflows**: Update repository references in workflow files.

## Timeline

The repository rename should be completed before the public release of version 1.0.0. Here's a suggested timeline:

1. **Day 1**: Backup repository and update internal references.
2. **Day 2**: Perform the rename on GitHub and verify redirects.
3. **Day 3**: Test all functionality to ensure the rename didn't break anything.
4. **Day 4**: Announce the rename to users and contributors.

## Conclusion

Renaming the repository to `pipe-pop-node` will improve clarity, discoverability, and branding alignment. The rename should be carefully planned and executed to minimize disruption to users and contributors. 