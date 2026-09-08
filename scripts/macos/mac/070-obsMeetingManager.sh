#!/usr/bin/env bash

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}"
export OBS_MEETING_MANAGER_ROOT="${OBS_MEETING_MANAGER_ROOT:-$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager}"
export FFMPEG_CLIPS_ROOT="${FFMPEG_CLIPS_ROOT:-$HOME/github/ffmpeg-clips}"
export FFMPEG_CLIPS_SCRIPTS="${FFMPEG_CLIPS_SCRIPTS:-$FFMPEG_CLIPS_ROOT/scripts}"
export FFMPEG_CLIPS_MEDIA_REQUEST="${FFMPEG_CLIPS_MEDIA_REQUEST:-$FFMPEG_CLIPS_SCRIPTS/media-request/media-request.py}"

exec python3 \
  "$OBS_MEETING_MANAGER_ROOT/scripts/macos/mac/obs/meeting/py/meeting_manager.py" \
  "$@"
