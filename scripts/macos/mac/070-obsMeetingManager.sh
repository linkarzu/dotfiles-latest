#!/usr/bin/env bash

export DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)}"
export OBS_MEETING_MANAGER_ROOT="${OBS_MEETING_MANAGER_ROOT:-$HOME/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager}"
export FFMPEG_CLIPS_ROOT="${FFMPEG_CLIPS_ROOT:-$HOME/github/ffmpeg-clips}"
export FFMPEG_CLIPS_SCRIPTS="${FFMPEG_CLIPS_SCRIPTS:-$FFMPEG_CLIPS_ROOT/scripts}"
export FFMPEG_CLIPS_MEDIA_REQUEST="${FFMPEG_CLIPS_MEDIA_REQUEST:-$FFMPEG_CLIPS_SCRIPTS/media-request/media-request.py}"

manager_dir="$OBS_MEETING_MANAGER_ROOT/scripts/macos/mac/obs/meeting/py"
venv_python="$manager_dir/.venv/bin/python"
requirements_marker="$manager_dir/.venv/.requirements.sha256"

# Start in the venv when its pinned requirements are installed; otherwise
# python3 lets meeting_manager.py create or update the venv first.
python="python3"
if [[ -x "$venv_python" && -f "$requirements_marker" ]] &&
  [[ "$(<"$requirements_marker")" == "$(shasum -a 256 "$manager_dir/requirements.txt" | cut -d' ' -f1)" ]]; then
  python="$venv_python"
fi

exec "$python" "$manager_dir/meeting_manager.py" "$@"
