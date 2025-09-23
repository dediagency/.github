#!/bin/bash

# Global state used across dependency helpers
DEPS_MISSING=0
ARRAY_PARSER=""

deps_reset_missing() {
    DEPS_MISSING=0
}

deps_require_command() {
    local cmd="$1"

    if [ -z "$cmd" ]; then
        echo "❌ ERROR: Empty command name provided to dependency checker."
        DEPS_MISSING=1
        return
    fi

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "❌ ERROR: Required command '$cmd' is not available on the server."
        DEPS_MISSING=1
    fi
}

deps_require_file() {
    local path="$1"

    if [ ! -f "$path" ]; then
        echo "❌ ERROR: Required file '$path' is missing."
        DEPS_MISSING=1
    fi
}

deps_first_word() {
    local command_string="$1"

    if [ -z "$command_string" ]; then
        echo ""
        return
    fi

    set -- $command_string
    echo "$1"
}

deps_ensure_json_parser() {
    if command -v jq >/dev/null 2>&1; then
        ARRAY_PARSER="jq"
    elif command -v python3 >/dev/null 2>&1; then
        ARRAY_PARSER="python3"
    elif command -v python >/dev/null 2>&1; then
        ARRAY_PARSER="python"
    else
        echo "❌ ERROR: Neither jq nor python3/python is available to parse JSON arrays."
        DEPS_MISSING=1
    fi
}

deps_ensure_composer_available() {
    local composer_path="$1"

    if [[ "$composer_path" = /* ]] || [[ "$composer_path" = ./* ]]; then
        deps_require_file "$composer_path"
    else
        deps_require_command "$composer_path"
    fi
}

json_array_to_lines() {
    local json="$1"

    if [ -z "$json" ] || [ "$json" = "[]" ]; then
        return 1
    fi

    # Skip parsing if the payload does not look like a JSON array
    if [ "${json:0:1}" = "'" ] && [ "${json: -1}" = "'" ]; then
        json=${json:1:-1}
    fi
    local trimmed
    trimmed=$(printf '%s' "$json" | tr -d '[:space:]')
    if [ -z "$trimmed" ] || [ "${trimmed:0:1}" != "[" ]; then
        return 1
    fi

    case "$ARRAY_PARSER" in
        jq)
            echo "$json" | jq -r '.[]'
            ;;
        python3|python)
            local output
            output=$(printf '%s' "$json" | "$ARRAY_PARSER" -c "
import json
import sys

try:
    data = json.load(sys.stdin)
    if not isinstance(data, list):
        sys.exit(1)
    for item in data:
        if isinstance(item, (list, dict)):
            print(json.dumps(item))
        else:
            print(item)
except:
    sys.exit(1)
" 2>/dev/null) || {
                echo "⚠️  Skipping invalid JSON array: $json" >&2
                return 1
            }
            printf '%s\n' "$output"
            ;;
        *)
            echo "⚠️  No JSON parser configured. Skipping array." >&2
            return 1
            ;;
    esac
}

deps_check() {
    local php_binary="$1"
    local composer_path="$2"
    local npm_install_command="$3"
    local build_command="$4"
    local node_binary="$5"
    local npm_binary="$6"
    local permission_method="$7"
    local reload_services_json="$8"

    deps_reset_missing

    deps_require_command git
    deps_require_command ssh
    deps_require_command ssh-keyscan
    deps_require_command "$php_binary"

    deps_ensure_json_parser

    if [ -n "$npm_install_command" ]; then
        local npm_install_binary
        npm_install_binary=$(deps_first_word "$npm_install_command")
        deps_require_command "$npm_install_binary"
    fi

    if [ -n "$build_command" ]; then
        local build_binary
        build_binary=$(deps_first_word "$build_command")
        deps_require_command "$build_binary"
    fi

    if [ -n "$node_binary" ]; then
        deps_require_command "$node_binary"
    fi

    if [ -n "$npm_binary" ]; then
        deps_require_command "$npm_binary"
    fi

    if [ "$permission_method" = "setfacl" ]; then
        deps_require_command setfacl
    fi

    if [ -n "$reload_services_json" ] && [ "$reload_services_json" != "[]" ]; then
        deps_require_command sudo
    fi

    deps_ensure_composer_available "$composer_path"

    if [ "$DEPS_MISSING" -ne 0 ]; then
        echo "⛔ Missing dependencies detected. Aborting deployment."
        exit 1
    fi
}
