#!/bin/sh
doctl compute droplet create NAME MCServer --image 22864516 --region nyc3 --size 2gb --ssh-keys e4:62:6e:89:d2:25:b6:b4:8d:a2:77:d2:d0:3a:f0:97 --WAIT
