#!/usr/bin/env python3

# Script created by Linkarzu
# Feel free to modify, distribute it
# If you find it useful, you can support me at ko-fi https://ko-fi.com/linkarzu
# HACK: Video related to this script:
# https://youtu.be/mmdqzcL7lCU
# Blogpost article
# https://linkarzu.com/posts/tools/obs-scene-py/

# NOTE: If you have auth disabled in OBS, you can call this script with the
# --no-auth flag, so that it does not try to get the secret from 1password

import json
import os
import sys
import subprocess
import tempfile
import time
from pathlib import Path

from component_diagnostics import install_diagnostics

# --- Vars ---
onepassword_secret = "op://helixdeeznuts/obs-websocket-password/credential"
requirements = ["obsws-python"]
SCENE_SWITCH_TIMEOUT = 5.0
SCENE_SWITCH_POLL_INTERVAL = 0.1
OBS_REQUEST_TIMEOUT = 2.0
SKETCHYBAR_VERIFY_TIMEOUT = 5.0
DIAGNOSTIC_LOG_PATH = Path(
    "~/.cache/obs-meeting-manager/scene-switcher.log"
).expanduser()


# --- Auto-create and activate .venv ---
def ensure_venv():
    venv_path = os.path.join(os.path.dirname(__file__), ".venv")

    # If we're not in the venv already, and it doesn't exist, create it
    #
    if sys.prefix != venv_path:
        if not os.path.exists(venv_path):
            print("[+] Creating .venv and installing dependencies...")
            subprocess.check_call([sys.executable, "-m", "venv", venv_path])
            subprocess.check_call(
                [
                    os.path.join(venv_path, "bin", "python"),
                    "-m",
                    "pip",
                    "install",
                    "--upgrade",
                    "pip",
                ]
            )

            # Install embedded requirements
            subprocess.check_call(
                [os.path.join(venv_path, "bin", "pip"), "install"] + requirements
            )

        # Re-run this script inside the virtual environment
        python_executable = os.path.join(venv_path, "bin", "python")
        os.execv(python_executable, [python_executable] + sys.argv)


if __name__ == "__main__":
    ensure_venv()

# Don't move this above with other imports, leave it here, this has to be
# imported after creating the venv
import obsws_python as obs


def get_password():
    try:
        # Retrieve password from 1Password
        # NOTE: If you want to try the 1password-cli and want to support me
        # I have a 1password affiliate link in which you can get a 14 day free
        # trial, link below:
        # https://www.dpbolvw.net/click-101327218-15917064
        result = subprocess.check_output(
            ["op", "read", onepassword_secret],
            stderr=subprocess.STDOUT,
        )
        return result.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"Unable to retrieve OBS password from 1Password (op read exited {e.returncode})"
        ) from None


def sanitized_error(error, password):
    message = str(error)
    if password:
        message = message.replace(password, "[REDACTED]")
    return message


def create_obs_client(**kwargs):
    client = obs.ReqClient.__new__(obs.ReqClient)
    try:
        client.__init__(**kwargs)
    except Exception:
        try:
            client.disconnect()
        except Exception:
            pass
        raise
    return client


def current_program_scene(client):
    response = client.get_current_program_scene()
    return response.current_program_scene_name


def switch_scene(scene_name, timeout=None, poll_interval=None):
    host = "localhost"
    port = 4455
    timeout = SCENE_SWITCH_TIMEOUT if timeout is None else timeout
    poll_interval = SCENE_SWITCH_POLL_INTERVAL if poll_interval is None else poll_interval
    password = get_password() if "--no-auth" not in sys.argv else None
    # NOTE: I would strongly advise you against hardcoding the password here for
    # security reasons
    # In my case I use the 1password-cli tool to get the password, but if you
    # want to hardcode it anyway, comment the line above, and uncomment below
    # password = "ligmanutz"
    client = None

    primary_error = None
    try:
        client = create_obs_client(
            host=host,
            port=port,
            password=password,
            timeout=OBS_REQUEST_TIMEOUT,
        )
        print(
            "phase=scene-switch step=program-scene status=start "
            f"expected={scene_name} timeout_seconds={timeout:g} "
            f"request_timeout_seconds={OBS_REQUEST_TIMEOUT:g}"
        )
        request_error = None
        try:
            client.set_current_program_scene(scene_name)
        except Exception as e:
            request_error = e
            print(
                "phase=scene-switch step=program-scene status=uncertain "
                f"request_status=error error_type={type(e).__name__} "
                "action=reconcile-authoritative-obs-state"
            )

        deadline = time.monotonic() + timeout
        attempt = 0
        last_observed = "unavailable"
        last_query_error = None
        while True:
            attempt += 1
            try:
                last_observed = current_program_scene(client)
                last_query_error = None
            except Exception as e:
                last_observed = "unavailable"
                last_query_error = e
            if last_query_error is None and last_observed == scene_name:
                print(
                    "phase=scene-switch step=program-scene status=success "
                    f"attempt={attempt} expected={scene_name} observed={last_observed} "
                    f"request_status={'error-reconciled' if request_error else 'accepted'}"
                )
                break
            if time.monotonic() >= deadline:
                query_evidence = (
                    f"query_error_type={type(last_query_error).__name__}"
                    if last_query_error
                    else f"observed={last_observed}"
                )
                print(
                    "phase=scene-switch step=program-scene status=timeout "
                    f"attempt={attempt} expected={scene_name} {query_evidence} "
                    f"request_status={'error' if request_error else 'accepted'} "
                    f"request_error_type={type(request_error).__name__ if request_error else 'none'} "
                    f"timeout_seconds={timeout:g}",
                    file=sys.stderr,
                )
                raise RuntimeError(
                    "OBS program scene could not be authoritatively verified "
                    f"within {timeout:g} seconds."
                )
            if attempt == 1:
                query_evidence = (
                    f"query_error_type={type(last_query_error).__name__}"
                    if last_query_error
                    else f"observed={last_observed}"
                )
                print(
                    "phase=scene-switch step=program-scene status=waiting "
                    f"attempt={attempt} expected={scene_name} {query_evidence}"
                )
            time.sleep(poll_interval)
    except Exception as e:
        primary_error = e
        raise RuntimeError(sanitized_error(e, password)) from None
    finally:
        if client is not None:
            try:
                client.disconnect()
            except Exception as e:
                if primary_error is None:
                    raise RuntimeError(sanitized_error(e, password)) from None

    print(f"Switched to scene: {scene_name}")


def trigger_sketchybar_update(expected_label, *, step="banner"):
    trigger = subprocess.run(
        ["sketchybar", "--trigger", "custom_text_update"],
        capture_output=True,
        check=False,
        timeout=SKETCHYBAR_VERIFY_TIMEOUT,
    )
    if trigger.returncode:
        raise RuntimeError(
            f"SketchyBar trigger failed with exit status {trigger.returncode}."
        )

    deadline = time.monotonic() + SKETCHYBAR_VERIFY_TIMEOUT
    last_observed = "query-unavailable"
    while True:
        try:
            query = subprocess.run(
                ["sketchybar", "--query", "custom_text"],
                capture_output=True,
                text=True,
                check=False,
                timeout=min(1.0, SKETCHYBAR_VERIFY_TIMEOUT),
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
                    f"phase=scene-switch step={step} status=success "
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
        time.sleep(SCENE_SWITCH_POLL_INTERVAL)


def write_banner_atomic(banner_file, contents):
    directory = os.path.dirname(banner_file)
    descriptor, temporary_path = tempfile.mkstemp(
        prefix=f".{os.path.basename(banner_file)}.",
        suffix=".tmp",
        dir=directory,
    )
    try:
        with os.fdopen(descriptor, "wb") as temporary_file:
            temporary_file.write(contents)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.replace(temporary_path, banner_file)
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


def main():
    if len(sys.argv) < 2:
        print("Usage: python switch_scene.py 'Scene Name'")
        return 1

    scene_name = sys.argv[1]
    try:
        switch_scene(scene_name)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        return 1

    # If the banner file exists:
    # - Save the scene name to the file
    # - Update the SketchyBar label with the scene name
    # This ensures no sketchybar commands are triggered for users without that
    # don't use SketchyBar
    banner_file = os.path.expanduser("~/github/dotfiles-latest/youtube-banner.txt")
    if os.path.exists(banner_file):
        try:
            with open(banner_file, "rb") as existing_banner:
                previous_contents = existing_banner.read()
            previous_label = previous_contents.decode("utf-8")
        except Exception:
            print(
                f"Partial failure: OBS switched to scene '{scene_name}', but the prior "
                "banner marker could not be read; no banner change was attempted.",
                file=sys.stderr,
            )
            return 1
        try:
            write_banner_atomic(banner_file, scene_name.encode("utf-8"))
        except Exception:
            print(
                f"Partial failure: OBS switched to scene '{scene_name}', but the banner "
                "file could not be written; SketchyBar was not updated.",
                file=sys.stderr,
            )
            return 1

        # Let the SketchyBar plugin compute colors, padding, and stream time.
        try:
            trigger_sketchybar_update(scene_name)
        except Exception as e:
            rollback_error = "none"
            try:
                write_banner_atomic(banner_file, previous_contents)
                marker_restored = True
            except Exception as rollback_exception:
                marker_restored = False
                rollback_error = (
                    f"marker-restore-error-{type(rollback_exception).__name__}"
                )
            sketchybar_restored = False
            if marker_restored:
                try:
                    trigger_sketchybar_update(previous_label, step="banner-rollback")
                    sketchybar_restored = True
                except Exception as rollback_exception:
                    rollback_error = str(rollback_exception)
            rollback = (
                "success"
                if marker_restored and sketchybar_restored
                else "failure-unverified"
            )
            print(
                "phase=scene-switch step=banner status=failure "
                f"evidence={json.dumps(str(e))} rollback={rollback} "
                f"marker_restored={str(marker_restored).lower()} "
                f"sketchybar_restored={str(sketchybar_restored).lower()} "
                f"rollback_evidence={json.dumps(rollback_error)}",
                file=sys.stderr,
            )
            return 1

    return 0


if __name__ == "__main__":
    diagnostics = install_diagnostics("scene-switcher", DIAGNOSTIC_LOG_PATH)
    try:
        exit_status = main()
    except BaseException as error:
        diagnostics.finish("failure", 1, error_type=type(error).__name__)
        diagnostics.close()
        raise
    diagnostics.finish("success" if exit_status == 0 else "failure", exit_status)
    diagnostics.close()
    sys.exit(exit_status)
