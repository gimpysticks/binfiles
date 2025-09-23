#!/bin/sh
/usr/bin/tmux new-session -s minecraft -d
tmux send -t minecraft "/usr/bin/java -Xmx1024M -Xms1024M -jar $HOME/minecraft/minecraft_server.jar --nogui" ENTER
