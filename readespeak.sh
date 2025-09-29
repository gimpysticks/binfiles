#!/bin/sh
 killall espeak-ng
 xclip -selection clipboard -o|espeak-ng -s 175
