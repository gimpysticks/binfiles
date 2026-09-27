#!/bin/bash
# ==============================================================================
# rb - System Reboot for Pop!_OS COSMIC / systemd
# ==============================================================================

DRY_RUN=0
FORCE=0
for arg in "$@"; do
    case "$arg" in
        -f|--force|-i|--ignore-inhibitors)
            FORCE=1
            ;;
        -n|--dry-run)
            DRY_RUN=1
            ;;
    esac
done

if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] Testing reboot capability (no actual reboot)..."
    if [ "$FORCE" -eq 1 ]; then
        systemctl --dry-run reboot -i && echo "[dry-run] Authorization confirmed for unprivileged reboot (ignoring inhibitors)." && exit 0
    else
        systemctl --dry-run reboot && echo "[dry-run] Authorization confirmed for unprivileged reboot." && exit 0
    fi
    echo "[dry-run] Direct reboot not authorized; would require sudo."
    exit 0
fi

# Notify desktop session if running under graphical environment
if command -v notify-send &>/dev/null && [ -n "$DISPLAY$WAYLAND_DISPLAY" ]; then
    notify-send -u critical -i system-reboot "Pop!_OS COSMIC" "Rebooting system..." 2>/dev/null || true
fi

echo "Initiating system reboot..."

# 1. Preferred modern method: unprivileged systemctl reboot via systemd-logind
# In a Pop!_OS COSMIC desktop session, local seat users are authorized by polkit
# to cleanly reboot without requiring root or sudo.
if [ "$FORCE" -eq 1 ]; then
    systemctl reboot -i 2>/dev/null && exit 0
else
    systemctl reboot 2>/dev/null && exit 0
fi

# 2. Fallback to sudo if unprivileged reboot was rejected (e.g. SSH / non-seat session)
echo "[*] Direct reboot not permitted; authenticating with sudo..."
if [ -n "$USERPASS" ]; then
    if [ "$FORCE" -eq 1 ]; then
        printf '%s\n' "$USERPASS" | sudo -S systemctl reboot -i 2>/dev/null || printf '%s\n' "$USERPASS" | sudo -S reboot -f
    else
        printf '%s\n' "$USERPASS" | sudo -S systemctl reboot 2>/dev/null || printf '%s\n' "$USERPASS" | sudo -S reboot
    fi
else
    if [ "$FORCE" -eq 1 ]; then
        sudo systemctl reboot -i 2>/dev/null || sudo reboot -f
    else
        sudo systemctl reboot 2>/dev/null || sudo reboot
    fi
fi
