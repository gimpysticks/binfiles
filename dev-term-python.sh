#!/bin/sh
tmux new-session -n 'python-dev' -d
tmux send -t python-dev 'cd /home/sticks/src/pythonfiles' ENTER
sleep 1
tmux send -t python-dev "vim" ENTER
tmux split-window -h
tmux send -t python-dev "clear" ENTER
tmux send -t python-dev 'cd /home/sticks/src/pythonfiles' ENTER
sleep 1
tmux send -t python-dev "bpython" ENTER
tmux split-window -v
tmux send -t python-dev 'cd /home/sticks/src/pythonfiles' ENTER
tmux resize-pane -D 10
tmux send -t python-dev "clear" ENTER
tmux rename-window 'python_dev'
tmux select-pane -t 1
tmux send-keys -t python-dev C-l
tmux select-pane -t 0
tmux a
