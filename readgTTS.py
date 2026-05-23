#!/usr/bin/env python3

import os
import subprocess
import sys
import uuid
from gtts import gTTS

def notify(title, message, urgency="normal"):
    subprocess.Popen(["notify-send", "-u", urgency, title, message])

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if text_to_speak:
        try:
            tts = gTTS(text=text_to_speak, lang='en', slow=False)
            # Save to a uniquely named file in /tmp
            temp_file = os.path.join('/tmp', f'gtts_{uuid.uuid4().hex}.mp3')
            tts.save(temp_file)
            # Play the audio using mpg123
            os.system(f'mpg123 {temp_file}')
        except Exception as e:
            notify("Read (gTTS)", f"Error: {e}", "critical")
    else:
        notify("Read (gTTS)", "No text provided.")
