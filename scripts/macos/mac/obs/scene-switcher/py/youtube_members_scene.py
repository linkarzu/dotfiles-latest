#!/usr/bin/env python3

"""Switch to the YouTube members scene or advance its active overlay page."""

import argparse
import fcntl
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Optional


HERE = Path(__file__).resolve().parent
VENV_PATH = HERE / ".venv"
SCENE_NAME = "youtube-members"
PAGE_COUNT = 2
PAGE_EVENT = "youtube-members-show-page"
BROWSER_SOURCE_NAME = "members"
CACHE_DIR = Path("~/.cache/obs-youtube-members").expanduser()
PAGE_STATE_PATH = CACHE_DIR / "page.txt"
LOADED_OVERLAY_MTIME_PATH = CACHE_DIR / "loaded-overlay-mtime.txt"
LOCK_PATH = CACHE_DIR / "page.lock"
BANNER_PATH = Path("~/github/dotfiles-latest/youtube-banner.txt").expanduser()
MEMBERS_OVERLAY_DIR = Path(
    "~/github/dotfiles-private/scripts/macos/mac/obs-meeting-manager/scripts/macos/mac/yt-members-overlay"
).expanduser()
MEMBERS_GENERATOR_PATH = MEMBERS_OVERLAY_DIR / "member_overlay.py"
MEMBERS_OUTPUT_DIR = Path(
    os.environ.get(
        "OBS_MEETING_MANAGER_OVERLAY_DIR",
        "~/Library/Application Support/obs-meeting-manager/member-overlay",
    )
).expanduser()
MEMBERS_JSON_PATH = MEMBERS_OUTPUT_DIR / "members.json"
MEMBERS_HTML_PATH = MEMBERS_OUTPUT_DIR / "index.html"
DOWNLOADS_DIR = Path("~/Downloads").expanduser()
ONEPASSWORD_SECRET = "op://helixdeeznuts/obs-websocket-password/credential"


def ensure_venv() -> None:
    if Path(sys.prefix) == VENV_PATH:
        return
    if not VENV_PATH.exists():
        subprocess.check_call([sys.executable, "-m", "venv", str(VENV_PATH)])
        subprocess.check_call([str(VENV_PATH / "bin" / "pip"), "install", "obsws-python"])
    python_executable = VENV_PATH / "bin" / "python"
    os.execv(str(python_executable), [str(python_executable)] + sys.argv)


ensure_venv()

import obsws_python as obs


def get_password() -> str:
    result = subprocess.check_output(
        ["op", "read", ONEPASSWORD_SECRET],
        stderr=subprocess.STDOUT,
    )
    return result.decode("utf-8").strip()


def read_page() -> int:
    try:
        page = int(PAGE_STATE_PATH.read_text(encoding="utf-8").strip())
    except (FileNotFoundError, ValueError):
        return 0
    return page if 0 <= page < PAGE_COUNT else 0


def write_page(page: int) -> None:
    temporary_path = PAGE_STATE_PATH.with_suffix(".tmp")
    temporary_path.write_text(f"{page}\n", encoding="utf-8")
    temporary_path.replace(PAGE_STATE_PATH)


def latest_members_csv() -> Path:
    files = list(DOWNLOADS_DIR.glob("Your members *.csv"))
    if not files:
        raise FileNotFoundError(f"No 'Your members *.csv' export found in {DOWNLOADS_DIR}")
    return max(files, key=lambda path: path.stat().st_mtime_ns)


def generated_csv_path() -> Optional[Path]:
    try:
        payload = json.loads(MEMBERS_JSON_PATH.read_text(encoding="utf-8"))
        source_csv = payload.get("sourceCsv")
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return None
    return Path(source_csv).expanduser() if isinstance(source_csv, str) and source_csv else None


def overlay_needs_regeneration(latest_csv: Path) -> bool:
    generated_csv = generated_csv_path()
    if generated_csv is None or generated_csv.resolve() != latest_csv.resolve():
        return True
    try:
        return latest_csv.stat().st_mtime_ns > MEMBERS_JSON_PATH.stat().st_mtime_ns
    except OSError:
        return True


def regenerate_overlay() -> None:
    print(f"[+] Regenerating members overlay from {latest_members_csv().name}")
    subprocess.run([sys.executable, str(MEMBERS_GENERATOR_PATH)], check=True)


def read_loaded_overlay_mtime() -> Optional[int]:
    try:
        return int(LOADED_OVERLAY_MTIME_PATH.read_text(encoding="utf-8").strip())
    except (FileNotFoundError, ValueError, OSError):
        return None


def write_loaded_overlay_mtime(mtime_ns: int) -> None:
    temporary_path = LOADED_OVERLAY_MTIME_PATH.with_suffix(".tmp")
    temporary_path.write_text(f"{mtime_ns}\n", encoding="utf-8")
    temporary_path.replace(LOADED_OVERLAY_MTIME_PATH)


def refresh_overlay_if_needed(client) -> bool:
    latest_csv = latest_members_csv()
    if overlay_needs_regeneration(latest_csv):
        regenerate_overlay()

    overlay_mtime = MEMBERS_HTML_PATH.stat().st_mtime_ns
    if read_loaded_overlay_mtime() == overlay_mtime:
        return False

    client.press_input_properties_button(BROWSER_SOURCE_NAME, "refreshnocache")
    write_loaded_overlay_mtime(overlay_mtime)
    print(f"[+] Reloaded OBS browser source: {BROWSER_SOURCE_NAME}")
    return True


def handle_press(client, overlay_refreshed: bool = False) -> tuple[int, bool]:
    response = client.get_current_program_scene()
    current_scene = response.current_program_scene_name
    if current_scene != SCENE_NAME:
        client.set_current_program_scene(SCENE_NAME)
        page = 0
        switched_scene = True
        print(f"[+] Switched to {SCENE_NAME} on page 1")
    elif overlay_refreshed:
        page = 0
        switched_scene = False
        print(f"[+] Reset {SCENE_NAME} to page 1 after refresh")
    else:
        page = (read_page() + 1) % PAGE_COUNT
        client.call_vendor_request(
            "obs-browser",
            "emit_event",
            {
                "event_name": PAGE_EVENT,
                "event_data": {"scene_name": SCENE_NAME, "page": page},
            },
        )
        switched_scene = False
        print(f"[+] Set {SCENE_NAME} to page {page + 1}")
    write_page(page)
    return page, switched_scene


def update_banner() -> None:
    if not BANNER_PATH.exists():
        return
    BANNER_PATH.write_text(SCENE_NAME, encoding="utf-8")
    subprocess.run(["sketchybar", "--trigger", "custom_text_update"], check=False)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-auth", action="store_true", help="Connect without an OBS WebSocket password")
    args = parser.parse_args()

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    with LOCK_PATH.open("w", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file, fcntl.LOCK_EX)
        password = None if args.no_auth else get_password()
        client = obs.ReqClient(host="localhost", port=4455, password=password)
        try:
            overlay_refreshed = refresh_overlay_if_needed(client)
            handle_press(client, overlay_refreshed=overlay_refreshed)
            update_banner()
        finally:
            client.disconnect()


if __name__ == "__main__":
    main()
