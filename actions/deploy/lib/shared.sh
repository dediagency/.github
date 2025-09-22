#!/bin/bash

shared_prepare_directories() {
    local shared_dirs_json="$1"
    local shared_root="$2"

    if [ -z "$shared_dirs_json" ] || [ "$shared_dirs_json" = "[]" ]; then
        return
    fi

    json_array_to_lines "$shared_dirs_json" | while IFS= read -r dir; do
        mkdir -p "$shared_root/$dir"
    done
}

shared_link_directories() {
    local shared_dirs_json="$1"
    local shared_root="$2"
    local release_dir="$3"

    if [ -z "$shared_dirs_json" ] || [ "$shared_dirs_json" = "[]" ]; then
        return
    fi

    echo "🔗 Creating symlinks to shared directories..."
    json_array_to_lines "$shared_dirs_json" | while IFS= read -r dir; do
        rm -rf "$release_dir/$dir"
        ln -sf "$shared_root/$dir" "$release_dir/$dir"
    done
}

shared_link_files() {
    local shared_files_json="$1"
    local shared_root="$2"
    local release_dir="$3"

    if [ -z "$shared_files_json" ] || [ "$shared_files_json" = "[]" ]; then
        return
    fi

    echo "🔗 Creating symlinks to shared files..."
    json_array_to_lines "$shared_files_json" | while IFS= read -r file; do
        if [ -f "$shared_root/$file" ]; then
            rm -f "$release_dir/$file"
            ln -sf "$shared_root/$file" "$release_dir/$file"
            echo "✅ $file symlinked"
        else
            echo "❌ ERROR: $file not found in $shared_root/"
            exit 1
        fi
    done
}
