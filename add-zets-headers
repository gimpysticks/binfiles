#!/usr/bin/env zsh

# Script to add YAML frontmatter headers to markdown files in ~/zets
# Format:
# ---
# title: filename_without_extension
# created: YYYY-MM-DD
# modified: YYYY-MM-DD
# ---

ZETS_DIR="$HOME/zets"

# Find all .md files in ~/zets
find "$ZETS_DIR" -maxdepth 1 -name "*.md" -type f | while read -r file; do
    # Check if file already has a header (starts with ---)
    if head -n 1 "$file" | grep -q "^---$"; then
        echo "Skipping $file (already has header)"
        continue
    fi
    
    # Extract filename without extension
    filename=$(basename "$file" .md)
    
    # Get file creation date (birth time) - fallback to modification if not available
    if stat -c %w "$file" 2>/dev/null | grep -qv "^-$"; then
        created_date=$(stat -c %w "$file" | cut -d' ' -f1)
    else
        # Fallback to modification date if birth time not available
        created_date=$(stat -c %y "$file" | cut -d' ' -f1)
    fi
    
    # Get last modification date
    modified_date=$(stat -c %y "$file" | cut -d' ' -f1)
    
    # Create temporary file with header
    temp_file=$(mktemp)
    
    # Write header
    cat > "$temp_file" << EOF
---
title: $filename
created: $created_date
modified: $modified_date
---

EOF
    
    # Append original content
    cat "$file" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file"
    
    echo "Added header to $file"
done

echo "Done processing markdown files in $ZETS_DIR"
