#!/bin/sh
/usr/bin/tmux send -t MC_lcl /save-all ENTER
/usr/bin/tmux send -t MC_lcl /stop ENTER
echo "Killing MC_lcl session"
/usr/bin/tmux kill-session -t MC_lcl
