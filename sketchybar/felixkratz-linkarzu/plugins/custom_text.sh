#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/custom_text.sh

source "$CONFIG_DIR/colors.sh"

# File created by ~/github/scripts-public/macos/mac/305-bannerOn.sh
youtube_banner="$HOME/github/dotfiles-latest/youtube-banner.txt"
streaming_time_script="$HOME/github/dotfiles-private/scripts/macos/mac/obs/streaming-time/py/streaming-time.py"
streaming_reminder_state="${TMPDIR:-/tmp}/sketchybar-streaming-16-minute-reminder"
# Remind from minute 16 every 15 minutes until this scene is shown.
members_scene="youtube-members"
reminder_interval_minutes=15

format_streaming_time() {
  local minutes="$1"

  if ! [[ "$minutes" =~ ^[0-9]+$ ]]; then
    minutes=0
  fi

  printf "%d:%02d" "$((minutes / 60))" "$((minutes % 60))"
}

set_custom_text() {
  local banner_text="$1"
  local streaming_time="$2"
  local color="$3"
  local scene_label_width=$((${#banner_text} * 7))
  local time_label_width=$((${#streaming_time} * 5))
  local icon_padding_left=$((scene_label_width - time_label_width))
  local icon_padding_right=$((-scene_label_width))

  sketchybar -m --set custom_text \
    label="$banner_text" \
    icon="$streaming_time" \
    icon.color=$BLUE \
    label.color=$color \
    icon.drawing=on \
    label.drawing=on \
    icon.padding_left="$icon_padding_left" \
    icon.padding_right="$icon_padding_right" \
    padding_right=3
}

# The state file holds "done" once the members scene was shown after a
# reminder this stream, otherwise the streaming minute of the last reminder. It is removed when the
# banner goes away and by the start/stop recording scripts.
show_streaming_reminder() {
  local state=""
  [[ -f "$streaming_reminder_state" ]] && state=$(<"$streaming_reminder_state")

  # The members scene only counts after the first reminder, so an early or
  # accidental switch never skips the minute-16 thank-you reminder.
  if [[ "$banner_text" == "$members_scene" && "$state" =~ ^[0-9]+$ ]]; then
    printf 'done\n' >"$streaming_reminder_state"
    return
  fi

  if [[ "$state" == "done" || "$streaming_minutes" -lt 16 ]]; then
    return
  fi

  if [[ "$state" =~ ^[0-9]+$ ]] &&
    ((streaming_minutes >= state && streaming_minutes - state < reminder_interval_minutes)); then
    return
  fi

  # Don't stack a new alert on top of one that is still open.
  if pgrep -f 'display alert "Stream reminder"' >/dev/null; then
    return
  fi

  printf '%s\n' "$streaming_minutes" >"$streaming_reminder_state"
  # Same style as the OBS Meeting Manager alerts: stays until OK is clicked.
  osascript -e 'activate' -e 'display alert "Stream reminder" message "Thank YouTube members." as informational buttons {"OK"} default button "OK"' >/dev/null 2>&1 &
}

if [ -f "$youtube_banner" ]; then
  banner_text=$(<"$youtube_banner")
  streaming_minutes=$(zsh -lc "python3 '$streaming_time_script'" 2>/dev/null)
  streaming_time=$(format_streaming_time "$streaming_minutes")

  if ! [[ "$streaming_minutes" =~ ^[0-9]+$ ]]; then
    streaming_minutes=0
  fi

  show_streaming_reminder

  # Choose color based on label value
  if [[ "$banner_text" == "main-screen" ]]; then
    color=$BLUE
  else
    color=$RED
  fi

  set_custom_text "$banner_text" "$streaming_time" "$color"
else
  rm -f "$streaming_reminder_state"
  sketchybar -m --set custom_text label="" icon="" icon.drawing=off
fi
