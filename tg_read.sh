#!/bin/sh
/usr/bin/tmux kill-session tg_mark_read
/usr/bin/tmux new -d -s tg_mark_read
/usr/bin/tmux split-window -v
/usr/bin/tmux send -t tg_mark_read "telegram-cli --json -P 4458" ENTER
/usr/bin/tmux select-pane -t 0
sleep 3
/usr/bin/tmux send -t tg_mark_read "/home/sticks/mark_read/mark_read.py" ENTER
/usr/bin/tmux a
