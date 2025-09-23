#!/bin/sh
echo -e $USERPASS|sudo -S sed -i '/0\.0\.0\.0/d' /etc/hosts
