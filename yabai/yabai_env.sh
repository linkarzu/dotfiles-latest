#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/yabai/yabai_env.sh
# ~/github/dotfiles-latest/yabai/yabai_env.sh

# To get the names of all the running applications
# yabai -m query --windows | jq -r '.[].app'

# apps_transparent="(Spotify|kitty|Neovide|Google Chrome|Code|WezTerm|Ghostty)"
apps_transparent="(Neovide|Code)"

display_resolution=$(system_profiler SPDisplaysDataType | grep Resolution)
if [[ $(echo "$display_resolution" | grep -c "Resolution") -ge 2 ]]; then
  apps_stream="(Microsoft Edge|OBS Studio|Jitsi Meet|Discord)"
  # This keeps apps always below, seems to be working fine when I switch to other
  # apps
  apps_mgoff_below="(Calculator|iStat Menus|Hammerspoon|BetterDisplay|GIMP|Notes|Activity Monitor|App StoreSoftware Update|TestRig|Gemini|Raycast|OBS Studio|Microsoft Edge|Cisco Packet Tracer|Stickies|kitty|ProLevel|Photo Booth|Hand Mirror|SteerMouse|remote-viewer|Jitsi Meet|DaVinci Resolve|Discord)"
else
  apps_stream="()"
  # This keeps apps always below, seems to be working fine when I switch to other
  # apps
  apps_mgoff_below="(Calculator|iStat Menus|Hammerspoon|BetterDisplay|GIMP|Notes|Activity Monitor|App StoreSoftware Update|TestRig|Gemini|Raycast|OBS Studio|Microsoft Edge|Cisco Packet Tracer|Stickies|kitty|ProLevel|Photo Booth|Hand Mirror|SteerMouse|remote-viewer|Jitsi Meet|DaVinci Resolve)"
fi

# Apps that I want to always show, even when I have a transparent app focused
apps_transp_ignore="(kitty)"
apps_scratchpad="(Udemy|WezTerm)"
# apps_transp_ignore="(kitty|CleanShot X)"

# Apps excluded from window management, so you can resize them and move them around
# This is basically the ignore list

# I had to move them away from normal, because all these apps would stay on top
# of other apps
# apps_mgoff_normal="()"

# This keeps apps always on the top
apps_mgoff_above="()"
