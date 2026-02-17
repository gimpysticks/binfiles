#!/bin/sh
# Reads selected text using gTTS (Google Text-to-Speech) for a more human-like voice.

# Ensure no previous gTTS process is lingering (though mpg123 is usually quick)
killall mpg123 > /dev/null 2>&1

# Get the primary selection (highlighted text) and pipe it to the Python script
xclip -selection primary -o | /home/sticks/bin/readgTTS.py

# Optionally, to use clipboard selection instead:
# xclip -selection clipboard -o | /home/sticks/bin/readgTTS.py
