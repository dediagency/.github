#!/bin/bash

config_load() {
    # Raw inputs
    export CFG_ENV="${DEPLOY_ENVIRONMENT}"
    export CFG_BRANCH="${DEPLOY_BRANCH}"
    export CFG_SSH_USERNAME="${DEPLOY_SSH_USERNAME}"
    export CFG_PLATFORM="${DEPLOY_PLATFORM}"
    export CFG_PHP_VERSION="${DEPLOY_PHP_VERSION}"
    export CFG_PHP_BINARY="${DEPLOY_PHP_BINARY}"
    export CFG_COMPOSER_PATH="${DEPLOY_COMPOSER_PATH}"
    export CFG_NODE_BINARY="${DEPLOY_NODE_BINARY}"
    export CFG_NPM_BINARY="${DEPLOY_NPM_BINARY}"
    export CFG_REPOSITORY="${DEPLOY_REPOSITORY}"
    export CFG_PERMISSION_METHOD="${DEPLOY_PERMISSION_METHOD}"
    export CFG_FILE_PERMISSIONS="${DEPLOY_FILE_PERMISSIONS}"
    export CFG_VAR_PERMISSIONS="${DEPLOY_VAR_PERMISSIONS}"
    export CFG_SETFACL_USER="${DEPLOY_SETFACL_USER}"
    export CFG_SETFACL_GROUP="${DEPLOY_SETFACL_GROUP}"
    export CFG_RUN_POST_DEPLOY_CMD="${DEPLOY_RUN_POST_DEPLOY_CMD}"

    # Smart defaults
    if [ -z "${DEPLOY_DEPLOY_PATH}" ]; then
        export CFG_DEPLOY_PATH="$HOME/${CFG_ENV}-${CFG_SSH_USERNAME}"
    else
        export CFG_DEPLOY_PATH="${DEPLOY_DEPLOY_PATH}"
    fi

    if [ -z "${DEPLOY_SITE_URL}" ]; then
        export CFG_SITE_URL="https://${CFG_ENV}-${CFG_SSH_USERNAME}.dediagency.dev"
    else
        export CFG_SITE_URL="${DEPLOY_SITE_URL}"
    fi

    if [ -z "${DEPLOY_APP_ENV}" ]; then
        case "${CFG_ENV}" in
            "recette")
                export CFG_APP_ENV="test"
                ;;
            "preproduction"|"preprod")
                export CFG_APP_ENV="staging"
                ;;
            "production"|"prod")
                export CFG_APP_ENV="prod"
                ;;
            *)
                export CFG_APP_ENV="staging"
                ;;
        esac
    else
        export CFG_APP_ENV="${DEPLOY_APP_ENV}"
    fi

    # Defaults for JSON commands/lists
    if [ -z "${DEPLOY_DB_OPERATIONS}" ] || [ "${DEPLOY_DB_OPERATIONS}" = "" ]; then
        case "${CFG_ENV}" in
            "recette")
                export CFG_DB_OPERATIONS='["doctrine:database:create --if-not-exists --no-interaction", "doctrine:schema:update --force --no-interaction", "sylius:fixtures:load --no-interaction || true"]'
                ;;
            "preproduction"|"preprod")
                export CFG_DB_OPERATIONS='["doctrine:migrations:migrate --no-interaction"]'
                ;;
            "production"|"prod")
                export CFG_DB_OPERATIONS='["doctrine:migrations:migrate --no-interaction"]'
                ;;
            *)
                export CFG_DB_OPERATIONS='[]'
                ;;
        esac
    else
        export CFG_DB_OPERATIONS="${DEPLOY_DB_OPERATIONS}"
    fi

    if [ -z "${DEPLOY_CACHE_COMMANDS}" ] || [ "${DEPLOY_CACHE_COMMANDS}" = "" ]; then
        case "${CFG_PLATFORM}" in
            "sylius"|"symfony")
                export CFG_CACHE_COMMANDS='["cache:clear --env=prod --no-interaction", "cache:warmup --env=prod --no-interaction"]'
                ;;
            *)
                export CFG_CACHE_COMMANDS='[]'
                ;;
        esac
    else
        export CFG_CACHE_COMMANDS="${DEPLOY_CACHE_COMMANDS}"
    fi

    if [ -z "${DEPLOY_ASSET_COMMANDS}" ] || [ "${DEPLOY_ASSET_COMMANDS}" = "" ]; then
        case "${CFG_PLATFORM}" in
            "sylius"|"symfony")
                export CFG_ASSET_COMMANDS='["assets:install public --symlink --relative --no-interaction"]'
                ;;
            *)
                export CFG_ASSET_COMMANDS='[]'
                ;;
        esac
    else
        export CFG_ASSET_COMMANDS="${DEPLOY_ASSET_COMMANDS}"
    fi

    # Raw JSON-style inputs
    export CFG_SHARED_DIRS="${DEPLOY_SHARED_DIRS}"
    export CFG_SHARED_FILES="${DEPLOY_SHARED_FILES}"
    export CFG_RELOAD_SERVICES="${DEPLOY_RELOAD_SERVICES}"
    export CFG_POST_DEPLOY_COMMANDS="${DEPLOY_POST_DEPLOY_COMMANDS}"
    export CFG_NPM_INSTALL_COMMAND="${DEPLOY_NPM_INSTALL_COMMAND}"
    export CFG_BUILD_COMMAND="${DEPLOY_BUILD_COMMAND}"
    export CFG_COMPOSER_INSTALL_ARGS="${DEPLOY_COMPOSER_INSTALL_ARGS}"
}
