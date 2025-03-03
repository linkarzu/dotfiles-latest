#!/bin/bash

source "$CONFIG_DIR/colors.sh"

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

# Check for the absence of "InternalBattery" to determine no battery present
# My mac mini doesn't have a battery, and it was leaving a blank space where the
# battery was supposed to be
if ! echo "$BATTERY_INFO" | grep -q "InternalBattery"; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on
fi

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

COLOR=$WHITE
case "${PERCENTAGE}" in
[8-9][0-9] | 100)
  ICON=""
  COLOR=$GREEN
  ;;
[3-7][0-9])
  ICON=""
  COLOR=$YELLOW
  ;;
# [3-5][0-9])
#   ICON=""
#   COLOR=$YELLOW
#   ;;
[1-2][0-9])
  ICON=""
  COLOR=$RED
  ;;
*) ICON="" ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}" icon.color=$COLOR
