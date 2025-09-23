#!/bin/sh
sudo add-apt-repository -y ppa:flexiondotorg/hal-flash
sudo add-apt-repository -y ppa:flexiondotorg/minecraft
sudo add-apt-repository -y ppa:audacity-team/daily
sudo add-apt-repository -y ppa:pj-assis/testing
sudo add-apt-repository -y ppa:peterlevi/ppa
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo add-apt-repository -y ppa:me-davidsansome/clementine
sudo add-apt-repository -y ppa:dlynch3
sudo add-apt-repository -y ppa:webupd8team/java
sudo add-apt-repository -y ppa:mystic-mirage/pycharm
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo add-apt-repository -y ppa:webupd8team/atom
sudo add-apt-repository -y ppa:ravefinity-project/ppa
sudo add-apt-repository -y ppa:mmk2410/intellij-idea-community
sudo add-apt-repository -y ppa:atareao/atareao
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
echo "deb http://apt.insynchq.com/ubuntu $(lsb_release -cs) non-free" | sudo tee /etc/apt/sources.list.d/insync.list
wget -O - https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key | sudo apt-key add -
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb http://apt.syncthing.net/ syncthing release" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install preload
sudo apt-get -y install ssh
sudo apt-get -y install screen cifs-utils nfs-common nfs-kernel-server
sudo apt-get -y install vinagre
sudo apt-get -y install python-software-properties pkg-config software-properties-common intellij-idea-community
sudo apt-get -y install chromium-browser
sudo apt-get -y install libhal1-flash
sudo apt-get -y install gparted
sudo apt-get -y install google-chrome-stable
sudo apt-get -y install pepperflashplugin-nonfree
sudo dpkg-reconfigure pepperflashplugin-nonfree
sudo apt-get -y install libdvdread4
sudo /usr/share/doc/libdvdread4/install-css.sh
sudo apt-get -y install kodi kodi-audioencoder-*
sudo apt-get -y install variety my-weather-indicator
sudo apt-get -y install syncthing
sudo apt-get -y install skype
sudo apt-get -y install unace p7zip-rar sharutils rar arj lunzip lzip avahi-discover
sudo apt-get -y install clipit
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.801_all.deb
sudo dpkg -i webmin_1.801_all.deb
sudo rm -rf webmin_1.801_all.deb
sudo apt-get -y install minecraft-installer
sudo apt-get -y install -f
#wget https://launchpad.net/~minecraft-installer-peeps/+archive/ubuntu/minecraft-installer/+files/minecraft-installer_0.1%2Br11~ubuntu14.10.1_amd64.deb
sudo apt-get -y install vivacious-colors-gtk-dark vivacious-colors-gtk-light vivacious-colors vivacious-folder-colors-addon
sudo apt-get -y install vibrancy-colors
sudo apt-get -y install gnubg gnubg-data
sudo apt-get -y install recordmydesktop cheese guvcview audacity mpv guvcview redshift redshift-gtk espeak espeak-data atom filezilla irssi terminator
sudo apt-get -y install idle3 idle3-tools
sudo apt-get -y install clementine
sudo apt-get -y install geany scite
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install pycharm-community intellij-idea-community
sudo apt-get -y install mumble
sudo apt-get -y install insync insync-mate
sudo apt-get -y install zenmap
sudo apt-get -y install guake
sudo apt-get autoremove
sudo apt-get upgrade
