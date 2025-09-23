#!/bin/sh
# $1 = Start Time hh:mm:ss
# $2 = Input video file
# $3 = End Time hh:mm:ss
# $4 = output video file
ffmpeg -ss "$1" -i "$2" -t "$3" -acodec copy -vcodec copy "$4"
