#!/bin/sh
sudo apt -y install cifs-utils nfs-common nfs-server
if [ ! -d /mnt/backup ]; then
    sudo mkdir /mnt/backup
    sudo chmod -R 777 /mnt/backup
fi

if [ ! -d /mnt/music ]; then
    sudo mkdir /mnt/music
    sudo chmod -R 777 /mnt/music
fi

if [ ! -d /mnt/videos ]; then
    sudo mkdir /mnt/videos
    sudo chmod -R 777 /mnt/videos
fi

if [ ! -d /mnt/documents ]; then
    sudo mkdir /mnt/documents
    sudo chmod -R 777 /mnt/documents
fi

if [ ! -d /mnt/pictures ]; then
    sudo mkdir /mnt/pictures
    sudo chmod -R 777 /mnt/pictures
fi

if [ ! -d /mnt/diskImages ]; then
    sudo mkdir /mnt/diskImages
    sudo chmod -R 777 /mnt/diskImages
fi

if [ ! -d /mnt/movies ]; then
    sudo mkdir /mnt/movies
    sudo chmod -R 777 /mnt/movies
fi
sudo mount -all
