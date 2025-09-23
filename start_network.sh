#!/bin/sh
echo -e $USERPASS|sudo -S systemctl restart networking.service
echo -e $USERPASS|sudo -S sudo service network-manager restart
