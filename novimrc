#!/bin/sh
tmux new-session -n 'novimrc' -d
tmux send -t novimrc "vim -u NONE -N" ENTER
tmux split-window -v
tmux select-pane -t 1
tmux resize-pane -D 10
tmux send -t novimrc "clear" ENTER
tmux select-pane -t 0
tmux rename-window 'novimrc'
tmux send-keys -t novimrc C-l
tmux select-pane -t 0
tmux a
