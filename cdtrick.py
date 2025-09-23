#!/usr/bin/env python

import os, time, random
sOpen = "eject cdrom"
sClose = "eject -t cdrom"
bopen = False
bclose = True
r = random.randint(1,6)
for x in range(1,r):
    if bclose == True:
        os.system(sOpen)
        time.sleep(r)
        bclose == False
    if bclose == False:
        os.system(sClose)
        time.sleep(r)
        bclose == True
