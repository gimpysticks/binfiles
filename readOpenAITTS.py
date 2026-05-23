#!/usr/bin/env python3
import os
import subprocess
import sys
import tempfile
from openai import OpenAI

def notify(title, message, urgency="normal"):
    subprocess.Popen(["notify-send", "-u", urgency, title, message])

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if not text_to_speak:
        notify("Read Human (OpenAI)", "No text provided.")
        sys.exit(1)

    fd, temp_file = tempfile.mkstemp(suffix=".mp3", prefix="openai_tts_")
    os.close(fd)
    try:
        client = OpenAI()
        response = client.audio.speech.create(
            model="tts-1",
            voice="echo",
            input=text_to_speak,
        )
        response.write_to_file(temp_file)
        os.system(f"mpg123 -q {temp_file}")
    except Exception as e:
        notify("Read Human (OpenAI)", f"Error: {e}", "critical")
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
