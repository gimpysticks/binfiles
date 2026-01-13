#!/usr/bin/env zsh

# Select a random PNG from the Midjourney folder
RANDOM_IMAGE=$(ls ~/Midjourney/*.png | shuf -n 1)

# Set it as wallpaper for both light and dark modes
gsettings set org.gnome.desktop.background picture-uri "file://$RANDOM_IMAGE"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$RANDOM_IMAGE"
