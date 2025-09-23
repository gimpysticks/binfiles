#!/bin/sh
for i in `seq 1 254`
do
    ping -c 1 -t 1 192.168.0.$i|grep "64 bytes" &
done

