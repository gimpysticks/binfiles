#!/bin/sh
MCRCON_PASS='!minecraft12345!'
MCRCON_PORT=36251
mcrcon -H 192.168.0.3 -p $MCRCON_PASS -P $MCRCON_PORT "say hello"


