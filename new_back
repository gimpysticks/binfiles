#!/bin/sh
# $1 = user
# $2 = destinaionfiles
if [ $# -eq 0 ]
    then
        echo "USAGE: '$0' username destinationpath"
        exit 1
fi
# echo -e $USERPASS|sudo -S mount -a
sleep 5
tmpfile="/home/$1/backup.tmp"
WEBHOOK_URL="$BACKUP_HOOKWEB"
#-------Start Notify--------------------------------------------------------------
beginmsg="$1 on $(hostname) Backup script Started  $(date +%c)"
/usr/bin/notify-send -t 0 "$(echo $beginmsg)"
MESSAGE="$(echo $beginmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
#-------Run Script--------------------------------------------------------------
param='-rtDvz'
rsync -rtDvz --delete --exclude-from "/home/$1/bin/rsyncexclude.txt" \
--delete-after --delete-excluded /home/$1 $2 2>&1 >> \
/mnt/backup/logs/$(hostname)-$1-$(date +%Y%m%d%H%M).log
#-------End Notify--------------------------------------------------------------
endmsg="$1 on $(hostname) Backup script completed  $(date +%c)"
/usr/bin/notify-send -t 0 "$(echo $endmsg)"
MESSAGE="$(echo $endmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
