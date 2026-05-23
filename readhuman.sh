#!/bin/sh
# Reads selected text using OpenAI TTS for a human-like voice.

# Load environment variables (needed when run from a keybinding)
. ~/.envrc

killall mpg123 readOpenAITTS.py > /dev/null 2>&1

# Try primary selection (highlighted text) first, fall back to clipboard
TEXT=$(xclip -selection primary -o 2>/dev/null)
if [ -z "$TEXT" ]; then
    TEXT=$(xclip -selection clipboard -o 2>/dev/null)
fi

if [ -z "$TEXT" ]; then
    notify-send -u normal "Read Human (OpenAI)" "No text selected or copied."
    exit 1
fi

notify-send -u low "Read Human (OpenAI)" "Generating speech..."
echo "$TEXT" | /home/sticks/bin/readOpenAITTS.py
