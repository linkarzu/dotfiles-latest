#!/usr/bin/env bash

set -euo pipefail

# Control the live fzf opened by the main tasks QAT (cmd + alt + F3).
#
# The QAT still displays an ordinary fzf interface. This helper talks to fzf's
# local Unix-socket API, allowing an AI to inspect unknown options and perform
# selections without screenshots, OCR, cursor-key timing, or source knowledge.
#
# Recommended AI loop:
#
#   fzf-ai.sh wait
#   fzf-ai.sh inspect
#   fzf-ai.sh choose 3
#   fzf-ai.sh inspect          # The next nested fzf, if there is one
#
# Multi-select menus:
#
#   fzf-ai.sh inspect
#   fzf-ai.sh mark 2 4
#   fzf-ai.sh inspect          # Verify FZF_SELECTED records
#   fzf-ai.sh accept
#
# `inspect` numbers the current ordered match list from 1. `choose` and `mark`
# use those displayed numbers, not an item's internal fzf index. The helper
# never executes arbitrary remote shell commands; the bridge uses fzf's safe
# `--listen` mode rather than `--listen-unsafe`.

socket_dir="${TMPDIR:-/tmp}"
socket="${FZF_AI_SOCKET:-${socket_dir%/}/linkarzu-system-task-fzf.sock}"

usage() {
  cat <<'EOF'
Usage: fzf-ai.sh [--socket PATH] COMMAND [ARGUMENTS]

Commands:
  wait [SECONDS]           Wait until an fzf menu is ready.
  inspect [LIMIT] [OFFSET] Print menu state and numbered options (default 1000).
  state [LIMIT] [OFFSET]   Print the raw fzf JSON state.
  choose INDEX             Move to one option and accept it.
  mark INDEX...            Select one or more options without accepting.
  unmark INDEX...          Deselect one or more options without accepting.
  accept                   Accept the current item or marked items.
  clear                    Clear fzf's current search query.
  cancel                   Abort the current fzf menu.
  help                     Show this help.

AI protocol:
  1. Run `wait`, then `inspect`; never assume the menu options.
  2. Use the 1-based FZF_OPTION number with `choose` for single selection.
  3. For multi-select, use `mark`, inspect again to verify FZF_SELECTED, then
     use `accept`.
  4. After choose/accept, inspect again. A nested fzf uses the same socket.
  5. `FZF_NEXT_READY` means another menu replaced the previous one.
     `FZF_FLOW_ENDED` means no next fzf appeared within the transition timeout.

Environment:
  FZF_AI_SOCKET overrides the default main-task QAT socket.
EOF
}

die() {
  printf 'fzf-ai: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is not installed or not in PATH"
}

validate_integer() {
  [[ "$1" =~ ^[0-9]+$ ]] || die "expected a positive integer, got: $1"
  [[ $1 -ge 1 ]] || die "expected a positive integer, got: $1"
}

socket_inode() {
  [[ -S "$socket" ]] || return 1
  stat -f '%i' "$socket" 2>/dev/null
}

get_state() {
  local limit="${1:-1000}"
  local offset="${2:-0}"

  curl --silent --show-error --fail \
    --unix-socket "$socket" \
    "http://localhost/?limit=${limit}&offset=${offset}"
}

socket_ready() {
  [[ -S "$socket" ]] || return 1
  get_state 1 0 >/dev/null 2>&1
}

wait_for_menu() {
  local timeout="${1:-10}"
  local deadline=0

  validate_integer "$timeout"
  deadline=$((SECONDS + timeout))
  while [[ $SECONDS -lt $deadline ]]; do
    if socket_ready; then
      printf 'FZF_READY socket=%s generation=%s\n' "$socket" "$(socket_inode)"
      return 0
    fi
    sleep 0.1
  done

  die "no active fzf menu appeared within ${timeout}s (socket: $socket)"
}

fzf_process_mode() {
  local pids=""
  local pid=""
  local command=""

  pids="$(lsof -t "$socket" 2>/dev/null || true)"
  pid="${pids%%$'\n'*}"
  if [[ -n "$pid" ]]; then
    command="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  fi

  if [[ "$command" == *" --multi"* || "$command" == *" -m "* ]]; then
    printf 'multi\n'
  else
    printf 'single\n'
  fi
}

inspect_menu() {
  local limit="${1:-1000}"
  local offset="${2:-0}"
  local state=""
  local mode=""
  local generation=""

  validate_integer "$limit"
  [[ "$offset" =~ ^[0-9]+$ ]] || die "offset must be zero or a positive integer"
  socket_ready || die "no active fzf menu (run 'fzf-ai.sh wait' after opening the QAT)"

  state="$(get_state "$limit" "$offset")"
  mode="$(fzf_process_mode)"
  generation="$(socket_inode)"

  jq -r \
    --arg mode "$mode" \
    --arg socket "$socket" \
    --arg generation "$generation" \
    --argjson offset "$offset" '
      "FZF_MENU mode=\($mode) query=\(.query | @json) total=\(.totalCount) matches=\(.matchCount) generation=\($generation)",
      "FZF_SOCKET \($socket)",
      (if .current == null then
        "FZF_CURRENT none"
      else
        "FZF_CURRENT \(.position + 1)\t\(.current.text)"
      end),
      (.matches | to_entries[] | "FZF_OPTION \($offset + .key + 1)\t\(.value.text)"),
      (.selected[]? as $selected |
        ([.matches | to_entries[] |
          select(.value.index == $selected.index) |
          ($offset + .key + 1)][0] // "outside-page") as $position |
        "FZF_SELECTED \($position)\t\($selected.text)")
    ' <<<"$state"
}

post_action() {
  local action="$1"

  socket_ready || die "no active fzf menu"
  curl --silent --show-error --fail \
    --unix-socket "$socket" \
    --request POST \
    --data-binary "$action" \
    http://localhost/ >/dev/null
}

validate_match_position() {
  local index="$1"
  local match_count=0

  validate_integer "$index"
  match_count="$(get_state 1 0 | jq -r '.matchCount')"
  [[ $index -le $match_count ]] || die "option $index is outside the current match list (1-${match_count})"
}

wait_for_transition() {
  local old_generation="$1"
  local timeout="${2:-3}"
  local deadline=$((SECONDS + timeout))
  local generation=""

  while [[ $SECONDS -lt $deadline ]]; do
    if socket_ready; then
      generation="$(socket_inode)"
      if [[ "$generation" != "$old_generation" ]]; then
        printf 'FZF_NEXT_READY socket=%s generation=%s\n' "$socket" "$generation"
        return 0
      fi
    fi
    sleep 0.1
  done

  printf 'FZF_FLOW_ENDED no next fzf menu appeared within %ss\n' "$timeout"
}

choose_option() {
  local index="$1"
  local generation=""

  validate_match_position "$index"
  generation="$(socket_inode)"
  post_action "pos(${index})+accept"
  printf 'FZF_CHOSEN %s\n' "$index"
  wait_for_transition "$generation"
}

change_marks() {
  local action_name="$1"
  local fzf_action="$2"
  local index=""
  local actions=""
  shift 2

  [[ $# -gt 0 ]] || die "$action_name requires at least one option number"
  [[ "$(fzf_process_mode)" == "multi" ]] || die "$action_name requires an fzf --multi menu"
  for index in "$@"; do
    validate_match_position "$index"
    if [[ -n "$actions" ]]; then
      actions+="+"
    fi
    actions+="pos(${index})+${fzf_action}"
  done

  post_action "$actions"
  printf 'FZF_%s' "$action_name"
  printf ' %s' "$@"
  printf '\n'
}

accept_selection() {
  local generation=""

  generation="$(socket_inode)"
  post_action accept
  printf 'FZF_ACCEPTED\n'
  wait_for_transition "$generation"
}

cancel_menu() {
  local generation=""

  generation="$(socket_inode)"
  post_action abort
  printf 'FZF_CANCELLED\n'
  wait_for_transition "$generation"
}

main() {
  local command=""
  local limit="1000"
  local offset="0"

  require_command curl
  require_command jq

  if [[ "${1:-}" == "--socket" ]]; then
    [[ -n "${2:-}" ]] || die "--socket requires a path"
    socket="$2"
    shift 2
  fi

  command="${1:-help}"
  [[ $# -eq 0 ]] || shift

  case "$command" in
  wait)
    wait_for_menu "${1:-10}"
    ;;
  inspect)
    limit="${1:-1000}"
    offset="${2:-0}"
    inspect_menu "$limit" "$offset"
    ;;
  state)
    limit="${1:-1000}"
    offset="${2:-0}"
    validate_integer "$limit"
    [[ "$offset" =~ ^[0-9]+$ ]] || die "offset must be zero or a positive integer"
    socket_ready || die "no active fzf menu"
    get_state "$limit" "$offset" | jq .
    ;;
  choose)
    [[ -n "${1:-}" ]] || die "choose requires an option number"
    choose_option "$1"
    ;;
  mark)
    change_marks MARKED select "$@"
    ;;
  unmark)
    change_marks UNMARKED deselect "$@"
    ;;
  accept)
    accept_selection
    ;;
  clear)
    post_action clear-query
    printf 'FZF_QUERY_CLEARED\n'
    ;;
  cancel)
    cancel_menu
    ;;
  help | -h | --help)
    usage
    ;;
  *)
    usage >&2
    die "unknown command: $command"
    ;;
  esac
}

main "$@"
