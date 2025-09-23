#!/bin/bash

# Fonction de retry avec backoff exponentiel
retry_with_backoff() {
    local max_attempts="$1"
    local delay="$2"
    local max_delay="$3"
    shift 3
    local cmd=("$@")

    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        echo "🔄 Attempt $attempt/$max_attempts: ${cmd[*]}"

        if "${cmd[@]}"; then
            echo "✅ Command succeeded on attempt $attempt"
            return 0
        fi

        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Command failed after $max_attempts attempts"
            return 1
        fi

        local wait_time=$((delay * (2 ** (attempt - 1))))
        if [ $wait_time -gt $max_delay ]; then
            wait_time=$max_delay
        fi

        echo "⏳ Waiting ${wait_time}s before retry..."
        sleep $wait_time
        ((attempt++))
    done
}

# Fonction pour exécuter une commande avec timeout
run_with_timeout() {
    local timeout_duration="$1"
    shift
    local cmd=("$@")

    echo "⏱️  Running with timeout ${timeout_duration}s: ${cmd[*]}"

    if command -v timeout >/dev/null 2>&1; then
        timeout "$timeout_duration" "${cmd[@]}"
    else
        # Fallback pour systèmes sans timeout
        "${cmd[@]}" &
        local pid=$!

        (
            sleep "$timeout_duration"
            if kill -0 "$pid" 2>/dev/null; then
                echo "⏰ Command timed out after ${timeout_duration}s, killing process $pid"
                kill -TERM "$pid" 2>/dev/null || true
                sleep 5
                kill -KILL "$pid" 2>/dev/null || true
            fi
        ) &
        local timeout_pid=$!

        if wait "$pid" 2>/dev/null; then
            kill "$timeout_pid" 2>/dev/null || true
            return 0
        else
            kill "$timeout_pid" 2>/dev/null || true
            return 1
        fi
    fi
}

# Fonction pour vérifier la santé d'une URL
health_check() {
    local url="$1"
    local max_attempts="${2:-5}"
    local delay="${3:-10}"

    echo "🏥 Health check: $url"

    for i in $(seq 1 $max_attempts); do
        echo "🔍 Health check attempt $i/$max_attempts..."

        if curl -f -s -o /dev/null --max-time 30 "$url"; then
            echo "✅ Health check passed: $url"
            return 0
        fi

        if [ $i -lt $max_attempts ]; then
            echo "⏳ Health check failed, waiting ${delay}s..."
            sleep $delay
        fi
    done

    echo "❌ Health check failed after $max_attempts attempts: $url"
    return 1
}

# Fonction pour créer un timestamp avec format lisible
get_timestamp() {
    date +%Y%m%d%H%M%S
}

get_readable_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Fonction pour logger avec timestamp
log() {
    local level="$1"
    shift
    local message="$*"

    case "$level" in
        "ERROR"|"error")
            echo "$(get_readable_timestamp) [ERROR] $message" >&2
            ;;
        "WARN"|"warn")
            echo "$(get_readable_timestamp) [WARN] $message" >&2
            ;;
        "INFO"|"info"|*)
            echo "$(get_readable_timestamp) [INFO] $message"
            ;;
    esac
}

# Fonction pour mode dry-run
dry_run() {
    local level="$1"
    shift
    local cmd=("$@")

    if [ "${DEPLOY_DRY_RUN:-false}" = "true" ]; then
        case "$level" in
            "DESTRUCTIVE")
                log "info" "🧪 [DRY-RUN] Would execute DESTRUCTIVE command: ${cmd[*]}"
                return 0
                ;;
            "WRITE")
                log "info" "🧪 [DRY-RUN] Would execute WRITE command: ${cmd[*]}"
                return 0
                ;;
            "READ")
                # Exécute les commandes de lecture même en dry-run
                "${cmd[@]}"
                ;;
            *)
                log "info" "🧪 [DRY-RUN] Would execute command: ${cmd[*]}"
                return 0
                ;;
        esac
    else
        "${cmd[@]}"
    fi
}