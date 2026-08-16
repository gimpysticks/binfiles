#!/usr/bin/env python3
"""
wt_fill_unassigned_keys.py
---------------------------
Interactive, offline tool to find every War Thunder keyboard action that has
NO binding (keyboard key or mouse button) in your active preset + overrides,
and walk you through assigning free keys/combos to them in the terminal.

Requires: wt_ext_cli (https://github.com/Warthunder-Open-Source-Foundation/wt_ext_cli)
installed and on PATH (installer already run once via:
  curl --proto '=https' --tlsv1.2 -LsSf \
    https://github.com/Warthunder-Open-Source-Foundation/wt_ext_cli/releases/download/v0.6.6/wt_ext_cli-installer.sh | sh
)

Usage:
  python3 wt_fill_unassigned_keys.py                 # interactive, all categories
  python3 wt_fill_unassigned_keys.py --categories aircraft,tank
  python3 wt_fill_unassigned_keys.py --list-only      # just print counts, no prompts
  python3 wt_fill_unassigned_keys.py --dry-run        # interactive, but don't write the file

At any prompt:
  <Enter>        accept the suggested key/combo
  <text>         type your own, e.g. "ctrl+r", "alt+f5", "home", "f10"
  s              skip this action
  n              skip the rest of this category
  q              save progress and quit
"""
import argparse
import glob
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime

# ----------------------------------------------------------------------------
# Paths - adjust here if your Steam/War Thunder install lives elsewhere.
# ----------------------------------------------------------------------------
STEAM_ROOT = os.path.expanduser(
    "~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/War Thunder"
)
ACES_VROMFS = os.path.join(STEAM_ROOT, "aces.vromfs.bin")
GUI_VROMFS = os.path.join(STEAM_ROOT, "gui.vromfs.bin")

UNPACK_ACES = "/tmp/wt_unpack_aces"
UNPACK_GUI = "/tmp/wt_unpack_gui"

HK_DIR = os.path.join(UNPACK_ACES, "aces.vromfs.bin_u", "config", "hotkeys")
SL_DIR = os.path.join(
    UNPACK_GUI, "gui.vromfs.bin_u", "scripts", "controls", "shortcutslist"
)

LIVE_CONFIG = os.path.expanduser(
    "~/.var/app/com.valvesoftware.Steam/.config/WarThunder/Saves/Default_CTLS.blk"
)

# Root of the keyboard preset chain actually used on Linux (see config/hotkeys/list.blk)
ROOT_PRESETS = ["hotkey.keyboard_ver2.blk", "hotkey.keyboard_shooter_ver3.blk"]

CATEGORY_ALIASES = {
    "aircraft": "shortcutsgroupaircraft.nut",
    "helicopter": "shortcutsgrouphelicopter.nut",
    "tank": "shortcutsgrouptank.nut",
    "ship": "shortcutsgroupship.nut",
    "submarine": "shortcutsgroupsubmarine.nut",
    "ingame": "shortcutsgroupingame.nut",
    "special": "shortcutsgroupspecial.nut",
    "replay": "shortcutsgroupreplay.nut",
    "interface": "shortcutsgroupinterface.nut",
    "artillery": "shortcutsgroupartillery.nut",
    "voice": "shortcutsgroupvoice.nut",
    "view": "shortcutsgroupview.nut",
    "trackir": "shortcutsgrouptrackir.nut",
    "gamepad": "shortcutsgroupgamepad.nut",
}
DEFAULT_ORDER = [
    "aircraft", "helicopter", "tank", "ship", "submarine",
    "ingame", "special", "replay", "interface", "artillery", "voice",
]

# ----------------------------------------------------------------------------
# DIK scancode <-> name mapping (the subset War Thunder's blk format uses)
# ----------------------------------------------------------------------------
NAME_TO_CODE = {
    "esc": 1, "1": 2, "2": 3, "3": 4, "4": 5, "5": 6, "6": 7, "7": 8, "8": 9,
    "9": 10, "0": 11, "minus": 12, "equals": 13, "backspace": 14, "tab": 15,
    "q": 16, "w": 17, "e": 18, "r": 19, "t": 20, "y": 21, "u": 22, "i": 23,
    "o": 24, "p": 25, "lbracket": 26, "rbracket": 27, "enter": 28, "return": 28,
    "lctrl": 29, "ctrl": 29, "a": 30, "s": 31, "d": 32, "f": 33, "g": 34,
    "h": 35, "j": 36, "k": 37, "l": 38, "semicolon": 39, "apostrophe": 40,
    "grave": 41, "lshift": 42, "shift": 42, "backslash": 43, "z": 44, "x": 45,
    "c": 46, "v": 47, "b": 48, "n": 49, "m": 50, "comma": 51, "period": 52,
    "slash": 53, "rshift": 54, "num*": 55, "lalt": 56, "alt": 56, "space": 57,
    "capslock": 58, "f1": 59, "f2": 60, "f3": 61, "f4": 62, "f5": 63, "f6": 64,
    "f7": 65, "f8": 66, "f9": 67, "f10": 68, "numlock": 69, "scrolllock": 70,
    "num7": 71, "num8": 72, "num9": 73, "num-": 74, "num4": 75, "num5": 76,
    "num6": 77, "num+": 78, "num1": 79, "num2": 80, "num3": 81, "num0": 82,
    "num.": 83, "f11": 87, "f12": 88, "numenter": 156, "rctrl": 157,
    "num/": 181, "printscreen": 183, "sysrq": 183, "ralt": 184, "pause": 197,
    "home": 199, "up": 200, "pageup": 201, "left": 203, "right": 205, "end": 207,
    "down": 208, "pagedown": 209, "insert": 210, "delete": 211,
}
CODE_TO_NAME = {v: k for k, v in NAME_TO_CODE.items()
                 if k not in ("ctrl", "shift", "alt", "enter", "sysrq")}
MODIFIER_CODES = {29: "Ctrl", 56: "Alt", 42: "Shift", 157: "RCtrl", 184: "RAlt"}

# Genuinely free single keys on a standard layout (no modifier needed)
FREE_SINGLE_KEYS = ["f10", "home", "end", "pause", "scrolllock", "numlock", "backslash"]


def code_name(code):
    return CODE_TO_NAME.get(code, f"<{code}>")


# ----------------------------------------------------------------------------
# Step 0: ensure vromfs archives are unpacked as readable text
# ----------------------------------------------------------------------------
def ensure_unpacked():
    wt_ext_cli = shutil.which("wt_ext_cli") or os.path.expanduser("~/.cargo/bin/wt_ext_cli")
    if not os.path.isdir(HK_DIR):
        if not os.path.exists(ACES_VROMFS):
            sys.exit(f"Can't find {ACES_VROMFS} - update STEAM_ROOT at the top of this script.")
        print("Unpacking aces.vromfs.bin (hotkey presets)...")
        subprocess.run([wt_ext_cli, "unpack_vromf", "-i", ACES_VROMFS,
                         "-o", UNPACK_ACES, "--format", "BlkText"], check=True)
    if not os.path.isdir(SL_DIR):
        if not os.path.exists(GUI_VROMFS):
            sys.exit(f"Can't find {GUI_VROMFS} - update STEAM_ROOT at the top of this script.")
        print("Unpacking gui.vromfs.bin (action registry)...")
        subprocess.run([wt_ext_cli, "unpack_vromf", "-i", GUI_VROMFS,
                         "-o", UNPACK_GUI, "--format", "BlkText"], check=True)


# ----------------------------------------------------------------------------
# Step 1: parse the master action registry (shortcutsList) per category
# ----------------------------------------------------------------------------
def top_level_brace_blocks(s):
    blocks, depth, start = [], 0, None
    for i, ch in enumerate(s):
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and start is not None:
                blocks.append(s[start:i + 1])
                start = None
    return blocks


ID_RE = re.compile(r'id\s*=\s*"([^"]*)"')
TYPE_RE = re.compile(r'type\s*=\s*CONTROL_TYPE\.(\w+)')
CHECKASSIGN_RE = re.compile(r'checkAssign\s*=\s*(true|false)')
KEYBIND_TYPES = {"SHORTCUT", "AXIS_SHORTCUT"}
# these ids in shortcutsgroupaxis.nut are generic per-axis UI templates, not real actions
TEMPLATE_NOISE_IDS = {"rangeMax", "rangeMin", "rangeSet", ""}


def load_registry():
    entries = []
    for f in sorted(glob.glob(os.path.join(SL_DIR, "shortcutsgroup*.nut"))):
        content = open(f, encoding="utf-8").read()
        for b in top_level_brace_blocks(content):
            m = ID_RE.search(b)
            if not m:
                continue
            _id = m.group(1)
            tm = TYPE_RE.search(b)
            _type = tm.group(1) if tm else "SHORTCUT"
            cam = CHECKASSIGN_RE.search(b)
            _checkassign = cam.group(1) == "true" if cam else True
            entries.append((_id, _type, _checkassign, os.path.basename(f)))
    return entries


# ----------------------------------------------------------------------------
# Step 2: parse the default keyboard preset chain + the live user config
# ----------------------------------------------------------------------------
BIND_FIELDS = ("keyboardKey", "mouseButton", "joyButton")


def parse_blk_hotkeys(path):
    """Returns (dict action_id -> set(keyboardKey codes), dict action_id -> bool bound_any, base_preset_path)"""
    codes_by_id = defaultdict(set)
    bound_any = set()
    base_path = None
    if not os.path.exists(path):
        return codes_by_id, bound_any, base_path
    content = open(path, encoding="utf-8").read()
    cm = re.search(r"controls\s*\{", content)
    if not cm:
        return codes_by_id, bound_any, base_path
    depth, i, start = 0, cm.end() - 1, cm.end() - 1
    while i < len(content):
        if content[i] == "{":
            depth += 1
        elif content[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    controls_block = content[start:i + 1]
    bp = re.search(r'basePresetPaths\s*\{[^}]*default\s*:\s*t\s*=\s*"([^"]+)"', controls_block)
    base_path = bp.group(1) if bp else None
    hkm = re.search(r"hotkeys\s*\{", controls_block)
    if hkm:
        depth, j, start2 = 0, hkm.end() - 1, hkm.end() - 1
        while j < len(controls_block):
            if controls_block[j] == "{":
                depth += 1
            elif controls_block[j] == "}":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        hotkeys_block = controls_block[start2 + 1:j]  # strip outer { }
        depth, blk_start = 0, None
        for k, ch in enumerate(hotkeys_block):
            if ch == "{":
                if depth == 0:
                    blk_start = k
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0 and blk_start is not None:
                    prefix = hotkeys_block[:blk_start]
                    block = hotkeys_block[blk_start:k + 1]
                    name_m = re.search(r"([A-Za-z0-9_]+)\s*$", prefix)
                    if name_m:
                        name = name_m.group(1)
                        if any(bf in block for bf in BIND_FIELDS):
                            bound_any.add(name)
                        for code in re.findall(r"keyboardKey:i\s*=\s*(\d+)", block):
                            codes_by_id[name].add(int(code))
                    blk_start = None
    return codes_by_id, bound_any, base_path


def build_default_bindings():
    visited = set()
    all_bound = set()
    all_codes = defaultdict(set)

    def walk(relpath):
        if relpath in visited:
            return
        visited.add(relpath)
        fpath = os.path.join(HK_DIR, os.path.basename(relpath))
        codes, bound, base = parse_blk_hotkeys(fpath)
        all_bound.update(bound)
        for k, v in codes.items():
            all_codes[k].update(v)
        if base:
            walk(base)

    for root in ROOT_PRESETS:
        walk(root)
    return all_bound, all_codes


# ----------------------------------------------------------------------------
# Step 3: description helper
# ----------------------------------------------------------------------------
DESCRIPTIONS = {
    "ID_TOGGLE_INSTRUCTOR": "Toggle flight instructor assist",
    "ID_MANEUVERABILITY_MODE": "Toggle maneuverability flap/control mode",
    "ID_IGNITE_BOOSTERS": "Ignite rocket boosters (JATO)",
    "ID_SWEEP_MODE": "Toggle variable wing-sweep mode",
    "ID_THRUST_VECTORING_MODE": "Toggle thrust-vectoring mode",
    "ID_JETTISON_SECONDARY": "Jettison secondary/external weapons",
    "ID_BAY_DOOR": "Toggle weapon bay doors",
    "ID_FUEL_TANKS": "Drop external fuel tanks",
    "ID_AIR_DROP": "Air-drop cargo/supplies",
    "ID_TOGGLE_BOMBS_AUTO_RELEASE": "Toggle bombsight auto-release",
    "ID_IRCM_SWITCH_PLANE": "Toggle infrared countermeasures (IRCM)",
    "ID_COUNTERMEASURES_FLARES": "Dispense flares",
    "ID_COUNTERMEASURES_CHAFF": "Dispense chaff",
    "ID_TOGGLE_PERIODIC_FLARES": "Toggle automatic periodic flare dispensing",
    "ID_TOGGLE_MLWS_FLARES_SLAVING": "Toggle missile-warning-slaved flare dispensing",
    "ID_TOGGLE_FUEL_DUMPING": "Toggle fuel dumping",
    "ID_TOGGLE_AIR_RADAR_GUI_NAVIGATION": "Toggle radar GUI navigation mode",
    "ID_SCHRAEGE_MUSIK": "Fire Schräge Musik (upward-firing guns)",
    "ID_TOGGLE_CANNONS_AND_ROCKETS_BALLISTIC_COMPUTER": "Toggle ballistic computer for guns/rockets",
    "ID_TOGGLE_ROCKETS_BALLISTIC_COMPUTER": "Toggle ballistic computer for rockets",
    "ID_SWITCH_COCKPIT_SIGHT_MODE": "Switch cockpit sight mode",
    "ID_SWITCH_REGISTERED_BOMB_TARGETING_POINT": "Switch registered bomb targeting point",
    "ID_AIM_MEM_POINT_SEL_NEXT": "Select next memorized aim point",
    "ID_AIM_MEM_POINT_SEL_PREV": "Select previous memorized aim point",
    "ID_AIM_MEM_POINT_ADD": "Add memorized aim point",
    "ID_AIM_MEM_POINT_DEL": "Delete memorized aim point",
    "ID_AIM_MEM_POINT_EDIT_SEL_TOGGLE": "Toggle edit mode for memorized aim point",
    "ID_AIM_MEM_POINT_LINK_WEAPON": "Link weapon to memorized aim point",
    "ID_AIM_MEM_POINT_UNLINK_WEAPON": "Unlink weapon from memorized aim point",
    "ID_AIM_MEM_POINT_SALVO_FIRE": "Salvo-fire at memorized aim point",
    "ID_SENSOR_MODES_SWITCH": "Switch sensor (radar) modes",
    "ID_SENSOR_STABILIZATION_SWITCH": "Toggle sensor stabilization",
    "ID_SENSOR_DIRECTION_AXES_RESET": "Reset sensor direction axes",
    "ID_RADAR_NEXT_IFF_FILTER_MODE": "Cycle radar IFF filter mode",
    "ID_TOGGLE_AIR_RADAR_NCTR_NAVIGATION": "Toggle radar NCTR navigation",
    "ID_TOGGLE_AIR_RADAR_NCTR_APPLY": "Apply radar NCTR",
    "ID_TOGGLE_GUNNERS": "Toggle AI gunners on/off",
    "ID_CAMERA_SEEKER": "View missile seeker camera",
    "ID_CAMERA_SHELL_FPV": "View shell/projectile FPV camera",
    "ID_AIM_CAMERA": "Toggle aiming camera",
    "ID_TOGGLE_COCKPIT_DOOR": "Toggle cockpit door",
    "ID_TOGGLE_COCKPIT_LIGHTS": "Toggle cockpit lights",
    "ID_MFD_1_PAGE_PLANE": "Cycle MFD 1 page",
    "ID_MFD_2_PAGE_PLANE": "Cycle MFD 2 page",
    "ID_MFD_3_PAGE_PLANE": "Cycle MFD 3 page",
    "ID_MFD_ZOOM_PLANE": "Zoom MFD",
    "ID_TOGGLE_HMD": "Toggle helmet-mounted display (HMD)",
    "ID_INC_HMD_BRIGHTNESS": "Increase HMD brightness",
    "ID_DEC_HMD_BRIGHTNESS": "Decrease HMD brightness",
    "ID_PLANE_KILLSTREAK_WHEEL_MENU": "Open aircraft killstreak wheel menu",
    "ID_CENTER_MOUSE_JOYSTICK": "Re-center mouse joystick",
    "ID_TRIM_RESET": "Reset trim",
    "ID_TRIM_SAVE": "Save current trim",
    "ID_COMPLEX_ENGINE": "Toggle complex engine management mode",
    "ID_RADIATOR_AUTO": "Toggle automatic radiator control",
    "ID_TOGGLE_AUTO_TURBO_CHARGER": "Toggle automatic turbocharger control",
    "ID_SUPERCHARGER": "Shift supercharger gear",
    "ID_MAGNETO_INCREASE": "Increase magneto setting",
    "ID_MAGNETO_DECREASE": "Decrease magneto setting",
    "ID_TOGGLE_PROP_FEATHERING": "Toggle propeller feathering",
    "ID_TOGGLE_1_ENGINE_CONTROL": "Toggle control of engine 1",
    "ID_TOGGLE_2_ENGINE_CONTROL": "Toggle control of engine 2",
    "ID_TOGGLE_3_ENGINE_CONTROL": "Toggle control of engine 3",
    "ID_TOGGLE_4_ENGINE_CONTROL": "Toggle control of engine 4",
    "ID_ENABLE_ALL_ENGINE_CONTROL": "Enable control of all engines",
}


def describe(action_id):
    if action_id in DESCRIPTIONS:
        return DESCRIPTIONS[action_id]
    pretty = action_id.replace("ID_", "").replace("_", " ").strip().title()
    return pretty or action_id


# ----------------------------------------------------------------------------
# Step 4: key parsing / suggestion
# ----------------------------------------------------------------------------
def parse_key_string(s):
    """Parse strings like 'ctrl+r', 'alt+f5', 'home' into a list of DIK codes."""
    parts = [p.strip().lower() for p in s.split("+") if p.strip()]
    codes = []
    for p in parts:
        if p not in NAME_TO_CODE:
            raise ValueError(f"Unknown key name: {p!r}")
        codes.append(NAME_TO_CODE[p])
    return codes


def combo_label(codes):
    return "+".join(
        MODIFIER_CODES.get(c, code_name(c).upper()) for c in codes
    )


def make_suggester(used_singles, used_combo_keys):
    """
    Yields suggestion codes lists, skipping anything already used.
    Priority: free single keys, then memorable modifier combos. The pool is
    intentionally large enough to cover every unbound action in one auto run.
    """
    letters = list("qwertyuiopasdfghjklzxcvbnm")
    digits = list("1234567890")
    fkeys = [f"f{i}" for i in range(1, 13)]
    punct = [
        "comma", "period", "slash", "semicolon", "apostrophe", "backslash",
        "lbracket", "rbracket", "minus", "equals", "grave",
    ]
    nav = ["home", "end", "insert", "delete", "pageup", "pagedown", "up", "down", "left", "right"]

    def gen():
        for name in FREE_SINGLE_KEYS:
            code = NAME_TO_CODE[name]
            if code not in used_singles:
                yield [code]
        primary_mods = (("ctrl", 29), ("alt", 56))
        all_mods = (("ctrl", 29), ("alt", 56), ("shift", 42), ("ralt", 184), ("rctrl", 157))
        for _mod_name, mod_code in primary_mods:
            for group in (letters, digits):
                for key in group:
                    combo = (mod_code, NAME_TO_CODE[key])
                    if combo not in used_combo_keys:
                        yield [mod_code, NAME_TO_CODE[key]]
        for _mod_name, mod_code in all_mods:
            for group in (letters, digits, fkeys, punct, nav):
                for key in group:
                    combo = (mod_code, NAME_TO_CODE[key])
                    if combo not in used_combo_keys:
                        yield [mod_code, NAME_TO_CODE[key]]

    return gen()


# ----------------------------------------------------------------------------
# Step 5: write results back into the live config
# ----------------------------------------------------------------------------
def write_assignments(assignments, dry_run=False):
    if not assignments:
        print("\nNo new assignments to write.")
        return
    if not os.path.exists(LIVE_CONFIG):
        sys.exit(f"Live config not found at {LIVE_CONFIG}")
    content = open(LIVE_CONFIG, encoding="utf-8").read()

    hkm = re.search(r"hotkeys\s*\{", content)
    if not hkm:
        sys.exit("Could not find hotkeys{} block in live config.")
    depth, j, start = 0, hkm.end() - 1, hkm.end() - 1
    while j < len(content):
        if content[j] == "{":
            depth += 1
        elif content[j] == "}":
            depth -= 1
            if depth == 0:
                break
        j += 1
    close_brace_idx = j  # index of the matching '}' for hotkeys{

    new_lines = []
    for action_id, codes in assignments.items():
        new_lines.append(f"    {action_id}{{")
        for c in codes:
            new_lines.append(f"      keyboardKey:i={c}")
        new_lines.append("    }")
        new_lines.append("")
    insertion = "\n" + "\n".join(new_lines)

    new_content = content[:close_brace_idx] + insertion + content[close_brace_idx:]

    if dry_run:
        print("\n--- DRY RUN: would insert into hotkeys{} block ---")
        print(insertion)
        return

    backup_path = LIVE_CONFIG + ".bak-" + datetime.now().strftime("%Y%m%d-%H%M%S")
    shutil.copy2(LIVE_CONFIG, backup_path)
    with open(LIVE_CONFIG, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"\nBacked up previous config to: {backup_path}")
    print(f"Wrote {len(assignments)} new binding(s) to: {LIVE_CONFIG}")
    print("Restart War Thunder (or reload controls) for changes to take effect.")


# ----------------------------------------------------------------------------
# Main interactive flow
# ----------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--categories", help="comma-separated list of categories to process "
                                          f"(default: {','.join(DEFAULT_ORDER)})")
    ap.add_argument("--list-only", action="store_true", help="just print unbound counts and exit")
    ap.add_argument("--dry-run", action="store_true", help="don't write the live config file")
    ap.add_argument("--auto", action="store_true",
                     help="non-interactive: auto-accept the suggested key/combo for every unbound action")
    args = ap.parse_args()

    ensure_unpacked()
    registry = load_registry()
    default_bound, default_codes = build_default_bindings()
    user_codes_map, user_bound, _ = parse_blk_hotkeys(LIVE_CONFIG)
    all_bound = default_bound | user_bound

    # collect used codes (singles + combos) to avoid collisions when suggesting
    used_singles = set()
    used_combo_keys = set()
    for action, codes in list(default_codes.items()) + list(user_codes_map.items()):
        codes = sorted(codes)
        if len(codes) == 1:
            used_singles.add(codes[0])
        elif len(codes) >= 2:
            used_combo_keys.add(tuple(codes[:2]))

    by_cat = defaultdict(list)
    for _id, _type, _checkassign, fname in registry:
        if _type not in KEYBIND_TYPES:
            continue
        if _id in TEMPLATE_NOISE_IDS:
            continue
        if _id in all_bound:
            continue
        by_cat[fname].append((_id, _checkassign))

    cats = [c.strip() for c in args.categories.split(",")] if args.categories else DEFAULT_ORDER

    if args.list_only:
        print(f"{'category':<12} unbound")
        for cat in cats:
            fname = CATEGORY_ALIASES.get(cat, cat)
            print(f"{cat:<12} {len(by_cat.get(fname, []))}")
        return

    assignments = {}
    suggester = make_suggester(used_singles, used_combo_keys)

    print(f"Default-bound actions: {len(default_bound)} | Your overrides: {len(user_bound - default_bound)}")
    if not args.auto:
        print("Type 's' skip one, 'n' skip category, 'q' save+quit, or Enter to accept suggestion.\n")

    quit_all = False
    for cat in cats:
        if quit_all:
            break
        fname = CATEGORY_ALIASES.get(cat, cat)
        items = by_cat.get(fname, [])
        if not items:
            continue
        print(f"\n=== {cat.upper()} ({len(items)} unbound) ===")
        if not args.auto:
            proceed = input(f"Process this category now? [Y/n] ").strip().lower()
            if proceed == "n":
                continue
        for action_id, checkassign in items:
            desc = describe(action_id)
            tag = "" if checkassign else "  (contextual/optional)"
            # find next unused suggestion
            suggestion = None
            for cand in suggester:
                key = tuple(cand) if len(cand) > 1 else None
                if len(cand) == 1:
                    if cand[0] not in used_singles:
                        suggestion = cand
                        break
                else:
                    if tuple(cand) not in used_combo_keys:
                        suggestion = cand
                        break
            label = combo_label(suggestion) if suggestion else "(no suggestion available)"
            if args.auto:
                if not suggestion:
                    print(f"[{action_id}] {desc}{tag}\n  ! no suggestion available, skipping")
                    continue
                codes = suggestion
                print(f"[{action_id}] {desc}{tag}\n  -> assigned {combo_label(codes)}")
            else:
                prompt = f"[{action_id}] {desc}{tag}\n  suggest: {label}  > "
                resp = input(prompt).strip()
                if resp.lower() == "q":
                    quit_all = True
                    break
                if resp.lower() == "n":
                    break
                if resp.lower() == "s" or resp == "":
                    if resp == "" and suggestion:
                        codes = suggestion
                    else:
                        continue
                else:
                    try:
                        codes = parse_key_string(resp)
                    except ValueError as e:
                        print(f"  ! {e}, skipping")
                        continue
                print(f"  -> assigned {combo_label(codes)}")
            assignments[action_id] = codes
            if len(codes) == 1:
                used_singles.add(codes[0])
            else:
                used_combo_keys.add(tuple(codes))

    print(f"\n{len(assignments)} new binding(s) assigned this session.")
    write_assignments(assignments, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
