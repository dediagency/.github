#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/shared"
if [ ! -d "$SHARED_DIR" ]; then
    SHARED_DIR="$SCRIPT_DIR/../shared"
fi

source "$SHARED_DIR/lib/utils.sh"
source "$SHARED_DIR/lib/config.sh"
source "$SHARED_DIR/lib/deps.sh"
source "$SHARED_DIR/lib/shared.sh"
source "$SHARED_DIR/lib/commands.sh"
source "$SHARED_DIR/lib/runtime.sh"
source "$SCRIPT_DIR/lib/config.sh"

apply_sylius_defaults
run_deploy
