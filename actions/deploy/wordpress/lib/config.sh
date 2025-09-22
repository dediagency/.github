#!/bin/bash

apply_wordpress_defaults() {
    config_require_base
    config_apply_base_defaults

    DEPLOY_PLATFORM="wordpress"

    if [ -z "${DEPLOY_DB_OPERATIONS:-}" ]; then
        DEPLOY_DB_OPERATIONS='[]'
    fi

    if [ -z "${DEPLOY_CACHE_COMMANDS:-}" ]; then
        DEPLOY_CACHE_COMMANDS='[]'
    fi

    if [ -z "${DEPLOY_ASSET_COMMANDS:-}" ]; then
        DEPLOY_ASSET_COMMANDS='[]'
    fi

    if [ -z "${DEPLOY_SHARED_DIRS:-}" ]; then
        DEPLOY_SHARED_DIRS='["web/app/uploads", "web/app/cache", "web/app/languages"]'
    fi

    if [ -z "${DEPLOY_SHARED_FILES:-}" ]; then
        DEPLOY_SHARED_FILES='[".env", "web/.htaccess"]'
    fi

    config_export_envs
}
