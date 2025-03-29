#!/usr/bin/env python3

# Script created by Linkarzu
# Feel free to modify, distribute it
# If you find it useful, you can support me at ko-fi https://ko-fi.com/linkarzu
# HACK: Video related to this script:

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


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python switch_scene.py 'Scene Name'")
        sys.exit(1)

    scene_name = sys.argv[1]
    switch_scene(scene_name)
