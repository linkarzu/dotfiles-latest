#!/usr/bin/env bash

set -euo pipefail

# NOTE: Reset after editing this file with this command in the terminal:
# pkill -f 'kitty-quick-access.*--instance-group=kitty-zoxide'
#
# The zoxide picker intentionally stays alive in the while loop below so QAT
# can toggle quickly. Restarting that process makes it load file changes.

qat_config="$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
zoxide_group="kitty-zoxide"
zoxide_script="$HOME/github/dotfiles-latest/kitty/scripts/kitty-zoxide-session.sh"
qat_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/558-skhdQatZoxide.sh"

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

toggle_zoxide_qat() {
  local sock

  sock="$(main_kitty_socket)" || return 0
  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$zoxide_group" >/dev/null 2>&1 || true
}

launch_zoxide_qat() {
  local sock

  sock="$(main_kitty_socket)" || {
    echo "No main kitty socket found."
    exit 1
  }

  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$zoxide_group" \
    /bin/bash "$qat_script" --pick
}

if [[ "${1:-}" == "--pick" ]]; then
  while true; do
    if "$zoxide_script"; then
      toggle_zoxide_qat
      continue
    fi

    read -r -p "Press enter to continue. "
    toggle_zoxide_qat
  done
fi

launch_zoxide_qat
