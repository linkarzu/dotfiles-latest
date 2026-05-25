#!/usr/bin/env bash

set -euo pipefail

bookmarks_files=(
  "$HOME/github/dotfiles-latest/bookmarks/bookmarks.tsv"
  "$HOME/github/dotfiles-private/bookmarks/bookmarks.tsv"
)
fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"
qat_config="$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
bookmarks_group="bookmarks"

main_kitty_socket() {
  local sock pid command

  # Each QAT creates its own /tmp/kitty-* socket. Use the main kitty process so
  # hide/show commands do not accidentally target another floating terminal.
  for sock in /tmp/kitty-*; do
    [[ -S "$sock" ]] || continue
    pid="${sock##*-}"
    command="$(ps -p "$pid" -o command= 2>/dev/null || true)"

    if [[ "$command" == "$kitty_bin"* ]]; then
      printf '%s\n' "$sock"
      return 0
    fi
  done

  return 1
}

toggle_bookmarks_qat() {
  local sock

  sock="$(main_kitty_socket)" || return 0
  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$bookmarks_group" >/dev/null 2>&1 || true
}

launch_bookmarks_qat() {
  local sock

  sock="$(main_kitty_socket)" || {
    echo "No main kitty socket found."
    exit 1
  }

  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$bookmarks_group" \
    /bin/bash "$HOME/github/dotfiles-latest/scripts/macos/mac/misc/557-skhdQatBookmarks.sh" --pick
}

if [[ "${1:-}" == "--pick" ]]; then
  bookmark_reload_cmd='query={q}; if [[ ${#query} -ge 3 ]]; then for bookmarks_file in'
  fzf_args=(
    --height=100%
    --reverse
    --delimiter=$'\t'
    --with-nth=1
    --header="Type at least 3 characters to search bookmarks"
    --prompt="Open bookmark > "
  )
  has_bookmarks=false

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is not installed."
    read -r -p "Press enter to close. "
    exit 1
  fi

  for bookmarks_file in "${bookmarks_files[@]}"; do
    if [[ -s "$bookmarks_file" ]]; then
      has_bookmarks=true
      break
    fi
  done

  if [[ "$has_bookmarks" == false ]]; then
    echo "No bookmarks found in:"
    printf '  %s\n' "${bookmarks_files[@]}"
    read -r -p "Press enter to close. "
    exit 1
  fi

  if [[ -f "$fzf_colors_file" ]]; then
    # shellcheck disable=SC1090
    source "$fzf_colors_file"
  fi

  for bookmarks_file in "${bookmarks_files[@]}"; do
    printf -v quoted_bookmarks_file '%q' "$bookmarks_file"
    bookmark_reload_cmd+=" $quoted_bookmarks_file"
  done
  bookmark_reload_cmd+='; do [[ -s "$bookmarks_file" ]] && cat "$bookmarks_file"; done; fi'
  fzf_args+=(--bind "change:reload($bookmark_reload_cmd)")

  if [[ -n "${linkarzu_fzf_colors:-}" ]]; then
    fzf_args+=(--color="$linkarzu_fzf_colors")
  fi

  while true; do
    # Keep this process alive after every action. When the QAT process stays
    # alive, kitty only toggles visibility instead of cold-starting a new panel.
    if ! selected=$(: | fzf "${fzf_args[@]}"); then
      # Esc makes fzf exit non-zero. Treat it as "hide and rearm" so the next
      # keypress shows an already-running picker instead of starting from cold.
      toggle_bookmarks_qat
      continue
    fi

    IFS=$'\t' read -r _name url <<<"$selected"

    if [[ -z "${url:-}" ]]; then
      echo "Invalid bookmark: $selected"
      read -r -p "Press enter to continue. "
      toggle_bookmarks_qat
      continue
    fi

    toggle_bookmarks_qat
    open "$url"
  done
fi

launch_bookmarks_qat
