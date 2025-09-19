#!/bin/bash
set -e

# Configuration from inputs (passed as environment variables)
ENV="${DEPLOY_ENVIRONMENT}"
BRANCH="${DEPLOY_BRANCH}"
SSH_USERNAME="${DEPLOY_SSH_USERNAME}"
PLATFORM="${DEPLOY_PLATFORM}"
PHP_VERSION="${DEPLOY_PHP_VERSION}"
PHP_BINARY="${DEPLOY_PHP_BINARY}"
COMPOSER_PATH="${DEPLOY_COMPOSER_PATH}"
NODE_BINARY="${DEPLOY_NODE_BINARY}"
NPM_BINARY="${DEPLOY_NPM_BINARY}"
REPOSITORY="${DEPLOY_REPOSITORY}"
PERMISSION_METHOD="${DEPLOY_PERMISSION_METHOD}"
FILE_PERMISSIONS="${DEPLOY_FILE_PERMISSIONS}"
VAR_PERMISSIONS="${DEPLOY_VAR_PERMISSIONS}"
SETFACL_USER="${DEPLOY_SETFACL_USER}"
SETFACL_GROUP="${DEPLOY_SETFACL_GROUP}"
RUN_POST_DEPLOY_CMD="${DEPLOY_RUN_POST_DEPLOY_CMD}"

# Smart defaults based on environment and ssh_username
if [ -z "${DEPLOY_DEPLOY_PATH}" ]; then
    DEPLOY_PATH="$HOME/${ENV}-${SSH_USERNAME}"
else
    DEPLOY_PATH="${DEPLOY_DEPLOY_PATH}"
fi

if [ -z "${DEPLOY_SITE_URL}" ]; then
    SITE_URL="https://${ENV}-${SSH_USERNAME}.dediagency.dev"
else
    SITE_URL="${DEPLOY_SITE_URL}"
fi

if [ -z "${DEPLOY_APP_ENV}" ]; then
    case $ENV in
        "recette")
            APP_ENV="test"
            ;;
        "preproduction"|"preprod")
            APP_ENV="staging"
            ;;
        "production"|"prod")
            APP_ENV="prod"
            ;;
        *)
            APP_ENV="staging"
            ;;
    esac
else
    APP_ENV="${DEPLOY_APP_ENV}"
fi

# Set environment-based defaults if not provided
if [ -z "${DEPLOY_DB_OPERATIONS}" ] || [ "${DEPLOY_DB_OPERATIONS}" = "" ]; then
    case $ENV in
        "recette")
            DB_OPERATIONS='["doctrine:database:create --if-not-exists --no-interaction", "doctrine:schema:update --force --no-interaction", "sylius:fixtures:load --no-interaction || true"]'
            ;;
        "preproduction"|"preprod")
            DB_OPERATIONS='["doctrine:migrations:migrate --no-interaction"]'
            ;;
        "production"|"prod")
            DB_OPERATIONS='["doctrine:migrations:migrate --no-interaction"]'
            ;;
        *)
            DB_OPERATIONS='[]'
            ;;
    esac
else
    DB_OPERATIONS="${DEPLOY_DB_OPERATIONS}"
fi

if [ -z "${DEPLOY_CACHE_COMMANDS}" ] || [ "${DEPLOY_CACHE_COMMANDS}" = "" ]; then
    case $PLATFORM in
        "sylius"|"symfony")
            CACHE_COMMANDS='["cache:clear --env=prod --no-interaction", "cache:warmup --env=prod --no-interaction"]'
            ;;
        *)
            CACHE_COMMANDS='[]'
            ;;
    esac
else
    CACHE_COMMANDS="${DEPLOY_CACHE_COMMANDS}"
fi

if [ -z "${DEPLOY_ASSET_COMMANDS}" ] || [ "${DEPLOY_ASSET_COMMANDS}" = "" ]; then
    case $PLATFORM in
        "sylius"|"symfony")
            ASSET_COMMANDS='["assets:install public --symlink --relative --no-interaction"]'
            ;;
        *)
            ASSET_COMMANDS='[]'
            ;;
    esac
else
    ASSET_COMMANDS="${DEPLOY_ASSET_COMMANDS}"
fi

# Parse remaining JSON arrays
SHARED_DIRS="${DEPLOY_SHARED_DIRS}"
SHARED_FILES="${DEPLOY_SHARED_FILES}"
RELOAD_SERVICES="${DEPLOY_RELOAD_SERVICES}"
POST_DEPLOY_COMMANDS="${DEPLOY_POST_DEPLOY_COMMANDS}"
NPM_INSTALL_COMMAND="${DEPLOY_NPM_INSTALL_COMMAND}"
BUILD_COMMAND="${DEPLOY_BUILD_COMMAND}"
COMPOSER_INSTALL_ARGS="${DEPLOY_COMPOSER_INSTALL_ARGS}"

# Variables
RELEASE_DIR="$DEPLOY_PATH/releases/$(date +%Y%m%d%H%M%S)"
SHARED_DIR="$DEPLOY_PATH/shared"
CURRENT_LINK="$DEPLOY_PATH/current"

echo "🚀 Starting deployment to ${ENV}..."
echo "📍 Deploy path: ${DEPLOY_PATH}"
echo "🌿 Branch: ${BRANCH}"
echo "🏗️  Platform: ${PLATFORM}"

# Create directories
echo "📁 Creating directory structure..."
mkdir -p $DEPLOY_PATH/releases

# Create shared directories
if [ "$SHARED_DIRS" != "[]" ]; then
    echo "$SHARED_DIRS" | jq -r '.[]' | while read dir; do
        mkdir -p "$SHARED_DIR/$dir"
    done
fi

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
git clone --depth 1 --branch ${BRANCH} git@github.com:${REPOSITORY}.git $RELEASE_DIR
cd $RELEASE_DIR

# Install PHP dependencies
echo "🔧 Installing PHP dependencies..."
${PHP_BINARY} ${COMPOSER_PATH} install ${COMPOSER_INSTALL_ARGS}

# Install Node dependencies and build assets (if build command provided)
if [ "${BUILD_COMMAND}" != "" ]; then
    echo "🎨 Building assets..."
    ${NPM_INSTALL_COMMAND}
    ${BUILD_COMMAND}
fi

# Create shared symlinks
if [ "$SHARED_DIRS" != "[]" ]; then
    echo "🔗 Creating symlinks to shared directories..."
    echo "$SHARED_DIRS" | jq -r '.[]' | while read dir; do
        rm -rf "$RELEASE_DIR/$dir"
        ln -sf "$SHARED_DIR/$dir" "$RELEASE_DIR/$dir"
    done
fi

# Create shared file symlinks
if [ "$SHARED_FILES" != "[]" ]; then
    echo "🔗 Creating symlinks to shared files..."
    echo "$SHARED_FILES" | jq -r '.[]' | while read file; do
        if [ -f "$SHARED_DIR/$file" ]; then
            rm -f "$RELEASE_DIR/$file"
            ln -sf "$SHARED_DIR/$file" "$RELEASE_DIR/$file"
            echo "✅ $file symlinked"
        else
            echo "❌ ERROR: $file not found in $SHARED_DIR/"
            exit 1
        fi
    done
fi

# Set permissions
echo "🔐 Setting permissions..."
if [ "$PERMISSION_METHOD" = "setfacl" ]; then
    if [ -z "$SETFACL_USER" ] || [ -z "$SETFACL_GROUP" ]; then
        echo "❌ ERROR: setfacl_user and setfacl_group are required when using setfacl method"
        exit 1
    fi
    echo "Using setfacl with user: $SETFACL_USER, group: $SETFACL_GROUP"
    setfacl -R -m u:$SETFACL_USER:rwX -m g:$SETFACL_GROUP:rwX $RELEASE_DIR
    if [ -d "$RELEASE_DIR/var" ]; then
        setfacl -R -m u:$SETFACL_USER:rwX -m g:$SETFACL_GROUP:rwX $RELEASE_DIR/var
        setfacl -R -d -m u:$SETFACL_USER:rwX -m g:$SETFACL_GROUP:rwX $RELEASE_DIR/var
    fi
else
    echo "Using chmod with file permissions: $FILE_PERMISSIONS, var permissions: $VAR_PERMISSIONS"
    chmod -R $FILE_PERMISSIONS $RELEASE_DIR
    if [ -d "$RELEASE_DIR/var" ]; then
        chmod -R $VAR_PERMISSIONS $RELEASE_DIR/var
    fi
fi

# Run database operations
if [ "$DB_OPERATIONS" != "[]" ]; then
    echo "🗄️  Running database operations..."
    echo "$DB_OPERATIONS" | jq -r '.[]' | while read cmd; do
        echo "Executing: $cmd"
        APP_ENV=${APP_ENV} ${PHP_BINARY} bin/console $cmd
    done
fi

# Run cache commands
if [ "$CACHE_COMMANDS" != "[]" ]; then
    echo "🗑️  Running cache commands..."
    echo "$CACHE_COMMANDS" | jq -r '.[]' | while read cmd; do
        echo "Executing: $cmd"
        APP_ENV=${APP_ENV} ${PHP_BINARY} bin/console $cmd
    done
fi

# Run asset commands
if [ "$ASSET_COMMANDS" != "[]" ]; then
    echo "📦 Running asset commands..."
    echo "$ASSET_COMMANDS" | jq -r '.[]' | while read cmd; do
        echo "Executing: $cmd"
        APP_ENV=${APP_ENV} ${PHP_BINARY} bin/console $cmd
    done
fi

# Run post-deploy-cmd from composer (if enabled)
if [ "$RUN_POST_DEPLOY_CMD" = "true" ]; then
    echo "🎯 Running composer post-deploy-cmd..."
    if ${PHP_BINARY} ${COMPOSER_PATH} run-script post-deploy-cmd --no-interaction 2>/dev/null; then
        echo "✅ Composer post-deploy-cmd completed"
    else
        echo "⚠️  No post-deploy-cmd defined in composer.json or command failed"
    fi
fi

# Run additional post-deploy commands
if [ "$POST_DEPLOY_COMMANDS" != "[]" ]; then
    echo "🔧 Running additional post-deploy commands..."
    echo "$POST_DEPLOY_COMMANDS" | jq -r '.[]' | while read cmd; do
        echo "Executing: $cmd"
        eval $cmd
    done
fi

# Update current symlink atomically
echo "🔄 Updating current symlink..."
ln -sfn $RELEASE_DIR $CURRENT_LINK.tmp
mv -Tf $CURRENT_LINK.tmp $CURRENT_LINK

# Reload services
if [ "$RELOAD_SERVICES" != "[]" ]; then
    echo "♻️  Reloading services..."
    echo "$RELOAD_SERVICES" | jq -r '.[]' | while read service; do
        sudo service $service reload 2>/dev/null || echo "⚠️  $service reload not available"
    done
fi

# Clean up old releases (keep last 3)
echo "🧹 Cleaning up old releases..."
cd $DEPLOY_PATH/releases
ls -t | tail -n +4 | xargs -r rm -rf

echo "✅ Deployment completed successfully!"

# Display URL
echo "🌐 Site available at: ${SITE_URL}"