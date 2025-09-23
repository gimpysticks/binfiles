#!/bin/sh
WEBHOOK_URL="$BACKUP_HOOKWEB"
#-------Start Notify--------------------------------------------------------------
beginmsg="$1 on $(hostname) Start Message sent $(date +%c)"
MESSAGE="$(echo $beginmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
for x in {1..1000};
do
    echo $x > /dev/null
done
notify-send -i "Message " "$x"
endmsg="$1 on $(hostname) End Message sent $(date +%c)"
/usr/bin/notify-send -t 0 "$(echo $endmsg)"
MESSAGE="$(echo $endmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
