#!/bin/sh
killall gtts-cli mpv > /dev/null 2>&1

TEXT=$(xclip -selection primary -o 2>/dev/null)
if [ -z "$TEXT" ]; then
    TEXT=$(xclip -selection clipboard -o 2>/dev/null)
fi

if [ -z "$TEXT" ]; then
    notify-send -u normal "Read (gTTS)" "No text selected or copied."
    exit 1
fi

notify-send -u low "Read (gTTS)" "Generating speech..."
gtts-cli "$TEXT" | mpv - || notify-send -u critical "Read (gTTS)" "gTTS playback failed."
