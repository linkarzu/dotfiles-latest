#!/usr/bin/env python3
import os
import sys
import subprocess
import obsws_python as obs


# --- Auto-create and activate .venv ---
def ensure_venv():
    venv_path = os.path.join(os.path.dirname(__file__), ".venv")

    # If we're not in the venv already, and it doesn't exist, create it
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
                [
                    os.path.join(venv_path, "bin", "pip"),
                    "install",
                    "-r",
                    os.path.join(os.path.dirname(__file__), "requirements.txt"),
                ]
            )

        # Re-run this script inside the virtual environment
        python_executable = os.path.join(venv_path, "bin", "python")
        os.execv(python_executable, [python_executable] + sys.argv)


ensure_venv()


def get_password():
    try:
        # Retrieve password from 1Password
        result = subprocess.check_output(
            ["op", "read", "op://helixdeeznuts/obs-websocket-password/credential"],
            stderr=subprocess.STDOUT,
        )
        return result.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        print(f"1Password Error: {e.output.decode().strip()}")
        sys.exit(1)


def switch_scene(scene_name):
    host = "localhost"
    port = 4455
    password = get_password()
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

    switch_scene(sys.argv[1])
