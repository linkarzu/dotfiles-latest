#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/brew.sh

source "$CONFIG_DIR/colors.sh"

# Homebrew can crash when `brew outdated` runs from SketchyBar (non-interactive
# environment) because it tries to detect CPU cores to set download concurrency,
# and that code path can error out there. Forcing a fixed concurrency avoids that
# CPU-detection path so `brew outdated` returns a proper list/count.
export HOMEBREW_DOWNLOAD_CONCURRENCY=1

# COUNT=1
if OUT="$(brew outdated 2>&1)"; then
  RC=0
  COUNT="$(printf "%s\n" "$OUT" | wc -l | tr -d ' ')"
else
  RC=$?
  COUNT="!"
  COLOR=$RED
fi

# # Debugging:
# # Homebrew can fail when `brew outdated` is executed from SketchyBar (non-interactive
# # environment). We capture stdout+stderr into $OUT and write it to a tmp file so we
# # can see the full Ruby stacktrace or error message instead of SketchyBar silently
# # showing a wrong count.
# printf "%s\n" "$OUT" >/tmp/sketchybar-brew-outdated.txt
#
# # Debugging:
# # Summary log for quick checks. This shows when the script ran, which item triggered
# # it ($NAME), the brew exit code ($RC), the brew path used, and the first line of
# # output (usually the error). To inspect later:
# #   tail -n 50 /tmp/sketchybar-brew.log
# #   cat /tmp/sketchybar-brew-outdated.txt
# echo "$(date) | NAME=$NAME | rc=$RC | brew=$(command -v brew 2>/dev/null) | first_line=$(printf '%s' "$OUT" | head -n 1) | full=/tmp/sketchybar-brew-outdated.txt" >/tmp/sketchybar-brew.log

case "$COUNT" in
[3-5][0-9])
  COLOR=$ORANGE
  ;;
[1-2][0-9])
  COLOR=$YELLOW
  ;;
[1-9])
  COLOR=$WHITE
  ;;
0)
  COLOR=$GREEN
  COUNT=􀆅
  ;;
esac

sketchybar --set $NAME label=$COUNT icon.color=$COLOR
