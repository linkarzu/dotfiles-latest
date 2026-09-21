#!/usr/bin/env bash

set -euo pipefail

# Control the live fzf opened by the main tasks QAT (cmd + alt + F3).
# The canonical launcher and lifecycle guide is the `CANONICAL AI ENTRY POINT`
# section in ~/github/dotfiles-latest/skhd/skhdrc.
#
# The QAT still displays an ordinary fzf interface. This helper talks to fzf's
# local Unix-socket API, allowing an AI to inspect unknown options and perform
# selections without screenshots, OCR, cursor-key timing, or source knowledge.
#
# Recommended fast loop:
#
#   fzf-ai.sh wait
#   fzf-ai.sh inspect
#   fzf-ai.sh pick "Option text"       # One call: inspect + unique match + accept
#   printf '%s' '[{"action":"pick","text":"Option text"}]' | fzf-ai.sh flow
#
# `pick` inspects the live menu and chooses a unique exact/prefix text match in
# a single call; on an ambiguous or missing match it prints the option list and
# exits non-zero. After choose/pick/accept, re-inspect only when it reports
# FZF_NEXT_READY; on FZF_FLOW_ENDED verify the terminal output or external
# action instead of selecting again.
#
# Multi-select menus:
#
#   fzf-ai.sh inspect
#   fzf-ai.sh mark 2 4
#   fzf-ai.sh inspect          # Verify FZF_SELECTED records
#   fzf-ai.sh accept
#
# `inspect` numbers the current ordered match list from 1. `choose`, `mark`,
# and `pick` use those displayed numbers, not an item's internal fzf index.
# The helper never executes arbitrary remote shell commands; the bridge uses
# fzf's safe `--listen` mode rather than `--listen-unsafe`.

socket_dir="${TMPDIR:-/tmp}"
socket="${FZF_AI_SOCKET:-${socket_dir%/}/linkarzu-system-task-fzf.sock}"
query_provenance_path="${FZF_AI_QUERY_PROVENANCE_PATH:-${socket}.ai/query}"
session_path="${FZF_AI_SESSION_PATH:-${socket}.ai/session}"

usage() {
  cat <<'EOF'
Usage: fzf-ai.sh [--socket PATH] COMMAND [ARGUMENTS]

Commands:
  wait [SECONDS]           Wait until an fzf menu is ready.
  inspect [LIMIT] [OFFSET] Print menu state and numbered options (default 1000).
  state [LIMIT] [OFFSET]   Print the raw fzf JSON state.
  choose [--wait N] INDEX  Move to one option and accept it.
  pick [--wait N] "TEXT"   Inspect, pick a unique exact/prefix text match, accept it.
  flow [FILE|-]            Run a validated JSON action sequence locally (default stdin).
  mark INDEX...            Select one or more options without accepting.
  unmark INDEX...          Deselect one or more options without accepting.
  accept [--wait N]        Accept the current item or marked items.
  cancel [--wait N]        Abort the current fzf menu.
  query TEXT               Replace fzf's current search query with TEXT.
  clear                    Clear fzf's current search query.
  help                     Show this help.

AI protocol:
  1. Run `wait`, then `inspect`; never assume the menu options.
  2. For single-selection, use `pick "TEXT"` (or the 1-based FZF_OPTION number
     with `choose`). On an ambiguous or missing pick match, the option list is
     printed and the command exits non-zero; fall back to a normal inspect.
  3. For multi-select, use `mark`, inspect again to verify FZF_SELECTED, then
     use `accept`.
  4. After choose/pick/accept, re-inspect only when it reports
     `FZF_NEXT_READY`. `FZF_FLOW_ENDED` means no next fzf appeared; verify the
     terminal output or external action instead of selecting again.
  5. For a text-entry menu, use `query`, inspect the exact query, then `accept`.
  6. A nested fzf uses the same socket and a new generation. Pass
     `--wait SECONDS` on choose/pick/accept/cancel for a panel that takes a few
     seconds to appear (e.g. the OBS Meeting Manager main menu).
  7. `query` records an authenticated hash of the exact AI-entered text and the
     current socket generation. The workflow consumes this record once.
  8. Acceptance alone and FZF_AI_SOCKET presence do not establish AI text origin.

Flow JSON:
  An array of pick or input actions. Each action validates the current live menu.
  `wait` is an optional hard timeout for a proven slow transition. It does not
  extend the 1s terminal grace. `expect` defaults to `next` and may be `handoff`
  or `ended` on the final action only.

  [{"action":"pick","text":"070-obsMeetingManager.sh"},
   {"action":"input","prompt":"Livestream title >","text":"My title"},
   {"action":"pick","text":"confirm","expect":"handoff"}]

Environment:
  FZF_AI_SOCKET overrides the default main-task QAT socket.
  FZF_AI_TRANSITION_GRACE overrides the default re-open wait (1) for a next fzf.
  FZF_AI_TRANSITION_TIMEOUT overrides the default transition ceiling (3).
  240-systemTask.sh creates private session/query files under SOCKET.ai/.
  FZF_AI_SESSION_PATH and FZF_AI_QUERY_PROVENANCE_PATH override helper sidecars.
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

write_ai_query_provenance() {
  local generation="$1"
  local query="$2"
  local query_sha256=""
  local session_token=""
  local temporary=""

  [[ -f "$session_path" && ! -L "$session_path" ]] || die "no active AI provenance session"
  session_token="$(<"$session_path")"
  [[ "$session_token" =~ ^[0-9a-f]{64}$ ]] || die "invalid AI provenance session"
  query_sha256="$(printf '%s' "$query" | shasum -a 256)"
  query_sha256="${query_sha256%% *}"
  [[ "$query_sha256" =~ ^[0-9a-f]{64}$ ]] || die "could not hash AI query"
  temporary="${query_provenance_path}.$$.$RANDOM.tmp"
  umask 077
  if ! jq -cn \
    --arg token "$session_token" \
    --arg generation "$generation" \
    --arg query_sha256 "$query_sha256" \
    '{kind:"fzf-ai-query",version:1,sessionToken:$token,generation:$generation,querySha256:$query_sha256}' \
    >"$temporary" || ! chmod 600 "$temporary" || ! mv -f "$temporary" "$query_provenance_path"; then
    rm -f "$temporary"
    die "could not publish AI query provenance"
  fi
}

remove_ai_query_provenance() {
  rm -f "$query_provenance_path"
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
    sleep 0.05
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

fzf_process_pid() {
  local pids=""

  pids="$(lsof -t "$socket" 2>/dev/null || true)"
  [[ -n "$pids" ]] || return 1
  printf '%s\n' "${pids%%$'\n'*}"
}

process_parent_pid() {
  local pid="$1"
  local parent=""

  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  parent="$(ps -p "$pid" -o ppid= 2>/dev/null || true)"
  parent="${parent#"${parent%%[![:space:]]*}"}"
  parent="${parent%"${parent##*[![:space:]]}"}"
  [[ "$parent" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$parent"
}

human_handoff_pid() {
  local parent_pid="$1"
  local pids=""

  [[ "$parent_pid" =~ ^[0-9]+$ ]] || return 1
  pids="$(pgrep -P "$parent_pid" -x fzf 2>/dev/null || true)"
  [[ -n "$pids" ]] || return 1
  printf '%s\n' "${pids%%$'\n'*}"
}

process_alive() {
  local pid="$1"

  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

current_fzf_prompt() {
  local pid=""
  local command=""
  local prompt=""
  local delimiter=""

  pid="$(fzf_process_pid)" || die "no active fzf menu"
  command="$(ps -ww -p "$pid" -o command= 2>/dev/null)" \
    || die "could not inspect the active fzf prompt"
  [[ "$command" == *"--prompt="* ]] || die "active fzf has no prompt metadata"
  prompt="${command#*--prompt=}"
  for delimiter in " --header=" " --color=" " --bind="; do
    if [[ "$prompt" == *"$delimiter"* ]]; then
      prompt="${prompt%%"$delimiter"*}"
    fi
  done
  prompt="${prompt#"${prompt%%[![:space:]]*}"}"
  prompt="${prompt%"${prompt##*[![:space:]]}"}"
  printf '%s\n' "$prompt"
}

inspect_menu() {
  local limit="${1:-1000}"
  local offset="${2:-0}"
  local state=""
  local mode=""
  local generation=""

  validate_integer "$limit"
  [[ "$offset" =~ ^[0-9]+$ ]] || die "offset must be zero or a positive integer"

  state="$(get_state "$limit" "$offset" 2>/dev/null)" \
    || die "no active fzf menu (run 'fzf-ai.sh wait' after opening the QAT)"
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

  # No readiness GET: a dead menu is reported by the same stat and error text,
  # while a live menu that rejects the action still surfaces curl's failure.
  [[ -S "$socket" ]] || die "no active fzf menu"
  curl --silent --show-error --fail \
    --unix-socket "$socket" \
    --request POST \
    --data-binary "$action" \
    http://localhost/ >/dev/null
}

change_query() {
  local query="$1"
  local generation=""

  [[ "$query" != *$'\n'* && "$query" != *$'\r'* ]] || die "query must be a single line"
  generation="$(socket_inode)" || die "no active fzf menu"
  # Publish before POST: acceptance can race the response, or the response can
  # be lost after mutation. Keep the proof on uncertainty; only OBS consumes it.
  write_ai_query_provenance "$generation" "$query"
  # fzf's colon form consumes the remaining payload as one argument, avoiding
  # action parsing for parentheses, backslashes, and strings such as +accept.
  post_action "change-query:${query}" || die "query change could not be confirmed; provenance retained"
  [[ "$(socket_inode)" == "$generation" ]] || die "fzf menu changed while setting query"
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
  local window="${FZF_AI_TRANSITION_GRACE:-1}"
  local old_parent_pid="${3:-}"
  local ceiling="${2:-${FZF_AI_TRANSITION_TIMEOUT:-3}}"
  local deadline=0
  local end_window=0
  local generation=""
  local gone=0
  local handoff_pid=""
  local handoff_candidate=""
  local handoff_polls=0

  validate_integer "$window"
  validate_integer "$ceiling"
  # --wait N raises only the hard ceiling. A dead workflow still uses the short
  # terminal grace, while a live parent may keep preparing a slow successor.
  if [[ "$window" -gt "$ceiling" ]]; then
    ceiling="$window"
  fi
  deadline=$((SECONDS + ceiling))
  while [[ $SECONDS -lt $deadline ]]; do
    if socket_ready; then
      generation="$(socket_inode)"
      if [[ -n "$generation" && "$generation" != "$old_generation" ]]; then
        printf 'FZF_NEXT_READY socket=%s generation=%s\n' "$socket" "$generation"
        return 0
      fi
      # The previous fzf is still alive on the old generation: keep polling.
      gone=0
      end_window=0
      handoff_candidate=""
      handoff_polls=0
    elif ! lsof -t "$socket" >/dev/null 2>&1; then
      handoff_pid="$(human_handoff_pid "$old_parent_pid" || true)"
      if [[ -n "$handoff_pid" ]]; then
        if [[ "$handoff_pid" == "$handoff_candidate" ]]; then
          handoff_polls=$((handoff_polls + 1))
        else
          handoff_candidate="$handoff_pid"
          handoff_polls=1
        fi
        # Give a new socket-visible fzf time to bind before classifying it as
        # the deliberate human-only successor.
        if [[ $handoff_polls -ge 4 ]]; then
          printf 'FZF_HUMAN_HANDOFF pid=%s\n' "$handoff_pid"
          return 0
        fi
      else
        handoff_candidate=""
        handoff_polls=0
      fi
      if process_alive "$old_parent_pid"; then
        gone=0
        end_window=0
      else
        # The workflow has exited. Bound only the quiet re-open grace, even
        # when this action had a larger timeout for a known slow successor.
        if [[ "$gone" == "0" ]]; then
          gone=1
          end_window=$((SECONDS + window))
        fi
      fi
    fi
    if [[ "$gone" == "1" && $SECONDS -ge $end_window ]]; then
      printf 'FZF_FLOW_ENDED no next fzf menu appeared within %ss\n' "$window"
      return 0
    fi
    sleep 0.05
  done

  printf 'FZF_FLOW_ENDED no next fzf menu appeared within %ss\n' "$ceiling"
}

choose_option() {
  local index="$1"
  local window="${2:-}"
  local generation=""
  local owner_pid=""
  local parent_pid=""

  validate_match_position "$index"
  generation="$(socket_inode)"
  owner_pid="$(fzf_process_pid || true)"
  parent_pid="$(process_parent_pid "$owner_pid" || true)"
  post_action "pos(${index})+accept"
  printf 'FZF_CHOSEN %s\n' "$index"
  wait_for_transition "$generation" "$window" "$parent_pid"
}

pick_option() {
  local text="${1:-}"
  local window="${2:-}"
  local state=""
  local generation=""
  local index=""
  local owner_pid=""
  local parent_pid=""

  [[ -n "$text" ]] || die "pick requires a text match"
  [[ "$(fzf_process_mode)" == "single" ]] || die "pick requires a single-select fzf menu"
  state="$(get_state 1000 0 2>/dev/null)" \
    || die "no active fzf menu (run 'fzf-ai.sh wait' after opening the QAT)"
  generation="$(socket_inode)"
  owner_pid="$(fzf_process_pid || true)"
  parent_pid="$(process_parent_pid "$owner_pid" || true)"

  index="$(printf '%s' "$state" | jq -r \
    --arg t "$text" '
      ([.matches | to_entries[] |
        select((.value.text | ascii_downcase) == ($t | ascii_downcase))]) as $exact
      | if ($exact | length) == 1 then
          $exact[0].key + 1
        elif ($exact | length) > 1 then
          "NONE"
        else
          ([.matches | to_entries[] |
            select((.value.text | ascii_downcase) | startswith($t | ascii_downcase))]) as $pre
          | if ($pre | length) == 1 then $pre[0].key + 1 else "NONE" end
        end')"

  if [[ -z "$index" || "$index" == "NONE" ]]; then
    inspect_menu
    die "no unique pick match for text: $text"
  fi
  [[ "$index" =~ ^[0-9]+$ ]] || die "pick could not resolve the match for: $text"
  validate_match_position "$index"
  post_action "pos(${index})+accept"
  printf 'FZF_PICKED %s\t%s\n' "$index" \
    "$(printf '%s' "$state" | jq -r --argjson i $((index - 1)) '.matches[$i].text')"
  wait_for_transition "$generation" "$window" "$parent_pid"
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
  local window="${1:-}"
  local generation=""
  local owner_pid=""
  local parent_pid=""

  generation="$(socket_inode)"
  owner_pid="$(fzf_process_pid || true)"
  parent_pid="$(process_parent_pid "$owner_pid" || true)"
  post_action accept
  printf 'FZF_ACCEPTED\n'
  wait_for_transition "$generation" "$window" "$parent_pid"
}

cancel_menu() {
  local window="${1:-}"
  local generation=""
  local owner_pid=""
  local parent_pid=""

  generation="$(socket_inode)"
  owner_pid="$(fzf_process_pid || true)"
  parent_pid="$(process_parent_pid "$owner_pid" || true)"
  post_action abort
  printf 'FZF_CANCELLED\n'
  wait_for_transition "$generation" "$window" "$parent_pid"
}

flow_transition_kind() {
  local output="$1"
  local last_line="${output##*$'\n'}"

  case "$last_line" in
  FZF_NEXT_READY*) printf 'next\n' ;;
  FZF_HUMAN_HANDOFF*) printf 'handoff\n' ;;
  FZF_FLOW_ENDED*) printf 'ended\n' ;;
  *) die "flow action returned no transition result" ;;
  esac
}

run_flow_json() {
  local payload="$1"
  local count=0
  local index=0
  local step=""
  local action=""
  local text=""
  local prompt=""
  local observed_prompt=""
  local wait_seconds=""
  local expected=""
  local actual=""
  local output=""

  jq -e '
    . as $steps |
    type == "array" and length > 0 and length <= 50 and
    all(to_entries[];
      . as $entry | .value as $step |
      ($step | type == "object") and
      (($step | keys_unsorted) - ["action", "text", "prompt", "wait", "expect"] | length == 0) and
      ($step.action == "pick" or $step.action == "input") and
      ($step.text | type == "string") and
      (($step | has("wait") | not) or
       ($step.wait | type == "number" and floor == . and . >= 1)) and
      (($step.expect // "next") | IN("next", "handoff", "ended")) and
      (if $step.action == "input" then ($step.prompt | type == "string" and length > 0)
       else ($step.text | length > 0 and ($step | has("prompt") | not)) end) and
      (if ($step.expect // "next") == "next" then true
       else $entry.key == (($steps | length) - 1) end)
    )' <<<"$payload" >/dev/null || die "flow requires a valid JSON action array"

  count="$(jq -r 'length' <<<"$payload")"
  wait_for_menu 10
  for ((index = 0; index < count; index++)); do
    step="$(jq -c ".[$index]" <<<"$payload")"
    action="$(jq -r '.action' <<<"$step")"
    text="$(jq -r '.text' <<<"$step")"
    wait_seconds="$(jq -r '.wait // empty' <<<"$step")"
    expected="$(jq -r '.expect // "next"' <<<"$step")"

    if [[ "$action" == "pick" ]]; then
      output="$(pick_option "$text" "$wait_seconds")" || return 1
    else
      prompt="$(jq -r '.prompt' <<<"$step")"
      observed_prompt="$(current_fzf_prompt)"
      [[ "$observed_prompt" == "$prompt" ]] \
        || die "flow step $((index + 1)) expected prompt '$prompt', got '$observed_prompt'"
      change_query "$text"
      printf 'FZF_QUERY_SET\n'
      get_state 1 0 | jq -e --arg text "$text" '.query == $text' >/dev/null \
        || die "flow step $((index + 1)) could not verify the exact query"
      output="$(accept_selection "$wait_seconds")" || return 1
    fi

    printf '%s\n' "$output"
    actual="$(flow_transition_kind "$output")"
    [[ "$actual" == "$expected" ]] \
      || die "flow step $((index + 1)) expected $expected, got $actual"
    printf 'FZF_FLOW_STEP %s/%s action=%s result=%s\n' \
      "$((index + 1))" "$count" "$action" "$actual"
  done
  printf 'FZF_FLOW_COMPLETE steps=%s result=%s\n' "$count" "$actual"
}

main() {
  local command=""
  local limit="1000"
  local offset="0"

  require_command curl
  require_command jq
  require_command lsof
  require_command pgrep
  require_command ps
  require_command shasum

  if [[ "${1:-}" == "--socket" ]]; then
    [[ -n "${2:-}" ]] || die "--socket requires a path"
    socket="$2"
    query_provenance_path="${FZF_AI_QUERY_PROVENANCE_PATH:-${socket}.ai/query}"
    session_path="${FZF_AI_SESSION_PATH:-${socket}.ai/session}"
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
    if [[ "$1" == "--wait" ]]; then
      [[ -n "${2:-}" ]] || die "--wait requires seconds"
      validate_integer "$2"
      [[ -n "${3:-}" ]] || die "choose requires an option number"
      choose_option "$3" "$2"
    else
      choose_option "$1"
    fi
    ;;
  pick)
    if [[ "${1:-}" == "--wait" ]]; then
      [[ -n "${2:-}" ]] || die "--wait requires seconds"
      validate_integer "$2"
      [[ -n "${3:-}" ]] || die "pick requires a text match"
      pick_option "$3" "$2"
    else
      pick_option "${1:-}"
    fi
    ;;
  flow)
    [[ $# -le 1 ]] || die "flow accepts at most one JSON file path"
    if [[ -n "${1:-}" && "$1" != "-" ]]; then
      [[ -f "$1" && ! -L "$1" ]] || die "flow file must be a regular non-symlink file"
      run_flow_json "$(<"$1")"
    else
      run_flow_json "$(</dev/stdin)"
    fi
    ;;
  mark)
    change_marks MARKED select "$@"
    ;;
  unmark)
    change_marks UNMARKED deselect "$@"
    ;;
  accept)
    if [[ "${1:-}" == "--wait" ]]; then
      [[ -n "${2:-}" ]] || die "--wait requires seconds"
      validate_integer "$2"
      accept_selection "$2"
    else
      accept_selection
    fi
    ;;
  query)
    [[ $# -eq 1 ]] || die "query requires exactly one text argument"
    change_query "$1"
    printf 'FZF_QUERY_SET\n'
    ;;
  clear)
    change_query ""
    printf 'FZF_QUERY_CLEARED\n'
    ;;
  cancel)
    if [[ "${1:-}" == "--wait" ]]; then
      [[ -n "${2:-}" ]] || die "--wait requires seconds"
      validate_integer "$2"
      cancel_menu "$2"
    else
      cancel_menu
    fi
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

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
