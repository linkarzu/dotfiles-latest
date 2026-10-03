#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/disk.sh

# Shows the used percentage of the startup disk and pushes it to the disk
# graph: white, yellow above 65%, red above 90%.
source "$CONFIG_DIR/colors.sh"

# APFS volumes share one container, df on / reports the container size and
# free space, so this counts every volume on the disk.
read -r size avail < <(df -k / | awk 'NR == 2 { print $2, $4 }')
[ -z "$size" ] && exit 0
percent=$((((size - avail) * 100 + size / 2) / size))

color=$WHITE
if ((percent > 90)); then
  color=$RED
elif ((percent > 65)); then
  color=$YELLOW
fi

sketchybar --push disk.graph "$(awk -v used="$((size - avail))" -v size="$size" 'BEGIN { printf "%.4f", used / size }')" \
  --set "$NAME" label="$percent" label.color="$color"
