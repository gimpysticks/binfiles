#!/bin/sh
echo -e $USERPASS|sudo -S mount -t cifs -o username=sticks,password=$userpass -rw //192.168.0.2/adult /media
#clear
#notify-send "Media Mounted"
kdialog --passivepopup 'Media Mounted' 5
