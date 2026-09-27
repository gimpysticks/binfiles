# Scripts

Pilfer as you will, but use at your own peril.

## Installation

Best way to use these is grab them and put them into your own stuff.
Technically, you are supposed to mention me if you do that (per Apache
license), but whatever.

The `.bashrc` in this `dot` repo is set to look in
`~/.local/bin/scripts` for stuff (and sets `$SCRIPTS` to that location)
but many of these scripts only work if `$SCRIPTS` is pointing to
something within a GitHub repo. So you might want to override that in
your `.bash_{personal,private,work}` file (from another repo,
presumably).

## What's a "shortcut command"?

A *shortcut command* is an alternative to aliases (which do not work
with subprocesses such as from within an editor session. You will see
this term a lot in the commit messages. Usually such a command will only
be two lines long.

## POSIX, Perl, or Python

Even though I have some `bash` still in here, my goal these days is to
use nothing but POSIX shell, `perl`, and `python3` for everything. POSIX
shell is the most widely supported (for Dockerfile builds and such) and
`perl` is the fastest prototyping language on the planet (unless you
*really* need OOP in which case `python` is the best choice for
*prototyping*. (Surprisingly enough, `python` and `perl` address
completely different needs and use cases that rarely *actually* overlap,
but the world is full of morons who try to argue they are the same.)

## Perl Power Scripts

Perl was primarily created to replace `sed`, `awk`, `tr`, and `cut` and
did it so well it became the de facto lingua franca of all server-side
web development for over two decades.

I really hate `sed` for all the reasons Larry Wall did, but mostly its
absolutely horrible BRE syntax. Using any of the PCRE variations are
not POSIX, might as well just use `perl` instead in those cases.

Script|Full|Purpose
||:-:|:-:|-
|`pie`|`perl -p -i -e`|Inplace edit
|`pae`|`perl -paE`|Replace `sed` and `awk` (prints line)
|`map`|`perl -aE`|Replace `sed` and `awk` (no printing)

## MJ-Bkup

Backup script for Midjourney assets, ChatGPT files, and video projects to the USB
drive (`/media/sticks/MidJourney1`). Moves files older than 5 days, preserving
subfolder structure.

- **PNGs**: `~/Pictures/Midjourney` → `MidJourney1/Midjourney/`
- **ZIPs**: `~/Pictures/Midjourney` → `MidJourney1/Midjourney/Zipfiles/`
- **ChatGPT**: `~/Pictures/ChatGPT` → `MidJourney1/ChatGPT/`
- **Videos**: `~/Videos` → `MidJourney1/Videos/` (directory-based move)

Videos use a **directory-based move**: when an `.mp4` is older than 5
days, the entire containing directory is moved — including companion
files (`.mlt` project files, `.mp3` audio tracks, etc.). Empty
directories are cleaned up afterward. Files matching `VID*` are excluded.

## readgTTS.sh

Reads selected/copied text aloud via `gtts-cli` (Google TTS) piped to `mpv`.
Bound to `Super + Ctrl + r` in COSMIC (see `keybindings_reference.md`).

### 2026-09-27 fix: silent failure due to missing `gtts` module

The keybind stopped producing audio with no visible error. Root cause:
`~/.local/bin/gtts-cli` shebangs to system `/usr/bin/python3`, but the
`gtts` package was missing from that interpreter's environment
(`ModuleNotFoundError: No module named 'gtts'`). The script's `notify-send`
calls were also commented out, so the failure was invisible.

Fix:
- Reinstalled the dependency: `python3 -m pip install --user --break-system-packages gtts`
  (Pop!_OS marks system Python as externally managed per PEP 668, so
  `--break-system-packages` is required to match how `gtts-cli` was
  originally installed).
- Uncommented the `notify-send` lines in `readgTTS.sh` so future failures
  (no text selected, or playback errors) surface as desktop notifications
  instead of failing silently.
- Verified by manually selecting text and running the script directly
  (confirmed `mpv` received and played the generated audio).

## ytdlp-mp3

Downloads a YouTube video or playlist as MP3. Copy a YouTube URL to the
clipboard or pass it as an argument:

```bash
ytdlp-mp3                             # reads URL from clipboard, uses Brave
ytdlp-mp3 "https://youtube.com/..."    # reads URL from argument
ytdlp-mp3 -b firefox                  # extracts cookies from Firefox
ytdlp-mp3 -b firefox "https://..."    # custom browser and argument URL
```

### Skipping already-downloaded files

The script automatically skips files that have already been downloaded:
- Maintains a `.ytdl-archive` file in the current working directory to track downloaded video IDs.
- On launch, pre-seeds `.ytdl-archive` from any existing `* [video_id].mp3` files in the folder.
- Passes `--download-archive .ytdl-archive` and `--no-overwrites` to `yt-dlp` to avoid re-querying or overwriting existing tracks.

### Cookie & Browser configuration

YouTube frequently returns a "Sign in to confirm you're not a bot" error
for anonymous requests. To work around this, the script authenticates
using `--cookies-from-browser` (default: `brave`, or set via `YTDLP_BROWSER` / `-b`).

- Supports `brave`, `firefox`, `chrome`, `chromium`.
- Requires the chosen browser to be logged into a Google/YouTube account.
- **Close the browser before running** `ytdlp-mp3` if yt-dlp reports the
  cookie database is locked.
- Only the `web` player client is used (`youtube:player_client=web`),
  since the `android` client doesn't support cookie authentication and
  is skipped by yt-dlp when cookies are supplied.

