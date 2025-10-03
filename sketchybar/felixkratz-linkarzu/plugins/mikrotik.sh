#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mikrotik.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mikrotik.sh

# echo "" >/tmp/mikrotik.sh.log

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"

TRANSFER_SPEEDS=$(ssh mikrotik "/interface/monitor-traffic bridge once")
# I'm monitoring the bridge interface, as I have 2 ISPs, from the bgridge
# interface perspective the Tx and Rx are opposites, so that cause a bit of
# confusion
RECEIVE_SPEED=$(echo "$TRANSFER_SPEEDS" | awk '/ tx-bits-per-second/ {print $2}')
TRANSMIT_SPEED=$(echo "$TRANSFER_SPEEDS" | awk '/ rx-bits-per-second/ {print $2}')
# echo "tx=$RECEIVE_SPEED" >>/tmp/mikrotik.sh.log
# echo "rx=$TRANSMIT_SPEED" >>/tmp/mikrotik.sh.log

RECEIVE_SPEED_HUMAN=$(echo "$RECEIVE_SPEED" | tr -d '\r' | sed -E 's/[[:space:]]+$//; s/\.\.\./0k/; s/kbps$/k/; s/Mbps$/M/; s/bps$/b/')
TRANSMIT_SPEED_HUMAN=$(echo "$TRANSMIT_SPEED" | tr -d '\r' | sed -E 's/[[:space:]]+$//; s/\.\.\./0k/; s/kbps$/k/; s/Mbps$/M/; s/bps$/b/')
# echo "txh=$RECEIVE_SPEED_HUMAN" >>/tmp/mikrotik.sh.log
# echo "rxh=$TRANSMIT_SPEED_HUMAN" >>/tmp/mikrotik.sh.log

CURRENT_ISP=$(ssh mikrotik "/ip route print where dst-address=0.0.0.0/0 and active")
GATEWAY=$(echo "$CURRENT_ISP" | awk '/0\.0\.0\.0\/0/ {print $(NF-1)}')
# echo "gateway=$GATEWAY" >>/tmp/mikrotik.sh.log

if [ "$GATEWAY" == "1.0.0.1" ]; then
  CURRENT_GATEWAY="CLARO"
  COLOR="$GREEN"
else
  CURRENT_GATEWAY="SIST"
  COLOR="$RED"
fi

sketchybar -m --set mikrotik \
  label="${CURRENT_GATEWAY}  ${RECEIVE_SPEED_HUMAN}  ${TRANSMIT_SPEED_HUMAN}" \
  icon= icon.color="$COLOR" \
  label.color="$COLOR"
