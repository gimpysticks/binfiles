#!/bin/sh
sudo add-apt-repository ppa:oranchelo/oranchelo-icon-theme
sudo add-apt-repository ppa:moka/daily
sudo add-apt-repository ppa:system76/pop
sudo add-apt-repository ppa:snwh/pulp
sudo add-apt-repository ppa:ravefinity-project/ppa
sudo add-apt-repository ppa:noobslab/icons
sudo apt-add-repository ppa:numix/ppa
sudo add-apt-repository ppa:ravefinity-project/ppa
sudo add-apt-repository ppa:noobslab/icons2
sudo add-apt-repository ppa:papirus/papirus
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 90127F5B
echo "deb http://downloads.sourceforge.net/project/xenlism-wildfire/repo deb/" | sudo tee -a /etc/apt/sources.list
########################################
sudo apt update
########################################
sudo apt-get install oranchelo-icon-theme
sudo apt install vibrancy-colors
sudo apt-get install obsidian-1-icons
sudo apt-get install shadow-icon-theme
sudo apt-get install vivacious-colors
sudo apt-get install square-icons
sudo apt-get install xenlism-wildfire-icon-theme
sudo apt-get install dalisha-icons
sudo apt-get install uniform-icons
sudo apt-get install numix-icon-theme-circle
sudo apt-get install moka-icon-theme
sudo apt-get install paper-icon-theme
sudo apt install papirus-icon-theme
sudo apt install pop-icon-theme

