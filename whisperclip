#!/bin/sh
# Check if filename was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <audio_file>" >&2
    exit 1
fi

AUDIO_FILE="$1"

# Check if file exists
if [ ! -f "$AUDIO_FILE" ]; then
    echo "Error: File not found: $AUDIO_FILE" >&2
    exit 1
fi

# Run whisper-cli on the audio file
/home/sticks/whisper.cpp/build/bin/whisper-cli -m /home/sticks/whisper.cpp/models/ggml-base.en.bin -f "$AUDIO_FILE"
