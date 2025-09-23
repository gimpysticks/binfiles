#!/bin/sh
title="Started Backup at "
datetext=" Latest Backup $(date)"
echo $datetext>>/home/sticks/backup.log
/usr/bin/notify-send -t 2000 "$title" "$(date)"
/usr/bin/rsync -r -t -l -q --delete --modify-window=1 -s /home/sticks \
/mnt/backup/desktop >> /home/sticks/backup.log 2>&1 &

