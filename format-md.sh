#!/bin/bash

# Format markdown file with proper line spacing
# Usage: format-md.sh <file.md>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file>"
    exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found"
    exit 1
fi

# Create backup
cp "$file" "$file.bak"

# Use sed to add proper spacing
sed -i \
    -e 's/\. --- /.\n\n---\n/g' \
    -e 's/--- ## /---\n\n## /g' \
    -e 's/## \(.*\) "/## \1\n\n"/g' \
    -e 's/grief\. ### /grief.\n\n### /g' \
    -e 's/| ### /|\n\n### /g' \
    -e 's/past\*\*\./past**.\n/g' \
    "$file"

echo "Formatted $file (backup saved as $file.bak)"