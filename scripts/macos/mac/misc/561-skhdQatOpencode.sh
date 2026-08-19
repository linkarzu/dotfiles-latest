#!/usr/bin/env bash

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
main_socket_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh"
qat_config="$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf"
selector="$HOME/github/dotfiles-latest/kitty/scripts/kitty-opencode-sessions.sh"
qat_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/561-skhdQatOpencode.sh"
instance_group="opencode-sessions"

toggle_qat() {
  local socket=""
  socket="$($main_socket_script 2>/dev/null || true)"
  [[ -n "$socket" ]] || return 0

  "$kitty_bin" @ --to "unix:${socket}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$instance_group" >/dev/null 2>&1 || true
}

launch_qat() {
  local socket=""
  socket="$($main_socket_script)"

  "$kitty_bin" @ --to "unix:${socket}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$instance_group" \
    /bin/bash "$qat_script" --pick
}

if [[ "${1:-}" == "--pick" ]]; then
  set +e
  available="$($selector --list)"
  list_rc=$?
  set -e

  if [[ $list_rc -ne 0 ]]; then
    exit "$list_rc"
  fi
  if [[ -z "$available" ]]; then
    printf 'No OpenCode tabs are running.\n'
    read -r -p "Press enter to hide. "
    toggle_qat
    exit 0
  fi

  set +e
  window_id="$($selector --pick-id)"
  picker_rc=$?
  set -e

  toggle_qat
  if [[ $picker_rc -eq 0 && -n "$window_id" ]]; then
    "$selector" --focus "$window_id" || true
  elif [[ $picker_rc -ne 1 && $picker_rc -ne 130 ]]; then
    exit "$picker_rc"
  fi
  exit 0
fi

launch_qat
