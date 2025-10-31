#!/usr/bin/env bash

# Switch to a kitty session by name or path

set -euo pipefail
session="$1"

sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1)"
/Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:${sock}" action goto_session "$session"
