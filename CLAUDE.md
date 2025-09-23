# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub organization repository providing centralized GitHub Actions and workflow templates for Dedi Agency deployments. It contains reusable composite actions for deploying Sylius e-commerce and WordPress/Bedrock applications with atomic deployment strategies.

## Repository Architecture

### Actions Structure
- **`actions/deploy/sylius/`** - Sylius deployment action with independent versioning
- **`actions/deploy/wordpress/`** - WordPress/Bedrock deployment action with independent versioning
- **`actions/deploy/shared/lib/`** - Common bash libraries shared between both actions
- **`workflow-templates/`** - Ready-to-use workflow templates for projects

### Shared Library Components (`actions/deploy/shared/lib/`)
- **`config.sh`** - Base configuration and environment variable management
- **`runtime.sh`** - Core deployment logic with atomic releases and rollback
- **`utils.sh`** - Utility functions (retry, timeout, health checks, logging, dry-run)
- **`deps.sh`** - Dependency checking and JSON parsing
- **`commands.sh`** - Console command execution and service management
- **`shared.sh`** - Shared directory and file management

### Deployment Architecture
Each action implements atomic deployment using:
1. **Timestamped releases** in `$DEPLOY_PATH/releases/YYYYMMDDHHMMSS/`
2. **Shared resources** via symlinks from `$DEPLOY_PATH/shared/`
3. **Current symlink** pointing to active release
4. **Automatic rollback** on failure with previous release restoration

## Development Commands

### Installing Dependencies
```bash
# Install semantic-release dependencies
npm install
```

### Testing Semantic Release
```bash
# Dry run to see what would be released
npx semantic-release --dry-run
```

## Versioning and Releases

### Unified Versioning System
The repository uses a single version for all actions with semantic-release automation:
- **Single version**: Tagged as `vX.Y.Z` (e.g., v1.2.3)
- **Actions reference**: Use `@v1`, `@v1.2`, or `@v1.2.3` in workflows
- **Automatic releases**: Triggered on every push to master with conventional commits

### Commit Message Format
Follow Conventional Commits for automatic versioning:
```bash
feat: add new deployment feature         # Minor version bump (0.1.0 → 0.2.0)
fix: correct rollback behavior          # Patch version bump (0.1.0 → 0.1.1)
perf: improve deployment speed           # Patch version bump
docs: update README                      # No version bump
chore: update dependencies               # No version bump
feat!: breaking change in API           # Major version bump (0.1.0 → 1.0.0)
```

## Action Configuration

### Platform-Specific Defaults
Each action applies intelligent defaults in `actions/deploy/{platform}/lib/config.sh`:
- **Sylius**: Database operations, cache commands, asset building with npm
- **WordPress**: Minimal defaults, no automatic database operations

### Key Features
- **Automatic rollback** on deployment failure
- **Health checks** before finalizing deployment
- **Retry mechanisms** with exponential backoff for network operations
- **Timeout support** for long-running operations
- **Dry-run mode** for deployment simulation (`dry_run: true`)
- **Structured logging** with timestamps
- **Configurable permissions** (chmod or setfacl)

### Deployment Flow
1. **Preparation**: Check dependencies, create directory structure
2. **Repository**: Clone target branch with retry mechanism
3. **Dependencies**: Install PHP (Composer) and Node.js dependencies with timeout
4. **Build**: Execute npm build commands if configured
5. **Shared Resources**: Create symlinks to shared directories and files
6. **Database/Cache**: Run platform-specific commands
7. **Health Check**: Verify deployment health before activation
8. **Activation**: Atomically switch symlink to new release
9. **Cleanup**: Remove old releases, reload services

## Usage Examples

### Direct Action Usage
```yaml
- name: Deploy Sylius
  uses: dediagency/.github/actions/deploy/sylius@v1
  with:
    ssh_host: preprod.dediagency.net
    ssh_username: project-sylius
    ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
    environment: recette
    branch: env/recette
    dry_run: false
```

### Key Parameters
- **Required**: `ssh_host`, `ssh_username`, `ssh_private_key`, `environment`, `branch`
- **Intelligent defaults**: `deploy_path`, `site_url`, `app_env` based on environment and username
- **Platform defaults**: Database operations, shared directories/files, build commands
- **Optional**: All binaries paths, permissions, custom commands

## Error Handling and Debugging

### Rollback Mechanism
On deployment failure, the system automatically:
1. Removes the failed release directory
2. Restores the previous release symlink
3. Reloads services with the previous version
4. Logs detailed error information

### Health Checks
Before finalizing deployment, the system performs HTTP health checks on `site_url` to ensure the application is responding correctly.

### Dry-Run Mode
Use `dry_run: true` to simulate deployments without making actual changes. This categorizes operations as READ/WRITE/DESTRUCTIVE and shows what would be executed.