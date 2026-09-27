#!/bin/sh
#Default netcard
#https://openweathermap.org/city/4291945
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i 's/metric/imperial/g' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i 's/2803138/4291945/g' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i 's/enp0s31f6/enp9s0/g' {} \;
find $HOME/.config/conky/ -name '*.lua' -exec sed -i 's/enp0s31f6/enp9s0/g' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i 's/wls33/enp9s0/g' {} \;
find $HOME/.config/conky/lua/ -name '*.lua' -exec sed -i 's/enp0s31f6/enp9s0/g' {} \;
find $HOME/.config/conky/lua/ -name '*.lua' -exec sed -i 's/wls33/enp9s0/g' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i 's/enp2s0/enp9s0/g' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i '/S Y S T E M/d' {} \;
find $HOME/.config/conky/ -name '*.conkyrc' -exec sed -i '/S H O R T/d' {} \;
