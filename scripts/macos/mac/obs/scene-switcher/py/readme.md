# How to run this

- When I run the script for the first time in a new machine or dir, the `.venv`
  will be created and dependencies installed automatically

```bash
python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "starting-soon"
```

```bash
linkarzu.@.[25/03/28] via 🐍 v3.9.6 (.venv)
~/obs-script/scene-switcher

❯❯❯❯ python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "starting-soon"

[+] Creating .venv and installing dependencies...
Requirement already satisfied: pip in /Users/linkarzu/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/.venv/lib/python3.9/site-packages (21.2.4)
Collecting pip
  Using cached pip-25.0.1-py3-none-any.whl (1.8 MB)
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.4
    Uninstalling pip-21.2.4:
      Successfully uninstalled pip-21.2.4
Successfully installed pip-25.0.1
Collecting obsws-python (from -r /Users/linkarzu/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/requirements.txt (line 1))
  Using cached obsws_python-1.7.1-py3-none-any.whl.metadata (5.5 kB)
Collecting tomli>=2.0.1 (from obsws-python->-r /Users/linkarzu/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/requirements.txt (line 1))
  Using cached tomli-2.2.1-py3-none-any.whl.metadata (10 kB)
Collecting websocket-client (from obsws-python->-r /Users/linkarzu/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/requirements.txt (line 1))
  Using cached websocket_client-1.8.0-py3-none-any.whl.metadata (8.0 kB)
Using cached obsws_python-1.7.1-py3-none-any.whl (30 kB)
Using cached tomli-2.2.1-py3-none-any.whl (14 kB)
Using cached websocket_client-1.8.0-py3-none-any.whl (58 kB)
Installing collected packages: websocket-client, tomli, obsws-python
Successfully installed obsws-python-1.7.1 tomli-2.2.1 websocket-client-1.8.0
Switched to scene: starting-soon
```

```bash
python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "video-and-stream"
python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "starting-soon"
```

```bash
linkarzu.@.[25/03/28] via 🐍 v3.9.6 (.venv) took 3s
~/obs-script/scene-switcher

❯❯❯❯ python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "video-and-stream"

Switched to scene: video-and-stream

------------------------------------------------------

linkarzu.@.[25/03/28] via 🐍 v3.9.6 (.venv)
~/obs-script/scene-switcher

❯❯❯❯ python3 ~/github/dotfiles-latest/scripts/macos/mac/obs/scene-switcher/py/switch_scene.py "starting-soon"

Switched to scene: starting-soon
```
