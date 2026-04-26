#!/usr/bin/env python3
import os
import sys
import tempfile
from openai import OpenAI

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if not text_to_speak:
        print("No text provided.", file=sys.stderr)
        sys.exit(1)

    fd, temp_file = tempfile.mkstemp(suffix=".mp3", prefix="openai_tts_")
    os.close(fd)
    try:
        print("Generating speech...", file=sys.stderr)
        client = OpenAI()
        response = client.audio.speech.create(
            model="tts-1",
            voice="echo",
            input=text_to_speak,
        )
        response.write_to_file(temp_file)
        os.system(f"mpg123 -q {temp_file}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

# Supported voices for model="tts-1":
# alloy
# ash
# coral
# echo
# fable
# onyx
# nova
# sage
# shimmer
