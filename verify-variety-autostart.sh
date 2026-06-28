#!/bin/bash
# Verify Variety wallpaper changer started after reboot.
# Run this ~30 seconds after login (variety autostart has a 20s delay).
# Usage: ~/bin/verify-variety-autostart.sh

LOG="$HOME/.config/variety/variety.log"
PASS="\033[32m✓\033[0m"
FAIL="\033[31m✗\033[0m"

echo "=== Variety Post-Reboot Verification ==="
echo ""

# 1. Process running?
PID=$(pgrep -f "/usr/bin/variety" | head -1)
if [ -n "$PID" ]; then
    echo -e "$PASS Variety is running (PID $PID)"
else
    echo -e "$FAIL Variety is NOT running"
    echo "  Try: variety &"
fi

# 2. Responding to commands?
CURRENT=$(variety --current 2>&1)
if [ $? -eq 0 ] && [[ "$CURRENT" != *"Error"* ]] && [[ "$CURRENT" != *"not running"* ]]; then
    echo -e "$PASS Variety responds to --current"
    echo "  Wallpaper: $(basename "$CURRENT")"
else
    echo -e "$FAIL Variety not responding to commands"
fi

# 3. Template files intact?
MISSING=0
for f in config/variety.conf config/ui.conf config/sources.txt config/filters.txt \
         scripts/set_wallpaper scripts/get_wallpaper scripts/set_lock_screen; do
    if [ ! -f "/usr/lib/python3/dist-packages/variety/data/$f" ]; then
        echo -e "$FAIL Missing: data/$f"
        MISSING=1
    fi
done
if [ "$MISSING" -eq 0 ]; then
    echo -e "$PASS All package template files present"
fi

# 4. Autostart entry?
if [ -f "$HOME/.config/autostart/variety.desktop" ]; then
    echo -e "$PASS Autostart desktop entry exists"
else
    echo -e "$FAIL No autostart entry found"
fi

# 5. Recent log activity (within last 5 minutes)?
if [ -f "$LOG" ]; then
    RECENT=$(find "$LOG" -mmin -5 2>/dev/null)
    if [ -n "$RECENT" ]; then
        echo -e "$PASS Log file updated recently"
    else
        echo -e "  ⚠ Log file not updated in last 5 minutes"
    fi
    # Check for fatal errors in last 20 lines
    FATAL=$(tail -20 "$LOG" 2>/dev/null | grep -i "FileNotFoundError\|ModuleNotFoundError\|ImportError" | head -1)
    if [ -n "$FATAL" ]; then
        echo -e "$FAIL Fatal error in log: $FATAL"
    fi
else
    echo "  ⚠ No log file found at $LOG"
fi

echo ""
echo "Done."
