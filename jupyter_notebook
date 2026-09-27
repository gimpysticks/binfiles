#!/bin/sh
tmux kill-server
clear
tmux new-session -n 'jupyter-notebook' -d
tmux send -t jupyter-notebook 'venv36' ENTER
tmux send -t jupyter-notebook 'jupyter notebook --ip=192.168.0.3 --port=8888 --no-browser' ENTER
echo 'Jupyter-notebook started'
