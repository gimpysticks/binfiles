#!/bin/sh
mv -f ~/.config/google-chrome-beta/Default/* ~/.config/google-chrome-beta/Backup/
rm -rf ~/.config/google-chrome-beta/Default
cp -R ~/.config/google-chrome-beta/Backup/ ~/.config/google-chrome-beta/Default/
