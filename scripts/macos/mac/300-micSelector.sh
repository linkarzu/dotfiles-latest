#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/300-micSelector.sh
# Lists available macOS input devices (mics) and lets you select one via fzf

# NOTE:
# If mic switching "doesn't work" or seems to revert after you pick a device,
# It's because of
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mic.sh
# That script auto-switches the input back to the preferred mic (e.g. "Shure"),
# so it can override whatever is selected in the fzf menu. Just unplug your
# preferred mic and this script will work

set -euo pipefail

# Requirements
if ! command -v SwitchAudioSource >/dev/null 2>&1; then
  echo "SwitchAudioSource is not installed or not in PATH."
  echo "Install (brew): brew install switchaudio-osx"
  exit 1
fi

if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is not installed or not in PATH."
  echo "Install (brew): brew install fzf"
  exit 1
fi

# Current input device
current_raw="$(SwitchAudioSource -t input -c 2>/dev/null || true)"
current="$(printf "%s" "$current_raw" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || true)"

# Build list of devices (skip invalid/empty lines to avoid malformed UTF-8 noise)
devices=()
while IFS= read -r d; do
  d_clean="$(printf "%s" "$d" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null || true)"
  if [[ -n "$d_clean" ]]; then
    devices+=("$d_clean")
  fi
done < <(SwitchAudioSource -a -t input 2>/dev/null || true)

if [[ ${#devices[@]} -eq 0 ]]; then
  echo "No input devices found."
  exit 1
fi

# Display list, marking the current device (if it matches)
menu_lines=()
for d in "${devices[@]}"; do
  if [[ -n "$current" && "$d" == "$current" ]]; then
    menu_lines+=("[current] $d")
  else
    menu_lines+=("          $d")
  fi
done

selected_line="$(
  printf "%s\n" "${menu_lines[@]}" |
    fzf --height=100% --reverse \
      --header="Select an input device (Esc to cancel)" \
      --prompt="Mic > " \
      --no-multi
)"

# User cancelled
if [[ -z "${selected_line:-}" ]]; then
  exit 0
fi

# Strip the prefixes we added
selected_device="${selected_line#[current] }"
selected_device="${selected_device#"          "}"

# Switch
SwitchAudioSource -t input -s "$selected_device" >/dev/null 2>&1

# echo "Selected mic: $selected_device"
