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
MAINGATEWAY="${MAINGATEWAY:0:1}"
BACKGATEWAY=$(echo "$ROUTER_OUTPUT" | awk -F= '/^BACKGATEWAY=/{print $2}')
BACKGATEWAY="${BACKGATEWAY:0:1}"
MAINISP_STATUS=$(echo "$ROUTER_OUTPUT" | awk -F= '/^MAINISP=/{print $2}')
BACKUPISP_STATUS=$(echo "$ROUTER_OUTPUT" | awk -F= '/^BACKUPISP=/{print $2}')
# echo "TRANSMIT_SPEED=$TRANSMIT_SPEED" >>/tmp/mikrotik.sh.log
# echo "RECEIVE_SPEED=$RECEIVE_SPEED" >>/tmp/mikrotik.sh.log
# echo "MAINISP_NAME=$MAINISP_NAME" >>/tmp/mikrotik.sh.log
# echo "BACKUPISP_NAME=$BACKUPISP_NAME" >>/tmp/mikrotik.sh.log
# echo "MAINISP_STATUS=$MAINISP_STATUS" >>/tmp/mikrotik.sh.log
# echo "BACKUPISP_STATUS=$BACKUPISP_STATUS" >>/tmp/mikrotik.sh.log

RECEIVE_SPEED_HUMAN=$(
  # Don't need decimals
  awk -v b="$RECEIVE_SPEED" 'BEGIN{ if(b>=1e6) printf("%.0fM", b/1e6); else if(b>=1e3) printf("%.0fk", b/1e3); else printf("%db", b) }'
  # awk -v b="$RECEIVE_SPEED" 'BEGIN{ if(b>=1e6) printf("%.1fM", b/1e6); else if(b>=1e3) printf("%.1fk", b/1e3); else printf("%db", b) }'
)

TRANSMIT_SPEED_HUMAN=$(
  # Don't need decimals
  awk -v b="$TRANSMIT_SPEED" 'BEGIN{ if(b>=1e6) printf("%.0fM", b/1e6); else if(b>=1e3) printf("%.0fk", b/1e3); else printf("%db", b) }'
  # awk -v b="$TRANSMIT_SPEED" 'BEGIN{ if(b>=1e6) printf("%.1fM", b/1e6); else if(b>=1e3) printf("%.1fk", b/1e3); else printf("%db", b) }'
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
  ISPS_STATUS="${MAINGATEWAY} ${BACKGATEWAY_DISPLAY}$BACKUPISP_ARROW"
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
  ISPS_STATUS="${BACKGATEWAY_DISPLAY}$BACKUPISP_ARROW"
fi

DOWNLOAD_LABEL=" ${RECEIVE_SPEED_HUMAN}"
UPLOAD_LABEL=" ${TRANSMIT_SPEED_HUMAN}"

# The speed labels share one column. The download item owns the width and the
# zero-width upload item moves back to the start of that reserved column.
SPEED_CHAR_WIDTH=5
DOWNLOAD_LABEL_WIDTH=$((${#DOWNLOAD_LABEL} * SPEED_CHAR_WIDTH))
UPLOAD_LABEL_WIDTH=$((${#UPLOAD_LABEL} * SPEED_CHAR_WIDTH))
SPEED_COLUMN_WIDTH=$DOWNLOAD_LABEL_WIDTH
if [ $UPLOAD_LABEL_WIDTH -gt $SPEED_COLUMN_WIDTH ]; then
  SPEED_COLUMN_WIDTH=$UPLOAD_LABEL_WIDTH
fi

# Increase this value to add more space between the speed column and the next item.
SPEED_COLUMN_PADDING_RIGHT=5

DOWNLOAD_PADDING_RIGHT=$((SPEED_COLUMN_WIDTH - DOWNLOAD_LABEL_WIDTH + SPEED_COLUMN_PADDING_RIGHT))
UPLOAD_PADDING_LEFT=$((-(SPEED_COLUMN_WIDTH + SPEED_COLUMN_PADDING_RIGHT)))

sketchybar -m --set mikrotik \
  label="${ISPS_STATUS}" \
  icon= icon.color="$COLOR" \
  label.color="$COLOR" \
  \
  --set mikrotik.download \
  label="$DOWNLOAD_LABEL" \
  padding_right="$DOWNLOAD_PADDING_RIGHT" \
  label.color="$COLOR" \
  \
  --set mikrotik.upload \
  label="$UPLOAD_LABEL" \
  padding_left="$UPLOAD_PADDING_LEFT" \
  label.color="$COLOR"
