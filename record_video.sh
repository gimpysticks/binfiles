#!/bin/sh
export VIDOUTPATH=/mnt/videos/webcams/$(hostname)-$(whoami)-Webcam-$(date +%F-T%H%M%S).mkv
echo $VIDOUTPATH
ffmpeg -f alsa -r 41000 -i hw:2,0 -f video4linux2 -s 800x600 -i /dev/video0 -r 30 -f avi -vcodec mpeg4 -acodec libmp3lame -ab 128k $VIDOUTPATH
