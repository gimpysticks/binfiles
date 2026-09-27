#!/usr/bin/env bash
# raid-restore.sh
# Run this on Tuesday after inserting the new drive into bay 3 (sdc).
# Copies partition table from sdb, adds sdc to all arrays, and monitors rebuild.

set -euo pipefail

NAS="root@192.168.4.2"

echo "=== Copying partition table from sdb to new sdc ==="
ssh "$NAS" "sfdisk -d /dev/sdb | sfdisk /dev/sdc"

echo "=== Waiting 2 seconds for partitions to settle ==="
sleep 2

echo "=== Adding sdc partitions to RAID arrays ==="
ssh "$NAS" "/sbin/mdadm --manage /dev/md0   --add /dev/sdc1"
ssh "$NAS" "/sbin/mdadm --manage /dev/md1   --add /dev/sdc2"
ssh "$NAS" "/sbin/mdadm --manage /dev/md127 --add /dev/sdc3"

echo "=== Array status — rebuild in progress ==="
ssh "$NAS" "cat /proc/mdstat"

echo ""
echo "Rebuild has started. Monitor progress with:"
echo "  watch -n5 'ssh $NAS cat /proc/mdstat'"
echo ""
echo "Once all arrays show [UUUU] and no rebuild activity, run:"
echo "  systemctl enable --now backup-sticks.timer"
