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
# - Control Center UI scripting was the reliable native path here. Use process
#   "ControlCenter" and the menu bar item whose description is "Control Center".
# - Opening Control Center was more reliable with AXPress than click:
#   perform action "AXPress" of menu bar item ...
# - The Focus tile was the wide checkbox in Control Center, usually checkbox 2.
#   This script searches for a checkbox wider than 100px and taller than 50px
#   before falling back to checkbox 2.
# - For JXA status output, return from run() instead of console.log so Bash
#   command substitution captures only the value.

set -euo pipefail

export PATH="/opt/homebrew/bin:$PATH"

ACTION="${1:-toggle}"
export DND_MODE_IDENTIFIER="${DND_MODE_IDENTIFIER:-com.apple.donotdisturb.mode.default}"
export DND_ASSERTIONS_DB="${DND_ASSERTIONS_DB:-$HOME/Library/DoNotDisturb/DB/Assertions.json}"

case "$ACTION" in
on | start | enable | off | stop | disable | toggle | status) ;;
*)
  echo "Usage: $(basename "$0") [on|off|toggle|status]" >&2
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
  /usr/bin/osascript <<'APPLESCRIPT'
tell application "System Events"
  key code 53
  delay 0.15

  tell process "ControlCenter"
    perform action "AXPress" of (first menu bar item of menu bar 1 whose description is "Control Center")

    repeat 20 times
      if (count of windows) > 0 then exit repeat
      delay 0.1
    end repeat

    if (count of windows) = 0 then error "Control Center did not open"

    set focusToggle to missing value
    repeat with candidate in (checkboxes of group 1 of window 1)
      set candidateSize to size of candidate
      if ((item 1 of candidateSize) > 100) and ((item 2 of candidateSize) > 50) then
        set focusToggle to candidate
        exit repeat
      end if
    end repeat

    if focusToggle is missing value then set focusToggle to checkbox 2 of group 1 of window 1
    click focusToggle
  end tell

  delay 0.2
  key code 53
end tell
APPLESCRIPT
}

turn_on() {
  if [[ "$(get_status)" == "on" ]]; then
    echo "on"
    return 0
  fi

  # If another Focus mode is active, the first click may turn it off; the second
  # click then turns the default Do Not Disturb mode on.
  for _ in {1..2}; do
    press_focus_toggle
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

  press_focus_toggle
  if wait_for_status "off"; then
    echo "off"
    return 0
  fi

  echo "Failed to disable Do Not Disturb" >&2
  return 1
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
esac
