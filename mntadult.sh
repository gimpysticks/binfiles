#!/bin/bash

if [[ $(findmnt -m "/mnt/adult") ]]; then
    echo -e $USERPASS|sudo -S umount /mnt/adult
    sleep 1
    echo -e $USERPASS|sudo -S rmdir /mnt/adult
    sleep 1
    clear
    echo "Unmounted"
else
    echo -e $USERPASS|sudo -S mkdir -p /mnt/adult
    sleep 1
    # echo -e $USERPASS|sudo -S mount -t cifs -o username="$USER",password="$USERPASS" -o sec="ntlmv2" //192.168.4.2/adult /mnt/adult
    echo -e $USERPASS|sudo -S mount 192.168.4.2:/data/adult /mnt/adult
    sleep 1
    clear
    echo 'Mounted'
    echo -e $USERPASS|sudo -S chmod 755 /mnt/adult/*
fi
