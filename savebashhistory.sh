#!/bin/sh
newfile=bash-history-$(date +%F-%H%M).txt
/bin/cp /home/sticks/.bash_history /home/sticks/saved_bash_history/$newfile
