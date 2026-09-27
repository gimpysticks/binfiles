#!/bin/sh

for i in 192.168.0.{1..254};
do
     if ping -c1 -w1 $i &>/dev/null
     then
         echo $i is up
     fi
 done
