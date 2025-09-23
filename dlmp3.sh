#!/bin/sh
cd /home/sticks/Downloads/mp3_dl
rm /home/sticks/Downloads/mp3_dl/*
while read f;
  do
    youtube-dl --extract-audio --audio-format mp3 $f
  done</home/sticks/Desktop/mp3_downloads.txt
