#!/usr/bin/env bash

work_hotkey_active='cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'
work_hotkey_disabled='# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh'

work_hotkey_state() {
  local skhdrc="$1"
  local active_count disabled_count
  active_count="$(grep -Fxc "$work_hotkey_active" "$skhdrc" || true)"
  disabled_count="$(grep -Fxc "$work_hotkey_disabled" "$skhdrc" || true)"
  if [[ "$active_count" == 1 && "$disabled_count" == 0 ]]; then
    printf 'enabled\n'
  elif [[ "$active_count" == 0 && "$disabled_count" == 1 ]]; then
    printf 'disabled\n'
  else
    return 1
  fi
}

recording_mode_marker_state() {
  local marker="$1"
  local state
  if [[ ! -f "$marker" ]]; then
    printf 'absent\n'
    return
  fi
  state="$(<"$marker")"
  case "$state" in
  hotkey_initial=enabled | hotkey_initial=disabled)
    printf '%s\n' "${state#hotkey_initial=}"
    ;;
  *)
    return 1
    ;;
  esac
}

capture_recording_mode_state() {
  local marker="$1"
  local skhdrc="$2"
  local marker_state current_state marker_tmp
  marker_state="$(recording_mode_marker_state "$marker")" || return 1
  if [[ "$marker_state" != absent ]]; then
    printf 'preserved %s\n' "$marker_state"
    return
  fi
  current_state="$(work_hotkey_state "$skhdrc")" || return 1
  mkdir -p "$(dirname "$marker")"
  marker_tmp="${marker}.$$"
  printf 'hotkey_initial=%s\n' "$current_state" >"$marker_tmp"
  mv "$marker_tmp" "$marker"
  [[ "$(recording_mode_marker_state "$marker")" == "$current_state" ]] || return 1
  printf 'created %s\n' "$current_state"
}

disable_work_hotkey() {
  local skhdrc="$1"
  local state
  state="$(work_hotkey_state "$skhdrc")" || return 1
  if [[ "$state" == enabled ]]; then
    sed -i '' 's|^cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|# cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
  fi
  [[ "$(work_hotkey_state "$skhdrc")" == disabled ]]
}

enable_work_hotkey() {
  local skhdrc="$1"
  local state
  state="$(work_hotkey_state "$skhdrc")" || return 1
  if [[ "$state" == disabled ]]; then
    sed -i '' 's|^# cmd + alt - f1 : \$HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh$|cmd + alt - f1 : $HOME/github/dotfiles-latest/scripts/macos/mac/misc/552-skhdDailyWork.sh|' "$skhdrc"
  fi
  [[ "$(work_hotkey_state "$skhdrc")" == enabled ]]
}

restore_initial_work_hotkey() {
  local skhdrc="$1"
  local initial_state="$2"
  case "$initial_state" in
  enabled)
    enable_work_hotkey "$skhdrc"
    ;;
  disabled)
    disable_work_hotkey "$skhdrc"
    ;;
  *)
    return 1
    ;;
  esac
}

restore_livestream_work_hotkey() {
  local skhdrc="$1"
  enable_work_hotkey "$skhdrc" || return 1
}

complete_livestream_work_hotkey_restore() {
  local marker="$1"
  local skhdrc="$2"
  [[ "$(work_hotkey_state "$skhdrc")" == enabled ]] || return 1
  rm -f "$marker"
  [[ ! -e "$marker" && "$(work_hotkey_state "$skhdrc")" == enabled ]]
}
