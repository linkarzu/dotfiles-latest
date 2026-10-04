#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz/plugins/volume.sh

WIDTH=100
# The newest volume_change invocation owns the collapse. Comparing percentages
# could leave the slider open when overlapping events (e.g. an output device
# switch under load) finished out of order.
TOKEN_FILE="/tmp/sketchybar_volume_slider.token"

volume_change() {
  TOKEN="$$-$RANDOM"
  echo "$TOKEN" >"$TOKEN_FILE"

  source "$CONFIG_DIR/icons.sh"
  case $INFO in
  [6-9][0-9] | 100)
    ICON=$VOLUME_100
    ;;
  [3-5][0-9])
    ICON=$VOLUME_66
    ;;
  [1-2][0-9])
    ICON=$VOLUME_33
    ;;
  [1-9])
    ICON=$VOLUME_10
    ;;
  0)
    ICON=$VOLUME_0
    ;;
  *) ICON=$VOLUME_100 ;;
  esac

  # Override icon if AirPods are currently the default output
  CONNECTED_OUTPUT=$(SwitchAudioSource -t output -c)
  if [[ "$CONNECTED_OUTPUT" == *"AirPods"* ]]; then
    ICON=$AIRPODS
  elif [[ "$CONNECTED_OUTPUT" == *"External"* ]]; then
    ICON=$HEADPHONES
  fi

  sketchybar --set volume_icon icon=$ICON \
    --set $NAME slider.percentage=$INFO

  INITIAL_WIDTH="$(sketchybar --query $NAME | jq -r ".slider.width")"
  if [ "$INITIAL_WIDTH" != "$WIDTH" ]; then
    sketchybar --animate tanh 30 --set $NAME slider.width=$WIDTH
  fi

  sleep 2

  # Collapse only if no newer volume change arrived while sleeping
  if [ "$(cat "$TOKEN_FILE" 2>/dev/null)" = "$TOKEN" ]; then
    sketchybar --animate tanh 30 --set $NAME slider.width=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
"volume_change")
  volume_change
  ;;
"mouse.clicked")
  mouse_clicked
  ;;
esac
