#!/usr/bin/env python3

# Script created by Linkarzu
# Feel free to modify, distribute it
# If you find it useful, you can support me at ko-fi https://ko-fi.com/linkarzu

import os
import sys
import subprocess
import obsws_python as obs

# --- Vars ---
onepassword_secret = "op://helixdeeznuts/obs-websocket-password/credential"
requirements = ["obsws-python"]


def ensure_venv():
    venv_path = os.path.join(os.path.dirname(__file__), ".venv")

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
            subprocess.check_call(
                [os.path.join(venv_path, "bin", "pip"), "install"] + requirements
            )

        python_executable = os.path.join(venv_path, "bin", "python")
        os.execv(python_executable, [python_executable] + sys.argv)


ensure_venv()


def get_password():
    try:
        result = subprocess.check_output(
            ["op", "read", onepassword_secret], stderr=subprocess.STDOUT
        )
        return result.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        print(f"1Password Error: {e.output.decode().strip()}")
        sys.exit(1)


# Function to get input settings and extract URL
def get_input_properties(input_name):
    host = "localhost"
    port = 4455
    password = get_password() if "--no-auth" not in sys.argv else None

    client = obs.ReqClient(host=host, port=port, password=password)

    try:
        resp = client.get_input_settings(input_name)
        settings = resp.__dict__.get("input_settings", {})

        if not settings:
            print(f"No properties found for '{input_name}'")
            return

        print(f"Properties for '{input_name}':")
        for key, value in settings.items():
            print(f"  {key}: {value}")

    except Exception as e:
        print(f"Error retrieving input properties: {str(e)}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_input_url.py 'Input Name'")
        sys.exit(1)

    input_name = sys.argv[1]
    get_input_properties(input_name)
