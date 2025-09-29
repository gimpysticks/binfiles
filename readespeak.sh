#!/bin/sh
 killall espeak-ng
 xclip -selection primary -o|espeak-ng -s 175
 # xclip -selection clipboard -o|espeak-ng -s 175
