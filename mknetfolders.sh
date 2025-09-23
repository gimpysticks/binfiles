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


sudo echo "192.168.4.2:/data/backup /mnt/backup nfs vers=3,proto=tcp,defaults    0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/Movies /mnt/movies nfs vers=3,proto=tcp,defaults    0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/Pictures /mnt/pictures nfs vers=3,proto=tcp,defaults	0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/Videos /mnt/videos nfs vers=3,proto=tcp,defaults    0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/Documents /mnt/Documents nfs vers=3,proto=tcp,defaults    0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/Music /mnt/music nfs vers=3,proto=tcp,defaults    0   0">>/etc/fstab
sudo echo "192.168.4.2:/data/disk_images	/mnt/diskImages	nfs vers=3,proto=tcp,defaults	0	0">>/etc/fstab
sudo echo "192.168.4.2:/data/WT-Backup	/mnt/WT-Backup	nfs vers=3,proto=tcp,defaults	0	0">>/etc/fstab

sudo mount -all
