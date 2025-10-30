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
        local release_path="$release_dir/$dir"
        local shared_path="$shared_root/$dir"

        mkdir -p "$shared_path"

        if [ -d "$release_path" ] && [ -z "$(ls -A "$shared_path" 2>/dev/null)" ]; then
            echo "  ↪️ Seeding initial contents of $dir into shared directory"
            cp -a "$release_path/." "$shared_path/"
        fi

        rm -rf "$release_path"
        ln -sfn "$shared_path" "$release_path"
        echo "✅ $shared_path symlinked"
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
