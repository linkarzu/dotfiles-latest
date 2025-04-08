#!/bin/bash

POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Black:16.0"
  # Here you can change the icon color
  icon.color=$GREEN
  padding_right=15
  label.drawing=off
  click_script="$POPUP_CLICK_SCRIPT"
  popup.height=35
)

apple_prefs=(
  icon=$PREFERENCES
  label="Preferences"
  click_script="open -a 'System Preferences'; $POPUP_OFF"
)

apple_activity=(
  icon=$ACTIVITY
  label="Activity"
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
  icon=$LOCK
  label="Lock Screen"
  click_script="pmset displaysleepnow; $POPUP_OFF"
)

apple_bluetooth=(
  icon=$BLUETOOTH
  label="BT Restart"
  click_script="open btt://execute_assigned_actions_for_trigger/?uuid=A85489BC-14EE-4332-9985-EF0C39F97389; $POPUP_OFF"
)

apple_restart=(
  icon=$RESTART
  label="Restart"
  click_script="~/github/dotfiles-latest/scripts/macos/mac/misc/220-restartConfirm.sh; $POPUP_OFF"
)

sketchybar --add item apple.logo left \
  --set apple.logo "${apple_logo[@]}" \
  \
  --add item apple.prefs popup.apple.logo \
  --set apple.prefs "${apple_prefs[@]}" \
  \
  --add item apple.activity popup.apple.logo \
  --set apple.activity "${apple_activity[@]}" \
  \
  --add item apple.lock popup.apple.logo \
  --set apple.lock "${apple_lock[@]}" \
  \
  --add item apple.bluetooth popup.apple.logo \
  --set apple.bluetooth "${apple_bluetooth[@]}" \
  \
  --add item apple.restart popup.apple.logo \
  --set apple.restart "${apple_restart[@]}"
