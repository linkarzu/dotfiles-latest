#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/kitty/scripts/kitty-list-tabs.sh
# Shows open kitty tab titles in fzf and switches using `action goto_session`
# Called from outside kitty (skhd, scripts, etc)

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"

# Requirements
if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is not installed or not in PATH."
  echo "Install (brew): brew install fzf"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed or not in PATH."
  echo "Install (brew): brew install jq"
  exit 1
fi

if [[ ! -x "$kitty_bin" ]]; then
  echo "kitty binary not found at: $kitty_bin"
  exit 1
fi

sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1 || true)"
if [[ -z "${sock:-}" ]]; then
  echo "No kitty sockets found in /tmp (kitty not running, or remote control not available)."
  exit 1
fi

tabs_tsv="$(
  "$kitty_bin" @ --to "unix:${sock}" ls 2>/dev/null | jq -r '
    .[].tabs[]
    | [(.title|tostring), (.is_focused|tostring)]
    | @tsv
  ' | sort -u
)"

if [[ -z "${tabs_tsv:-}" ]]; then
  echo "No tabs found."
  exit 1
fi

# Format menu as:
# raw_title<TAB>pretty_display
menu_lines="$(
  printf "%s\n" "$tabs_tsv" | awk -F'\t' '{
    title=$1
    focused=$2
    if (focused == "true") {
      printf "%s\t\033[31m[current]\033[0m %s\n", title, title
    } else {
      printf "%s\t          %s\n", title, title
    }
  }'
)"

selected_line="$(
  printf "%s\n" "$menu_lines" |
    fzf --ansi --height=100% --reverse \
      --header="Select a kitty tab/session (Esc to cancel)" \
      --prompt="Kitty > " \
      --no-multi \
      --with-nth=2..
)"

# User cancelled
if [[ -z "${selected_line:-}" ]]; then
  exit 0
fi

selected_title="$(printf "%s" "$selected_line" | awk -F'\t' '{print $1}')"
if [[ -z "${selected_title:-}" ]]; then
  exit 0
fi

# Switch using goto_session (will jump to existing session/tab if it exists)
"$kitty_bin" @ --to "unix:${sock}" action goto_session "$selected_title"
