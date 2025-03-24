#!/usr/bin/env bash

# I (linkarzu) did not come up with this script, It's a slightly modified
# version of https://gist.github.com/dhulihan/4c65e868851660fb0d8bfa2d059e7967
# by github user dhulihan

# NOTE: My YouTube video related to this script:
# Tmux Cleanup Session Script | Automatically Kill Unused Tmux Sessions
# https://youtu.be/3axjsVR7QfA

# If I do not add this, the script will not find tmux or any other apps in
# the /opt/homebrew/bin dir. So it will not run the tmux ls command
export PATH="/opt/homebrew/bin:$PATH"

# I make this slightly lower than the LaunchAgent interval
TOO_OLD_THRESHOLD_MIN=110
TMUX_LOG_PATH="/tmp/tmuxKillSessions.log"

NOW=$(($(date +%s)))

tmux ls -F '#{session_name} #{session_activity}' | while read -r LINE; do
  SESSION_NAME=$(echo $LINE | awk '{print $1}')
  LAST_ACTIVITY=$(echo $LINE | awk '{print $2}')
  LAST_ACTIVITY_MINS_ELAPSED=$(((NOW - LAST_ACTIVITY) / 60))
  # # print all sessions
  # echo "${SESSION_NAME} is ${LAST_ACTIVITY_MINS_ELAPSED}min"

  if [[ "$LAST_ACTIVITY_MINS_ELAPSED" -gt "$TOO_OLD_THRESHOLD_MIN" ]]; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$TIMESTAMP - Killed session: $SESSION_NAME (Inactive for ${LAST_ACTIVITY_MINS_ELAPSED}min)" | tee -a $TMUX_LOG_PATH
    tmux kill-session -t ${SESSION_NAME}
    # In case you want to test the script without killing sessions, comment the 2 lines above and uncomment below
    # echo "${SESSION_NAME} is ${LAST_ACTIVITY_MINS_ELAPSED}min inactive and would be killed."
  fi
done
