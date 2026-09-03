#!/usr/bin/env bash

# This script was created by the clanker:
# Native macOS Do Not Disturb control. This intentionally avoids BetterTouchTool.
#
# Useful macOS 15 findings for future debugging:
# - The old defaults key no longer exists here:
#   defaults -currentHost read com.apple.notificationcenterui doNotDisturb
# - Active Focus/DND assertions are visible in:
#   ~/Library/DoNotDisturb/DB/Assertions.json
# - The active records are under:
#   data[0].storeAssertionRecords
# - Default Do Not Disturb mode identifier is:
#   com.apple.donotdisturb.mode.default
# - Configured Focus modes are visible in:
#   ~/Library/DoNotDisturb/DB/ModeConfigurations.json
# - DoNotDisturb.framework can be loaded from JXA with:
#   ObjC.import('Foundation')
#   $.NSBundle.bundleWithPath('/System/Library/PrivateFrameworks/DoNotDisturb.framework').load
# - On macOS 15, an unentitled osascript process could load/query framework
#   classes, but creating Focus assertions was blocked. Specifically,
#   DNDModeAssertionService.takeModeAssertionWithDetailsError returned nil.
# - Do not write Assertions.json, ModeConfigurations.json, or Settings.sqlite
#   directly. donotdisturbd owns those files and direct writes would be brittle.
# - Hammerspoon drives Control Center through stable accessibility identifiers:
#   com.apple.menuextra.controlcenter and controlcenter-focus-modes.
# - recording-on records the initial state once and ensures DND is on.
# - recording-off restores that initial state, including leaving preexisting
#   DND enabled.
# - For JXA status output, return from run() instead of console.log so Bash
#   command substitution captures only the value.

set -euo pipefail

export PATH="/opt/homebrew/bin:$PATH"

ACTION="${1:-toggle}"
export DND_MODE_IDENTIFIER="${DND_MODE_IDENTIFIER:-com.apple.donotdisturb.mode.default}"
export DND_ASSERTIONS_DB="${DND_ASSERTIONS_DB:-$HOME/Library/DoNotDisturb/DB/Assertions.json}"
HAMMERSPOON_RESULT="/tmp/dnd-hammerspoon-result"
RECORDING_STATE="${TMPDIR:-/tmp}/recording-dnd-initial-state"

case "$ACTION" in
on | start | enable | off | stop | disable | toggle | status | recording-on | recording-off) ;;
*)
  echo "Usage: $(basename "$0") [on|off|toggle|status|recording-on|recording-off]" >&2
  exit 2
  ;;
esac

get_status() {
  /usr/bin/osascript -l JavaScript <<'JXA'
ObjC.import('Foundation')

function env(name, fallback) {
  const value = $.NSProcessInfo.processInfo.environment.objectForKey(name)
  return value ? ObjC.unwrap(value) : fallback
}

function isNil(value) {
  return value === null || ObjC.unwrap(value) === undefined
}

function run() {
  const modeIdentifier = env('DND_MODE_IDENTIFIER', 'com.apple.donotdisturb.mode.default')
  const assertionsDB = env('DND_ASSERTIONS_DB', '')
  const data = $.NSData.dataWithContentsOfFile(assertionsDB)

  if (isNil(data)) return 'off'

  const json = $.NSJSONSerialization.JSONObjectWithDataOptionsError(data, 0, null)
  if (isNil(json)) return 'off'

  const root = ObjC.deepUnwrap(json)
  const records = (((root.data || [])[0] || {}).storeAssertionRecords) || []
  const enabled = records.some((record) => {
    const assertion = record.assertion || record
    const details = assertion.assertionDetails || {}
    return details.assertionDetailsModeIdentifier === modeIdentifier
  })

  return enabled ? 'on' : 'off'
}
JXA
}

wait_for_status() {
  local expected="$1"
  local current=""

  for _ in {1..20}; do
    current="$(get_status)"
    if [[ "$current" == "$expected" ]]; then
      return 0
    fi
    sleep 0.15
  done

  return 1
}

press_focus_toggle() {
  local target_state="$1"
  rm -f "$HAMMERSPOON_RESULT"
  hs -c "return require(\"dnd\").pressFocus(\"$target_state\")" >/dev/null

  for _ in {1..120}; do
    if [[ -f "$HAMMERSPOON_RESULT" ]]; then
      result="$(<"$HAMMERSPOON_RESULT")"
      if [[ "$result" == ok:* ]]; then
        return 0
      fi
      echo "${result#error: }" >&2
      return 1
    fi
    sleep 0.1
  done

  echo "Timed out waiting for Hammerspoon to press the Focus control" >&2
  return 1
}

turn_on() {
  if [[ "$(get_status)" == "on" ]]; then
    echo "on"
    return 0
  fi

  # If another Focus mode is active, the first click may turn it off; the second
  # click then turns the default Do Not Disturb mode on.
  for _ in {1..2}; do
    press_focus_toggle on
    if wait_for_status "on"; then
      echo "on"
      return 0
    fi
  done

  echo "Failed to enable Do Not Disturb" >&2
  return 1
}

turn_off() {
  if [[ "$(get_status)" == "off" ]]; then
    echo "off"
    return 0
  fi

  press_focus_toggle off
  if wait_for_status "off"; then
    echo "off"
    return 0
  fi

  echo "Failed to disable Do Not Disturb" >&2
  return 1
}

recording_on() {
  if [[ ! -f "$RECORDING_STATE" ]]; then
    get_status >"$RECORDING_STATE"
  fi
  turn_on
}

recording_off() {
  if [[ ! -f "$RECORDING_STATE" ]]; then
    echo "No recording DND state found; leaving DND $(get_status)"
    return 0
  fi

  initial_status="$(<"$RECORDING_STATE")"
  case "$initial_status" in
  on)
    turn_on
    ;;
  off)
    turn_off
    ;;
  *)
    echo "Invalid recording DND state: $initial_status" >&2
    return 1
    ;;
  esac
  rm -f "$RECORDING_STATE"
}

case "$ACTION" in
on | start | enable)
  turn_on
  ;;
off | stop | disable)
  turn_off
  ;;
toggle)
  if [[ "$(get_status)" == "on" ]]; then
    turn_off
  else
    turn_on
  fi
  ;;
status)
  get_status
  ;;
recording-on)
  recording_on
  ;;
recording-off)
  recording_off
  ;;
esac
