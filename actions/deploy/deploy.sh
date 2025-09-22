#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/deps.sh"
source "$SCRIPT_DIR/lib/shared.sh"
source "$SCRIPT_DIR/lib/commands.sh"

config_load

# Variables
RELEASE_DIR="$CFG_DEPLOY_PATH/releases/$(date +%Y%m%d%H%M%S)"
SHARED_DIR="$CFG_DEPLOY_PATH/shared"
CURRENT_LINK="$CFG_DEPLOY_PATH/current"

deps_check "$CFG_PHP_BINARY" "$CFG_COMPOSER_PATH" "$CFG_NPM_INSTALL_COMMAND" "$CFG_BUILD_COMMAND" "$CFG_NODE_BINARY" "$CFG_NPM_BINARY" "$CFG_PERMISSION_METHOD" "$CFG_RELOAD_SERVICES"

echo "🚀 Starting deployment to ${CFG_ENV}..."
echo "📍 Deploy path: ${CFG_DEPLOY_PATH}"
echo "🌿 Branch: ${CFG_BRANCH}"
echo "🏗️  Platform: ${CFG_PLATFORM}"

# Create directories
echo "📁 Creating directory structure..."
mkdir -p "$CFG_DEPLOY_PATH/releases"

shared_prepare_directories "$CFG_SHARED_DIRS" "$SHARED_DIR"

# Setup SSH for GitHub access
echo "🔑 Setting up SSH access..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null
fi

# Test GitHub SSH connection
echo "🔗 Testing GitHub SSH connection..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ GitHub SSH authentication successful"
else
    echo "⚠️  GitHub SSH test completed (this is normal if using deploy keys)"
fi

# Clone the repository
echo "📦 Cloning repository..."
git clone --depth 1 --branch "${CFG_BRANCH}" "git@github.com:${CFG_REPOSITORY}.git" "$RELEASE_DIR"
cd "$RELEASE_DIR"

# Install PHP dependencies
echo "🔧 Installing PHP dependencies..."
"${CFG_PHP_BINARY}" "${CFG_COMPOSER_PATH}" install ${CFG_COMPOSER_INSTALL_ARGS}

# Install Node dependencies and build assets (if build command provided)
if [ "${CFG_BUILD_COMMAND}" != "" ]; then
    echo "🎨 Building assets..."
    if [ -n "${CFG_NPM_INSTALL_COMMAND}" ]; then
        ${CFG_NPM_INSTALL_COMMAND}
    fi
    ${CFG_BUILD_COMMAND}
fi

shared_link_directories "$CFG_SHARED_DIRS" "$SHARED_DIR" "$RELEASE_DIR"
shared_link_files "$CFG_SHARED_FILES" "$SHARED_DIR" "$RELEASE_DIR"

# Set permissions
echo "🔐 Setting permissions..."
if [ "$CFG_PERMISSION_METHOD" = "setfacl" ]; then
    if [ -z "$CFG_SETFACL_USER" ] || [ -z "$CFG_SETFACL_GROUP" ]; then
        echo "❌ ERROR: setfacl_user and setfacl_group are required when using setfacl method"
        exit 1
    fi
    echo "Using setfacl with user: $CFG_SETFACL_USER, group: $CFG_SETFACL_GROUP"
    setfacl -R -m u:$CFG_SETFACL_USER:rwX -m g:$CFG_SETFACL_GROUP:rwX "$RELEASE_DIR"
    if [ -d "$RELEASE_DIR/var" ]; then
        setfacl -R -m u:$CFG_SETFACL_USER:rwX -m g:$CFG_SETFACL_GROUP:rwX "$RELEASE_DIR/var"
        setfacl -R -d -m u:$CFG_SETFACL_USER:rwX -m g:$CFG_SETFACL_GROUP:rwX "$RELEASE_DIR/var"
    fi
else
    echo "Using chmod with file permissions: $CFG_FILE_PERMISSIONS, var permissions: $CFG_VAR_PERMISSIONS"
    chmod -R "$CFG_FILE_PERMISSIONS" "$RELEASE_DIR"
    if [ -d "$RELEASE_DIR/var" ]; then
        chmod -R "$CFG_VAR_PERMISSIONS" "$RELEASE_DIR/var"
    fi
fi

commands_run_console_list "$CFG_DB_OPERATIONS" "🗄️  Running database operations..." "$CFG_PHP_BINARY" "$CFG_APP_ENV"
commands_run_console_list "$CFG_CACHE_COMMANDS" "🗑️  Running cache commands..." "$CFG_PHP_BINARY" "$CFG_APP_ENV"
commands_run_console_list "$CFG_ASSET_COMMANDS" "📦 Running asset commands..." "$CFG_PHP_BINARY" "$CFG_APP_ENV"

# Run post-deploy-cmd from composer (if enabled)
if [ "$CFG_RUN_POST_DEPLOY_CMD" = "true" ]; then
    echo "🎯 Running composer post-deploy-cmd..."
    if "${CFG_PHP_BINARY}" "${CFG_COMPOSER_PATH}" run-script post-deploy-cmd --no-interaction 2>/dev/null; then
        echo "✅ Composer post-deploy-cmd completed"
    else
        echo "⚠️  No post-deploy-cmd defined in composer.json or command failed"
    fi
fi

commands_run_post_deploy "$CFG_POST_DEPLOY_COMMANDS"

# Update current symlink atomically
echo "🔄 Updating current symlink..."
ln -sfn "$RELEASE_DIR" "$CURRENT_LINK.tmp"
mv -Tf "$CURRENT_LINK.tmp" "$CURRENT_LINK"

commands_reload_services "$CFG_RELOAD_SERVICES"

# Clean up old releases (keep last 3)
echo "🧹 Cleaning up old releases..."
cd "$CFG_DEPLOY_PATH/releases"
ls -t | tail -n +4 | xargs -r rm -rf

echo "✅ Deployment completed successfully!"

echo "🌐 Site available at: ${CFG_SITE_URL}"
