#!/bin/sh
xhost +
docker run --privileged -it --rm --net host --cpuset-cpus 0 --memory 1024mb -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -v $HOME/Downloads:/home/chrome/Downloads --device /dev/snd --entrypoint /bin/bash --name chrome jess/chrome:latest
