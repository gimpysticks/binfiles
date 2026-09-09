#!/usr/bin/env bash
# diagnose-freeze.sh
#
# Run this the moment GNOME Shell starts freezing/stuttering. It captures
# live system state to a timestamped log file so the freeze can be
# diagnosed after the fact. Stop it with Ctrl+C once the freeze has passed.
#
# Usage: ~/bin/diagnose-freeze.sh

set -uo pipefail

OUTDIR="$HOME/freeze-diagnostics"
mkdir -p "$OUTDIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$OUTDIR/freeze-$STAMP.log"

echo "Logging to $LOG"
echo "Press Ctrl+C to stop once the freeze has passed."

{
  echo "=== diagnose-freeze.sh started at $(date) ==="

  echo "--- vmstat (1s interval, background) ---"
  vmstat 1 > "$OUTDIR/vmstat-$STAMP.log" &
  VMSTAT_PID=$!

  echo "--- top snapshot every 2s (background) ---"
  ( while true; do
      echo "== $(date) =="
      top -b -n1 -o %CPU | head -20
      sleep 2
    done ) > "$OUTDIR/top-$STAMP.log" &
  TOP_PID=$!

  echo "--- processes in D-state (uninterruptible I/O wait), sampled every 2s (background) ---"
  ( while true; do
      echo "== $(date) =="
      ps -eo pid,ppid,stat,etimes,cmd | awk '$3 ~ /D/'
      sleep 2
    done ) > "$OUTDIR/dstate-$STAMP.log" &
  DSTATE_PID=$!

  cleanup() {
    echo "Stopping background collectors..."
    kill "$VMSTAT_PID" "$TOP_PID" "$DSTATE_PID" 2>/dev/null
    echo "=== diagnose-freeze.sh stopped at $(date) ==="
    echo "Logs written to:"
    echo "  $OUTDIR/vmstat-$STAMP.log"
    echo "  $OUTDIR/top-$STAMP.log"
    echo "  $OUTDIR/dstate-$STAMP.log"
    echo "  $LOG (journalctl -f output)"
  }
  trap cleanup EXIT INT TERM

  echo "--- following journalctl (foreground; Ctrl+C to stop) ---"
  journalctl -f
} | tee "$LOG"
