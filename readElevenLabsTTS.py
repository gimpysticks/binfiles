#!/usr/bin/env python3
import os
import sys
import tempfile
from elevenlabs import ElevenLabs

# Default voice/model; tweak as desired.
VOICE_ID = "1TE7ou3jyxHsyRehUuMB"
MODEL_ID = "eleven_multilingual_v2"

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if not text_to_speak:
        print("No text provided.", file=sys.stderr)
        sys.exit(1)

    fd, temp_file = tempfile.mkstemp(suffix=".mp3", prefix="elevenlabs_tts_")
    os.close(fd)
    try:
        print("Generating speech...", file=sys.stderr)
        # ElevenLabs() reads ELEVENLABS_API_KEY from the environment.
        client = ElevenLabs()
        audio = client.text_to_speech.convert(
            text=text_to_speak,
            voice_id=VOICE_ID,
            model_id=MODEL_ID,
        )
        with open(temp_file, "wb") as f:
            for chunk in audio:
                f.write(chunk)
        os.system(f"mpg123 -q {temp_file}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

# Popular pre-made voice IDs:
# JBFqnCBsd6RMkjVDRZzb  George     (male, narrative)
# EXAVITQu4vr4xnSDxMaL  Sarah      (female, soft)
# onwK4e9ZLuTAKqWW03F9  Daniel     (male, authoritative)
# XB0fDUnXU5powFXDhCwa  Charlotte  (female, conversational)
# WjFBu0iZUdHEAU667n2a  gimpysticks
# 1SjPSPlX9pxOYy7FCOqX  Mature British female
# VcyGZynTFi3sLWTwHfgd  Hard Cockney female.
# 1TE7ou3jyxHsyRehUuMB  Eastend Steve

# Models:
# eleven_v3              highest quality, emotional range (70+ langs)
# eleven_multilingual_v2 high quality, long-form (29 langs)
# eleven_flash_v2_5      ultra-low latency (~75ms, 32 langs)
# eleven_turbo_v2_5      balanced quality/speed (~250ms, 32 langs)
