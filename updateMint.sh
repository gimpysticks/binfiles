#!/bin/sh
sudo add-apt-repository -y ppa:peterlevi/ppa
sudo add-apt-repository -y ppa:webupd8team/java
sudo add-apt-repository -y ppa:noobslab/macbuntu
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo add-apt-repository -y ppa:nilarimogard/webupd8
sudo add-apt-repository -y ppa:alexlarsson/flatpak
sudo add-apt-repository -y ppa:atareao/nautilus-extensions
sudo add-apt-repository -y ppa:noobslab/themes
sudo add-apt-repository -y ppa:noobslab/icons
sudo add-apt-repository -y ppa:noobslab/apps
sudo add-apt-repository -y ppa:webupd8team/terminix
#sudo add-apt-repository -y ppa:libreoffice/ppa
sudo add-apt-repository -y ppa:gezakovacs/ppa
#sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release
sudo add-apt-repository -y ppa:sergiomejia666/respin
sudo sh -c 'echo "deb http://apt.insynchq.com/ubuntu $(lsb_release -cs) non-free" | sudo tee /etc/apt/sources.list.d/insync.list'
wget -O - https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key | sudo apt-key add -
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#===============================================================================================================
#Spotify Key and Repository
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
#sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list'
#===============================================================================================================
sudo apt update
sudo apt upgrade
sudo apt install -y preload
sudo apt install -y linux-headers-$(uname -r)
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt install -y tmux
sudo apt install -y vim
sudo apt install -y gparted
sudo apt install -y pcmanfm
sudo apt install -y google-chrome-stable
sudo apt install -y ncdu
sudo apt install -y git
sudo apt install -y hwinfo
sudo apt install -y ubuntu-restricted-extras
sudo apt -y unstall build-essential
sudo apt install -y ssh
sudo apt install -y seahorse-nautilus
sudo apt install -y ranger
sudo apt install -y xdotool
sudo apt install -y wmctrl
sudo apt install -y xvfb
sudo apt install -y xsel
sudo apt install -y espeak
sudo apt install -y unetbootin
sudo apt install -y synaptic
sudo apt install -y dcomf-editor
sudo apt install -y htop glances at
sudo apt install -y qemu
sudo apt install -y woeusb
sudo apt install -y espeak-data
sudo apt install -y vinagre
#sudo apt install -y vino
sudo apt install -y alacarte
sudo apt install -y ffmpeg
#sudo apt install -y gimp
sudo apt install -y uget
sudo apt install -y aria2
sudo apt install -y obs-studio
#:sudo apt install -y spotify-client
sudo apt install -y darktable
sudo apt install -y flatpak
sudo apt install -y macbuntu-os-icons-v1804
sudo apt install -y macbuntu-os-ithemes-v1804
sudo apt install -y tilix grsync powerwake
sudo apt install -y corebird calibre liferea
sudo snap install discord
sudo snap install gtk-common-themes
sudo snap install odio
sudo snap install wavebox
sudo snap install wavebird
sudo apt install -y etcher-electron
sudo apt install -y nautilus-reduceimages
sudo apt install -y nfs-common nfs-server cifs-utils sni-qt
sudo apt install -y wine-stable flashplugin-installer
sudo apt install -y python-software-properties pkg-config python3.6
sudo apt install -y python3-venv
sudo apt install -y virtualenv
sudo apt install -y python3-pip
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#sudo -H pip3 install git+git://github.com/Lokaltog/powerline
#wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
#wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
#sudo mv PowerlineSymbols.otf /usr/share/fonts/
#sudo fc-cache -vf /usr/share/fonts/
#sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
#sudo apt install -y chromium-browser
sudo apt install -y neofetch
#sudo apt install -y libhal1-flash
#sudo apt install -y pepperflashplugin-nonfree
#sudo apt install -y libreoffice libreoffice-style-breeze
#sudo dpkg-reconfigure pepperflashplugin-nonfree
sudo apt install -y libdvdread4
sudo /usr/share/doc/libdvdread4/install-css.sh
sudo apt install -y libavcodec-extra
sudo apt install -y libdvd-pkg
sudo apt install -y variety
sudo apt install -y unace p7zip-rar sharutils rar arj lunzip lzip avahi-discover
sudo curl https://www.teleconsole.com/get.sh | sh
sudo wget http://prdownloads.sourceforge.net/webadmin/webmin_1.900_all.deb
sudo gdebi -n webmin_1.900_all.deb
sudo rm -rf webmin_1.900_all.deb
sudo apt install -f
sudo apt install -y gnubg gnubg-data
sudo apt install -y respin
sudo apt install -y cheese guvcview audacity mpv guvcview filezilla
sudo apt install -y idle3 idle3-tools
sudo apt install -y clementine cmus cmus-*
sudo apt install -y scribus shutter
sudo apt install -y oracle-common oracle-java8-installer
sudo apt install -y mumble
sudo apt install -y insync
sudo apt install -y zenmap
#===========================================================================
# Install Youtube-dl
sudo wget https://yt-dl.org/latest/youtube-dl -O /usr/local/bin/youtube-dl
sudo chmod a+x /usr/local/bin/youtube-dl
hash -r
#==============================================
# Install Minecraft
wget -c https://launcher.mojang.com/download/Minecraft.deb && \
sudo dpkg -i Minecraft.deb && \
sudo apt install -f && \
sudo rm Minecraft.deb
#==============================================
#==============================================
#Install Zoom client
cd /home/sticks/Downloads
wget -c https://zoom.us/client/latest/zoom_amd64.deb
sudo dpkg -i zoom_amd64.deb && sudo rm zoom_amd64.deb
#==============================================
sudo apt install -y steam
sudo apt install libnvidia-gl-390:i386
sudo apt install -f
sudo apt autoremove
sudo apt upgrade
sudo apt update

