#!/usr/bin/env python3

import argparse
import datetime
import os
import plistlib
import subprocess
import sys
import tempfile
import time
from pathlib import Path


WALLPAPER_INDEX = Path.home() / "Library/Application Support/com.apple.wallpaper/Store/Index.plist"
IMAGE_PROVIDER = "com.apple.wallpaper.choice.image"


class WallpaperError(Exception):
    pass


def shared_image_choices(store):
    if store.get("Spaces") != {} or store.get("Displays") != {}:
        raise WallpaperError(
            'macOS is not using "Show on all Spaces"; enable it once in Wallpaper settings'
        )

    result = []
    for section_name in ("AllSpacesAndDisplays", "SystemDefault"):
        section = store.get(section_name)
        if not isinstance(section, dict) or section.get("Type") != "individual":
            raise WallpaperError(f"unexpected {section_name} wallpaper configuration")

        desktop = section.get("Desktop")
        content = desktop.get("Content") if isinstance(desktop, dict) else None
        choices = content.get("Choices") if isinstance(content, dict) else None
        if not isinstance(choices, list):
            raise WallpaperError(f"missing {section_name} desktop choices")

        choice = next(
            (
                item
                for item in choices
                if isinstance(item, dict) and item.get("Provider") == IMAGE_PROVIDER
            ),
            None,
        )
        if choice is None or not isinstance(choice.get("Configuration"), bytes):
            raise WallpaperError(f"missing {section_name} image wallpaper configuration")

        result.append((desktop, choice))

    return result


def atomic_write(path, data, mode):
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as temporary_file:
            temporary_file.write(data)
            temporary_file.flush()
            os.fsync(temporary_file.fileno())
        os.chmod(temporary_name, mode)
        os.replace(temporary_name, path)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)


def restart_wallpaper_agent():
    subprocess.run(
        ["/usr/bin/killall", "WallpaperAgent"],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )


def main():
    parser = argparse.ArgumentParser(description="Set one image on all macOS Spaces")
    parser.add_argument("image", help="path to the wallpaper image")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="validate the image and wallpaper store without changing them",
    )
    args = parser.parse_args()

    image = Path(args.image).expanduser().resolve()
    if not image.is_file():
        raise WallpaperError(f"wallpaper does not exist: {image}")
    if not WALLPAPER_INDEX.is_file():
        raise WallpaperError(f"wallpaper store does not exist: {WALLPAPER_INDEX}")

    original_data = WALLPAPER_INDEX.read_bytes()
    store = plistlib.loads(original_data)
    choices = shared_image_choices(store)
    image_url = image.as_uri()

    now = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)
    for desktop, choice in choices:
        choice["Files"] = [{"relative": image_url}]
        desktop["LastSet"] = now
        desktop["LastUse"] = now

    if args.dry_run:
        print(f"Wallpaper store is ready for: {image}")
        return

    mode = WALLPAPER_INDEX.stat().st_mode & 0o777
    backup_path = WALLPAPER_INDEX.with_name(
        f"{WALLPAPER_INDEX.name}.colorscheme-selector-backup"
    )
    updated_data = plistlib.dumps(store, fmt=plistlib.FMT_BINARY, sort_keys=False)

    atomic_write(backup_path, original_data, mode)
    atomic_write(WALLPAPER_INDEX, updated_data, mode)

    try:
        restart_wallpaper_agent()
        time.sleep(1)

        applied_store = plistlib.loads(WALLPAPER_INDEX.read_bytes())
        applied_choices = shared_image_choices(applied_store)
        if any(
            choice.get("Files") != [{"relative": image_url}]
            for _, choice in applied_choices
        ):
            raise WallpaperError("WallpaperAgent did not retain the requested wallpaper")
    except Exception:
        atomic_write(WALLPAPER_INDEX, original_data, mode)
        try:
            restart_wallpaper_agent()
        except subprocess.CalledProcessError:
            pass
        raise

    print(f"Wallpaper set on all Spaces: {image}")
    print(f"Previous wallpaper store backed up to: {backup_path}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, plistlib.InvalidFileException, subprocess.CalledProcessError, WallpaperError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
