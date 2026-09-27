#!/bin/sh
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

killall gtts-cli mpv > /dev/null 2>&1

TEXT=""
# Try Wayland primary selection (highlighted text) first, then clipboard
if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-paste >/dev/null 2>&1; then
    TEXT=$(wl-paste --primary --no-newline 2>/dev/null)
    if [ -z "$TEXT" ]; then
        TEXT=$(wl-paste --no-newline 2>/dev/null)
    fi
fi

# Fall back to X11 if Wayland returned nothing or is not active
if [ -z "$TEXT" ] && command -v xclip >/dev/null 2>&1; then
    TEXT=$(xclip -selection primary -o 2>/dev/null)
    if [ -z "$TEXT" ]; then
        TEXT=$(xclip -selection clipboard -o 2>/dev/null)
    fi
fi

if [ -z "$(printf '%s' "$TEXT" | tr -d '[:space:]')" ]; then
    notify-send -u normal "Read (gTTS)" "No text selected or copied."
    exit 1
fi

notify-send -u low "Read (gTTS)" "Generating speech..."
printf '%s\n' "$TEXT" | gtts-cli - | mpv --no-video --no-terminal - || notify-send -u critical "Read (gTTS)" "gTTS playback failed."

