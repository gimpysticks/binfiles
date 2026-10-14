# Git Repository Synchronization & Push Automation Guide

> **Quick command:** `push-repos` (or `sync-repos`, `repo-sync`)  
> **Source executable:** [`/home/sticks/bin/sync-repos`](file:///home/sticks/bin/sync-repos)  
> **Symlinks:** `push-repos`, `repo-sync`, `git-sync`  
> **User profile:** `@gimpysticks`  

---

## 1. Executive Summary

This tool automates the full git change lifecycle across all your repositories:
1. **Analyzes working tree changes** (`git status --porcelain=v1 -uall`).
2. **Extracts semantic context**:
   - Markdown documents: Parses `# Title` headings for prompt libraries and notes.
   - Shell & Python scripts: Parses docstrings (`"""..."""`) and descriptive header comments.
   - Configuration files: Analyzes configuration keys and diffs (e.g. tilde path expansion).
   - Permission updates: Detects execution bit changes (e.g. `100644` -> `100755`).
3. **Synthesizes clean conventional commit messages**:
   - Formats conventional type prefixes (`feat:`, `docs:`, `config:`, `chore:`, `fix:`).
   - Generates concise subject lines under 72 characters.
   - Builds detailed multi-line bullet points documenting added, modified, deleted, and permission-changed files.
4. **Interactive review & editor support**:
   - Accept with `<Enter>`, edit in `$EDITOR` (`nvim`), manually type a message, skip, or quit.
5. **Stages, pulls, and pushes**:
   - Automatically runs `git add -A`.
   - Safely pulls remote updates with `git pull --rebase`.
   - Pushes to tracked remote branches (`git push -u origin <branch>`).
6. **Safety barriers**:
   - Detects and skips repositories mid-rebase or in merge conflicts (e.g. `Documents/chats`).
   - Ignores 3rd-party vendor repositories to avoid pushing to external forks.

---

## 2. Command Reference

| Command | Action |
| :--- | :--- |
| `push-repos` | Synchronize current repository (if inside one) or scan all |
| `push-repos --all` (or `-a`) | Scan and synchronize all user repositories across `~` |
| `push-repos --dry-run` (or `-n`) | Simulate analysis, staged files, commit message, and push without changing git |
| `push-repos --list` (or `-l`) | List pending changes across all repositories |
| `push-repos -y` (or `--yes`) | Non-interactive mode (auto-accepts commit messages and pushes) |
| `push-repos -m "custom message"` | Override commit message generation |
| `push-repos --guide` | Display this reference guide directly in your terminal |
| `push-repos <repo-name>` | Target a specific repo by name (e.g., `push-repos Prompt_library`) |
| `push-repos <path>` | Target a specific repo path (e.g., `push-repos ~/.config/variety`) |
| `push-repos --no-push` | Stage and commit locally without pushing to remote |
| `push-repos --no-pull` | Skip pulling remote updates before pushing |

---

## 3. Repository Inventory & Remotes

| Repository Directory | Default Branch | Remote URL | Purpose |
| :--- | :---: | :--- | :--- |
| `~/bin` | `master` | `https://github.com/gimpysticks/binfiles.git` | Primary shell & Python utility suite |
| `~/.config/variety` | `main` | `https://github.com/gimpysticks/variety-config.git` | Wallpaper automation & COSMIC scripts |
| `~/Documents/Prompt_library` | `master` | `https://github.com/gimpysticks/Prompt_library.git` | AI image generation & LLM prompts |
| `~/Documents/gimpysticks_canonical_prompt_system` | `master` | `https://github.com/gimpysticks/gimpysticks_canonical_prompt_system.git` | Canonical AI prompt framework |
| `~/repos/ai-art-challenges` | `master` | `https://github.com/gimpysticks/ai-art-challenges.git` | AI art challenges archive |
| `~/repos/nvim-config` | `main` | `https://github.com/gimpysticks/nvim-config.git` | Neovim configuration |
| `~/.config/nvim` | `master` | `https://github.com/gimpysticks/nvim-config.git` | Live Neovim configuration |
| `~/zets` | `master` | `https://github.com/gimpysticks/Zets.git` | Zettelkasten knowledge base notes |

---

## 4. Script Ecosystem Analysis Summary

### Language Distribution (1,017 Executables)
* **Bash** (`#!/bin/bash`): **515 scripts (51%)** — Core interactive utilities and system tools.
* **POSIX sh** (`#!/bin/sh`): **280 scripts (28%)** — High-speed wrappers and git aliases.
* **Python 3** (`#!/usr/bin/env python3`): **24 scripts** — Bluetooth OBEX transfer, DBus tools, and scrapers.
* **Zsh & Others**: **22 scripts** — Custom shell workflows.
* **ABS Reference Guide**: 370+ scripts stored in `~/bin/abs-scripts`.

### Functional Categorization
1. **Terminal & Shell Workflow (266 scripts)**: `autolj`, `tmuxlive`, `pwdname`, `topegntokfilter`.
2. **Notes, Markdown & Productivity (182 scripts)**: `update_zets`, `wiki-update`, `combine_md`.
3. **Multimedia & Stream Ingestion (70 scripts)**: `ytdlp-mp3`, `obs-backup`, `vivaldi-media`.
4. **Hardware, Bluetooth & Network (71 scripts)**: `bluetooth-send`, `bt-send`, `reconnect-bt`, `nordconn`.
5. **Desktop & Window Management (51 scripts)**: COSMIC keybindings, `restore_keybinds`, `ud`.
6. **System Administration & Maintenance (91 scripts)**: `updateArch`, `update-nvim`, `fstab`.
7. **Git & Version Control (54 scripts)**: `commit`, `status`, `save`, `add`, `switch`, `latest`.

---

## 5. Shell Script Invariant
All executable scripts created in this environment **must not use `.sh` extensions**. They must include a valid shebang (`#!/bin/sh`, `#!/usr/bin/env bash`, or `#!/usr/bin/env python3`) and have execution permissions (`chmod +x`).
