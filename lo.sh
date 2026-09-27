#!/bin/sh
# lo.sh - Session logout script (COSMIC / GNOME / systemd)

if [ "${XDG_CURRENT_DESKTOP:-}" = "COSMIC" ] || [ -n "${COSMIC_SESSION_BUS:-}" ]; then
    loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null || loginctl terminate-user "$USER"
    exit 0
fi

if command -v gnome-session-quit >/dev/null 2>&1 && pgrep -x gnome-session >/dev/null 2>&1; then
    gnome-session-quit --logout --no-prompt
    exit 0
fi

# Fallback: standard systemd session/user termination
loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null || loginctl terminate-user "$USER"
