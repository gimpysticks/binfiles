#!/usr/bin/env python3
"""
export_cosmic_keybinds.py

Generates Pop!_OS COSMIC desktop custom keybindings from GNOME dconf keybindings.
- Preserves Pop!_OS COSMIC default keybindings (e.g. Super+t for cosmic-term, tiling, etc.)
- Creates a backup copy of current keybindings for reference
- Outputs:
    1. ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom (Active COSMIC config)
    2. ~/bin/cosmic-custom-keybindings.ron (Repository copy)
    3. ~/bin/keybindings_reference.md (Human-readable Markdown reference table)
    4. ~/bin/custom-keybindings-backup.dconf (Dconf backup copy)
"""

import os
import re
import shutil
import configparser
from datetime import datetime

BIN_DIR = os.path.dirname(os.path.abspath(__file__))
DCONF_FILE = os.path.join(BIN_DIR, "custom-keybindings.dconf")
BACKUP_DCONF_FILE = os.path.join(BIN_DIR, "custom-keybindings-backup.dconf")
BIN_RON_FILE = os.path.join(BIN_DIR, "cosmic-custom-keybindings.ron")
REF_MD_FILE = os.path.join(BIN_DIR, "keybindings_reference.md")

COSMIC_CONFIG_DIR = os.path.expanduser("~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1")
COSMIC_CUSTOM_FILE = os.path.join(COSMIC_CONFIG_DIR, "custom")

def parse_binding(b_str):
    raw = b_str.strip("'\"")
    raw_mods = re.findall(r"<([^>]+)>", raw)
    mod_map = {
        "Alt": "Alt",
        "Super": "Super",
        "Primary": "Ctrl",
        "Ctrl": "Ctrl",
        "Control": "Ctrl",
        "Shift": "Shift"
    }
    mods = []
    for m in raw_mods:
        if m in mod_map and mod_map[m] not in mods:
            mods.append(mod_map[m])
    
    # Conventional modifier ordering: Super, Ctrl, Alt, Shift
    order = {"Super": 1, "Ctrl": 2, "Alt": 3, "Shift": 4}
    mods.sort(key=lambda m: order.get(m, 5))
    
    key = re.sub(r"<[^>]+>", "", raw)
    if key == "Launch1":
        key = "XF86Launch1"
    return mods, key

def main():
    if not os.path.isfile(DCONF_FILE):
        print(f"Error: {DCONF_FILE} not found!")
        return

    # 1. Backup original dconf
    shutil.copy2(DCONF_FILE, BACKUP_DCONF_FILE)
    print(f"✓ Backed up current dconf keybindings to: {BACKUP_DCONF_FILE}")

    # 2. Parse dconf entries
    cfg = configparser.ConfigParser()
    cfg.read(DCONF_FILE)

    entries = []
    for sec in cfg.sections():
        b = cfg.get(sec, "binding", fallback="").strip("'\"")
        c = cfg.get(sec, "command", fallback="").strip("'\"")
        n = cfg.get(sec, "name", fallback="").strip("'\"")
        if not (b and c):
            continue
        mods, key = parse_binding(b)
        entries.append({
            "section": sec,
            "name": n,
            "raw_binding": b,
            "command": c,
            "mods": mods,
            "key": key
        })

    # Sort entries nicely
    entries.sort(key=lambda x: (x["mods"], x["key"], x["name"]))

    # 3. Categorize into active vs preserved/duplicates
    seen_combos = {}
    active_blocks = []
    commented_blocks = []
    table_rows = []

    # Known Pop!_OS COSMIC defaults to preserve
    # Super+t = Terminal (cosmic-term), Super+/ = Launcher, Super+f = Files, Super+b = Browser, etc.
    cosmic_reserved = {
        ( ("Super",), "t" ): "Pop!_OS COSMIC default terminal (cosmic-term)",
        ( ("Super",), "b" ): "Pop!_OS COSMIC default web browser",
        ( ("Super",), "f" ): "Pop!_OS COSMIC default file manager (cosmic-files)",
        ( ("Super",), "slash" ): "Pop!_OS COSMIC launcher",
    }

    for e in entries:
        combo_tuple = (tuple(e["mods"]), e["key"])
        human_combo = (" + ".join(e["mods"]) + (" + " if e["mods"] else "") + e["key"]).replace("XF86Launch1", "Launch1")

        mods_str = "\n".join([f"            {m}," for m in e["mods"]])
        mods_block = f"[\n{mods_str}\n        ]" if mods_str else "[]"

        status = ""
        note = ""

        mods_inline = f"[{', '.join(e['mods'])}]"

        # Check if conflicts with COSMIC default
        if combo_tuple in cosmic_reserved:
            status = "Preserved COSMIC Default"
            note = f"Not overwritten. Reserved by {cosmic_reserved[combo_tuple]}."
            commented_blocks.append(
                f"    // PRESERVED COSMIC DEFAULT: {human_combo}\n"
                f"    // In GNOME: \"{e['command']}\" ({e['name']})\n"
                f"    // Preserving COSMIC built-in {cosmic_reserved[combo_tuple]}.\n"
                f"    // (modifiers: {mods_inline}, key: \"{e['key']}\", description: Some(\"{e['name']}\")): Spawn(\"{e['command']}\"),\n"
            )
        # Check duplicate in GNOME
        elif combo_tuple in seen_combos:
            orig = seen_combos[combo_tuple]
            status = "Duplicate in GNOME"
            note = f"Duplicate key combo. Active: '{orig['name']}'. Commented in RON."
            commented_blocks.append(
                f"    // DUPLICATE IN GNOME: {human_combo} ({e['name']})\n"
                f"    // Already bound to '{orig['name']}' -> {orig['command']}\n"
                f"    // (modifiers: {mods_inline}, key: \"{e['key']}\", description: Some(\"{e['name']}\")): Spawn(\"{e['command']}\"),\n"
            )
        else:
            seen_combos[combo_tuple] = e
            status = "Active in COSMIC"
            note = "Exported to COSMIC custom shortcuts"
            active_blocks.append(
                f"    (\n"
                f"        modifiers: {mods_block},\n"
                f"        key: \"{e['key']}\",\n"
                f"        description: Some(\"{e['name']}\"),\n"
                f"    ): Spawn(\"{e['command']}\"),\n"
            )

        table_rows.append({
            "combo": human_combo,
            "raw": e["raw_binding"],
            "name": e["name"],
            "command": e["command"],
            "status": status,
            "note": note,
            "section": e["section"]
        })

    # 4. Generate RON File Content
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    ron_content = f"""// =============================================================================
// Pop!_OS COSMIC Custom Keybindings (RON Format)
// Generated: {now_str}
// Source: {DCONF_FILE}
//
// File Location: ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
// Repository Copy: {BIN_RON_FILE}
// Markdown Reference: {REF_MD_FILE}
//
// NOTE:
// Pop!_OS COSMIC default keybindings (e.g. Super+t for cosmic-term,
// Super+f for cosmic-files, workspace switching, tiling) are preserved
// and NOT overwritten.
// =============================================================================

{{
"""
    for b in active_blocks:
        ron_content += b + "\n"

    if commented_blocks:
        ron_content += """    // =========================================================================
    // INACTIVE / PRESERVED ENTRIES (Left for Reference)
    // =========================================================================\n\n"""
        for b in commented_blocks:
            ron_content += b + "\n"

    ron_content += "}\n"

    # Write to ~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom
    os.makedirs(COSMIC_CONFIG_DIR, exist_ok=True)
    with open(COSMIC_CUSTOM_FILE, "w", encoding="utf-8") as f:
        f.write(ron_content)
    print(f"✓ Saved active Pop!_OS COSMIC shortcuts: {COSMIC_CUSTOM_FILE}")

    # Write copy to repository bin folder
    with open(BIN_RON_FILE, "w", encoding="utf-8") as f:
        f.write(ron_content)
    print(f"✓ Saved repository copy: {BIN_RON_FILE}")

    # 5. Generate Markdown Reference Table
    md_content = f"""# Pop!_OS Custom Keybindings Reference

Generated: `{now_str}`  
Source: [`custom-keybindings.dconf`](custom-keybindings.dconf)  
Backup Dconf: [`custom-keybindings-backup.dconf`](custom-keybindings-backup.dconf)  
COSMIC RON Config: [`cosmic-custom-keybindings.ron`](cosmic-custom-keybindings.ron)  
Live COSMIC Path: `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`  

---

## Overview

- **Total Keybindings in GNOME**: {len(entries)}
- **Active in Pop!_OS COSMIC**: {len(active_blocks)}
- **Preserved COSMIC Defaults**: {sum(1 for r in table_rows if r['status'] == 'Preserved COSMIC Default')}
- **Duplicates Handled**: {sum(1 for r in table_rows if r['status'] == 'Duplicate in GNOME')}

---

## Keybindings Table

| Key Combination | Name | Command | COSMIC Status | Notes |
| :--- | :--- | :--- | :--- | :--- |
"""

    for r in table_rows:
        badge = "🟢 **Active**" if r["status"] == "Active in COSMIC" else ("🔵 **Preserved**" if r["status"] == "Preserved COSMIC Default" else "🟡 **Duplicate**")
        md_content += f"| `{r['combo']}` | {r['name']} | `{r['command']}` | {badge} | {r['note']} |\n"

    md_content += """
---

## Pop!_OS COSMIC Default Keybindings Cheatsheet

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
| `Print` | Interactive Screenshot |
"""

    with open(REF_MD_FILE, "w", encoding="utf-8") as f:
        f.write(md_content)
    print(f"✓ Saved Markdown reference guide: {REF_MD_FILE}")

    print("\n✨ Done! Keybindings successfully converted and documented for Pop!_OS COSMIC.")

if __name__ == "__main__":
    main()
