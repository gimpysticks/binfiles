#!/bin/sh


TOKEN="894327394:AAHpY2eoebJDhYHWse9-DFvu6xr3fcT2pi8"
CHAT_ID="@gimpysgroup"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
tmpfile="telegram_response.txt"
#-------Start Notify--------------------------------------------------------------
MESSAGE="$1"
if [ "$#" -eq "0" ]; then
    echo "Usage: $0 <Your message>"
    exit
else
    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" -o $tmpfile
fi
