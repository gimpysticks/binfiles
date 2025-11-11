#!/bin/bash

OUTPUT_FILE="$HOME/zets/OBS_Hotkeys.md"
OBS_CONFIG_FILE="$HOME/.config/obs-studio/basic/profiles/Untitled/basic.ini"

echo "# OBS Hotkeys" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ ! -f "$OBS_CONFIG_FILE" ]; then
    echo "Error: OBS configuration file not found at $OBS_CONFIG_FILE" >> "$OUTPUT_FILE"
    echo "Please ensure OBS Studio is installed and configured, and the 'Untitled' profile exists." >> "$OUTPUT_FILE"
    exit 1
fi

# Extract the [Hotkeys] section
awk '/^\[Hotkeys\]/{flag=1;next}/^\[/{flag=0}flag' "$OBS_CONFIG_FILE" | while IFS= read -r line; do
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
        ACTION="${BASH_REMATCH[1]}"
        JSON_BINDINGS="${BASH_REMATCH[2]}"

        # Extract key bindings from JSON
        # This is a simplified approach and might need refinement for more complex JSON structures
        # For now, it looks for "key":"OBS_KEY_X" and optionally "control":true, "shift":true, "alt":true
        BINDINGS=$(echo "$JSON_BINDINGS" | grep -oP '"key":"OBS_KEY_\K[^"]+' | while IFS= read -r key; do
            MODIFIERS=""
            if echo "$JSON_BINDINGS" | grep -q '"control":true'; then
                MODIFIERS+="Ctrl+"
            fi
            if echo "$JSON_BINDINGS" | grep -q '"shift":true'; then
                MODIFIERS+="Shift+"
            fi
            if echo "$JSON_BINDINGS" | grep -q '"alt":true'; then
                MODIFIERS+="Alt+"
            fi
            echo "${MODIFIERS}${key}"
        done)

        # Format for Markdown
        if [ -n "$BINDINGS" ]; then
            echo "- **$ACTION**: $BINDINGS" >> "$OUTPUT_FILE"
        else
            echo "- **$ACTION**: No hotkey assigned" >> "$OUTPUT_FILE"
        fi
    fi
done

echo "OBS Hotkeys saved to $OUTPUT_FILE"
