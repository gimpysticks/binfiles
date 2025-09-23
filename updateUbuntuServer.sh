#!/bin/sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install preload
sudo apt-get -y install ssh
sudo apt-get -y install screen tmux
sudo apt-get -y install python-software-properties pkg-config software-properties-common
sudo apt-get -y install unace p7zip-rar sharutils rar arj lunzip lzip
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb
sudo dpkg -i webmin_1.791_all.deb
sudo rm -rf webmin_1.791_all.deb
sudo apt-get -y install oracle-java8-installer
apt-get -y install -f
