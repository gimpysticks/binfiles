#!/bin/bash

# Function to generate timestamp prefix
get_timestamp() {
    date +"%Y%m%d-%H%M%S"
}

# Function to check if filename has leading timestamp
has_timestamp() {
    local filename="$1"
    [[ "$filename" =~ ^[0-9]{8,}[0-9]*-[0-9]*- ]]
}

# Function to get new filename with timestamp prefix
get_new_name() {
    local filename="$1"
    local timestamp=$(get_timestamp)
    echo "${timestamp}-${filename}"
}

echo "Interactive file renaming - adding timestamp prefix to files without one"
echo "======================================================================="

for file in *.md; do
    # Skip if no .md files exist
    [[ "$file" == "*.md" ]] && continue
    
    # Skip Home.md
    if [[ "$file" == "Home.md" ]]; then
        echo "Skipping: $file (excluded from renaming)"
        continue
    fi
    
    # Skip files that already have timestamp pattern
    if has_timestamp "$file"; then
        echo "Skipping: $file (already has timestamp)"
        continue
    fi
    
    new_name=$(get_new_name "$file")
    
    # Skip if target file already exists
    if [[ -e "$new_name" ]]; then
        echo "Skipping: $file -> $new_name (target already exists)"
        continue
    fi
    
    echo ""
    echo "Rename: $file"
    echo "    -> $new_name"
    read -p "Approve this rename? (y/n/q): " -n 1 -r
    echo
    
    case $REPLY in
        [Yy])
            mv "$file" "$new_name"
            echo "✓ Renamed successfully"
            ;;
        [Qq])
            echo "Quitting..."
            exit 0
            ;;
        *)
            echo "✗ Skipped"
            ;;
    esac
done

echo ""
echo "Rename process complete!"
