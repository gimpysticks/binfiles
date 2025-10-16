#!/usr/bin/env bash

# Script to update OPENAI_API_KEY in all .envrc files
# Usage: ./update-openai-key.sh <new_api_key>

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_api_key>"
    echo "Example: $0 sk-proj-..."
    exit 1
fi

NEW_API_KEY="$1"

# Find all .envrc files in user directories (excluding cargo cache and lazy nvim cache)
ENVRC_FILES=(
    "/home/sticks/.envrc"
    "/home/sticks/bin/.envrc"
    "/home/sticks/.config/nvim/.envrc"
    "/home/sticks/.config/nvim/lua/config/.envrc"
    "/home/sticks/yazi/.envrc"
)

echo "Updating OPENAI_API_KEY in .envrc files..."

for file in "${ENVRC_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Check if OPENAI_API_KEY already exists in the file
        if grep -q "^export OPENAI_API_KEY=" "$file"; then
            # Replace existing OPENAI_API_KEY
            sed -i "s/^export OPENAI_API_KEY=.*/export OPENAI_API_KEY='$NEW_API_KEY'/" "$file"
            echo "  ✓ Updated existing OPENAI_API_KEY"
        else
            # Add OPENAI_API_KEY before OPENAI_API_ORG_ID if it exists, otherwise at the end
            if grep -q "^export OPENAI_API_ORG_ID=" "$file"; then
                sed -i "/^export OPENAI_API_ORG_ID=/i export OPENAI_API_KEY='$NEW_API_KEY'" "$file"
                echo "  ✓ Added OPENAI_API_KEY before OPENAI_API_ORG_ID"
            else
                echo "export OPENAI_API_KEY='$NEW_API_KEY'" >> "$file"
                echo "  ✓ Added OPENAI_API_KEY at end of file"
            fi
        fi
    else
        echo "  ⚠ File not found: $file"
    fi
done

echo ""
echo "Allowing and reloading direnv for all directories..."

# Array of directories to reload direnv
DIRS=(
    "/home/sticks"
    "/home/sticks/bin"
    "/home/sticks/.config/nvim"
    "/home/sticks/.config/nvim/lua/config"
    "/home/sticks/yazi"
)

for dir in "${DIRS[@]}"; do
    if [ -f "$dir/.envrc" ]; then
        echo "Processing directory: $dir"
        (cd "$dir" && direnv allow) || echo "  ⚠ Failed to allow direnv in $dir"
    fi
done

echo ""
echo "✅ OPENAI_API_KEY update complete!"
echo "🔑 New key: ${NEW_API_KEY:0:20}..."
echo ""
echo "To verify, run: echo \$OPENAI_API_KEY"