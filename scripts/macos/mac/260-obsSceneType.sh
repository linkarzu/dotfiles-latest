#!/usr/bin/env bash

# Used only to set some OBS scenes in my karabiler rules.ts file depending on
# the recording type

echo "This script will configure karabiner with the correct scene type"
echo "Type of recording:"
echo "1 - Solo"
echo "2 - Solo livestream"
echo "3 - 1 guest"
echo "4 - 1 guest livestream"
echo "5 - 2 guest"
echo "6 - 2 guest livestream"
echo "7 - 3 guest"
echo "8 - 3 guest livestream"
echo "9 - 4 guest"
echo "10 - 4 guest livestream"
echo "11 - Solo keyboard"
echo "12 - 5 guest"
echo "13 - 5 guest livestream"
read -rp "Enter number: " choice

target_file="$HOME/github/dotfiles-latest/kanata/configs/macos.kbd"

# Determine new scene name
case "$choice" in
1)
  main_scene="main-screen"
  guest_scene="guests-solo"
  guest_1="guest1-0guest"
  ;;
2)
  main_scene="main-screen-live"
  guest_scene="guests-solo-live"
  guest_1="guest1-0guest"
  ;;
3)
  main_scene="main-1-guest"
  guest_scene="guests-all-notes-right"
  guest_1="guest1-1guest"
  ;;
4)
  main_scene="main-1-guest-live"
  guest_scene="guests-all-notes-right-live"
  guest_1="guest1-1guest-live"
  ;;
5)
  main_scene="main-2-guest"
  guest_scene="guests2-all-notes-right"
  guest_1="guest1-2guest"
  guest_2="guest2-2guest"
  ;;
6)
  main_scene="main-2-guest-live"
  guest_scene="guests2-all-notes-right-live"
  guest_1="guest1-2guest-live"
  guest_2="guest2-2guest-live"
  ;;
7)
  main_scene="main-3-guest"
  guest_scene="guests3-all-notes-right"
  guest_1="guest1-3guest"
  guest_2="guest2-3guest"
  guest_3="guest3-3guest"
  ;;
8)
  main_scene="main-3-guest-live"
  guest_scene="guests3-all-notes-right-live"
  guest_1="guest1-3guest-live"
  guest_2="guest2-3guest-live"
  guest_3="guest3-3guest-live"
  ;;
9)
  main_scene="main-4-guest"
  guest_scene="guests4-all-notes-right"
  guest_1="guest1-4guest"
  guest_2="guest2-4guest"
  guest_3="guest3-4guest"
  guest_4="guest4-4guest"
  ;;
10)
  main_scene="main-4-guest-live"
  guest_scene="guests4-all-notes-right-live"
  guest_1="guest1-4guest-live"
  guest_2="guest2-4guest-live"
  guest_3="guest3-4guest-live"
  guest_4="guest4-4guest-live"
  guest_1_full="cam-full-guest1-4guest"
  guest_2_full="cam-full-guest2-4guest"
  guest_3_full="cam-full-guest3-4guest"
  guest_4_full="cam-full-guest4-4guest"
  ;;
11)
  main_scene="main-screen-keyboard"
  guest_scene="guests-solo-keyboard"
  ;;
12)
  main_scene="main-5-guest"
  guest_scene="guests5-all-notes-right"
  guest_1="guest1-5guest"
  guest_2="guest2-5guest"
  guest_3="guest3-5guest"
  guest_4="guest4-5guest"
  guest_5="guest5-5guest"
  ;;
13)
  main_scene="main-5-guest-live"
  guest_scene="guests5-all-notes-right-live"
  guest_1="guest1-5guest-live"
  guest_2="guest2-5guest-live"
  guest_3="guest3-5guest-live"
  guest_4="guest4-5guest-live"
  guest_5="guest5-5guest-live"
  guest_1_full="cam-full-guest1-5guest"
  guest_2_full="cam-full-guest2-5guest"
  guest_3_full="cam-full-guest3-5guest"
  guest_4_full="cam-full-guest4-5guest"
  guest_5_full="cam-full-guest5-5guest"
  ;;
*)
  echo "Invalid choice. Only 1 and 3 are supported right now."
  exit 1
  ;;
esac

# Replace just the scene name in the next line after the marker
sed -i '' "/lineid_obs_switchscene_main/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$main_scene|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_scene|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest1/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_1|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest2/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_2|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest3/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_3|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest4/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_4|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest5/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_5|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_cam_guest1/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_1_full|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_cam_guest2/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_2_full|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_cam_guest3/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_3_full|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_cam_guest4/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_4_full|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_cam_guest5/{n;s|\(switch_scene\.py \)[a-zA-Z0-9\-]*|\1$guest_5_full|;}" "$target_file"

echo "Replaced scene with '$main_scene' in $target_file"

# Reload Kanata if the target file is a Kanata config
if [[ "$target_file" == *kanata* ]]; then
  echo "Reloading Kanata via launchctl..."
  launchctl kickstart -k gui/$(id -u)/com.linkarzu.kanata
fi
