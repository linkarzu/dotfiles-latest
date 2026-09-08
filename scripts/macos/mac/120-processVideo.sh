#!/usr/bin/env bash
# Compatibility entry point for the FFmpeg Clips workflow.
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}"
export FFMPEG_CLIPS_ROOT="${FFMPEG_CLIPS_ROOT:-$HOME/github/ffmpeg-clips}"
export FFMPEG_CLIPS_SCRIPTS="${FFMPEG_CLIPS_SCRIPTS:-$FFMPEG_CLIPS_ROOT/scripts}"
export FFMPEG_CLIPS_MEDIA_REQUEST="${FFMPEG_CLIPS_MEDIA_REQUEST:-$FFMPEG_CLIPS_SCRIPTS/media-request/media-request.py}"
exec "$FFMPEG_CLIPS_SCRIPTS/run-workflow.sh" "$@"
