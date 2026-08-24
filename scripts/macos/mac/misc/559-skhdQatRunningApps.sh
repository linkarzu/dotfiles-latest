#!/usr/bin/env bash

set -euo pipefail

# NOTE: Reset after editing this file with this command in the terminal:
# pkill -f 'kitty-quick-access.*--instance-group=running-apps'
#
# The running app picker intentionally stays alive in the while loop below so
# QAT can toggle quickly. Restarting that process makes it load file changes.

fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"
qat_config="$HOME/github/dotfiles-latest/kitty/quick-access-terminal-center.conf"
kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
running_apps_group="running-apps"
qat_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/559-skhdQatRunningApps.sh"

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

toggle_running_apps_qat() {
  local sock

  sock="$(main_kitty_socket)" || return 0
  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$running_apps_group" >/dev/null 2>&1 || true
}

launch_running_apps_qat() {
  local sock

  sock="$(main_kitty_socket)" || {
    echo "No main kitty socket found."
    exit 1
  }

  "$kitty_bin" @ --to "unix:${sock}" \
    action launch --type=background kitten quick-access-terminal \
    --config "$qat_config" \
    --instance-group "$running_apps_group" \
    /bin/bash "$qat_script" --pick
}

running_apps() {
  yabai -m query --windows | jq -r '
    [.[].app]
    | sort_by(ascii_downcase)
    | group_by(.)
    | map({app: .[0], count: length})
    | sort_by(.app | ascii_downcase)
    | .[]
    | if .count > 1 then "\(.app) (\(.count))" else .app end
  '
}

app_from_display() {
  local display

  display="$1"
  if [[ "$display" =~ ^(.*)\ \([0-9]+\)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
  else
    printf '%s\n' "$display"
  fi
}

focus_app() {
  local app id

  app="$1"
  id="$(yabai -m query --windows | jq -r --arg app "$app" '[.[] | select(.app == $app)][0].id')"

  if [[ -n "$id" && "$id" != null ]]; then
    yabai -m window --focus "$id"
  fi
}

quit_app() {
  local app

  app="$1"
  [[ -n "$app" ]] || return 0
  osascript - "$app" <<'APPLESCRIPT'
on run argv
  tell application (item 1 of argv) to quit
end run
APPLESCRIPT
}

wait_for_app_to_disappear() {
  local app id

  app="$1"
  [[ -n "$app" ]] || return 0

  for _ in {1..20}; do
    id="$(yabai -m query --windows | jq -r --arg app "$app" '[.[] | select(.app == $app)][0].id')"
    if [[ -z "$id" || "$id" == null ]]; then
      return 0
    fi
    sleep 0.1
  done
}

if [[ "${1:-}" == "--list" ]]; then
  running_apps
  exit 0
fi

if [[ "${1:-}" == "--quit" ]]; then
  shift
  quit_app "$(app_from_display "$*")"
  exit 0
fi

if [[ "${1:-}" == "--pick" ]]; then
  fzf_args=(
    --height=100%
    --reverse
    --header="Type to filter running apps | Enter: switch | Ctrl-Alt-k: quit"
    --prompt="Switch app > "
    --expect=ctrl-alt-k
    --bind "change:reload($qat_script --list)"
    --no-clear
  )

  for dependency in fzf jq osascript yabai; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
      echo "$dependency is not installed or not in PATH."
      read -r -p "Press enter to close. "
      exit 1
    fi
  done

  if [[ -f "$fzf_colors_file" ]]; then
    # shellcheck disable=SC1090
    source "$fzf_colors_file"
  fi

  if [[ -n "${linkarzu_fzf_colors:-}" ]]; then
    fzf_args+=(--color="$linkarzu_fzf_colors")
  fi

  while true; do
    set +e
    fzf_output="$(running_apps | fzf "${fzf_args[@]}")"
    fzf_rc=$?
    set -e

    if [[ $fzf_rc -ne 0 ]]; then
      # Esc makes fzf exit non-zero. Treat it as "hide and rearm" so the next
      # keypress shows an already-running picker instead of starting from cold.
      toggle_running_apps_qat
      continue
    fi

    key="${fzf_output%%$'\n'*}"
    if [[ "$fzf_output" == "$key" ]]; then
      selected="$key"
    else
      selected="${fzf_output#*$'\n'}"
    fi

    if [[ "$key" == "ctrl-alt-k" ]]; then
      [[ -n "$selected" ]] || continue
      app="$(app_from_display "$selected")"
      quit_app "$app"
      wait_for_app_to_disappear "$app"
      toggle_running_apps_qat
      continue
    fi

    [[ -n "$selected" ]] || continue
    app="$(app_from_display "$selected")"
    toggle_running_apps_qat
    focus_app "$app"
  done
fi

launch_running_apps_qat
