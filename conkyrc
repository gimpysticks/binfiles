#!/bin/sh

if [[ $USER != "liveuser" && $XDG_CURRENT_DESKTOP == "i3" ]]; then
	conky -c ~/.conkyrc
else
	conky -c ~/.conkyrc-live
fi
