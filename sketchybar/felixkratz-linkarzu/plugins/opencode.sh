#!/usr/bin/env bash

set -u

source "$CONFIG_DIR/colors.sh"

selector="$HOME/github/dotfiles-latest/kitty/scripts/kitty-opencode-sessions.sh"
qat_launcher="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/561-skhdQatOpencode.sh"
refresh_lock="/tmp/sketchybar-opencode-refresh.lock"

refresh() {
  local windows="[]"
  local count=0
  local waiting=0
  local color="$GREY"
  local id=""
  local status=""
  local reason=""
  local busy=0
  local title=""
  local cwd=""
  local detail=""
  local row_icon=""
  local row_color="$GREY"
  local args=()

  if ! mkdir "$refresh_lock" 2>/dev/null; then
    (sleep 0.2 && sketchybar --trigger opencode_update) >/dev/null 2>&1 &
    return 0
  fi
  trap 'rmdir "$refresh_lock" 2>/dev/null || true' EXIT

  windows="$($selector --json 2>/dev/null || printf '[]\n')"
  if ! jq -e 'type == "array"' >/dev/null 2>&1 <<<"$windows"; then
    windows="[]"
  fi

  count="$(jq 'length' <<<"$windows")"
  waiting="$(jq '[.[] | select(.waiting > 0)] | length' <<<"$windows")"

  if ((waiting > 0)); then
    color="$RED"
  elif ((count > 0)); then
    color="$BLUE"
  fi

  args+=(--set opencode label="$count" icon.color="$color")
  args+=(--remove '/opencode\.window\..*/')

  while IFS=$'\t' read -r id status reason busy title cwd; do
    [[ -n "$id" ]] || continue
    cwd="${cwd/#$HOME/~}"

    case "$status" in
    attention)
      row_icon="!"
      row_color="$RED"
      detail="$reason"
      ;;
    running)
      row_icon=">"
      row_color="$BLUE"
      detail="${busy} busy"
      ;;
    *)
      row_icon="-"
      row_color="$GREY"
      detail="idle"
      ;;
    esac

    args+=(
      --clone "opencode.window.${id}" opencode.template
      --set "opencode.window.${id}"
      drawing=on
      icon="$row_icon"
      icon.color="$row_color"
      label="${title}  ${cwd}  ${detail}"
      click_script="$selector --focus $id; sketchybar --set opencode popup.drawing=off"
    )
  done < <(jq -r '.[] | [.id, .status, .reason, .busy, .title, .cwd] | @tsv' <<<"$windows")

  if ((count == 0)); then
    args+=(
      --clone opencode.window.empty opencode.template
      --set opencode.window.empty
      drawing=on
      icon="-"
      icon.color="$GREY"
      label="No OpenCode tabs"
    )
  fi

  sketchybar "${args[@]}" >/dev/null
  rmdir "$refresh_lock" 2>/dev/null || true
  trap - EXIT
}

case "${SENDER:-routine}" in
mouse.clicked)
  if [[ "${BUTTON:-left}" == "right" ]]; then
    "$qat_launcher" >/dev/null 2>&1 &
  else
    refresh
    sketchybar --set opencode popup.drawing=toggle
  fi
  ;;
mouse.exited.global)
  sketchybar --set opencode popup.drawing=off
  ;;
system_woke)
  sleep 2
  refresh
  ;;
*)
  refresh
  ;;
esac
