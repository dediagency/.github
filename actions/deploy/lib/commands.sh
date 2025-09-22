#!/bin/bash

commands_run_console_list() {
    local commands_json="$1"
    local label="$2"
    local php_binary="$3"
    local app_env="$4"
    local console_cmd="bin/console"

    if [ -z "$commands_json" ] || [ "$commands_json" = "[]" ]; then
        return
    fi

    echo "$label"
    json_array_to_lines "$commands_json" | while IFS= read -r cmd; do
        echo "Executing: $cmd"
        APP_ENV="$app_env" "$php_binary" "$console_cmd" $cmd
    done
}

commands_run_post_deploy() {
    local commands_json="$1"

    if [ -z "$commands_json" ] || [ "$commands_json" = "[]" ]; then
        return
    fi

    echo "🔧 Running additional post-deploy commands..."
    json_array_to_lines "$commands_json" | while IFS= read -r cmd; do
        echo "Executing: $cmd"
        eval "$cmd"
    done
}

commands_reload_services() {
    local services_json="$1"

    if [ -z "$services_json" ] || [ "$services_json" = "[]" ]; then
        return
    fi

    echo "♻️  Reloading services..."
    json_array_to_lines "$services_json" | while IFS= read -r service; do
        sudo service "$service" reload 2>/dev/null || echo "⚠️  $service reload not available"
    done
}
