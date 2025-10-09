#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mikrotik.sh
# ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/mikrotik.sh

# echo "" >/tmp/mikrotik.sh.log

source "$HOME/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"

# I'm monitoring the bridge interface, as I have 2 ISPs, from the bgridge
# interface perspective the Tx and Rx are opposites, so that cause a bit of
# confusion
#
# tr -d '\r' deletes carriage returns at the end of values
ROUTER_OUTPUT=$(ssh mikrotik ":put (\"TRANSMITSPEED=\" . [/interface/monitor-traffic interface=bridge once as-value]->\"rx-bits-per-second\"); \
:put (\"RECEIVESPEED=\" . [/interface/monitor-traffic interface=bridge once as-value]->\"tx-bits-per-second\"); \
:put (\"MAINGATEWAY=\" . \$maingateway);
:put (\"BACKGATEWAY=\" . \$backgateway);
:if ([:len [/ip route find comment=\"mainisp\"]] > 0) do={:put \"MAINISP=UP\"} else={:put \"MAINISP=DOWN\"}; \
:if ([:len [/ip route find comment=\"backupisp\"]] > 0) do={:put \"BACKUPISP=UP\"} else={:put \"BACKUPISP=DOWN\"}" | tr -d '\r')
# echo "$ROUTER_OUTPUT" >>/tmp/mikrotik.sh.log

# Parse values from KEY=VALUE lines
TRANSMIT_SPEED=$(echo "$ROUTER_OUTPUT" | awk -F= '/^TRANSMITSPEED=/{print $2}')
RECEIVE_SPEED=$(echo "$ROUTER_OUTPUT" | awk -F= '/^RECEIVESPEED=/{print $2}')
MAINGATEWAY=$(echo "$ROUTER_OUTPUT" | awk -F= '/^MAINGATEWAY=/{print $2}')
BACKGATEWAY=$(echo "$ROUTER_OUTPUT" | awk -F= '/^BACKGATEWAY=/{print $2}')
MAINISP_STATUS=$(echo "$ROUTER_OUTPUT" | awk -F= '/^MAINISP=/{print $2}')
BACKUPISP_STATUS=$(echo "$ROUTER_OUTPUT" | awk -F= '/^BACKUPISP=/{print $2}')
# echo "TRANSMIT_SPEED=$TRANSMIT_SPEED" >>/tmp/mikrotik.sh.log
# echo "RECEIVE_SPEED=$RECEIVE_SPEED" >>/tmp/mikrotik.sh.log
# echo "MAINISP_NAME=$MAINISP_NAME" >>/tmp/mikrotik.sh.log
# echo "BACKUPISP_NAME=$BACKUPISP_NAME" >>/tmp/mikrotik.sh.log
# echo "MAINISP_STATUS=$MAINISP_STATUS" >>/tmp/mikrotik.sh.log
# echo "BACKUPISP_STATUS=$BACKUPISP_STATUS" >>/tmp/mikrotik.sh.log

RECEIVE_SPEED_HUMAN=$(
  awk -v b="$RECEIVE_SPEED" 'BEGIN{ if(b>=1e6) printf("%.1fM", b/1e6); else if(b>=1e3) printf("%.1fk", b/1e3); else printf("%db", b) }'
)

TRANSMIT_SPEED_HUMAN=$(
  awk -v b="$TRANSMIT_SPEED" 'BEGIN{ if(b>=1e6) printf("%.1fM", b/1e6); else if(b>=1e3) printf("%.1fk", b/1e3); else printf("%db", b) }'
)
# echo "TRANSMIT_SPEED_HUMAN=$TRANSMIT_SPEED_HUMAN" >>/tmp/mikrotik.sh.log
# echo "RECEIVE_SPEED_HUMAN=$RECEIVE_SPEED_HUMAN" >>/tmp/mikrotik.sh.log

if [ "$BACKUPISP_STATUS" = "UP" ]; then
  BACKGATEWAY_DISPLAY=$(printf %s "$BACKGATEWAY" | tr '[:lower:]' '[:upper:]')
  BACKUPISP_ARROW=""
else
  BACKGATEWAY_DISPLAY=$(printf %s "$BACKGATEWAY" | tr '[:upper:]' '[:lower:]')
  BACKUPISP_ARROW=""
fi

if [ "$MAINISP_STATUS" = "UP" ]; then
  COLOR="$GREEN"
  ISPS_STATUS="A:${MAINGATEWAY} B:${BACKGATEWAY_DISPLAY}$BACKUPISP_ARROW"
  if [ "$BACKUPISP_STATUS" != "UP" ]; then
    COLOR="$YELLOW"
  fi
else
  COLOR="$YELLOW"
  if [ "$BACKUPISP_STATUS" = "DOWN" ]; then
    TRANSMIT_SPEED_HUMAN=0
    RECEIVE_SPEED_HUMAN=0
    COLOR="$RED"
  fi
  ISPS_STATUS="B:${BACKGATEWAY_DISPLAY}$BACKUPISP_ARROW"
fi

sketchybar -m --set mikrotik \
  label="${ISPS_STATUS}  ${RECEIVE_SPEED_HUMAN}  ${TRANSMIT_SPEED_HUMAN}" \
  icon= icon.color="$COLOR" \
  label.color="$COLOR"
