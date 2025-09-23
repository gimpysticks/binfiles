#!/bin/sh
tmux send-keys -N $1 -t 'minecraft' "$2 " Enter
