#!/bin/sh
tmux new-session -n 'pract_vim' -d
tmux send -t pract_vim "vim -u ~/bin/code/essential.vim"  ENTER
tmux split-window -v
tmux select-pane -t 1
tmux resize-pane -D 10
tmux send -t pract_vim "clear" ENTER
tmux select-pane -t 0
tmux rename-window 'pract_vim'
tmux send-keys -t pract_vim C-l
tmux select-pane -t 0
tmux a
