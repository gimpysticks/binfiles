#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/reinstall_$(date +%Y%m%d_%H%M%S).log"

echo "=== Starting reinstallation at $(date) ===" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE"

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Install APT packages
log ""
log "=== Processing APT packages ==="
if [ -f "$SCRIPT_DIR/apt_packages_list.txt" ]; then
    while IFS= read -r package || [ -n "$package" ]; do
        # Skip empty lines
        [ -z "$package" ] && continue
        
        # Check if package is already installed
        if dpkg -l | grep -q "^ii  $package "; then
            log "SKIP: $package (already installed)"
        else
            log "INSTALL: $package"
            if sudo apt-get install -y "$package" >> "$LOG_FILE" 2>&1; then
                log "SUCCESS: $package"
            else
                log "FAILED: $package"
            fi
        fi
    done < "$SCRIPT_DIR/apt_packages_list.txt"
else
    log "WARNING: apt_packages_list.txt not found"
fi

# Install Flatpak apps
log ""
log "=== Processing Flatpak apps ==="
if [ -f "$SCRIPT_DIR/flatpak_apps_list.txt" ]; then
    while IFS= read -r app || [ -n "$app" ]; do
        # Skip empty lines
        [ -z "$app" ] && continue
        
        # Check if flatpak is already installed
        if flatpak list --app | grep -q "^$app"; then
            log "SKIP: $app (already installed)"
        else
            log "INSTALL: $app"
            if flatpak install -y flathub "$app" >> "$LOG_FILE" 2>&1; then
                log "SUCCESS: $app"
            else
                log "FAILED: $app"
            fi
        fi
    done < "$SCRIPT_DIR/flatpak_apps_list.txt"
else
    log "WARNING: flatpak_apps_list.txt not found"
fi

# Install Snap apps
log ""
log "=== Processing Snap apps ==="
if [ -f "$SCRIPT_DIR/snap_apps_list.txt" ]; then
    while IFS= read -r snap || [ -n "$snap" ]; do
        # Skip empty lines or snapd itself
        [ -z "$snap" ] && continue
        [ "$snap" = "snapd" ] && continue
        
        # Check if snap is already installed
        if snap list 2>/dev/null | grep -q "^$snap "; then
            log "SKIP: $snap (already installed)"
        else
            log "INSTALL: $snap"
            if sudo snap install "$snap" >> "$LOG_FILE" 2>&1; then
                log "SUCCESS: $snap"
            else
                log "FAILED: $snap"
            fi
        fi
    done < "$SCRIPT_DIR/snap_apps_list.txt"
else
    log "WARNING: snap_apps_list.txt not found"
fi

# Note about AppImages
log ""
log "=== AppImage files ==="
if [ -f "$SCRIPT_DIR/appimage_files_list.txt" ]; then
    log "NOTE: AppImage files found in the list:"
    cat "$SCRIPT_DIR/appimage_files_list.txt" | tee -a "$LOG_FILE"
    log "AppImages need to be manually downloaded and placed in the appropriate locations."
else
    log "WARNING: appimage_files_list.txt not found"
fi

log ""
log "=== Reinstallation completed at $(date) ==="
log "Check $LOG_FILE for detailed output"
