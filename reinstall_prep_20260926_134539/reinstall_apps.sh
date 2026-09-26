#!/bin/bash
# Multi-source reinstall script generated on 2026-09-26 13:45:40
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/reinstall_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "=== Reinstall started at $(date) ==="

# 1. APT Packages (Manual)
if [ -f "$SCRIPT_DIR/apt_manual_packages.txt" ]; then
    log "\n=== Installing APT Manual Packages ==="
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        [ -z "$pkg" ] && continue
        if dpkg -l | grep -q "^ii  $pkg "; then
            log "SKIP: $pkg (already installed)"
        else
            log "INSTALL: $pkg"
            sudo apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1 || log "FAILED: $pkg"
        fi
    done < "$SCRIPT_DIR/apt_manual_packages.txt"
fi

# 2. Flatpak Apps
if [ -f "$SCRIPT_DIR/flatpak_apps_list.txt" ] && command -v flatpak >/dev/null 2>&1; then
    log "\n=== Installing Flatpak Apps ==="
    while IFS= read -r app || [ -n "$app" ]; do
        [ -z "$app" ] && continue
        if flatpak list --app | grep -q "^$app"; then
            log "SKIP: $app (already installed)"
        else
            log "INSTALL: $app"
            flatpak install -y flathub "$app" >> "$LOG_FILE" 2>&1 || log "FAILED: $app"
        fi
    done < "$SCRIPT_DIR/flatpak_apps_list.txt"
fi

# 3. Snap Apps
if [ -f "$SCRIPT_DIR/snap_apps_list.txt" ] && command -v snap >/dev/null 2>&1; then
    log "\n=== Installing Snap Apps ==="
    while IFS= read -r snap || [ -n "$snap" ]; do
        [ -z "$snap" ] && continue
        [ "$snap" = "snapd" ] && continue
        if snap list 2>/dev/null | grep -q "^$snap "; then
            log "SKIP: $snap (already installed)"
        else
            log "INSTALL: $snap"
            sudo snap install "$snap" >> "$LOG_FILE" 2>&1 || log "FAILED: $snap"
        fi
    done < "$SCRIPT_DIR/snap_apps_list.txt"
fi

# 4. Cargo Crates
if [ -f "$SCRIPT_DIR/cargo_packages_list.txt" ] && command -v cargo >/dev/null 2>&1; then
    log "\n=== Installing Cargo Packages ==="
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        pkg=$(echo "$line" | awk '{print $1}')
        log "INSTALL: cargo install $pkg"
        cargo install "$pkg" >> "$LOG_FILE" 2>&1 || log "FAILED: cargo install $pkg"
    done < "$SCRIPT_DIR/cargo_packages_list.txt"
fi

# 5. Global NPM Packages
if [ -f "$SCRIPT_DIR/npm_global_packages_list.txt" ] && command -v npm >/dev/null 2>&1; then
    log "\n=== Installing Global NPM Packages ==="
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        pkg=$(echo "$line" | cut -d'@' -f1)
        [ "$pkg" = "npm" ] && continue
        [ "$pkg" = "corepack" ] && continue
        log "INSTALL: sudo npm install -g $pkg"
        sudo npm install -g "$pkg" >> "$LOG_FILE" 2>&1 || log "FAILED: npm $pkg"
    done < "$SCRIPT_DIR/npm_global_packages_list.txt"
fi

# 6. Python User Packages
if [ -f "$SCRIPT_DIR/python_packages_list.txt" ] && command -v pip >/dev/null 2>&1; then
    log "\n=== Installing Python User Packages ==="
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        pkg=$(echo "$line" | cut -d'=' -f1 | awk '{print $1}')
        log "INSTALL: pip install --user $pkg"
        pip install --user "$pkg" >> "$LOG_FILE" 2>&1 || log "FAILED: pip $pkg"
    done < "$SCRIPT_DIR/python_packages_list.txt"
fi

log "\n=== AppImage Reminders ==="
if [ -f "$SCRIPT_DIR/appimage_files_list.txt" ]; then
    log "AppImages to manually restore:"
    cat "$SCRIPT_DIR/appimage_files_list.txt" | tee -a "$LOG_FILE"
fi

log "\n=== Reinstallation finished at $(date) ==="
