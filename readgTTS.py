#!/usr/bin/env python3

import os
import sys
from gtts import gTTS

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if text_to_speak:
        try:
            tts = gTTS(text=text_to_speak, lang='en', slow=False)
            # Save to a temporary file
            temp_file = os.path.join('/tmp', 'gtts_output.mp3')
            tts.save(temp_file)
            # Play the audio using mpg123
            os.system(f'mpg123 {temp_file}')
            os.remove(temp_file) # Clean up the temporary file
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
    else:
        print("No text provided for gTTS.", file=sys.stderr)
