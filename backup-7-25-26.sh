#!/bin/sh
# $1 = user
# $2 = destinationfiles

if [ $# -lt 2 ]
    then
        echo "USAGE: '$0' username destinationpath"
        exit 1
fi

sleep 5

[ -z "$BACKUP_HOOKWEB" ] && . "$HOME/.envrc"
WEBHOOK_URL="$BACKUP_HOOKWEB"
LOG_DIR="$2/logs"

# Ensure target backup directory and log folder exist
mkdir -p "$LOG_DIR"

#-------Start Notify--------------------------------------------------------------
beginmsg="$1 on $(hostname) Backup script Started $(date +%c)"
MESSAGE="$(echo -e $beginmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"

#-------Run Script--------------------------------------------------------------
# Modified flags for exFAT compatibility (-rltDv instead of -aAXHv)
rsync -rltDv --info=progress2 --delete \
--exclude={'.cache/*','.local/share/Trash/*','.mozilla/firefox/*/Cache*/*','.mozilla/firefox/*/cache*/*','.thumbnails/*','.npm/*','node_modules/*','.yarn/*','*.tmp','*.temp','.steam/steam.token','steam.token','.local/share/Steam/*','target/debug/*','target/release/*','.cargo/registry/*','.cargo/git/*','.rustup/toolchains/*/lib/*','.wine/*','snap/*','.snapd/*','flatpak/*','.var/app/*'} \
--exclude="$2" \
"/home/$1/" "$2" >> "$LOG_DIR/$(hostname)-$1-$(date +%Y%m%d%H%M).log" 2>&1

#-------End Notify--------------------------------------------------------------
endmsg="$1 on $(hostname) Backup script completed $(date +%c)"
MESSAGE="$(echo -e $endmsg)"
PAYLOAD='{"content": "'"$MESSAGE"'"}'
curl -s -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL"