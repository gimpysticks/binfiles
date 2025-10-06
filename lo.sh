#!/bin/sh
DISTRO=$(cat /etc/*release|grep DISTRIB_ID|cut -d= -f2)
case "$DISTRO" in
    Ubuntu|Mint|Pop)
        gnome-session-quit --logout --no-prompt
        exit
    ;;
    Arch|Salient|MX)
        loginctl terminate-user $USER
    ;;
esac
