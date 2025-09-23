## [1.1.2](https://github.com/dediagency/.github/compare/v1.1.1...v1.1.2) (2025-09-23)


### Bug Fixes

* correction deploy env ([73a5e38](https://github.com/dediagency/.github/commit/73a5e38826807b1876e312ae24d14a363b4e49c8))
* revert clean up composer output to avoid false error messages ([f738469](https://github.com/dediagency/.github/commit/f7384693e21a51b2411259de48371ddd8c9e589a))

## [1.1.2](https://github.com/dediagency/.github/compare/v1.1.1...v1.1.2) (2025-09-23)


### Bug Fixes

* revert clean up composer output to avoid false error messages ([f738469](https://github.com/dediagency/.github/commit/f7384693e21a51b2411259de48371ddd8c9e589a))

## [1.1.1](https://github.com/dediagency/.github/compare/v1.1.0...v1.1.1) (2025-09-23)


### Bug Fixes

* remove health check from deployment process ([2170679](https://github.com/dediagency/.github/commit/217067928aab69203f1c06c83148006c6f3dba18))

## [1.1.0](https://github.com/dediagency/.github/compare/v1.0.4...v1.1.0) (2025-09-23)


### Features

* add deployment mutex system to prevent concurrent deployments ([760b160](https://github.com/dediagency/.github/commit/760b16020450fdcef212ab9b32dd196c99498614))


### Bug Fixes

* move mutex check before script copy to prevent conflicts ([aea1a36](https://github.com/dediagency/.github/commit/aea1a3609770e363b6923763c754e64667b74157))

## [1.0.4](https://github.com/dediagency/.github/compare/v1.0.3...v1.0.4) (2025-09-23)


### Bug Fixes

* clean up composer output to avoid false error messages ([278915a](https://github.com/dediagency/.github/commit/278915abe0483e62fb87d2ad02f95ef2a065d321))

## [1.0.3](https://github.com/dediagency/.github/compare/v1.0.2...v1.0.3) (2025-09-23)


### Bug Fixes

* correct python here document syntax error in deps.sh ([9a097bb](https://github.com/dediagency/.github/commit/9a097bb10204c90104b928edba6cf7de0a10460b))

## [1.0.2](https://github.com/dediagency/.github/compare/v1.0.1...v1.0.2) (2025-09-23)


### Bug Fixes

* add missing shell property in composite actions ([9707816](https://github.com/dediagency/.github/commit/9707816935667953797f4eb1c6b1c96f2643aad5))

## [1.0.1](https://github.com/dediagency/.github/compare/v1.0.0...v1.0.1) (2025-09-23)


### Bug Fixes

* remove problematic assets configuration from semantic-release ([eedc889](https://github.com/dediagency/.github/commit/eedc889534519791b998e639c3e7021183299bf2))

## 1.0.0 (2025-09-23)


### Features

* add preflight commands ([dcb1421](https://github.com/dediagency/.github/commit/dcb14211bfb809c5d8b08605105bb6f303c39802))
* add semantic release and tags ([bf3db6e](https://github.com/dediagency/.github/commit/bf3db6e148512a704474f49fc17af4a438e2fc30))
* initial commit + add deploy github action ([35d496a](https://github.com/dediagency/.github/commit/35d496a10f22d50f01ecbd3931a68e18668163a1))
* refacto ([b884986](https://github.com/dediagency/.github/commit/b884986f42d67ec61f4e443caeb49d40f15f57e1))
* refacto ([ad9ea8b](https://github.com/dediagency/.github/commit/ad9ea8b96bd34070a1740612fe4adc03a9423ebb))
* refactorisation ([7527889](https://github.com/dediagency/.github/commit/7527889b51280e6aeca5b880b8d1d8c2e88e6efa))


### Bug Fixes

* add missing conventional-changelog-conventionalcommits dependency ([2c1e5c8](https://github.com/dediagency/.github/commit/2c1e5c83f9297acb1531ac1c5c1c9b31b476ea68))
* correction scp ([9d9ec0d](https://github.com/dediagency/.github/commit/9d9ec0dc1e7040017af65feed872cb519039bb3c))
* correction wordpress deploy workflowg ([54a8600](https://github.com/dediagency/.github/commit/54a860081189bcf49e83f68205409cb5288ddd5b))
* deploy ([3ba9485](https://github.com/dediagency/.github/commit/3ba94853294ed9b00998174963e1399bed001f74))
* deploy ([bc52190](https://github.com/dediagency/.github/commit/bc52190f3efd31631b48d9d6c7714cb88c4f7610))
* deploy path ([f99ce16](https://github.com/dediagency/.github/commit/f99ce16a9fde487901946c0243766c6a351a292a))
* json parsing ([495fe6b](https://github.com/dediagency/.github/commit/495fe6b1ebe75928d8e28c9a54236b69990b853d))
* missing deploy key ([d9d81df](https://github.com/dediagency/.github/commit/d9d81df7cc903433c5fd12b8c08b492e3d6fa449))
* parsing ([061d831](https://github.com/dediagency/.github/commit/061d8316b3fc478a88b079f5446ad848ae7f4a8e))
* private key ([6ebc102](https://github.com/dediagency/.github/commit/6ebc1028dd3a8196a8d02638c9b042cc5e5ad395))
* variables ([98827f8](https://github.com/dediagency/.github/commit/98827f85ac5320fbc495e52af361881d74d1f12b))

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
