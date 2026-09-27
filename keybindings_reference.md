# Pop!_OS Custom Keybindings Reference

Last synced: `2026-09-27 16:22`
Live COSMIC Path: `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`  
Repository Copy: [`cosmic-custom-keybindings.ron`](cosmic-custom-keybindings.ron)  
Symlink: [`keybindings.ron`](keybindings.ron)  

---

## Overview

- **Active in Pop!_OS COSMIC**: 40
- **Removed - app not installed**: 7
- **Removed - explicitly requested**: 2 (Guake, Digikam)
- **Preserved COSMIC Defaults**: 1

---

## TildaZ Migration (2026-09-27)

Guake has been fully uninstalled and replaced by TildaZ as the drop-down terminal:

- Guake processes killed, its autostart entries removed (`~/.config/autostart/guake.desktop` and `.disabled`), and the package removed via `pkexec apt remove -y guake`.
- TildaZ was already installed at `/home/sticks/.local/opt/tildaz/tildaz`, with autostart enabled (`~/.config/autostart/tildaz.desktop`, `X-GNOME-Autostart-enabled=true`) and its own config at `~/.config/tildaz/config_0.toml`.
- TildaZ is bound to `F12` in COSMIC (`/home/sticks/.local/opt/tildaz/tildaz --toggle 0`).

---

## Active Keybindings Table

| Key Combination | Name | Command | Notes |
| :--- | :--- | :--- | :--- |
| `F12` | Tildaz | `/home/sticks/.local/opt/tildaz/tildaz --toggle 0` | Replaces Guake; toggles TildaZ drop-down terminal |
| `Super + e` | Gmail | `gtk-launch gmail` |  |
| `Super + F10` | Youtube Music | `xdg-open https://music.youtube.com/` |  |
| `Super + F2` | VimWiki | `gnome-terminal -- zsh -l -c "nvim"` | routed through `~/.local/bin/gnome-terminal` shim to `cosmic-term` |
| `Super + F3` | Gimp | `/bin/gimp` |  |
| `Super + F4` | Inkscape | `/bin/inkscape` |  |
| `Super + Ctrl + a` | AI Urls | `/home/sticks/bin/aiurls` |  |
| `Super + Ctrl + b` | Bpytop | `gnome-terminal -- bash -c "bpytop"` |  |
| `Super + Ctrl + c` | Connections | `flatpak run org.gnome.Connections` |  |
| `Super + Ctrl + d` | Discord | `flatpak run com.discordapp.Discord` |  |
| `Super + Ctrl + g` | agy | `cosmic-term -e agy` | Launch Antigravity CLI in cosmic-term |
| `Super + Ctrl + o` | ChatGPT | `xdg-open https://www.chatgpt.com` |  |
| `Super + Ctrl + r` | Read Human | `/home/sticks/bin/readgTTS.sh` |  |
| `Super + Ctrl + s` | Steam | `steam` | updated from flatpak to native `steam` install |
| `Super + Ctrl + w` | War Thunder | `steam steam://rungameid/236390` | updated from flatpak to native `steam` install |
| `Super + Alt + b` | Change Browser | `/home/sticks/bin/chgbrowser` |  |
| `Super + Alt + d` | Discord Web | `xdg-open https://discord.com/channels/411154143567282177/1182420235672887397` |  |
| `Super + Alt + e` | Eleven Labs | `xdg-open https://elevenlabs.io/app/home` |  |
| `Super + Alt + f` | Facebook | `xdg-open https://www.facebook.com/gimpysticks` |  |
| `Super + Alt + g` | Gemini | `xdg-open https://gemini.google.com/app` |  |
| `Super + Alt + i` | Instagram | `xdg-open https://www.instagram.com` |  |
| `Super + Alt + k` | Grok | `xdg-open https://www.grok.com` |  |
| `Super + Alt + l` | Linktree to Clipboard | `/home/sticks/bin/cplinktree` |  |
| `Super + Alt + m` | Midjourney | `xdg-open https://www.midjourney.com` |  |
| `Super + Alt + o` | OBS-Studio | `flatpak run com.obsproject.Studio` |  |
| `Super + Alt + r` | Redbubble | `xdg-open https://www.redbubble.com/portfolio/manage_works?ref=account-nav-dropdown` |  |
| `Super + Alt + t` | TikTok | `xdg-open https://www.tiktok.com` |  |
| `Super + Alt + w` | Warp Terminal | `warp-terminal` |  |
| `Super + Alt + x` | X.com | `xdg-open https://x.com/home` |  |
| `Super + Shift + o` | ChatGpt | `xdg-open https://chatgpt.com/` |  |
| `Super + Shift + s` | Shotcut | `flatpak run org.shotcut.Shotcut` |  |
| `Super + Shift + t` | Twitch | `/usr/bin/firefox www.twitch.com` |  |
| `Ctrl + space` | Handy Speech to Text | `/home/sticks/.local/bin/handy --toggle-transcription` |  |
| `Ctrl + Alt + BackSpace` | Restart X | `/home/sticks/bin/restartx` |  |
| `Ctrl + Alt + Left` | Variety Previous | `/usr/bin/variety --previous` |  |
| `Ctrl + Alt + Right` | Variety Next | `variety --next` |  |
| `Alt + Left` | variety Previous | `/usr/bin/variety --previous` |  |
| `Alt + Right` | Variety Next | `/usr/bin/variety --next` |  |
| `Alt + Shift + s` | Standard Notes | `xdg-open https://app.standardnotes.com/` |  |
| `Alt + Shift + w` | Work URLS | `bash -c /home/sticks/bin/workurls` |  |

---

## Removed Keybindings

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
| `Ctrl + Alt + d` | Digikam | installed via flatpak (`org.kde.digikam` 9.1.0); removed per explicit user request |

---

## Incident Notes (2026-09-27)

The live COSMIC file (`~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`) had diverged from this repository and become corrupted: a truncated `F12` entry made the entire RON document fail to parse, which silently disabled all custom shortcuts. The file was repaired directly and re-synced.

Backups of the corrupted live file are kept at:
- `custom-live-CORRUPTED-backup-20260927-100423.ron` (this repo)
- `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom.corrupted-backup-20260927-100423` (live config directory)

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
