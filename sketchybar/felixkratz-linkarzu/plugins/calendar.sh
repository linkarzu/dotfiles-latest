#!/bin/bash

sketchybar --set calendar.date label="$(date '+%a %y%m%d')" \
  --set calendar.time label="$(date '+%H:%M')"
