#!/bin/sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install preload
sudo apt-get -y install ssh
sudo apt-get -y install screen
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb
sudo dpkg -i webmin_1.791_all.deb
sudo rm -rf webmin_1.791_all.deb
sudo apt-get -y install mint-backgrounds-*
sudo apt-get -y install chromium-browser
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get -y install google-chrome-stable
sudo apt-get -y install pepperflashplugin-nonfree
sudo dpkg-reconfigure pepperflashplugin-nonfree
sudo apt-get -y install libdvdread4
sudo /usr/share/doc/libdvdread4/install-css.sh
sudo apt-get -y install skype
sudo apt-get -y install unace p7zip-rar sharutils rar arj lunzip lzip
sudo apt-get -y install clipit
#sudo apt-get -y install mint-meta-mate
sudo apt-get autoremove
apt-get -y install -f
sudo apt-get update
sudo add-apt-repository -y ppa:audacity-team/daily
sudo apt-get -y install recordmydesktop recorditnow cheese guvcview audacity
sudo apt-get -y install idle3 idle3-tools eric
sudo apt-get -y install python-software-properties pkg-config software-properties-common
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt-get update
sudo apt-get -y install kodi kodi-audioencoder-*
sudo add-apt-repository -y ppa:soylent-tv/screenstudio
sudo apt-get update
sudo add-apt-repository -y ppa:me-davidsansome/clementine
sudo apt-get update
sudo apt-get -y install clementine
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59
sudo add-apt-repository -y "deb http://repository.spotify.com stable non-free"
sudo apt-get update
sudo apt-get -y install spotify-client
sudo add-apt-repository -y ppa:dlynch3
sudo apt-get update
sudo apt-get -y install geany scite
sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
