#!/usr/bin/env python3
"""
export_cosmic_keybinds.py

Synchronizes active Pop!_OS COSMIC keybindings to the repository:
1. Validates the live ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom RON file.
2. Backs it up to ~/bin/cosmic-custom-keybindings.ron.
3. Maintains the ~/bin/keybindings.ron symlink.
4. Generates an up-to-date human-readable reference table in ~/bin/keybindings_reference.md.
"""

import os
import sys
import re
import shutil
from datetime import datetime

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
LIVE_COSMIC_DIR = os.path.expanduser("~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1")
LIVE_CUSTOM_FILE = os.path.join(LIVE_COSMIC_DIR, "custom")

BIN_RON_FILE = os.path.join(BIN_DIR, "cosmic-custom-keybindings.ron")
BIN_SYMLINK = os.path.join(BIN_DIR, "keybindings.ron")
REF_MD_FILE = os.path.join(BIN_DIR, "keybindings_reference.md")


def validate_ron_content(content):
    """Ensure RON syntax is balanced and all Spawn actions parse correctly."""
    if not content.strip():
        return False, "File is empty."

    if content.count("{") != content.count("}"):
        return False, "Mismatched curly braces '{' and '}' in RON file."

    if content.count("(") != content.count(")"):
        return False, "Mismatched parentheses '(' and ')' in RON file."

    if content.count("[") != content.count("]"):
        return False, "Mismatched square brackets '[' and ']' in RON file."

    pattern = re.compile(
        r"\(\s*modifiers:\s*\[(.*?)\]\s*,\s*key:\s*\"((?:[^\"\\]|\\.)*)\"\s*,\s*description:\s*(?:Some\(\"((?:[^\"\\]|\\.)*)\"\)|None)\s*,?\s*\):\s*Spawn\(\"((?:[^\"\\]|\\.)*)\"\)",
        re.DOTALL,
    )
    matches = pattern.findall(content)
    spawns = re.findall(r"Spawn\(", content)

    if len(matches) != len(spawns):
        return False, f"Mismatch: found {len(spawns)} 'Spawn(' entries but only parsed {len(matches)} valid shortcut blocks."

    return True, matches


def extract_existing_notes(md_file):
    """Extract existing notes from keybindings_reference.md table to preserve annotations."""
    notes = {}
    if not os.path.isfile(md_file):
        return notes

    try:
        with open(md_file, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("| `") and "|" in line:
                    parts = [p.strip() for p in line.split("|")[1:-1]]
                    if len(parts) >= 4:
                        combo = parts[0].strip("` ")
                        name = parts[1]
                        note = parts[3]
                        if note:
                            notes[(combo, name)] = note
    except Exception:
        pass
    return notes


def sync_from_cosmic():
    if not os.path.isfile(LIVE_CUSTOM_FILE):
        print(f"Error: Live COSMIC shortcuts file not found at: {LIVE_CUSTOM_FILE}")
        sys.exit(1)

    with open(LIVE_CUSTOM_FILE, "r", encoding="utf-8") as f:
        live_content = f.read()

    valid, result = validate_ron_content(live_content)
    if not valid:
        print(f"Error: Live COSMIC keybindings failed validation: {result}")
        sys.exit(1)

    matches = result
    print(f"✓ Validated live COSMIC shortcuts ({len(matches)} entries parsed).")

    # 1. Write exact live content to ~/bin/cosmic-custom-keybindings.ron
    with open(BIN_RON_FILE, "w", encoding="utf-8") as f:
        f.write(live_content)
    print(f"✓ Backed up to repository: {BIN_RON_FILE}")

    # 3. Create or update symlink ~/bin/keybindings.ron
    try:
        if os.path.islink(BIN_SYMLINK) or os.path.isfile(BIN_SYMLINK):
            os.remove(BIN_SYMLINK)
        os.symlink("cosmic-custom-keybindings.ron", BIN_SYMLINK)
        print(f"✓ Updated symlink: {BIN_SYMLINK} -> cosmic-custom-keybindings.ron")
    except Exception as e:
        print(f"Note: Could not create symlink {BIN_SYMLINK}: {e}")

    # 4. Generate/update Markdown reference
    update_markdown_reference(matches)


def update_markdown_reference(matches):
    existing_notes = extract_existing_notes(REF_MD_FILE)

    special_notes = {
        ("F12", "Tildaz"): "Replaces Guake; toggles TildaZ drop-down terminal",
        ("F12", "TildaZ_0"): "Replaces Guake; toggles TildaZ drop-down terminal",
        ("Super + Ctrl + g", "agy"): "Launch Antigravity CLI in cosmic-term",
    }
    for k, v in special_notes.items():
        if k not in existing_notes:
            existing_notes[k] = v

    order = {"Super": 1, "Ctrl": 2, "Alt": 3, "Shift": 4}
    entries = []

    for raw_mods, key, name, cmd in matches:
        mods = [x.strip() for x in raw_mods.split(",") if x.strip()]
        mods.sort(key=lambda m: order.get(m, 5))
        combo = (" + ".join(mods) + (" + " if mods else "") + key)
        note = existing_notes.get((combo, name), "")
        cmd_display = cmd.replace('\\"', '"')
        entries.append((mods, key, name, cmd_display, combo, note))

    entries.sort(key=lambda x: ([order.get(m, 5) for m in x[0]], len(x[0]), x[1].lower(), x[2]))

    table_lines = [
        "| Key Combination | Name | Command | Notes |",
        "| :--- | :--- | :--- | :--- |",
    ]
    for e in entries:
        table_lines.append(f"| `{e[4]}` | {e[2]} | `{e[3]}` | {e[5]} |")
    table_block = "\n".join(table_lines)

    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")

    # Read existing sections if available
    tildaz_section = """## TildaZ Migration (2026-09-27)

Guake has been fully uninstalled and replaced by TildaZ as the drop-down terminal:

- Guake processes killed, its autostart entries removed (`~/.config/autostart/guake.desktop` and `.disabled`), and the package removed via `pkexec apt remove -y guake`.
- TildaZ was already installed at `/home/sticks/.local/opt/tildaz/tildaz`, with autostart enabled (`~/.config/autostart/tildaz.desktop`, `X-GNOME-Autostart-enabled=true`) and its own config at `~/.config/tildaz/config_0.toml`.
- TildaZ is bound to `F12` in COSMIC (`/home/sticks/.local/opt/tildaz/tildaz --toggle 0`)."""

    removed_section = """## Removed Keybindings

### Removed - application not installed
| Former Binding | App | Evidence |
| :--- | :--- | :--- |
| `Launch1` | WiFi (`gnome-control-center wifi`) | `gnome-control-center` not on PATH; Pop!_OS 24.04/COSMIC uses `cosmic-settings` |
| `Ctrl + Alt + b` | Beeper AppImage | `Beeper-4.0.747.AppImage` file no longer exists |
| `Ctrl + Alt + g` | Glances | `glances` not on PATH, not in dpkg |
| `Ctrl + Alt + o` | OpenRGB (flatpak) | `org.openrgb.OpenRGB` not in `flatpak list` |
| `Ctrl + Alt + p` | polychromatic-tray-applet | binary not on PATH, not in dpkg |
| `Super + Alt + h` | Hypnotix | binary not on PATH, not in dpkg |
| `Super + Alt + n` | toggle_nerd_dict | `nerddict` wrapper exists but calls `nerd-dictation`, which is not installed |

### Removed - explicitly requested (both were actually installed)
| Former Binding | App | Installed evidence |
| :--- | :--- | :--- |
| `F12` | Guake | was `install ok installed` via dpkg and running; package fully uninstalled 2026-09-27, replaced by TildaZ |
| `Ctrl + Alt + d` | Digikam | installed via flatpak (`org.kde.digikam` 9.1.0); removed per explicit user request |"""

    incident_section = """## Incident Notes (2026-09-27)

The live COSMIC file (`~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`) had diverged from this repository and become corrupted: a truncated `F12` entry made the entire RON document fail to parse, which silently disabled all custom shortcuts. The file was repaired directly and re-synced.

Backups of the corrupted live file are kept at:
- `custom-live-CORRUPTED-backup-20260927-100423.ron` (this repo)
- `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom.corrupted-backup-20260927-100423` (live config directory)"""

    cheatsheet_section = """## Pop!_OS COSMIC Default Keybindings Cheatsheet

For your reference, Pop!_OS COSMIC includes these built-in system shortcuts that were left untouched:

| Shortcut | Action in COSMIC |
| :--- | :--- |
| `Super + t` | Open Terminal (`cosmic-term`) |
| `Super + b` | Open Default Web Browser |
| `Super + f` | Open Files (`cosmic-files`) |
| `Super + /` | Open Launcher |
| `Super + a` | Open Applications Library |
| `Super + w` | Open Workspaces Overview |
| `Super + q` | Close Focused Window |
| `Super + m` | Maximize / Unmaximize |
| `Super + y` | Toggle Auto-Tiling |
| `Super + g` | Float / Unfloat Window |
| `Super + s` | Toggle Stacking |
| `Super + o` | Toggle Orientation |
| `Super + x` | Swap Window Position |
| `Super + 1..9, 0` | Switch to Workspace 1..9, Last |
| `Super + Shift + 1..9, 0` | Move Window to Workspace 1..9, Last |
| `Super + Ctrl + Left/Right/Up/Down` | Navigate Workspaces |
| `Super + Alt + Left/Right/Up/Down` | Switch Output Monitor Display |
| `Alt + Tab` | Window Switcher |
| `Print` | Interactive Screenshot |"""

    md_content = f"""# Pop!_OS Custom Keybindings Reference

Last synced: `{now_str}`
Live COSMIC Path: `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`  
Repository Copy: [`cosmic-custom-keybindings.ron`](cosmic-custom-keybindings.ron)  
Symlink: [`keybindings.ron`](keybindings.ron)  

---

## Overview

- **Active in Pop!_OS COSMIC**: {len(entries)}
- **Removed - app not installed**: 7
- **Removed - explicitly requested**: 2 (Guake, Digikam)
- **Preserved COSMIC Defaults**: 1

---

{tildaz_section}

---

## Active Keybindings Table

{table_block}

---

{removed_section}

---

{incident_section}

---

{cheatsheet_section}
"""

    with open(REF_MD_FILE, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"✓ Updated Markdown reference: {REF_MD_FILE}")


def main():
    if "--help" in sys.argv or "-h" in sys.argv:
        print("Usage: export_cosmic_keybinds.py")
        print("Syncs active Pop!_OS COSMIC keybindings to ~/bin/cosmic-custom-keybindings.ron and keybindings_reference.md")
        return

    sync_from_cosmic()
    print("✨ Pop!_OS COSMIC keybindings successfully synced.")


if __name__ == "__main__":
    main()
