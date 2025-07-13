#!/usr/bin/env bash

# Debug log location
LOG_FILE="/tmp/280-setupObs.log"
: >"$LOG_FILE"

MD_DIR="$HOME/github/dotfiles-private/scripts/macos/mac/obs/meeting/py/meetings"
PY_SCRIPT="$HOME/github/dotfiles-private/scripts/macos/mac/obs/set-obs/obs-from-md.py"

echo "[DEBUG] MD_DIR: $MD_DIR" >>"$LOG_FILE"
echo "[DEBUG] PY_SCRIPT: $PY_SCRIPT" >>"$LOG_FILE"

# Ensure fzf is installed
if ! command -v fzf &>/dev/null; then
  echo "fzf is not installed. Please install it first."
  echo "[DEBUG] fzf not found" >>"$LOG_FILE"
  exit 1
fi

# Gather available .md files
files=($(ls "$MD_DIR"/*.md 2>/dev/null | xargs -n 1 basename))
echo "[DEBUG] Found ${#files[@]} markdown files" >>"$LOG_FILE"

# Abort if none found
if [ ${#files[@]} -eq 0 ]; then
  echo "No markdown files found in $MD_DIR."
  echo "[DEBUG] abort – none found" >>"$LOG_FILE"
  exit 1
fi

# pick a file
selected_file=$(printf "%s\n" "${files[@]}" |
  fzf --height=40% --reverse --header="Select a meeting file" --prompt="Meeting > ")

echo "[DEBUG] selected_file: $selected_file" >>"$LOG_FILE"

# Abort if nothing chosen
if [ -z "$selected_file" ]; then
  echo "No file selected."
  echo "[DEBUG] abort – no selection" >>"$LOG_FILE"
  exit 0
fi

# Run generate_links.py with the chosen file
echo "[DEBUG] Running: python3 \"$PY_SCRIPT\" \"$MD_DIR/$selected_file\"" >>"$LOG_FILE"
python3 "$PY_SCRIPT" "$MD_DIR/$selected_file"

export MD_HEADING_BG=transparent && NVIM_APPNAME=neobean nvim "$MD_DIR/$selected_file"
