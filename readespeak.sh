#!/bin/sh
killall espeak-ng > /dev/null 2>&1

TEXT=$(xclip -selection primary -o 2>/dev/null)
if [ -z "$TEXT" ]; then
    TEXT=$(xclip -selection clipboard -o 2>/dev/null)
fi

if [ -z "$TEXT" ]; then
    notify-send -u normal "Read (espeak)" "No text selected or copied."
    exit 1
fi

notify-send -u low "Read (espeak)" "Reading aloud..."
echo "$TEXT" | espeak-ng -s 175 || notify-send -u critical "Read (espeak)" "espeak-ng failed."
