#!/usr/bin/env bash

# Used only to set some OBS scenes in my karabiler rules.ts file depending on
# the recording type

echo "This script will configure karabiner with the correct scene type"
echo "Type of recording:"
echo "1 - Solo"
echo "2 - Solo livestream"
echo "3 - 1 guest"
echo "4 - 1 guest livestream"
read -rp "Enter number: " choice

target_file="$HOME/github/dotfiles-latest/karabiner/mxstbr/rules.ts"

# Determine new scene name
case "$choice" in
1)
  main_scene="main-screen"
  guest_scene="guests-solo"
  ;;
3)
  main_scene="main-1-guest"
  guest_scene="guests-all-notes"
  ;;
*)
  echo "Invalid choice. Only 1 and 3 are supported right now."
  exit 1
  ;;
esac

# Replace just the scene name in the next line after the marker
sed -i '' "/lineid_obs_switchscene_main/{n;s|switch_scene\.py [^\\\`]*|switch_scene.py $main_scene|;}" "$target_file"
sed -i '' "/lineid_obs_switchscene_guest/{n;s|switch_scene\.py [^\\\`]*|switch_scene.py $guest_scene|;}" "$target_file"

echo "Replaced scene with '$main_scene' in $target_file"
