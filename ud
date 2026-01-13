#!/bin/bash
# Create the updatelog folder of it doesn't exist

mkdir -p $HOME/updatelogs/

# DISTRO=$(cat /etc/issue|cut -d" " -f1)
DISTRO=$(cat /etc/os-release|grep '^ID='|cut -d '=' -f2)
case "$DISTRO" in
    ubuntu|mint|pop|debian)
        echo -e $USERPASS|sudo -S apt-get -o Acquire::ForceIPv4=true update
        echo -e $USERPASS|sudo -S apt-get -y upgrade
        echo -e $USERPASS|sudo -S apt-get -y full-upgrade
        echo -e $USERPASS|sudo -S apt-get -y autoremove
        echo -e $USERPASS|sudo -S apt-get -y autoclean
        echo -e $USERPASS|sudo -S snap refresh
        echo -e $USERPASS|sudo -S flatpak update -y
        flatpak -y --user update
    ;;
    arch|salient)
        echo -e $USERPASS|sudo -S pacman -Syyu --noconfirm
        yay -Syu --noconfirm --devel
    ;;
    *)
        #Special Thanks to DG for inspiring my default error msgs
        echo "$DISTRO Not in case statement"
    ;;
esac
exit
