#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT/kitty/scripts/kitty-zoxide-session.sh"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

mkdir -p \
  "$TEMP/bin" \
  "$TEMP/dotfiles/scripts/macos/mac/misc" \
  "$TEMP/worktrees/issues/obs-meeting-manager/issue-21/obs-meeting-manager"

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

for command in fzf tmux; do
  cat >"$TEMP/bin/$command" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
done
chmod +x "$TEMP/bin/kitty" "$TEMP/bin/zoxide" "$TEMP/bin/fzf" "$TEMP/bin/tmux"

export PATH="$TEMP/bin:$PATH"
export HOME="$TEMP/home"
export DOTFILES_DIR="$TEMP/dotfiles"
export KITTY_BIN="$TEMP/bin/kitty"
export KITTY_ZOXIDE_SESSION_DIR="$TEMP/sessions"
export TEST_KITTY_LS_FILE="$TEMP/kitty-ls.json"
export TEST_KITTY_LOG="$TEMP/kitty.log"
export TEST_ZOXIDE_LOG="$TEMP/zoxide.log"
export linkarzu_color03="#ffffff"

WORKTREE="$(cd -- "$TEMP/worktrees/issues/obs-meeting-manager/issue-21/obs-meeting-manager" && pwd -P)"
SESSION_NAME="z-issue-21-obs-meeting-manager"
SESSION_FILE="$TEMP/sessions/$SESSION_NAME.kitty-session"

printf '%s\n' '[]' >"$TEST_KITTY_LS_FILE"
: >"$TEST_KITTY_LOG"
: >"$TEST_ZOXIDE_LOG"
"$SCRIPT" --issue-opencode 21 "$WORKTREE"

[[ -f "$SESSION_FILE" ]]
grep -F "cd $WORKTREE" "$SESSION_FILE" >/dev/null
grep -F "launch --title \"$SESSION_NAME\" zsh -lic 'o; exec zsh -l'" "$SESSION_FILE" >/dev/null
grep -F "action goto_session $SESSION_FILE" "$TEST_KITTY_LOG" >/dev/null
grep -F "add -- $WORKTREE" "$TEST_ZOXIDE_LOG" >/dev/null

printf '[{"tabs":[{"windows":[{"session_name":"%s","env":{"PWD":"%s"}}]}]}]\n' \
  "$SESSION_NAME" "$WORKTREE" >"$TEST_KITTY_LS_FILE"
: >"$TEST_KITTY_LOG"
"$SCRIPT" --issue-opencode 21 "$WORKTREE"
grep -F "action goto_session $SESSION_NAME" "$TEST_KITTY_LOG" >/dev/null
if grep -F ".kitty-session" "$TEST_KITTY_LOG" >/dev/null; then
  echo "existing session was duplicated instead of focused" >&2
  exit 1
fi

if "$SCRIPT" --issue-opencode 22 "$WORKTREE" >/dev/null 2>&1; then
  echo "mismatched issue path unexpectedly succeeded" >&2
  exit 1
fi

printf '%s\n' "kitty zoxide issue handoff tests passed"
