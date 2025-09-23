#!/bin/bash

sudo apt clean | tee -a ~/updates.txt

sudo apt update -m | tee -a ~/updates.txt

sudo dpkg --configure -a | tee -a ~/updates.txt

sudo apt install -f | tee -a ~/updates.txt

sudo apt full-upgrade | tee -a ~/updates.txt

sudo apt autoremove --purge | tee -a ~/updates.txt

sudo apt install pop-desktop gdm3 | tee -a ~/updates.txt

flatpak update --appstream

flatpak repair --user

sudo flatpak repair --system

flatpak update

flatpak uninstall --unused
