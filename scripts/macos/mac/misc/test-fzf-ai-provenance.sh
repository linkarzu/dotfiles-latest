#!/usr/bin/env bash

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

: "${OBS_MEETING_MANAGER_ROOT:?Set OBS_MEETING_MANAGER_ROOT to the OBS source checkout for the writer/consumer check}"
root="$(mktemp -d "${TMPDIR:-/tmp}/fzf-ai-provenance-test.XXXXXX")"
trap 'rm -rf "$root"' EXIT
export HOME="$root/home" TMPDIR="$root"
export DOTFILES_DIR="$root/runtime root"
export OBS_MEETING_MANAGER_DATA_DIR="$HOME/state"
export OBS_MEETING_MANAGER_LIVESTREAM_ROOT="$HOME/livestream"
export PROVENANCE_HELPER="$(dirname "$0")/fzf-ai.sh"
mkdir -p "$HOME" "$DOTFILES_DIR/scripts/macos/mac"
touch "$DOTFILES_DIR/scripts/macos/mac/synthetic.sh"
unset FZF_AI_SOCKET FZF_AI_SESSION_PATH FZF_AI_QUERY_PROVENANCE_PATH

# Replace only the UI process. The current launcher initializes the real session
# and the real controller writes provenance, without a QAT, socket, or server.
fzf() (
  set -euo pipefail
  [[ "$FZF_AI_SOCKET" == "$EXPECTED_SOCKET" ]]
  [[ "$FZF_AI_SESSION_PATH" == "${FZF_AI_SOCKET}.ai/session" ]]
  [[ "$FZF_AI_QUERY_PROVENANCE_PATH" == "${FZF_AI_SOCKET}.ai/query" ]]
  [[ "$(stat -f '%Lp' "${FZF_AI_SOCKET}.ai")" == "700" ]]
  [[ "$(stat -f '%Lp' "$FZF_AI_SESSION_PATH")" == "600" ]]
  printf -v listen '%q' "--listen=$FZF_AI_SOCKET"
  [[ "$FZF_DEFAULT_OPTS" == *"$listen"* ]]
  token="$(<"$FZF_AI_SESSION_PATH")"
  [[ "$token" =~ ^[0-9a-f]{64}$ ]]
  # A separately invoked controller derives the same paths without inheriting
  # the launcher's provenance variables.
  unset FZF_AI_SESSION_PATH FZF_AI_QUERY_PROVENANCE_PATH
  source "$PROVENANCE_HELPER"
  [[ "$socket" == "$EXPECTED_SOCKET" ]]
  export FZF_AI_SESSION_PATH="$session_path" FZF_AI_QUERY_PROVENANCE_PATH="$query_provenance_path"
  socket_inode() { printf '12345\n'; }
  post_action() { [[ "$1" == 'change-query:PrivateGuestName' || "$1" == accept ]]; }
  wait_for_transition() { :; }
  change_query 'PrivateGuestName'
  [[ "$(stat -f '%Lp' "$FZF_AI_QUERY_PROVENANCE_PATH")" == "600" ]]
  query_sha256="$(printf '%s' 'PrivateGuestName' | shasum -a 256)"
  query_sha256="${query_sha256%% *}"
  jq -e --arg token "$token" --arg digest "$query_sha256" \
    '.kind == "fzf-ai-query" and .version == 1 and .sessionToken == $token and
     .generation == "12345" and .querySha256 == $digest' \
    "$FZF_AI_QUERY_PROVENANCE_PATH" >/dev/null
  before="$(<"$FZF_AI_QUERY_PROVENANCE_PATH")"
  [[ "$before" != *'PrivateGuestName'* ]]
  accept_selection >/dev/null
  [[ "$(<"$FZF_AI_QUERY_PROVENANCE_PATH")" == "$before" ]]
  python3 - <<'PY'
import io
import json
import os
from pathlib import Path
import subprocess
import sys
from unittest.mock import patch

sys.path.insert(0, str(Path(os.environ["OBS_MEETING_MANAGER_ROOT"]) / "scripts/macos/mac/obs/meeting/py"))
import meeting_manager as manager

path = Path(os.environ["FZF_AI_QUERY_PROVENANCE_PATH"])
session = Path(os.environ["FZF_AI_SESSION_PATH"])
receipt, token = path.read_bytes(), session.read_bytes()
payload = json.loads(receipt)
assert payload["sessionToken"].encode() == token.strip()
assert manager.consume_fzf_ai_query_provenance("PrivateGuestName", "12345") == "ai"
assert not path.exists()
assert manager.consume_fzf_ai_query_provenance("PrivateGuestName", "12345") == "human"

# Only the fzf process result and external provider boundary are substituted.
# The prompt, consumer, resolver and fallback all execute their production code.
with patch.object(subprocess, "run", side_effect=AssertionError("external process")), \
     patch.object(subprocess, "Popen", side_effect=AssertionError("external process")), \
     patch.object(manager, "urlopen", side_effect=AssertionError("network")), \
     patch.object(manager, "fzf_colors", return_value=""), \
     patch("sys.stdout", new_callable=io.StringIO):
    for case in ("ai", "malformed", "wrong-token", "stale", "no-generation", "missing-session", "bad-session", "unsafe-session", "unsafe-receipt", "missing-config"):
        path.write_bytes(receipt)
        path.chmod(0o600)
        session.write_bytes(token)
        session.chmod(0o600)
        generation = "12345"
        if case == "malformed":
            path.write_text("{not-json")
        elif case == "wrong-token":
            path.write_text(json.dumps({**payload, "sessionToken": "0" * 64}))
        elif case == "stale":
            generation = "67890"
        elif case == "no-generation":
            generation = None
        elif case == "missing-session":
            session.unlink()
        elif case == "bad-session":
            session.write_text("invalid-token\n")
        elif case == "unsafe-session":
            session.chmod(0o644)
        elif case == "unsafe-receipt":
            path.chmod(0o644)
        with patch.dict(os.environ, {"FZF_AI_SESSION_PATH": ""} if case == "missing-config" else {}), \
             patch.object(manager, "run_fzf_text_process", return_value=(subprocess.CompletedProcess([], 0, stdout="PrivateGuestName\n"), generation)), \
             patch.object(manager, "fetch_youtube_profile", side_effect=AssertionError("unknown AI provider lookup")), \
             patch.object(manager, "write_json", side_effect=AssertionError("unknown AI state write")):
            assert manager.prompt_new_youtube_guest({"guests": []}, [], {}) is None, case

    # A human edits the AI query, or types in an authenticated session without a
    # query receipt. Accepting either does not invent AI provenance.
    session.write_bytes(token)
    session.chmod(0o600)
    for human_edit in (True, False):
        path.unlink(missing_ok=True)
        if human_edit:
            path.write_bytes(receipt)
            path.chmod(0o600)
        with patch.object(manager, "run_fzf_text_process", return_value=(subprocess.CompletedProcess([], 0, stdout="humanhandle\n"), "12345")), \
             patch.object(manager, "fetch_youtube_profile", return_value={"channelId": "UCHUMAN", "name": "Human Guest", "handle": "@humanhandle"}) as fetch:
            candidate = manager.prompt_new_youtube_guest({"guests": []}, [], {})
        assert candidate["resolutionReceipt"]["matchType"] == "bareHandleFallback"
        fetch.assert_called_once_with("https://www.youtube.com/@humanhandle")
        assert not path.exists()
PY
  assert_bare_query_blocked() {
    python3 - "$1" "$2" "${3:-ai}" <<'PY'
import io
import os
from pathlib import Path
import subprocess
import sys
from unittest.mock import patch

sys.path.insert(0, str(Path(os.environ["OBS_MEETING_MANAGER_ROOT"]) / "scripts/macos/mac/obs/meeting/py"))
import meeting_manager as manager

query, generation, expected_origin = sys.argv[1:]
real_consume = manager.consume_fzf_ai_query_provenance
def checked_consume(value, observed_generation):
    origin = real_consume(value, observed_generation)
    assert origin == expected_origin, (origin, expected_origin)
    return origin

with patch.object(subprocess, "run", side_effect=AssertionError("external process")), \
     patch.object(subprocess, "Popen", side_effect=AssertionError("external process")), \
     patch.object(manager, "urlopen", side_effect=AssertionError("network")), \
     patch.object(manager, "fzf_colors", return_value=""), \
     patch.object(manager, "run_fzf_text_process", return_value=(subprocess.CompletedProcess([], 0, stdout=query + "\n"), generation)), \
     patch.object(manager, "consume_fzf_ai_query_provenance", side_effect=checked_consume) as consume, \
     patch.object(manager, "fetch_youtube_profile", side_effect=AssertionError("unknown AI provider lookup")), \
     patch.object(manager, "write_json", side_effect=AssertionError("unknown AI state write")), \
     patch("sys.stdout", new_callable=io.StringIO):
    assert manager.prompt_new_youtube_guest({"guests": []}, [], {}) is None
    consume.assert_called_once_with(query, generation)
assert not Path(os.environ["FZF_AI_QUERY_PROVENANCE_PATH"]).exists()
PY
  }

  # Acceptance can consume the query while POST is still in flight. The writer
  # must already have published proof, and must not recreate it after consumption.
  (
    post_action() {
      [[ "$1" == 'change-query:DuringPostGuest' ]]
      assert_bare_query_blocked 'DuringPostGuest' 12345
    }
    change_query 'DuringPostGuest'
  )
  [[ ! -e "$FZF_AI_QUERY_PROVENANCE_PATH" ]]

  # The UI applied the action, but curl lost the response. Its retained proof
  # must still block the bare AI query when OBS consumes it after the failure.
  if (
    post_action() {
      printf '%s' "${1#change-query:}" >"$HOME/applied-query"
      return 52
    }
    change_query 'LostResponseGuest'
  ) 2>/dev/null; then
    exit 1
  fi
  [[ "$(<"$HOME/applied-query")" == 'LostResponseGuest' ]]
  assert_bare_query_blocked "$(<"$HOME/applied-query")" 12345

  # Fail actual writer commands, not the writer function. The old proof must
  # remain byte-for-byte intact and usable, with no POST before new proof exists.
  for failed_command in jq chmod mv; do
    write_ai_query_provenance 12345 'PreviousAiGuest'
    before="$(shasum -a 256 "$FZF_AI_QUERY_PROVENANCE_PATH")"
    if (
      post_action() { touch "$HOME/unproven-post"; }
      case "$failed_command" in
        jq) jq() { printf '{"incomplete":'; return 1; } ;;
        chmod) chmod() { return 1; } ;;
        mv) mv() { return 1; } ;;
      esac
      change_query 'UnprovenNewGuest'
    ) 2>/dev/null; then
      exit 1
    fi
    [[ ! -e "$HOME/unproven-post" ]]
    [[ "$(shasum -a 256 "$FZF_AI_QUERY_PROVENANCE_PATH")" == "$before" ]]
    assert_bare_query_blocked 'PreviousAiGuest' 12345
  done

  if (
    test_menu_generation=12345
    socket_inode() { printf '%s\n' "$test_menu_generation"; }
    post_action() { test_menu_generation=67890; }
    change_query 'PrivateGuestName'
  ) 2>/dev/null; then
    exit 1
  fi
  assert_bare_query_blocked 'PrivateGuestName' 67890 untrusted
  remove_ai_query_provenance
  accept_selection >/dev/null
  [[ ! -e "$FZF_AI_QUERY_PROVENANCE_PATH" ]]

  get_state() {
    printf '%s' '{"query":"","totalCount":1,"matchCount":1,"current":{"position":0,"text":"confirm\tDT -> @distrotube"},"matches":[{"index":0,"text":"confirm\tDT -> @distrotube"}],"selected":[]}'
  }
  socket_ready() { return 0; }
  fzf_process_mode() { printf 'single\n'; }
  [[ "$(inspect_menu)" == *$'FZF_OPTION 1\tconfirm\tDT -> @distrotube'* ]]

  # A true leaf finishes on the 1s re-open grace. An explicit wait raises both
  # the grace and transition ceiling for a slow nested panel.
  (
    source "$PROVENANCE_HELPER"
    socket_ready() { return 1; }
    lsof() { return 1; }
    [[ "$(wait_for_transition 111)" == "FZF_FLOW_ENDED no next fzf menu appeared within 1s" ]]
    [[ "$(wait_for_transition 111 6)" == "FZF_FLOW_ENDED no next fzf menu appeared within 6s" ]]
  )

  # Every accepting action passes its optional --wait window to the transition.
  (
    wait_for_transition() { printf 'WAIT %s\n' "${2:-default}"; }
    socket_inode() { printf '333\n'; }
    post_action() { printf 'ACTION %s\n' "$1"; }
    get_state() {
      printf '%s' '{"query":"","totalCount":2,"matchCount":2,"current":{"position":0,"text":"Run QAT"},"matches":[{"index":0,"text":"Run QAT"},{"index":1,"text":"Prepare livestream media"}],"selected":[]}'
    }
    fzf_process_mode() { printf 'single\n'; }
    [[ "$(choose_option 2 6)" == *$'ACTION pos(2)+accept\nFZF_CHOSEN 2\nWAIT 6'* ]]
    [[ "$(pick_option 'prepare livestream' 6)" == *$'ACTION pos(2)+accept\nFZF_PICKED 2\tPrepare livestream media\nWAIT 6'* ]]
    [[ "$(accept_selection 6)" == *$'ACTION accept\nFZF_ACCEPTED\nWAIT 6'* ]]
    [[ "$(cancel_menu 6)" == *$'ACTION abort\nFZF_CANCELLED\nWAIT 6'* ]]
  )

  # Exact and unique-prefix text matching is case-insensitive.
  (
    pick_fixture='{"query":"","totalCount":2,"matchCount":2,"current":{"position":0,"text":"Run QAT"},"matches":[{"index":0,"text":"Run QAT"},{"index":1,"text":"Prepare livestream media"}],"selected":[]}'
    get_state() { printf '%s' "$pick_fixture"; }
    fzf_process_mode() { printf 'single\n'; }
    socket_inode() { printf '444\n'; }
    post_action() { printf 'ACTION %s\n' "$1"; }
    wait_for_transition() { :; }
    [[ "$(pick_option 'rUn qat')" == $'ACTION pos(1)+accept\nFZF_PICKED 1\tRun QAT' ]]
    [[ "$(pick_option 'prepare livestream')" == $'ACTION pos(2)+accept\nFZF_PICKED 2\tPrepare livestream media' ]]
  )

  # Ambiguous prefixes, duplicate exact labels, and missing matches list the
  # current options and fail without taking action.
  for text in prepare duplicate zzz; do
    (
      pick_fixture='{"query":"","totalCount":5,"matchCount":5,"current":{"position":0,"text":"Run QAT"},"matches":[{"index":0,"text":"Run QAT"},{"index":1,"text":"Prepare livestream media"},{"index":2,"text":"Prepare recordings"},{"index":3,"text":"Duplicate"},{"index":4,"text":"duplicate"}],"selected":[]}'
      get_state() { printf '%s' "$pick_fixture"; }
      fzf_process_mode() { printf 'single\n'; }
      socket_inode() { printf '444\n'; }
      post_action() { touch "$HOME/unexpected-pick-action"; }
      if output="$(pick_option "$text" 2>/dev/null)"; then
        echo "non-unique pick unexpectedly succeeded: $text" >&2
        exit 1
      fi
      [[ "$output" == *$'FZF_OPTION 1\tRun QAT'* ]]
      [[ ! -e "$HOME/unexpected-pick-action" ]]
    )
  done

  # A multi-select menu is refused before state inspection or action.
  (
    fzf_process_mode() { printf 'multi\n'; }
    get_state() { touch "$HOME/unexpected-pick-state"; }
    post_action() { touch "$HOME/unexpected-pick-action"; }
    if ( pick_option 'Run QAT' ) 2>/dev/null; then
      echo "multi-menu pick unexpectedly succeeded" >&2
      exit 1
    fi
    [[ ! -e "$HOME/unexpected-pick-state" && ! -e "$HOME/unexpected-pick-action" ]]
  )

  # A stable non-socket fzf child is an intentional human handoff, while a
  # socket-visible successor still wins during the short classification grace.
  (
    source "$PROVENANCE_HELPER"
    socket_ready() { return 1; }
    lsof() { return 1; }
    human_handoff_pid() { printf '999\n'; }
    sleep() { :; }
    [[ "$(wait_for_transition 111 6 222)" == "FZF_HUMAN_HANDOFF pid=999" ]]
  )
  (
    source "$PROVENANCE_HELPER"
    ready_polls=0
    socket_ready() {
      ready_polls=$((ready_polls + 1))
      [[ $ready_polls -ge 3 ]]
    }
    socket_inode() { printf '222\n'; }
    lsof() { return 1; }
    human_handoff_pid() { printf '999\n'; }
    sleep() { :; }
    [[ "$(wait_for_transition 111 6 222)" == *'FZF_NEXT_READY'* ]]
  )

  # Prompt extraction exposes only the live fzf prompt needed to validate a
  # text-input step, not its potentially private header.
  (
    fzf_process_pid() { printf '42\n'; }
    ps() {
      printf '%s\n' 'fzf --reverse --prompt=Livestream title >  --header=Private header --color=x'
    }
    [[ "$(current_fzf_prompt)" == 'Livestream title >' ]]
  )

  # A complete flow performs validated live picks and text entry in one local
  # process and accepts a declared human-only terminal boundary.
  (
    flow_query=""
    wait_for_menu() { printf 'FZF_READY fixture\n'; }
    pick_option() {
      if [[ "$1" == "confirm" ]]; then
        printf 'FZF_PICKED 1\tconfirm\nFZF_HUMAN_HANDOFF pid=999\n'
      else
        printf 'FZF_PICKED 1\t%s\nFZF_NEXT_READY fixture\n' "$1"
      fi
    }
    current_fzf_prompt() { printf 'Livestream title >\n'; }
    change_query() { flow_query="$1"; }
    get_state() { jq -cn --arg query "$flow_query" '{query:$query}'; }
    accept_selection() { printf 'FZF_ACCEPTED\nFZF_NEXT_READY fixture\n'; }
    flow_output="$(run_flow_json '[
      {"action":"pick","text":"schedule"},
      {"action":"input","prompt":"Livestream title >","text":"Fast flow"},
      {"action":"pick","text":"confirm","expect":"handoff"}
    ]')"
    [[ "$flow_output" == *'FZF_FLOW_STEP 2/3 action=input result=next'* ]]
    [[ "$flow_output" == *'FZF_FLOW_COMPLETE steps=3 result=handoff'* ]]
  )

  # Prompt mismatches fail before mutating the live query.
  (
    wait_for_menu() { :; }
    current_fzf_prompt() { printf 'Unexpected prompt >\n'; }
    change_query() { touch "$HOME/unexpected-flow-query"; }
    if (run_flow_json '[{"action":"input","prompt":"Livestream title >","text":"Nope"}]') \
      >/dev/null 2>&1; then
      echo "mismatched flow prompt unexpectedly succeeded" >&2
      exit 1
    fi
    [[ ! -e "$HOME/unexpected-flow-query" ]]
  )

  printf 'passed\n' >"$HOME/checked"
)
export -f fzf

for mode in normal override; do
  export EXPECTED_SOCKET="$TMPDIR/linkarzu-system-task-fzf.sock"
  if [[ "$mode" == override ]]; then
    export EXPECTED_SOCKET="$root/selected runtime.sock"
    export FZF_AI_SOCKET="$EXPECTED_SOCKET"
  fi
  bash "$(dirname "$0")/240-systemTask.sh" >/dev/null
  [[ -f "$HOME/checked" ]]
  rm "$HOME/checked"
  [[ ! -e "${EXPECTED_SOCKET}.ai/session" && ! -e "${EXPECTED_SOCKET}.ai/query" ]]
done
printf 'fzf-ai provenance tests passed (normal and overridden runtime socket)\n'
