#!/bin/sh
grep -i -A 2 -B 2 "$1" /home/sticks/.config/openbox/rc.xml
