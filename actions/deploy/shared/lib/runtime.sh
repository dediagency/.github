#!/bin/bash

run_deploy() {
    local timestamp release_dir shared_root current_link

    timestamp=$(date +%Y%m%d%H%M%S)
    release_dir="$DEPLOY_DEPLOY_PATH/releases/$timestamp"
    shared_root="$DEPLOY_DEPLOY_PATH/shared"
    current_link="$DEPLOY_DEPLOY_PATH/current"

    deps_check \
        "$DEPLOY_PHP_BINARY" \
        "$DEPLOY_COMPOSER_PATH" \
        "$DEPLOY_NPM_INSTALL_COMMAND" \
        "$DEPLOY_BUILD_COMMAND" \
        "$DEPLOY_NODE_BINARY" \
        "$DEPLOY_NPM_BINARY" \
        "$DEPLOY_PERMISSION_METHOD" \
        "$DEPLOY_RELOAD_SERVICES"

    echo "🚀 Starting deployment to ${DEPLOY_ENVIRONMENT}..."
    echo "📍 Deploy path: ${DEPLOY_DEPLOY_PATH}"
    echo "🌿 Branch: ${DEPLOY_BRANCH}"
    echo "🏗️  Platform: ${DEPLOY_PLATFORM}"

    echo "📁 Creating directory structure..."
    mkdir -p "$DEPLOY_DEPLOY_PATH/releases"

    shared_prepare_directories "$DEPLOY_SHARED_DIRS" "$shared_root"

    echo "🔑 Setting up SSH access..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
        ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null
    fi

    echo "🔗 Testing GitHub SSH connection..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ GitHub SSH authentication successful"
    else
        echo "⚠️  GitHub SSH test completed (this is normal if using deploy keys)"
    fi

    echo "🔍 Checking repository access..."
    if ! git ls-remote --exit-code "git@github.com:${DEPLOY_REPOSITORY}.git" >/dev/null 2>&1; then
        echo "❌ Unable to access git@github.com:${DEPLOY_REPOSITORY}.git via SSH."
        echo "   Ensure the deploy key installed on this runner has read access to the repository."
        echo "   Tip: add the runner's public key as a Deploy Key in GitHub → Settings → Deploy keys."
        exit 1
    fi

    echo "📦 Cloning repository..."
    git clone --depth 1 --branch "${DEPLOY_BRANCH}" "git@github.com:${DEPLOY_REPOSITORY}.git" "$release_dir"
    cd "$release_dir"

    echo "🔧 Installing PHP dependencies..."
    "${DEPLOY_PHP_BINARY}" "${DEPLOY_COMPOSER_PATH}" install ${DEPLOY_COMPOSER_INSTALL_ARGS}

    if [ -n "${DEPLOY_BUILD_COMMAND}" ]; then
        echo "🎨 Building assets..."
        if [ -n "${DEPLOY_NPM_INSTALL_COMMAND}" ]; then
            ${DEPLOY_NPM_INSTALL_COMMAND}
        fi
        ${DEPLOY_BUILD_COMMAND}
    fi

    shared_link_directories "$DEPLOY_SHARED_DIRS" "$shared_root" "$release_dir"
    shared_link_files "$DEPLOY_SHARED_FILES" "$shared_root" "$release_dir"

    echo "🔐 Setting permissions..."
    if [ "$DEPLOY_PERMISSION_METHOD" = "setfacl" ]; then
        if [ -z "$DEPLOY_SETFACL_USER" ] || [ -z "$DEPLOY_SETFACL_GROUP" ]; then
            echo "❌ ERROR: setfacl_user and setfacl_group are required when using setfacl method"
            exit 1
        fi
        echo "Using setfacl with user: $DEPLOY_SETFACL_USER, group: $DEPLOY_SETFACL_GROUP"
        setfacl -R -m u:$DEPLOY_SETFACL_USER:rwX -m g:$DEPLOY_SETFACL_GROUP:rwX "$release_dir"
        if [ -d "$release_dir/var" ]; then
            setfacl -R -m u:$DEPLOY_SETFACL_USER:rwX -m g:$DEPLOY_SETFACL_GROUP:rwX "$release_dir/var"
            setfacl -R -d -m u:$DEPLOY_SETFACL_USER:rwX -m g:$DEPLOY_SETFACL_GROUP:rwX "$release_dir/var"
        fi
    else
        echo "Using chmod with file permissions: $DEPLOY_FILE_PERMISSIONS, var permissions: $DEPLOY_VAR_PERMISSIONS"
        chmod -R "$DEPLOY_FILE_PERMISSIONS" "$release_dir"
        if [ -d "$release_dir/var" ]; then
            chmod -R "$DEPLOY_VAR_PERMISSIONS" "$release_dir/var"
        fi
    fi

    commands_run_console_list "$DEPLOY_DB_OPERATIONS" "🗄️  Running database operations..." "$DEPLOY_PHP_BINARY" "$DEPLOY_APP_ENV"
    commands_run_console_list "$DEPLOY_CACHE_COMMANDS" "🗑️  Running cache commands..." "$DEPLOY_PHP_BINARY" "$DEPLOY_APP_ENV"
    commands_run_console_list "$DEPLOY_ASSET_COMMANDS" "📦 Running asset commands..." "$DEPLOY_PHP_BINARY" "$DEPLOY_APP_ENV"

    if [ "$DEPLOY_RUN_POST_DEPLOY_CMD" = "true" ]; then
        echo "🎯 Running composer post-deploy-cmd..."
        if "${DEPLOY_PHP_BINARY}" "${DEPLOY_COMPOSER_PATH}" run-script post-deploy-cmd --no-interaction 2>/dev/null; then
            echo "✅ Composer post-deploy-cmd completed"
        else
            echo "⚠️  No post-deploy-cmd defined in composer.json or command failed"
        fi
    fi

    commands_run_post_deploy "$DEPLOY_POST_DEPLOY_COMMANDS"

    echo "🔄 Updating current symlink..."
    ln -sfn "$release_dir" "$current_link.tmp"
    mv -Tf "$current_link.tmp" "$current_link"

    commands_reload_services "$DEPLOY_RELOAD_SERVICES"

    echo "🧹 Cleaning up old releases..."
    cd "$DEPLOY_DEPLOY_PATH/releases"
    ls -t | tail -n +4 | xargs -r rm -rf

    echo "✅ Deployment completed successfully!"

    echo "🌐 Site available at: ${DEPLOY_SITE_URL}"
}
