#!/bin/sh
sudo pacman --noconfirm -Syu preload
# sudo --noconfirm -Syu linux-headers-$(uname -r)
# sudo pacman -Syu --noconfirm -transport-https ca-certificates curl software-properties-common
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -key add -
sudo pacman --noconfirm -Syu ssh
sudo pacman --noconfirm -Syu tmux
sudo pacman --noconfirm -Syu neovim
sudo -Syu --noconfirm git
# git clone https://github.com/gimpysticks/bashscripts.git ~/bin
git clone https://github.com/myusuf3/numbers.vim.git ~/.vim/bundle/numbers
sudo pacman --noconfirm -Syu ranger
sudo pacman --noconfirm -Syu xdotool
sudo pacman --noconfirm -Syu wmctrl
sudo pacman --noconfirm -Syu xvfb
sudo pacman --noconfirm -Syu xsel
sudo pacman --noconfirm -Syu espeak
sudo pacman --noconfirm -Syu unetbootin
sudo  --noconfirm -Syu htop glances at
sudo pacman --noconfirm -Syu espeak-data
sudo pacman --noconfirm -Syu ffmpeg
sudo  --noconfirm -Syu gimp
sudo pacman --noconfirm -Syu obs-studio
sudo  --noconfirm -Syu darktable
sudo  --noconfirm -Syu flatpak
sudo  --noconfirm -Syu powerwake
sudo --noconfirm -Syu thunderbird corebird calibre lifrea
sudo pacman --noconfirm -Syu etcher-electron
sudo  -Syu --noconfirm nautilus-reduceimages
sudo pacman --noconfirm -Syu nfs-common nfs-server cifs-utils sni-qt
sudo  --noconfirm -Syu wine-stable
sudo pacman --noconfirm -Syu python-software-properties pkg-config python3.6
sudo pacman --noconfirm -Syu python3-venv
sudo  -Syu --noconfirm virtualenv
sudo  -Syu --noconfirm python3-pip
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#sudo -H pip3 -Syu git+git://github.com/Lokaltog/powerline
#wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
#wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
#sudo mv PowerlineSymbols.otf /usr/share/fonts/
#sudo fc-cache -vf /usr/share/fonts/
#sudo mv 10-powerline-symbols.conf /etc/fonts/conf.d/
sudo pacman --noconfirm -Syu chromium-browser
sudo pacman --noconfirm -Syu neofetch
sudo pacman --noconfirm -Syu unace p7zip-rar sharutils rar arj lunzip lzip
sudo pacman --noconfirm -Syu gnubg gnubg-data
sudo pacman --noconfirm -Syu obs-studio filezilla
sudo pacman --noconfirm -Syu idle3 idle3-tools
sudo pacman --noconfirm -Syu clementine cmus cmus-*
sudo pacman --noconfirm -Syu inkscape scribus shutter gimp
sudo pacman --noconfirm -Syu mumble
#==============================================
# Install Minecraft
sudo mkdir -p /usr/share/minecraft/
wget -c http://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar
chmod a+x Minecraft.jar
sudo mv Minecraft.jar /usr/share/minecraft/
#==============================================
sudo pacman --noconfirm -Syu steam
