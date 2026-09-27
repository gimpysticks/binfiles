#!/usr/bin/env bash
# Font consolidation / fontconfig cleanup.
# Nothing is deleted: everything removed from the active font path is moved
# into $ARCHIVE so it can be restored or reviewed later.
set -uo pipefail

HOME_DIR="/home/sticks"
ACTIVE="$HOME_DIR/.local/share/fonts"
LEGACY="$HOME_DIR/.fonts"
ARCHIVE="$HOME_DIR/font-cleanup-archive-$(date +%Y%m%d)"
MANIFEST="$ARCHIVE/MANIFEST.txt"

mkdir -p "$ARCHIVE"/{duplicates,non-font-files,legacy-dot-fonts-remains,config-backup,stale-uuid-files}

log() { printf '%s\n' "$*" | tee -a "$MANIFEST"; }

log "=== font cleanup $(date -Is) ==="
log ""

# ---------------------------------------------------------------------------
# 0. Pre-inventory: hash every font file in both trees so we can prove later
#    that no unique font content was lost.
# ---------------------------------------------------------------------------
log "--- hashing fonts before changes (this takes a moment) ---"
find "$LEGACY" "$ACTIVE" -type f \
     \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.ttc' -o -iname '*.pfb' -o -iname '*.woff*' \) \
     -exec md5sum {} + 2>/dev/null | awk '{print $1}' | sort -u > "$ARCHIVE/hashes-before.txt"
log "unique font blobs before: $(wc -l < "$ARCHIVE/hashes-before.txt")"
log ""

# ---------------------------------------------------------------------------
# 1. Promote fonts that exist ONLY in the deprecated ~/.fonts tree into the
#    active XDG tree.
# ---------------------------------------------------------------------------
log "--- 1. moving unique fonts out of deprecated ~/.fonts into active tree ---"

promote_dir() { # $1 = source dir under ~/.fonts, $2 = dest name under active tree
  if [ -d "$LEGACY/$1" ]; then
    mkdir -p "$ACTIVE/$2"
    # shellcheck disable=SC2086
    find "$LEGACY/$1" -type f ! -name '.uuid' -exec mv -n {} "$ACTIVE/$2/" \;
    log "  promoted: ~/.fonts/$1 -> ~/.local/share/fonts/$2"
  fi
}

# Whole families that exist nowhere else
promote_dir "Kalnia"          "Kalnia"
promote_dir "Uncial_Antiqua"  "UncialAntiqua"
promote_dir "Old_Standard_TT" "OldStandardTT"

# Variable-font files that the active tree lacks (it only has the static cuts)
for pair in "Cormorant_Garamond:CormorantGaramond" \
            "Libre_Baskerville:LibreBaskerville" \
            "Playfair_Display:PlayfairDisplay"; do
  src="${pair%%:*}"; dst="${pair##*:}"
  mkdir -p "$ACTIVE/$dst"
  for f in "$LEGACY/$src"/*VariableFont*.ttf; do
    [ -e "$f" ] || continue
    mv -n "$f" "$ACTIVE/$dst/" && log "  promoted variable font: $(basename "$f") -> $dst/"
  done
done

# Victorian Parlor exists only in ~/.fonts (kept in both formats)
mkdir -p "$ACTIVE/VictorianParlor"
for f in "$LEGACY"/Victorian\ Parlor*; do
  [ -e "$f" ] || continue
  mv -n "$f" "$ACTIVE/VictorianParlor/" && log "  promoted: $(basename "$f") -> VictorianParlor/"
done
log ""

# ---------------------------------------------------------------------------
# 2. Byte-identical duplicates -> archive
# ---------------------------------------------------------------------------
log "--- 2. archiving byte-identical duplicate fonts ---"

archive_dup() { # $1 = path under ~/.fonts
  if [ -e "$LEGACY/$1" ]; then
    mkdir -p "$ARCHIVE/duplicates/$(dirname "$1")"
    mv -n "$LEGACY/$1" "$ARCHIVE/duplicates/$1" && log "  dup archived: ~/.fonts/$1"
  fi
}

for d in Alex_Brush IM_Fell_English Monsieur_La_Doulaise Parisienne Pinyon_Script; do
  archive_dup "$d"
done
for d in Cormorant_Garamond Libre_Baskerville Playfair_Display; do
  archive_dup "$d/static"
done
archive_dup "Billy Argel Font___.ttf"
archive_dup "Death Stinger.otf"
archive_dup "Frost Scream.otf"
archive_dup "ThellyBlack-Regular.ttf"

# Older duplicate *version* of Rochester (active tree has a newer build)
archive_dup "Rochester"
log ""

# ---------------------------------------------------------------------------
# 3. Non-font clutter sitting inside the scanned font path
# ---------------------------------------------------------------------------
log "--- 3. archiving non-font files from the font scan path ---"
for f in "$LEGACY/cover.png" \
         "$LEGACY/Thank-you.png" \
         "$LEGACY/Visit Here for More Fonts and Freebies.url" \
         "$ACTIVE/billy_argel_font_regular/.DS_Store" \
         "$ACTIVE/billy_argel_font_regular/BILLYA ARGEL FONT.jpg" \
         "$ACTIVE/Old Cave.png" \
         "$ACTIVE/Thelly Black.pdf"; do
  [ -e "$f" ] || continue
  mv -n "$f" "$ARCHIVE/non-font-files/" && log "  archived: ${f#"$HOME_DIR"/}"
done
log ""

# ---------------------------------------------------------------------------
# 4. Retire the deprecated ~/.fonts tree entirely
# ---------------------------------------------------------------------------
log "--- 4. retiring deprecated ~/.fonts ---"
if [ -d "$LEGACY" ]; then
  remaining=$(find "$LEGACY" -type f ! -name '.uuid' | wc -l)
  log "  font/other files still in ~/.fonts (expected 0): $remaining"
  if [ "$remaining" -eq 0 ]; then
    mv "$LEGACY" "$ARCHIVE/legacy-dot-fonts-remains/dot-fonts" \
      && log "  ~/.fonts retired -> $ARCHIVE/legacy-dot-fonts-remains/dot-fonts"
  else
    log "  !! NOT retiring ~/.fonts: unexpected leftovers, review manually"
    find "$LEGACY" -type f ! -name '.uuid' | tee -a "$MANIFEST"
  fi
fi
log ""

# ---------------------------------------------------------------------------
# 5. Stale fontconfig .uuid files (deprecated feature, removed upstream)
# ---------------------------------------------------------------------------
log "--- 5. archiving stale .uuid marker files ---"
count=0
while IFS= read -r u; do
  rel="${u#"$HOME_DIR"/}"
  mkdir -p "$ARCHIVE/stale-uuid-files/$(dirname "$rel")"
  mv -n "$u" "$ARCHIVE/stale-uuid-files/$rel" && count=$((count+1))
done < <(find "$ACTIVE" "$HOME_DIR/.Fontmatrix" -name '.uuid' 2>/dev/null)
log "  .uuid files archived: $count"
log ""

# ---------------------------------------------------------------------------
# 6. Remove empty directories left inside the active tree
# ---------------------------------------------------------------------------
log "--- 6. pruning empty directories in active tree ---"
while IFS= read -r d; do
  rmdir "$d" 2>/dev/null && log "  pruned empty dir: ${d#"$HOME_DIR"/}"
done < <(find "$ACTIVE" -mindepth 1 -type d -empty)
log ""

# ---------------------------------------------------------------------------
# 7. Dead fontconfig configuration
# ---------------------------------------------------------------------------
log "--- 7. cleaning dead fontconfig config ---"
cp -a "$HOME_DIR/.config/fontconfig" "$ARCHIVE/config-backup/" \
  && log "  backed up ~/.config/fontconfig -> $ARCHIVE/config-backup/fontconfig"

# PowerlineSymbols is not installed -> every alias in this file is a dead end
if [ -f "$HOME_DIR/.config/fontconfig/conf.d/10-powerline-symbols.conf" ]; then
  if [ "$(fc-list PowerlineSymbols | wc -l)" -eq 0 ]; then
    mv "$HOME_DIR/.config/fontconfig/conf.d/10-powerline-symbols.conf" \
       "$ARCHIVE/config-backup/10-powerline-symbols.conf.disabled" \
      && log "  disabled 10-powerline-symbols.conf (PowerlineSymbols not installed)"
  fi
fi

# Font Manager's reject list is empty -> file does nothing
if [ -f "$HOME_DIR/.config/fontconfig/conf.d/78-Reject.conf" ]; then
  if ! grep -q 'rejectfont' "$HOME_DIR/.config/fontconfig/conf.d/78-Reject.conf"; then
    log "  note: 78-Reject.conf is empty (rejects nothing) - left in place for Font Manager"
  fi
fi
log ""

# ---------------------------------------------------------------------------
# 8. Purge the fontconfig cache (785 files / 30M for only ~133 real dirs)
# ---------------------------------------------------------------------------
log "--- 8. purging stale fontconfig cache ---"
log "  cache files before: $(ls -1 "$HOME_DIR/.cache/fontconfig" 2>/dev/null | wc -l) ($(du -sh "$HOME_DIR/.cache/fontconfig" 2>/dev/null | cut -f1))"
rm -rf "$HOME_DIR/.cache/fontconfig"
log "  cache purged (will be regenerated)"
log ""

log "=== file moves complete; rebuild + verification runs next ==="
