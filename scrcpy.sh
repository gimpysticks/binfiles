#!/bin/sh
/usr/bin/tmux kill-session scrpy
/usr/bin/tmux new -d -s scrpy
/usr/bin/tmux send -t scrpy "scrcpy" ENTER
