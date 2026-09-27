#!/bin/sh
tmux new-session -n 'Bash-dev' -d
tmux send -t Bash-dev "vim" ENTER
tmux split-window -v
tmux select-pane -t 1
tmux resize-pane -D 10
tmux send -t Bash-dev "clear" ENTER
tmux select-pane -t 0
tmux rename-window 'Bash-dev'
tmux send-keys -t Bash-dev C-l
tmux select-pane -t 0
tmux a
