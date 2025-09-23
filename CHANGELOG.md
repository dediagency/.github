# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Semantic release automation with automatic versioning
- Automatic rollback on deployment failure
- Health check verification after deployment
- Retry mechanism with exponential backoff for network operations
- Timeout support for long-running operations
- Dry-run mode for deployment simulation
- Structured logging with timestamps

### Changed
- Improved error handling with `set -euo pipefail`
- Enhanced deployment robustness and reliability
- Simplified versioning system with single version for all actions

## [0.3.0] - 2024-09-23

### Added
- Initial deploy actions for Sylius and WordPress/Bedrock
- Atomic deployment with releases and current symlink
- Shared library architecture for common functionality
- Configurable permissions and environment-specific defaults