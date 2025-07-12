#!/usr/bin/env python3

# Script created by Linkarzu
# Feel free to modify, distribute it
# If you find it useful, you can support me at ko-fi https://ko-fi.com/linkarzu

import os
import sys
import subprocess
import obsws_python as obs

# --- Vars ---
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


# Function to set the input's URL property
def set_input_url(input_name, new_url):
    host = "localhost"
    port = 4455
    client = obs.ReqClient(host=host, port=port, password=None)

    try:
        # Send request to update input settings
        client.set_input_settings(
            name=input_name,
            settings={"url": new_url},
            overlay=True,
        )
        print(f"[+] Updated URL of '{input_name}' to: {new_url}")
    except Exception as e:
        print(f"Error updating input URL: {str(e)}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python set_url.py 'Input Name' 'New URL'")
        sys.exit(1)

    input_name = sys.argv[1]
    new_url = sys.argv[2]
    set_input_url(input_name, new_url)
