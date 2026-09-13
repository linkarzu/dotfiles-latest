#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/kitty/scripts/kitty-zoxide-session.sh"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

mkdir -p \
  "$TEMP/bin" \
  "$TEMP/dotfiles/scripts/macos/mac/misc" \
  "$TEMP/worktrees/issues/obs-meeting-manager/issue-21/obs-meeting-manager" \
  "$TEMP/other-worktree"

cat >"$TEMP/dotfiles/scripts/macos/mac/misc/549-kittyMainSocket.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '/tmp/test-kitty.sock'
EOF
chmod +x "$TEMP/dotfiles/scripts/macos/mac/misc/549-kittyMainSocket.sh"

cat >"$TEMP/bin/kitty" <<'EOF'
#!/usr/bin/env bash
if [[ "${*: -1}" == "ls" ]]; then
  cat "$TEST_KITTY_LS_FILE"
  exit 0
fi
printf '%s\n' "$*" >>"$TEST_KITTY_LOG"
EOF

cat >"$TEMP/bin/zoxide" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_ZOXIDE_LOG"
EOF

cat >"$TEMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_GH_LOG"
if [[ "${TEST_GH_FAIL:-false}" == "true" ]]; then
  exit 1
fi
printf '%s\n' "${TEST_GH_JSON:-{\"number\":21,\"state\":\"OPEN\",\"title\":\"Automate issue handoff\"}}"
EOF

for command in fzf tmux; do
  cat >"$TEMP/bin/$command" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
done
chmod +x "$TEMP/bin/kitty" "$TEMP/bin/zoxide" "$TEMP/bin/gh" \
  "$TEMP/bin/fzf" "$TEMP/bin/tmux"

export PATH="$TEMP/bin:$PATH"
export HOME="$TEMP/home"
export DOTFILES_DIR="$TEMP/dotfiles"
export KITTY_BIN="$TEMP/bin/kitty"
export KITTY_ZOXIDE_SESSION_DIR="$TEMP/sessions"
export TEST_KITTY_LS_FILE="$TEMP/kitty-ls.json"
export TEST_KITTY_LOG="$TEMP/kitty.log"
export TEST_ZOXIDE_LOG="$TEMP/zoxide.log"
export TEST_GH_LOG="$TEMP/gh.log"
export linkarzu_color03="#ffffff"

WORKTREE="$(cd -- "$TEMP/worktrees/issues/obs-meeting-manager/issue-21/obs-meeting-manager" && pwd -P)"
git init --quiet --initial-branch=issue-21-fix-audio "$WORKTREE"
SESSION_NAME="z-21-omm-fix-audio"
SESSION_FILE="$TEMP/sessions/$SESSION_NAME.kitty-session"
TITLE_B64="$(printf '%s' 'Automate issue handoff' | jq -Rrs '@base64')"

printf '%s\n' '[]' >"$TEST_KITTY_LS_FILE"
: >"$TEST_KITTY_LOG"
: >"$TEST_ZOXIDE_LOG"
: >"$TEST_GH_LOG"
"$SCRIPT" --issue-opencode 21 "$WORKTREE" fix-audio

[[ -f "$SESSION_FILE" ]]
grep -F "cd $WORKTREE" "$SESSION_FILE" >/dev/null
grep -F "launch --title \"$SESSION_NAME\" --env OPENCODE_OBS_ISSUE_NUMBER=21 --env OPENCODE_OBS_ISSUE_TITLE_B64=$TITLE_B64 zsh -lic 'o --prompt \"/work-issue 21\"; exec zsh -l'" "$SESSION_FILE" >/dev/null
grep -F "action goto_session $SESSION_FILE" "$TEST_KITTY_LOG" >/dev/null
grep -F "add -- $WORKTREE" "$TEST_ZOXIDE_LOG" >/dev/null
grep -Fx "issue view 21 --repo linkarzu/obs-meeting-manager --json number,state,title" "$TEST_GH_LOG" >/dev/null

printf '[{"tabs":[{"windows":[{"session_name":"%s","env":{"PWD":"%s"}}]}]}]\n' \
  "$SESSION_NAME" "$WORKTREE" >"$TEST_KITTY_LS_FILE"
: >"$TEST_KITTY_LOG"
: >"$TEST_GH_LOG"
"$SCRIPT" --issue-opencode 21 "$WORKTREE" fix-audio
grep -F "action goto_session $SESSION_NAME" "$TEST_KITTY_LOG" >/dev/null
if grep -F ".kitty-session" "$TEST_KITTY_LOG" >/dev/null; then
  echo "existing session was duplicated instead of focused" >&2
  exit 1
fi
[[ ! -s "$TEST_GH_LOG" ]]

if "$SCRIPT" --issue-opencode 22 "$WORKTREE" fix-audio >/dev/null 2>&1; then
  echo "mismatched issue path unexpectedly succeeded" >&2
  exit 1
fi

printf '%s\n' '[]' >"$TEST_KITTY_LS_FILE"
: >"$TEST_GH_LOG"
if "$SCRIPT" --issue-opencode 21 "$WORKTREE" wrong-slug >/dev/null 2>&1; then
  echo "mismatched branch slug unexpectedly succeeded" >&2
  exit 1
fi
[[ ! -s "$TEST_GH_LOG" ]]

printf '[{"tabs":[{"windows":[{"session_name":"%s","env":{"PWD":"%s"}}]}]}]\n' \
  "$SESSION_NAME" "$TEMP/other-worktree" >"$TEST_KITTY_LS_FILE"
: >"$TEST_KITTY_LOG"
if "$SCRIPT" --issue-opencode 21 "$WORKTREE" fix-audio >/dev/null 2>&1; then
  echo "session-name collision unexpectedly succeeded" >&2
  exit 1
fi
if grep -F "action goto_session" "$TEST_KITTY_LOG" >/dev/null; then
  echo "session-name collision unexpectedly navigated Kitty" >&2
  exit 1
fi

printf '%s\n' '[]' >"$TEST_KITTY_LS_FILE"
export TEST_GH_JSON='{"number":21,"state":"CLOSED","title":"Automate issue handoff"}'
if "$SCRIPT" --issue-opencode 21 "$WORKTREE" fix-audio >/dev/null 2>&1; then
  echo "closed issue unexpectedly launched" >&2
  exit 1
fi

printf '%s\n' "kitty zoxide issue handoff tests passed"
