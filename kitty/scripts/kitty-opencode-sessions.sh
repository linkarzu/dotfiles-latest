#!/usr/bin/env bash

set -euo pipefail

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
main_socket_script="$HOME/github/dotfiles-latest/scripts/macos/mac/misc/549-kittyMainSocket.sh"
fzf_colors_file="$HOME/github/dotfiles-latest/colorscheme/active/active-fzf-colors.sh"

require_cmd() {
  local command="$1"
  if ! command -v "$command" >/dev/null 2>&1; then
    printf '%s is not installed or not in PATH.\n' "$command" >&2
    exit 127
  fi
}

require_cmd jq

if [[ ! -x "$kitty_bin" ]]; then
  printf 'kitty binary not found at: %s\n' "$kitty_bin" >&2
  exit 1
fi

kitty_socket() {
  "$main_socket_script"
}

opencode_windows() {
  local socket=""
  socket="$(kitty_socket 2>/dev/null || true)"
  if [[ -z "$socket" ]]; then
    printf '[]\n'
    return 0
  fi

  "$kitty_bin" @ --to "unix:${socket}" ls 2>/dev/null | jq '
    def number: try tonumber catch 0;
    [
      .[] as $os
      | $os.tabs[] as $tab
      | $tab.windows[]?
      | select(any(.foreground_processes[]?.cmdline[0]?; type == "string" and split("/")[-1] == "opencode"))
      | {
          id,
          title: (.title // "OpenCode"),
          session_name: (.session_name // ""),
          cwd: (.env.PWD // .cwd // ""),
          focused: (($os.is_focused // false) and ($tab.is_focused // false) and (.is_focused // false)),
          last_focused_at: (.last_focused_at // 0),
          busy: ((.user_vars.opencode_busy // "0") | number),
          waiting: ((.user_vars.opencode_waiting // "0") | number),
          reason: (.user_vars.opencode_reason // "none"),
          instance: (.user_vars.opencode_instance // ""),
          generation: ((.user_vars.opencode_generation // "0") | number)
        }
      | .opencode_title = (.title | sub("^OC[[:space:]]*\\|[[:space:]]*"; ""))
      | .display_title = (
          if .session_name == "" then .opencode_title
          else "\(.session_name) | \(.opencode_title)"
          end
        )
      | .status = (if .waiting > 0 then "attention" elif .busy > 0 then "running" else "idle" end)
    ]
    | sort_by(
        if .waiting > 0 then 0 elif .busy > 0 then 1 else 2 end,
        -.last_focused_at
      )
  '
}

focus_window() {
  local window_id="$1"
  local socket=""
  local acknowledgement=""
  local session_name=""
  local window=""

  [[ "$window_id" =~ ^[0-9]+$ ]] || return 1
  window="$(opencode_windows | jq -c --argjson id "$window_id" '.[] | select(.id == $id)')"
  if [[ -z "$window" ]]; then
    printf 'OpenCode window %s is no longer available.\n' "$window_id" >&2
    return 1
  fi

  socket="$(kitty_socket)"
  acknowledgement="$(jq -r '"\(.instance):\(.generation)"' <<<"$window")"
  session_name="$(jq -r '.session_name' <<<"$window")"
  "$kitty_bin" @ --to "unix:${socket}" set-user-vars --match "id:${window_id}" \
    opencode_waiting=0 opencode_reason=none "opencode_ack=${acknowledgement}"
  /opt/homebrew/bin/sketchybar --trigger opencode_update >/dev/null 2>&1 || true
  if [[ -n "$session_name" ]]; then
    "$kitty_bin" @ --to "unix:${socket}" action goto_session "$session_name"
  fi
  "$kitty_bin" @ --to "unix:${socket}" focus-window --match "id:${window_id}"
  open -a kitty
}

menu_lines() {
  local home_display=""
  local status=""
  local reason=""
  local display_title=""
  local cwd=""
  local busy=""
  local id=""
  local color=""
  local marker=""
  local reset=$'\033[0m'
  local red=$'\033[31m'
  local blue=$'\033[34m'
  local grey=$'\033[90m'

  while IFS=$'\t' read -r id status reason busy display_title cwd; do
    [[ -n "$id" ]] || continue
    home_display="${cwd/#$HOME/~}"

    case "$status" in
    attention)
      color="$red"
      marker="[!]"
      ;;
    running)
      color="$blue"
      marker="[>]"
      reason="${busy} busy"
      ;;
    *)
      color="$grey"
      marker="[-]"
      reason="idle"
      ;;
    esac

    printf '%s\t%b%s%b %s  %s  %s\n' "$id" "$color" "$marker" "$reset" "$display_title" "$home_display" "$reason"
  done < <(
    opencode_windows | jq -r '.[] | [.id, .status, .reason, .busy, .display_title, .cwd] | @tsv'
  )
}

pick_window() {
  local lines=""
  local selection=""
  local fzf_rc=0
  local fzf_args=()

  require_cmd fzf
  if [[ -f "$fzf_colors_file" ]]; then
    # shellcheck disable=SC1090
    source "$fzf_colors_file"
  fi

  lines="$(menu_lines)"
  [[ -n "$lines" ]] || return 1

  fzf_args=(
    --ansi
    --height=100%
    --reverse
    --header="Attention first | Enter: switch | Esc: close"
    --prompt="OpenCode tabs > "
    --no-multi
    --with-nth=2..
    --no-clear
  )

  if [[ -n "${linkarzu_fzf_colors:-}" ]]; then
    fzf_args+=(--color="$linkarzu_fzf_colors")
  fi

  set +e
  selection="$(printf '%s\n' "$lines" | fzf "${fzf_args[@]}")"
  fzf_rc=$?
  set -e

  if [[ $fzf_rc -ne 0 ]]; then
    return "$fzf_rc"
  fi
  [[ -n "$selection" ]] || return 1
  printf '%s\n' "${selection%%$'\t'*}"
}

case "${1:-}" in
--json)
  opencode_windows
  ;;
--list)
  menu_lines
  ;;
--focus)
  [[ -n "${2:-}" ]] || exit 1
  focus_window "$2"
  ;;
--pick-id)
  pick_window
  ;;
*)
  window_id="$(pick_window || true)"
  if [[ -z "$window_id" ]]; then
    exit 0
  fi
  focus_window "$window_id"
  ;;
esac
