#!/bin/bash

apply_sylius_defaults() {
    config_require_base
    config_apply_base_defaults

    DEPLOY_PLATFORM="sylius"

    if [ -z "${DEPLOY_DB_OPERATIONS:-}" ]; then
        case "${DEPLOY_ENVIRONMENT}" in
            recette)
                DEPLOY_DB_OPERATIONS='["doctrine:database:create --if-not-exists --no-interaction", "doctrine:schema:update --force --no-interaction", "sylius:fixtures:load --no-interaction || true"]'
                ;;
            preproduction|preprod|production|prod)
                DEPLOY_DB_OPERATIONS='["doctrine:migrations:migrate --no-interaction"]'
                ;;
            *)
                DEPLOY_DB_OPERATIONS='[]'
                ;;
        esac
    fi

    if [ -z "${DEPLOY_CACHE_COMMANDS:-}" ]; then
        DEPLOY_CACHE_COMMANDS='["cache:clear --env=prod --no-interaction", "cache:warmup --env=prod --no-interaction"]'
    fi

    if [ -z "${DEPLOY_ASSET_COMMANDS:-}" ]; then
        DEPLOY_ASSET_COMMANDS='["assets:install public --symlink --relative --no-interaction"]'
    fi

    if [ -z "${DEPLOY_SHARED_DIRS:-}" ]; then
        DEPLOY_SHARED_DIRS='["var/log", "var/storage", "public/media", "public/uploads"]'
    fi

    if [ -z "${DEPLOY_SHARED_FILES:-}" ]; then
        DEPLOY_SHARED_FILES='[".env.local"]'
    fi

    if [ -z "${DEPLOY_NPM_INSTALL_COMMAND:-}" ]; then
        DEPLOY_NPM_INSTALL_COMMAND="npm install --silent"
    fi

    if [ -z "${DEPLOY_BUILD_COMMAND:-}" ]; then
        DEPLOY_BUILD_COMMAND="npm run build:prod"
    fi

    config_export_envs
}
