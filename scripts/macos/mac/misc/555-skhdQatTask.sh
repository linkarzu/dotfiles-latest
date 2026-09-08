#!/usr/bin/env bash

set -euo pipefail

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
export OBS_MEETING_MANAGER_ROOT="${OBS_MEETING_MANAGER_ROOT:-$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager}"
export FFMPEG_CLIPS_ROOT="${FFMPEG_CLIPS_ROOT:-$HOME/github/ffmpeg-clips}"
export FFMPEG_CLIPS_SCRIPTS="${FFMPEG_CLIPS_SCRIPTS:-$FFMPEG_CLIPS_ROOT/scripts}"
export FFMPEG_CLIPS_MEDIA_REQUEST="${FFMPEG_CLIPS_MEDIA_REQUEST:-$FFMPEG_CLIPS_SCRIPTS/media-request/media-request.py}"
socket_dir="${TMPDIR:-/tmp}"
export FZF_AI_SOCKET="${FZF_AI_SOCKET:-${socket_dir%/}/linkarzu-system-task-fzf.sock}"
export KITTY_BIN="${KITTY_BIN:-/Applications/kitty.app/Contents/MacOS/kitty}"
KITTY_SOCKET="$("$DOTFILES_DIR/scripts/macos/mac/misc/549-kittyMainSocket.sh")"
export KITTY_SOCKET

# A detached launch otherwise uses the long-running Kitty server's environment.
# Remove unset optional values too, so a stale runtime cannot supply them.
launch_env=(--env "PYTHONPATH=$FFMPEG_CLIPS_SCRIPTS" --env BASH_ENV --env ENV)
for name in PATH HOME TMPDIR DOTFILES_DIR OBS_MEETING_MANAGER_ROOT \
  FFMPEG_CLIPS_ROOT FFMPEG_CLIPS_SCRIPTS FFMPEG_CLIPS_MEDIA_REQUEST \
  FFMPEG_CLIPS_RUNTIME_ID FFMPEG_CLIPS_PYTHON FZF_AI_SOCKET FZF_DEFAULT_OPTS \
  FFMPEG_CLIPS_DASHBOARD_ROOT FFMPEG_CLIPS_DASHBOARD_PUBLIC_URL \
  FFMPEG_CLIPS_LIVESTREAM_ROOT FFMPEG_CLIPS_RENDER_LOCK \
  OBS_MEETING_MANAGER_DATA_DIR OBS_MEETING_MANAGER_LIVESTREAM_ROOT \
  XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME HF_HOME HUGGINGFACE_HUB_CACHE \
  TORCH_HOME FFMPEG_BIN FFPROBE_BIN FONTCONFIG_FILE FONTCONFIG_PATH \
  KITTY_BIN KITTY_SOCKET QAT_INSTANCE_GROUP QAT_KITTY_CONFIG; do
  if [[ -n "${!name:-}" ]]; then
    launch_env+=(--env "$name=${!name}")
  else
    launch_env+=(--env "$name")
  fi
done

qat_options=(--config "$DOTFILES_DIR/kitty/quick-access-terminal-center.conf")
if [[ -n "${QAT_KITTY_CONFIG:-}" ]]; then
  qat_options+=(--override "kitty_conf=$QAT_KITTY_CONFIG")
fi

"$KITTY_BIN" @ --to "unix:${KITTY_SOCKET}" \
  launch --type=background "${launch_env[@]}" kitten quick-access-terminal "${qat_options[@]}" \
  --instance-group "${QAT_INSTANCE_GROUP:-system-task}" /bin/bash "$DOTFILES_DIR/scripts/macos/mac/misc/240-systemTask.sh"
