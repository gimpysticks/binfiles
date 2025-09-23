#!/bin/sh
tmux new-session -n 'python-dev' -d
tmux send -t python-dev "vim" ENTER
tmux split-window -h
tmux send -t python-dev "clear" ENTER
tmux send -t python-dev "docker run -it --rm --name Bpython -v $HOME:/home gimpysticks/python-dev" ENTER
sleep 1
tmux send -t python-dev "/usr/local/bin/bpython" ENTER
tmux split-window -v
tmux resize-pane -D 20
tmux send -t python-dev "docker run -it --rm --name PythonCli -v $HOME:/home gimpysticks/python-dev" ENTER
tmux send -t python-dev "clear" ENTER
tmux rename-window 'python_dev'
tmux select-pane -t 1
tmux send-keys -t python-dev C-l
tmux select-pane -t 0
tmux a
