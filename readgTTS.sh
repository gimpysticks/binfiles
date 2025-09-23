#!/bin/sh
 killall gtts-cli mpv
 gtts-cli "$(xsel -o)"|mpv -
