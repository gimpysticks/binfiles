#!/usr/bin/env python3

import os
import sys
import pyttsx3

if __name__ == "__main__":
    text_to_speak = sys.stdin.read().strip()
    if text_to_speak:
        try:
            engine = pyttsx3.init()
            # Set properties for the voice
            voices = engine.getProperty('voices')
            # You can choose a different voice if available, e.g., voices[1]
            engine.setProperty('voice', voices[0].id) 

            # Set a faster speech rate (words per minute)
            # Default rate is often around 200 wpm. Adjust as needed.
            current_rate = engine.getProperty('rate')
            engine.setProperty('rate', 250) # Set to 250 WPM as an example

            # Save to a temporary file
            temp_file = os.path.join('/tmp', 'pyttsx3_output.mp3')
            engine.save_to_file(text_to_speak, temp_file)
            engine.runAndWait()

            # Play the audio using mpg123
            os.system(f'mpg123 {temp_file}')
            os.remove(temp_file) # Clean up the temporary file
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
    else:
        print("No text provided for pyttsx3.", file=sys.stderr)
