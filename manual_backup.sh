#!/bin/sh
tmux new-session -d -s Backup '/home/sticks/bin/backup.sh sticks "/mnt/backup/thelio/">/dev/null 2>&1'
#tmux a
