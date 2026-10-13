#!/usr/bin/env bash

# Claude Code hook that publishes session state to the Kitty window as user
# vars, the same way opencode/plugins/sketchybar-status.ts does for OpenCode,
# so the SketchyBar opencode item can show Claude sessions too.
#
# Registered in ~/.claude/settings.json for SessionStart, UserPromptSubmit,
# Notification, Stop, StopFailure and SessionEnd, plus PreToolUse and
# PostToolUse for AskUserQuestion and ExitPlanMode.
#
# Attention is only raised when the Claude window is not focused. The Kitty
# watcher kitty/watchers/claude_attention.py clears it after the window stays
# focused for two seconds.

set -u

kitty_bin="/Applications/kitty.app/Contents/MacOS/kitty"
sketchybar_bin="/opt/homebrew/bin/sketchybar"

[[ -n "${KITTY_PID:-}" && -n "${KITTY_WINDOW_ID:-}" ]] || exit 0
socket="unix:/tmp/kitty-${KITTY_PID}"

input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null)"
notification_type="$(jq -r '.notification_type // empty' <<<"$input" 2>/dev/null)"
tool_name="$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)"

window_focused() {
  "$kitty_bin" @ --to "$socket" ls --match "id:${KITTY_WINDOW_ID}" 2>/dev/null |
    jq -e '.[0] as $os | ($os.is_focused and $os.tabs[0].is_focused and $os.tabs[0].windows[0].is_focused)' >/dev/null 2>&1
}

publish() {
  "$kitty_bin" @ --to "$socket" set-user-vars --match "id:${KITTY_WINDOW_ID}" "$@" >/dev/null 2>&1 || return 0
  "$sketchybar_bin" --trigger opencode_update >/dev/null 2>&1 || true
}

attention() {
  local reason="$1"

  if window_focused; then
    publish claude_waiting=0 claude_reason=none "${@:2}"
  else
    publish claude_waiting=1 "claude_reason=${reason}" "${@:2}"
  fi
}

case "$event" in
SessionStart)
  publish claude_busy=0 claude_waiting=0 claude_reason=none
  ;;
UserPromptSubmit)
  publish claude_busy=1 claude_waiting=0 claude_reason=none
  ;;
Notification)
  case "$notification_type" in
  permission_prompt | worker_permission_prompt)
    attention permission
    ;;
  elicitation_dialog | elicitation_url_dialog | agent_needs_input)
    attention question
    ;;
  esac
  ;;
PreToolUse)
  # Questions and plan approvals block mid-turn, the permission_prompt
  # notification for them only arrives 6 seconds later
  case "$tool_name" in
  AskUserQuestion | ExitPlanMode)
    attention question
    ;;
  esac
  ;;
PostToolUse)
  case "$tool_name" in
  AskUserQuestion | ExitPlanMode)
    publish claude_waiting=0 claude_reason=none
    ;;
  esac
  ;;
Stop)
  # A turn that ends while background shells or agents are still running is
  # not done, Claude resumes on its own when they finish
  if jq -e '[.background_tasks[]? | select(.status == "running" or .status == "pending")] | length > 0' <<<"$input" >/dev/null 2>&1; then
    publish claude_busy=1 claude_waiting=0 claude_reason=none
  else
    attention done claude_busy=0
  fi
  ;;
StopFailure)
  attention error claude_busy=0
  ;;
SessionEnd)
  publish claude_busy claude_waiting claude_reason
  ;;
esac

exit 0
