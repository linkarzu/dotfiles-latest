#!/usr/bin/env python3

# Script created by Linkarzu
# Feel free to modify, distribute it
# If you find it useful, you can support me at ko-fi https://ko-fi.com/linkarzu
# HACK: Video related to this script:
# https://youtu.be/mmdqzcL7lCU
# Blogpost article
# https://linkarzu.com/posts/tools/obs-scene-py/

import os
import sys
import subprocess
import obsws_python as obs

# --- Vars ---
onepassword_secret = "op://helixdeeznuts/obs-websocket-password/credential"
requirements = ["obsws-python"]


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


ensure_venv()


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
        print(f"1Password Error: {e.output.decode().strip()}")
        sys.exit(1)


def switch_scene(scene_name):
    host = "localhost"
    port = 4455
    password = get_password() if "--no-auth" not in sys.argv else None
    # NOTE: I would strongly advise you against hardcoding the password here for
    # security reasons
    # In my case I use the 1password-cli tool to get the password, but if you
    # want to hardcode it anyway, comment the line above, and uncomment below
    # password = "ligmanutz"
    client = obs.ReqClient(host=host, port=port, password=password)

    try:
        client.set_current_program_scene(scene_name)
        print(f"Switched to scene: {scene_name}")
    except Exception as e:
        print(f"Error: {str(e)}")


# This is just to load my SketchyBar colors file
def get_color_from_shell(var_name, colors_file):
    command = f'source "{colors_file}" && echo "${{{var_name}}}"'
    result = subprocess.run(
        ["zsh", "-c", command],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip() if result.returncode == 0 else None


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python switch_scene.py 'Scene Name'")
        sys.exit(1)

    scene_name = sys.argv[1]
    switch_scene(scene_name)

    # If the banner file exists:
    # - Save the scene name to the file
    # - Update the SketchyBar label with the scene name
    # This ensures no sketchybar commands are triggered for users without that
    # don't use SketchyBar
    banner_file = os.path.expanduser("~/github/dotfiles-latest/youtube-banner.txt")
    if os.path.exists(banner_file):
        with open(banner_file, "w") as f:
            f.write(scene_name)

        # Load BLUE from your sketchybar colors file
        colors_file = os.path.expanduser(
            "~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/colors.sh"
        )
        color1 = get_color_from_shell("BLUE", colors_file)
        color2 = get_color_from_shell("RED", colors_file)

        color = color1 if scene_name == "main-screen" else color2

        # Update SketchyBar item immediately
        subprocess.run(
            [
                "sketchybar",
                "-m",
                "--set",
                "custom_text",
                f"label={scene_name}",
                "icon=",
                f"icon.color={color}",
                f"label.color={color}",
                "icon.drawing=on",
            ]
        )
