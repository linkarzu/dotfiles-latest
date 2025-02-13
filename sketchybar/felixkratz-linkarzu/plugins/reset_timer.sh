#!/usr/bin/env bash

pid=$(ps -A | grep -v 'grep' | grep -v 'sh' | grep ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/timer.py | cut -d ' ' -f 1)
kill ${pid}

sketchybar --set timer label=""
