#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/keyboard_battery.sh

# Shows the name and battery level of both halves of the connected Forager or
# Toucan: green from 50%, yellow from 15%, red below that, it lasts for weeks so
# it warns later than battery.sh. Hidden when neither is connected. The right click popup adds the Magic
# Mouse, and estimates from a history of the levels, per device. All of that is
# kept outside the sketchybar config directory, because writing there would
# hotload sketchybar.
source "$CONFIG_DIR/colors.sh"

source_file="$(dirname "${BASH_SOURCE[0]}")/keyboard_battery.swift"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
bin="$cache_dir/keyboard-battery"
mouse_history="$cache_dir/mouse-battery-history"

mkdir -p "$cache_dir"
if [[ ! -x "$bin" || "$source_file" -nt "$bin" ]]; then
  swiftc -O -o "$bin.$$" "$source_file" &&
    mv -f "$bin.$$" "$bin"
fi

# Keeps the mac or Windows layer icon up to date. items/keyboard_battery.sh stops
# it on a sketchybar reload, so it also picks up a rebuilt binary.
if ! pgrep -f '/keyboard-battery --watch-layer$' >/dev/null; then
  "$bin" --watch-layer >/dev/null 2>&1 &
  disown
fi

color() {
  case "$1" in
  [5-9][0-9] | 100) echo "$GREEN" ;;
  1[5-9] | [2-4][0-9]) echo "$YELLOW" ;;
  [0-9] | 1[0-4]) echo "$RED" ;;
  *) echo "$GREY" ;;
  esac
}

# Appends a row, keeping about a year of them at one row every 5 minutes, so a
# charge that lasts for months doesn't lose its last charged date.
record() {
  local file="$1"
  shift
  echo "$(date +%s) $*" >>"$file"
  if (($(wc -l <"$file") > 120000)); then
    tail -n 105000 "$file" >"$file.$$" && mv -f "$file.$$" "$file"
  fi
}

# Prints "<time left>|<last charged epoch>" for a history column, either empty
# when it can't tell yet. A rise of 5 or more starts a charge, and being on USB
# (usb_col) counts as one too. Last charged is when the level last rose during
# that charge. Time left extrapolates from the
# highest level since, once it has dropped 3 or more over at least a day, so
# voltage noise doesn't produce wild estimates.
estimate() {
  awk -v col="$2" -v usb_col="${3:-0}" '
    $col ~ /^[0-9]+$/ {
      level = $col + 0
      if (!seen) { seen = 1; peak = low = level; peak_time = $1 }
      if (level >= low + 5 || (usb_col && $usb_col == 1)) {
        charging = 1; charged = $1
        if (level >= low + 5) { peak = low = level; peak_time = $1 }
      }
      if (level < low) low = level
      if (level > peak) {
        peak = level; peak_time = $1
        if (charging) charged = $1
      }
      last = level; last_time = $1
    }
    END {
      elapsed = last_time - peak_time
      if (seen && elapsed >= 86400 && peak - last >= 3) {
        seconds = last * elapsed / (peak - last)
        left = seconds >= 86400 ? "~" int(seconds / 86400) "d" : "~" int(seconds / 3600) "h"
      }
      print left "|" charged
    }' "$1"
}

# Prints a last charged epoch as "Nov 2 09:14 · 3d ago".
charged_label() {
  [[ -z "$1" ]] && echo "--" && return
  local ago=$(($(date +%s) - $1))
  if ((ago >= 86400)); then
    ago="$((ago / 86400))d"
  elif ((ago >= 3600)); then
    ago="$((ago / 3600))h"
  else
    ago="$((ago / 60))m"
  fi
  echo "$(date -r "$1" '+%b %-d %H:%M') · $ago ago"
}

mouse="$(ioreg -r -c AppleDeviceManagementHIDEventService -l -w 0 | awk -F' = ' '
  /"Product"/ { product = $2 }
  /"BatteryPercent"/ && product ~ /Magic Mouse/ { print $2; exit }')"
[[ -n "$mouse" ]] && record "$mouse_history" "$mouse"

name="" left="" right=""
read -r name left right < <("$bin" 2>/dev/null)

if [[ -z "$name" ]]; then
  sketchybar --set '/keyboard\..*/' drawing=off popup.drawing=off
  exit 0
fi

# Either half can be on USB and both report the keyboard name as the product, so
# only the serial number, unique to each half's chip, tells them apart. A serial
# not listed here counts as the left half.
right_half_usb_serials="111284EC2EE7C604"
usb_left=0 usb_right=0
while read -r serial; do
  if [[ " $right_half_usb_serials " == *" $serial "* ]]; then
    usb_right=1
  else
    usb_left=1
  fi
done < <(ioreg -p IOUSB -l -w 0 | awk -F'"' -v name="$name" '
  /"USB Product Name"/ {
    if (found) print serial
    found = index(tolower($4), tolower(name)) > 0
    serial = "none"
  }
  /"USB Serial Number"/ { serial = $4 }
  END { if (found) print serial }')

history="$cache_dir/$name-battery-history"
record "$history" "$left" "$right" "$usb_left" "$usb_right"

IFS='|' read -r left_time left_charged < <(estimate "$history" 2 4)
IFS='|' read -r right_time right_charged < <(estimate "$history" 3 5)
IFS='|' read -r mouse_time mouse_charged < <(estimate "$mouse_history" 2)

# Prints "<level>% · <status>", without the % when the level couldn't be read.
level_label() {
  [[ "$1" == "--" ]] && echo "-- · $2" || echo "$1% · $2"
}

left_status="${left_time:---}"
((usb_left)) && left_status="charging"
left_charged_label="$(charged_label "$left_charged")"
((usb_left)) && left_charged_label="now"
right_status="${right_time:---}"
((usb_right)) && right_status="charging"
right_charged_label="$(charged_label "$right_charged")"
((usb_right)) && right_charged_label="now"

mouse_label="not connected"
[[ -n "$mouse" ]] && mouse_label="$mouse% · ${mouse_time:---}"

sketchybar --set '/keyboard\..*/' drawing=on \
  --set keyboard.title label="$name" \
  --set keyboard.left label="L $left" label.color="$(color "$left")" \
  --set keyboard.right label="R $right" label.color="$(color "$right")" \
  --set keyboard.popup.left label="$(level_label "$left" "$left_status")" label.color="$(color "$left")" \
  --set keyboard.popup.right label="$(level_label "$right" "$right_status")" label.color="$(color "$right")" \
  --set keyboard.popup.mouse label="$mouse_label" label.color="$(color "$mouse")" \
  --set keyboard.popup.left_charged label="$left_charged_label" \
  --set keyboard.popup.right_charged label="$right_charged_label" \
  --set keyboard.popup.mouse_charged label="$(charged_label "$mouse_charged")" \
  --set keyboard.popup.updated label="$(date +%H:%M:%S)"
