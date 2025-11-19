#!/bin/bash

# OBS Hotkeys Lister
# Lists all hotkeys from the Sticks profile (Flatpak install)

OBS_PROFILE_DIR="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/profiles/Sticks"
OBS_SCENES_FILE="$HOME/.var/app/com.obsproject.Studio/config/obs-studio/basic/scenes/Untitled.json"
OUTPUT_FILE="$HOME/zets/OBS_Keys.md"

# Function to convert OBS key names to readable format
convert_key() {
    local key="$1"
    key="${key#OBS_KEY_}"
    echo "$key"
}

# Function to parse modifiers
get_modifiers() {
    local binding="$1"
    local mods=""
    
    if echo "$binding" | grep -q '"control":true'; then
        mods="${mods}Ctrl+"
    fi
    if echo "$binding" | grep -q '"shift":true'; then
        mods="${mods}Shift+"
    fi
    if echo "$binding" | grep -q '"alt":true'; then
        mods="${mods}Alt+"
    fi
    
    echo "$mods"
}

# Function to parse hotkey bindings
parse_hotkey() {
    local line="$1"
    local action="${line%%=*}"
    local bindings="${line#*=}"
    
    # Handle special nested JSON format for SelectScene and ReplayBuffer
    if [[ "$action" == "OBSBasic.SelectScene" ]]; then
        echo "**Select Scene:**"
        # Extract scene names and their bindings
        echo "$bindings" | grep -o '"[^"]*":\[{[^}]*}\]' | while IFS= read -r scene_binding; do
            local scene_name=$(echo "$scene_binding" | grep -o '^"[^"]*"' | tr -d '"')
            local keys=$(echo "$scene_binding" | grep -o '"key":"[^"]*"' | cut -d'"' -f4 | sed 's/OBS_KEY_//g')
            local mods=$(get_modifiers "$scene_binding")
            
            echo "  - $scene_name: ${mods}${keys}" | tr '\n' ' '
            echo
        done
    elif [[ "$action" == "ReplayBuffer" ]]; then
        echo "**Replay Buffer Save:**"
        local key=$(echo "$bindings" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/OBS_KEY_//g')
        local mods=$(get_modifiers "$bindings")
        echo "  - ${mods}${key}"
    else
        # Regular hotkey format
        local key=$(echo "$bindings" | grep -o '"key":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/OBS_KEY_//g')
        local mods=$(get_modifiers "$bindings")
        
        # Convert action name to readable format
        local readable_action="${action#OBSBasic.}"
        readable_action=$(echo "$readable_action" | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //')
        
        if [ -n "$key" ]; then
            echo "- **$readable_action:** ${mods}${key}"
        fi
    fi
}

# Check if profile directory exists
if [ ! -d "$OBS_PROFILE_DIR" ]; then
    echo "Error: OBS Sticks profile not found at $OBS_PROFILE_DIR"
    echo "Make sure OBS Studio (Flatpak) is installed and the Sticks profile exists."
    exit 1
fi

basic_ini="$OBS_PROFILE_DIR/basic.ini"

if [ ! -f "$basic_ini" ]; then
    echo "Error: Configuration file not found at $basic_ini"
    exit 1
fi

if [ ! -f "$OBS_SCENES_FILE" ]; then
    echo "Error: Scene collection file not found at $OBS_SCENES_FILE"
    exit 1
fi

echo "Processing OBS hotkeys..."

# Initialize output file
{
    echo "# OBS Studio Hotkeys - Sticks Profile"
    echo ""
    echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    echo "## Global Hotkeys"
    echo ""
    
    # Extract and parse hotkeys section from profile
    in_hotkeys=0
    while IFS= read -r line; do
        if [[ "$line" == "[Hotkeys]" ]]; then
            in_hotkeys=1
            continue
        elif [[ "$line" =~ ^\[.*\]$ ]]; then
            in_hotkeys=0
        elif [ $in_hotkeys -eq 1 ] && [[ "$line" =~ ^[^=]+=.* ]]; then
            parse_hotkey "$line"
        fi
    done < "$basic_ini"
    
    echo ""
    echo "## Scene Hotkeys"
    echo ""
    
    # Parse scene hotkeys from JSON file using jq
    if command -v jq >/dev/null 2>&1; then
        jq -r '.sources[] | select(.hotkeys != {} and .hotkeys != null) | 
            select(.hotkeys."OBSBasic.SelectScene" != null and (.hotkeys."OBSBasic.SelectScene" | length) > 0) | 
            .name as $name | 
            .hotkeys."OBSBasic.SelectScene"[] | 
            "- **Switch to \($name):** \(.key | gsub("OBS_KEY_"; "") | gsub("NUM"; "Numpad ") | gsub("ESCAPE"; "Esc"))"' \
            "$OBS_SCENES_FILE" 2>/dev/null | sort
    else
        echo "Note: jq is not installed. Scene hotkeys cannot be parsed."
        echo "Install jq to see scene-specific hotkeys: sudo apt install jq"
    fi
    
    echo ""
    echo "## Source Show/Hide Hotkeys"
    echo ""
    
    # Parse source visibility hotkeys
    if command -v jq >/dev/null 2>&1; then
        # Get scene names and their source visibility hotkeys
        jq -r '.sources[] | 
            select(.hotkeys != {} and .hotkeys != null) | 
            .name as $scene_name | 
            .hotkeys | to_entries[] | 
            select(.key | startswith("libobs.show_scene_item") or startswith("libobs.hide_scene_item")) | 
            select(.value != [] and (.value | length) > 0) | 
            .key as $action_key | 
            .value[] | 
            if $action_key | startswith("libobs.show_scene_item") then
                "- **Show source in \($scene_name):** \(.key // "None" | gsub("OBS_KEY_"; "") | gsub("NUM"; "Numpad ") | gsub("ESCAPE"; "Esc"))"
            else
                "- **Hide source in \($scene_name):** \(.key // "None" | gsub("OBS_KEY_"; "") | gsub("NUM"; "Numpad ") | gsub("ESCAPE"; "Esc"))"
            end' \
            "$OBS_SCENES_FILE" 2>/dev/null | grep -v "None" | sort
        
        # Check if there were any source hotkeys
        source_count=$(jq '[.sources[] | select(.hotkeys != {} and .hotkeys != null) | .hotkeys | to_entries[] | select(.key | startswith("libobs.show_scene_item") or startswith("libobs.hide_scene_item")) | select(.value != [] and (.value | length) > 0)] | length' "$OBS_SCENES_FILE" 2>/dev/null)
        if [ "$source_count" = "0" ]; then
            echo "No source show/hide hotkeys configured."
        fi
    fi
} > "$OUTPUT_FILE"

echo ""
echo "Hotkeys list saved to: $OUTPUT_FILE"
