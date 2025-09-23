#!/bin/sh
# $1 = user
# $2 = destinationfiles
if [ $# -eq 0 ]
    then
        echo "USAGE: '$0' username destinationpath"
        exit 1
fi
# echo -e $USERPASS|sudo -S mount -rtDvz
sleep 5
WEBHOOK_URL="https://discord.com/api/webhooks/1175156341027897354/am4XoajWvByCWM7FynU2u7yJDP9DQCr42pvjntOBXzINxsNRQbjyHovMm5EfTBE3Tj3J"
tmpfile="/home/$1/backup.tmp"
#-------Start Notify--------------------------------------------------------------
beginmsg="$1 on $(hostname) Backup script Started  $(date +%c)"
#/usr/bin/notify-send -t 0 "$(echo -e $beginmsg)"
MESSAGE="$(echo -e $beginmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
#-------Run Script--------------------------------------------------------------
# Create backup directory if it doesn't exist
mkdir -p $2

# More comprehensive exclude patterns to avoid permission errors and recursion
rsync -aAXHv --info=progress2 --delete \
--exclude={'.cache/*','.local/share/Trash/*','.mozilla/firefox/*/Cache*/*','.mozilla/firefox/*/cache*/*','.thumbnails/*','.npm/*','node_modules/*','.yarn/*','*.tmp','*.temp','.steam/steam.token','steam.token','.local/share/Steam/*','target/debug/*','target/release/*','.cargo/registry/*','.cargo/git/*','.rustup/toolchains/*/lib/*','.wine/*','snap/*','.snapd/*','flatpak/*','.var/app/*'} \
--exclude="$2" \
/home/$1/ $2 2>&1 >> /mnt/backup/logs/$(hostname)-$1-$(date +%Y%m%d%H%M).log
#-------End Notify--------------------------------------------------------------
endmsg="$1 on $(hostname) Backup script completed  $(date +%c)"
#/usr/bin/notify-send -t 0 "$(echo -e $endmsg)"
MESSAGE="$(echo -e $endmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"
