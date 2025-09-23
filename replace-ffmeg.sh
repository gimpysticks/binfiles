#!/bin/sh
# Replace avconv with the real ffmpeg
#   www.askubuntu.com/a/373509/165265
#
sudo apt-get remove ffmpeg
sudo apt-get purge libav-tools
sudo add-apt-repository ppa:jon-severinsson/ffmpeg
sudo apt-get update
sudo apt-get install ffmpeg
sudo apt-get install frei0r-plugins              # recommended
sudo apt-get --purge autoremove
