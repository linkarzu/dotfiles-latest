#!/usr/bin/env bash

pid=$(ps -A | grep -v 'grep' | grep -v 'sh' | grep ~/.config/sketchybar/plugins/timer.py | cut -d ' ' -f 1)
kill ${pid}

sketchybar --set timer label=""
