#!/bin/bash
# Script to monitor an rsync process and send a desktop notification upon completion.
# Usage: monitor_rsync_completion.sh <PID>

if [ -z "$1" ]; then
    echo "Usage: $0 <PID>"
    exit 1
fi

PID="$1"
LOG_FILE="/tmp/rsync_monitor_${PID}.log"

echo "Monitoring rsync process with PID: $PID. Output will be logged to $LOG_FILE"
echo "You can close this terminal. The script will continue to run in the background."

# Run in the background, detach from terminal
nohup bash -c "while ps -p $PID > /dev/null; do sleep 10; done; notify-send \"rsync complete\" \"rsync process $PID finished.\" || echo \"rsync process $PID finished.\" > $LOG_FILE" &

echo "Monitor started. PID: $!"
