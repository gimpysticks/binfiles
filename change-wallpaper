#!/usr/bin/env bash
# change-wallpaper.sh - Set random Midjourney wallpaper (supports COSMIC & GNOME)

RANDOM_IMAGE=$(find "$HOME/Midjourney" -maxdepth 1 -name "*.png" 2>/dev/null | shuf -n 1)

if [ -z "$RANDOM_IMAGE" ] || [ ! -f "$RANDOM_IMAGE" ]; then
    echo "No PNG images found in $HOME/Midjourney" >&2
    exit 1
fi

echo "Setting wallpaper to: $RANDOM_IMAGE"

# 1. Pop!_OS COSMIC desktop support
COSMIC_BG="$HOME/.config/cosmic/com.system76.CosmicBackground/v1/all"
if [ -f "$COSMIC_BG" ] || [ "${XDG_CURRENT_DESKTOP:-}" = "COSMIC" ]; then
    mkdir -p "$(dirname "$COSMIC_BG")"
    cat > "$COSMIC_BG" << EOL
(
    output: "all",
    source: Path("$RANDOM_IMAGE"),
    filter_by_theme: false,
    rotation_frequency: 3600,
    filter_method: Lanczos,
    scaling_mode: Zoom,
    sampling_method: Alphanumeric,
)
EOL
fi

# 2. GNOME fallback
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_IMAGE" 2>/dev/null || true
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$RANDOM_IMAGE" 2>/dev/null || true
fi
