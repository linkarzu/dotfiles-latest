#!/usr/bin/env python3

"""Switch to the YouTube members scene or advance its active overlay page."""

import argparse
import fcntl
import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Optional
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from component_diagnostics import install_diagnostics


HERE = Path(__file__).resolve().parent
VENV_PATH = HERE / ".venv"
SCENE_NAME = "youtube-members"
PAGE_COUNT = 2
BROWSER_SOURCE_NAME = "members"
PAGE_NAMES = ("premium", "members")
OBS_REQUEST_TIMEOUT = 2.0
VERIFY_TIMEOUT = 5.0
POLL_INTERVAL = 0.1
SKETCHYBAR_VERIFY_TIMEOUT = 5.0
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
DIAGNOSTIC_LOG_PATH = Path(
    "~/.cache/obs-meeting-manager/youtube-members-scene.log"
).expanduser()


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
    try:
        result = subprocess.check_output(
            ["op", "read", ONEPASSWORD_SECRET],
            stderr=subprocess.STDOUT,
        )
    except subprocess.CalledProcessError as error:
        raise RuntimeError(
            "Unable to retrieve the OBS password from 1Password "
            f"(exit_status={error.returncode})."
        ) from None
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


def input_settings(client) -> dict:
    response = client.get_input_settings(name=BROWSER_SOURCE_NAME)
    settings = getattr(response, "input_settings", None)
    if not isinstance(settings, dict):
        data = response.to_dict() if hasattr(response, "to_dict") else vars(response)
        settings = data.get("inputSettings") or data.get("input_settings")
    if not isinstance(settings, dict):
        raise RuntimeError("OBS browser input settings are unavailable.")
    return settings


def browser_url(client) -> str:
    url = input_settings(client).get("url")
    if not isinstance(url, str) or not url:
        raise RuntimeError("OBS members browser input URL is unavailable.")
    return url


def page_url(url: str, page: int, overlay_mtime: int) -> str:
    parts = urlsplit(url)
    query = dict(parse_qsl(parts.query, keep_blank_values=True))
    query.update(page=PAGE_NAMES[page], overlay_mtime=str(overlay_mtime))
    return urlunsplit((parts.scheme, parts.netloc, parts.path, urlencode(query), parts.fragment))


def set_and_verify_browser_page(
    client,
    page: int,
    overlay_mtime: int,
    *,
    timeout: Optional[float] = None,
    poll_interval: Optional[float] = None,
) -> None:
    timeout = VERIFY_TIMEOUT if timeout is None else timeout
    poll_interval = POLL_INTERVAL if poll_interval is None else poll_interval
    target_url = page_url(browser_url(client), page, overlay_mtime)
    print(
        "phase=members-scene step=browser-page status=start "
        f"expected_page={page} overlay_mtime={overlay_mtime} timeout_seconds={timeout:g}"
    )
    request_error = None
    try:
        client.set_input_settings(
            name=BROWSER_SOURCE_NAME,
            settings={"url": target_url},
            overlay=True,
        )
    except Exception as error:
        request_error = error
        print(
            "phase=members-scene step=browser-page status=uncertain "
            f"error_type={type(error).__name__} action=reconcile-obs-input-settings"
        )
    deadline = time.monotonic() + timeout
    attempt = 0
    last_observed = "unavailable"
    last_error = None
    while True:
        attempt += 1
        try:
            last_observed = browser_url(client)
            last_error = None
        except Exception as error:
            last_error = error
        if last_error is None and last_observed == target_url:
            print(
                "phase=members-scene step=browser-page status=success "
                f"attempt={attempt} observed_page={page} verification=obs-input-url "
                f"request_status={'error-reconciled' if request_error else 'accepted'}"
            )
            return
        if time.monotonic() >= deadline:
            evidence = (
                f"query_error_type={type(last_error).__name__}"
                if last_error
                else "observed_url_mismatch=true"
            )
            print(
                "phase=members-scene step=browser-page status=timeout "
                f"attempt={attempt} expected_page={page} {evidence} "
                f"request_error_type={type(request_error).__name__ if request_error else 'none'} "
                f"timeout_seconds={timeout:g}",
                file=sys.stderr,
            )
            raise RuntimeError("OBS members browser page could not be authoritatively verified.")
        if attempt == 1:
            print(
                "phase=members-scene step=browser-page status=waiting "
                f"attempt={attempt} expected_page={page}"
            )
        time.sleep(poll_interval)


def set_and_verify_scene(
    client,
    *,
    current_scene: Optional[str] = None,
    timeout: Optional[float] = None,
    poll_interval: Optional[float] = None,
) -> bool:
    timeout = VERIFY_TIMEOUT if timeout is None else timeout
    poll_interval = POLL_INTERVAL if poll_interval is None else poll_interval
    if current_scene is None:
        current_scene = client.get_current_program_scene().current_program_scene_name
    if current_scene == SCENE_NAME:
        print(
            "phase=members-scene step=program-scene status=success "
            f"attempt=1 observed={SCENE_NAME} action=verified-no-op"
        )
        return False
    print(
        "phase=members-scene step=program-scene status=start "
        f"expected={SCENE_NAME} timeout_seconds={timeout:g}"
    )
    request_error = None
    try:
        client.set_current_program_scene(SCENE_NAME)
    except Exception as error:
        request_error = error
        print(
            "phase=members-scene step=program-scene status=uncertain "
            f"error_type={type(error).__name__} action=reconcile-authoritative-obs-state"
        )
    deadline = time.monotonic() + timeout
    attempt = 0
    last_observed = current_scene
    last_error = None
    while True:
        attempt += 1
        try:
            last_observed = client.get_current_program_scene().current_program_scene_name
            last_error = None
        except Exception as error:
            last_error = error
        if last_error is None and last_observed == SCENE_NAME:
            print(
                "phase=members-scene step=program-scene status=success "
                f"attempt={attempt} observed={SCENE_NAME} "
                f"request_status={'error-reconciled' if request_error else 'accepted'}"
            )
            return True
        if time.monotonic() >= deadline:
            evidence = (
                f"query_error_type={type(last_error).__name__}"
                if last_error
                else f"observed={last_observed}"
            )
            print(
                "phase=members-scene step=program-scene status=timeout "
                f"attempt={attempt} expected={SCENE_NAME} {evidence} "
                f"request_error_type={type(request_error).__name__ if request_error else 'none'} "
                f"timeout_seconds={timeout:g}",
                file=sys.stderr,
            )
            raise RuntimeError("OBS members scene could not be authoritatively verified.")
        if attempt == 1:
            print(
                "phase=members-scene step=program-scene status=waiting "
                f"attempt={attempt} observed={last_observed}"
            )
        time.sleep(poll_interval)


def refresh_overlay_if_needed(client) -> bool:
    latest_csv = latest_members_csv()
    if overlay_needs_regeneration(latest_csv):
        regenerate_overlay()

    overlay_mtime = MEMBERS_HTML_PATH.stat().st_mtime_ns
    if read_loaded_overlay_mtime() == overlay_mtime:
        return False

    set_and_verify_browser_page(client, 0, overlay_mtime)
    write_loaded_overlay_mtime(overlay_mtime)
    print(
        "phase=members-scene step=overlay-refresh status=success "
        f"overlay_mtime={overlay_mtime} verification=obs-input-url"
    )
    return True


def handle_press(client, overlay_refreshed: bool = False) -> tuple[int, bool]:
    current_scene = client.get_current_program_scene().current_program_scene_name
    overlay_mtime = MEMBERS_HTML_PATH.stat().st_mtime_ns
    if current_scene != SCENE_NAME:
        page = 0
        if not overlay_refreshed:
            set_and_verify_browser_page(client, page, overlay_mtime)
        switched_scene = set_and_verify_scene(client, current_scene=current_scene)
        print(f"[+] Switched to {SCENE_NAME} on page 1")
    else:
        switched_scene = set_and_verify_scene(client, current_scene=current_scene)
        if overlay_refreshed:
            page = 0
            print(f"[+] Reset {SCENE_NAME} to page 1 after refresh")
        else:
            page = (read_page() + 1) % PAGE_COUNT
            set_and_verify_browser_page(client, page, overlay_mtime)
            print(f"[+] Set {SCENE_NAME} to page {page + 1}")
    write_page(page)
    return page, switched_scene


def write_banner_atomic(contents: bytes) -> None:
    descriptor, temporary_path = tempfile.mkstemp(
        prefix=f".{BANNER_PATH.name}.",
        suffix=".tmp",
        dir=BANNER_PATH.parent,
    )
    try:
        with os.fdopen(descriptor, "wb") as temporary_file:
            temporary_file.write(contents)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.replace(temporary_path, BANNER_PATH)
    except Exception:
        try:
            os.close(descriptor)
        except OSError:
            pass
        try:
            os.unlink(temporary_path)
        except OSError:
            pass
        raise


def trigger_and_verify_banner(
    expected_label: str,
    timeout: Optional[float] = None,
    *,
    step: str = "banner",
) -> None:
    timeout = SKETCHYBAR_VERIFY_TIMEOUT if timeout is None else timeout
    try:
        trigger = subprocess.run(
            ["sketchybar", "--trigger", "custom_text_update"],
            capture_output=True,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        raise RuntimeError(
            f"SketchyBar banner trigger failed ({type(error).__name__})."
        ) from None
    if trigger.returncode:
        raise RuntimeError(
            f"SketchyBar banner trigger failed with exit status {trigger.returncode}."
        )

    deadline = time.monotonic() + timeout
    last_observed = "query-unavailable"
    while True:
        try:
            query = subprocess.run(
                ["sketchybar", "--query", "custom_text"],
                capture_output=True,
                text=True,
                timeout=min(1.0, timeout),
                check=False,
            )
            payload = json.loads(query.stdout) if query.returncode == 0 else {}
            icon_drawing = payload.get("icon", {}).get("drawing")
            label_drawing = payload.get("label", {}).get("drawing")
            label = payload.get("label", {}).get("value")
            label_matches = label == expected_label
            last_observed = (
                f"icon-drawing-{icon_drawing} label-drawing-{label_drawing} "
                f"label-matches-{str(label_matches).lower()}"
            )
            if (
                (icon_drawing is True or icon_drawing == "on")
                and (label_drawing is True or label_drawing == "on")
                and label_matches
            ):
                print(
                    f"phase=members-scene step={step} status=success "
                    "observed=sketchybar-icon-and-label-drawing-on-and-label-matched"
                )
                return
        except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError) as error:
            last_observed = f"query-error-{type(error).__name__}"
        if time.monotonic() >= deadline:
            raise RuntimeError(
                "SketchyBar banner state could not be verified "
                f"({last_observed})."
            )
        time.sleep(POLL_INTERVAL)


def update_banner() -> None:
    if not BANNER_PATH.exists():
        return
    previous_contents = BANNER_PATH.read_bytes()
    previous_label = previous_contents.decode("utf-8")
    print(
        "phase=members-scene step=banner status=start "
        "expected=atomic-marker-published-and-sketchybar-icon-and-label-drawing-on"
    )
    try:
        write_banner_atomic(SCENE_NAME.encode("utf-8"))
        trigger_and_verify_banner(SCENE_NAME)
    except Exception as error:
        rollback_error = "none"
        try:
            write_banner_atomic(previous_contents)
            marker_restored = True
        except Exception as rollback_exception:
            marker_restored = False
            rollback_error = f"marker-restore-error-{type(rollback_exception).__name__}"
        sketchybar_restored = False
        if marker_restored:
            try:
                trigger_and_verify_banner(previous_label, step="banner-rollback")
                sketchybar_restored = True
            except Exception as rollback_exception:
                rollback_error = str(rollback_exception)
        rollback = (
            "success"
            if marker_restored and sketchybar_restored
            else "failure-unverified"
        )
        print(
            "phase=members-scene step=banner status=failure "
            f"error_type={type(error).__name__} "
            f"evidence={json.dumps(str(error) if str(error).startswith('SketchyBar ') else 'detail-redacted')} "
            f"rollback={rollback} "
            f"marker_restored={str(marker_restored).lower()} "
            f"sketchybar_restored={str(sketchybar_restored).lower()} "
            f"rollback_evidence={json.dumps(rollback_error)}",
            file=sys.stderr,
        )
        raise RuntimeError(
            "Members banner publication could not be authoritatively verified."
        ) from None


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-auth", action="store_true", help="Connect without an OBS WebSocket password")
    args = parser.parse_args()

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    with LOCK_PATH.open("w", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file, fcntl.LOCK_EX)
        password = None if args.no_auth else get_password()
        client = obs.ReqClient(
            host="localhost",
            port=4455,
            password=password,
            timeout=OBS_REQUEST_TIMEOUT,
        )
        try:
            overlay_refreshed = refresh_overlay_if_needed(client)
            handle_press(client, overlay_refreshed=overlay_refreshed)
            update_banner()
        finally:
            client.disconnect()


if __name__ == "__main__":
    diagnostics = install_diagnostics(
        "youtube-members-scene",
        DIAGNOSTIC_LOG_PATH,
    )
    try:
        main()
    except BaseException as error:
        diagnostics.finish("failure", 1, error_type=type(error).__name__)
        diagnostics.close()
        raise
    diagnostics.finish("success", 0)
    diagnostics.close()
