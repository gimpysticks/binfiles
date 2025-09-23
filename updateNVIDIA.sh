#!/bin/sh
sudo apt purge 'nvidia-*'
sudo apt install linux-headers-$(uname -r)
sudo apt install nvidia-384
