#!/usr/bin/env bash
# Synthetic wrapper integration only: no real Kitty, fzf, projects, or services.
set -euo pipefail
exec python3 - "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)" <<'PY'
import json
import os
from pathlib import Path
import shlex
import shutil
import socket
import subprocess
import sys
import tempfile
import textwrap
import unittest

REPO = Path(sys.argv.pop())
MAC = Path("scripts/macos/mac")
SCRIPTS = (
    "070-obsMeetingManager.sh", "120-processVideo.sh",
    "misc/240-systemTask.sh", "misc/549-kittyMainSocket.sh",
    "misc/550-skhdSession.sh", "misc/555-skhdQatTask.sh",
    "misc/560-skhdTmuxSession.sh",
)
TMUX_HELPER = Path("kitty/scripts/kitty-tmux-launch.sh")
ROOT_OPTIONS = (
    "FFMPEG_CLIPS_DASHBOARD_ROOT", "FFMPEG_CLIPS_LIVESTREAM_ROOT", "FFMPEG_CLIPS_RENDER_LOCK",
    "OBS_MEETING_MANAGER_DATA_DIR", "OBS_MEETING_MANAGER_LIVESTREAM_ROOT",
    "XDG_CACHE_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "HF_HOME",
    "HUGGINGFACE_HUB_CACHE", "TORCH_HOME", "FFMPEG_BIN", "FFPROBE_BIN",
    "FONTCONFIG_FILE", "FONTCONFIG_PATH",
)
KEYS = (
    "PATH", "HOME", "TMPDIR", "DOTFILES_DIR", "OBS_MEETING_MANAGER_ROOT",
    "FFMPEG_CLIPS_ROOT", "FFMPEG_CLIPS_SCRIPTS", "FFMPEG_CLIPS_MEDIA_REQUEST",
    "FFMPEG_CLIPS_RUNTIME_ID", "FFMPEG_CLIPS_PYTHON", "FZF_AI_SOCKET",
    "FZF_DEFAULT_OPTS", "KITTY_BIN", "KITTY_SOCKET", "SERVICE_FIXTURE_ENABLED",
    *ROOT_OPTIONS, "PYTHONPATH", "BASH_ENV", "ENV", "QAT_INSTANCE_GROUP", "QAT_KITTY_CONFIG",
    "FFMPEG_CLIPS_DASHBOARD_PUBLIC_URL",
)


class QatRuntimeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="qr-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.latest = self.root / "selected latest 'checkout"
        self.obs = self.root / "selected obs 'checkout"
        self.ffmpeg = self.root / "selected ffmpeg 'checkout"
        self.bin = self.root / "frozen bin"
        for relative in SCRIPTS:
            target = self.latest / MAC / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO / MAC / relative, target)
        colors = self.latest / "colorscheme/active/active-fzf-colors.sh"
        colors.parent.mkdir(parents=True)
        colors.write_text("linkarzu_fzf_colors='fg:#123456'\n")
        config = self.latest / "kitty/quick-access-terminal-center.conf"
        config.parent.mkdir()
        config.write_text("# selected fixture config\n")
        helper = self.latest / TMUX_HELPER
        helper.parent.mkdir()
        shutil.copy2(REPO / TMUX_HELPER, helper)
        (self.root / "stale-shell-bootstrap.sh").write_text("exit 92\n")
        (self.root / "home").mkdir()
        (self.root / "tmp").mkdir()
        self.kitty_socket = self.root / "k.sock"
        self.fzf_socket = self.root / "f sock"
        for path in (self.kitty_socket, self.fzf_socket):
            sock = socket.socket(socket.AF_UNIX)
            self.addCleanup(sock.close)
            sock.bind(str(path))
        self.base_env = {
            "HOME": str(self.root / "home"), "TMPDIR": str(self.root / "tmp") + "/",
            "PATH": f"{self.bin}:/usr/bin:/bin", "KITTY_BIN": str(self.bin / "kitty"),
            "KITTY_SOCKET": str(self.kitty_socket), "PYTHONDONTWRITEBYTECODE": "1",
        }
        self.env = {
            **self.base_env, "DOTFILES_DIR": str(self.latest),
            "OBS_MEETING_MANAGER_ROOT": str(self.obs), "FFMPEG_CLIPS_ROOT": str(self.ffmpeg),
            "FFMPEG_CLIPS_SCRIPTS": str(self.ffmpeg / "scripts"),
            "FFMPEG_CLIPS_MEDIA_REQUEST": str(self.ffmpeg / "scripts/media-request/media-request.py"),
            "FFMPEG_CLIPS_RUNTIME_ID": "fixture-generation", "FFMPEG_CLIPS_PYTHON": str(self.bin / "python3"),
            "FZF_AI_SOCKET": str(self.fzf_socket), "FZF_DEFAULT_OPTS": "--border --info=inline",
            **{key: str(self.root / key.lower()) for key in ROOT_OPTIONS},
        }
        self.python_fixture(self.bin / "kitty", '''
            args = sys.argv[1:]
            record("kitty")
            assert args[:3] == ["@", "--to", "unix:" + str(root / "k.sock")], args
            if args[3:5] == ["action", "goto_session"]:
                sys.exit(0)
            # Use the argv-based remote command, not a reparsed `action launch` string.
            assert args[3:5] == ["launch", "--type=background"], args
            # Simulate a long-running server from another generation, not the caller.
            server = {key: "stale-" + key for key in keys}
            server.update(HOME=str(root / "stale-home"), PATH="/usr/bin:/bin",
                          SERVICE_FIXTURE_ENABLED="yes", BASH_ENV=str(root / "stale-shell-bootstrap.sh"),
                          ENV=str(root / "stale-shell-bootstrap.sh"))
            index = 5
            while args[index] == "--env":
                key, separator, value = args[index + 1].partition("=")
                if separator:
                    server[key] = value
                else:
                    # Kitty 0.48 background launches pass the deletion marker literally.
                    server[key] = "_delete_this_env_var_"
                index += 2
            subprocess.run(args[index:], env=server, check=True, timeout=5)
        ''')
        self.python_fixture(self.bin / "kitten", '''
            command = ["kitten", *sys.argv[1:]]
            server = dict(os.environ)
            assert command[:3] == ["kitten", "quick-access-terminal", "--config"], command
            assert command[3] == server["DOTFILES_DIR"] + "/kitty/quick-access-terminal-center.conf", command
            assert Path(command[3]).is_file()
            index = 4
            if server.get("QAT_KITTY_CONFIG"):
                assert command[index:index + 2] == ["--override", "kitty_conf=" + server["QAT_KITTY_CONFIG"]], command
                assert Path(server["QAT_KITTY_CONFIG"]).is_file()
                index += 2
            assert command[index:index + 3] == ["--instance-group", server.get("QAT_INSTANCE_GROUP", "system-task"), "/bin/bash"], command
            assert command[index + 3:] == [server["DOTFILES_DIR"] + "/scripts/macos/mac/misc/240-systemTask.sh"], command
            assert "BASH_ENV" not in server and "ENV" not in server, server.keys()
            assert all(server.get(key) != "_delete_this_env_var_" for key in keys)
            record("remote", env=server, command=command)
            subprocess.run(command[index + 2:], env=server, check=True, timeout=5)
        ''')
        self.python_fixture(self.bin / "fzf", '''
            items = sys.stdin.read().splitlines()
            choice = (root / "choice").read_text()
            assert choice in items, (choice, items)
            record("fzf", items=items)
            print(choice)
        ''')
        self.python_fixture(self.bin / "python3", '''
            record("python")
            os.execv(sys.executable, [sys.executable, *sys.argv[1:]])
        ''')
        self.python_fixture(self.bin / "selected python", '''
            record("selected-python")
            os.execv(sys.executable, [sys.executable, *sys.argv[1:]])
        ''')
        self.python_fixture(self.bin / "tmux", '''
            record("tmux")
            if sys.argv[1] == "display-message":
                print((root / "tmux-root").read_text())
            elif sys.argv[1] == "show-environment":
                print("FFMPEG_CLIPS_PROJECT_ID=fixture-owned")
            else:
                assert sys.argv[1] == "has-session", sys.argv
        ''')
        self.reattach = self.root / "reattach.sh"
        self.reattach.write_text(
            'set -euo pipefail\nsource "$1"\n'
            'kitty_remote action goto_session "$4"\n'
            'focus_or_launch_tmux "$2" "$3"\n'
        )
        self.producer_fixtures(self.obs, self.ffmpeg)

    def python_fixture(self, path, body):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            f"#!{sys.executable}\n"
            "import json, os, subprocess, sys\nfrom pathlib import Path\n"
            f"root = Path({str(self.root)!r})\nkeys = {KEYS!r}\n"
            "def record(kind, **extra):\n"
            "    item = dict(kind=kind, file=__file__, argv=sys.argv[1:], "
            "env={key: os.environ.get(key) for key in keys})\n"
            "    item.update(extra)\n"
            "    with (root / 'events.jsonl').open('a') as stream:\n"
            "        stream.write(json.dumps(item) + '\\n')\n"
            + textwrap.dedent(body)
        )
        path.chmod(0o755)

    def producer_fixtures(self, obs, ffmpeg):
        self.python_fixture(obs / MAC / "obs/meeting/py/meeting_manager.py", 'record("obs")')
        self.python_fixture(ffmpeg / "scripts/run-workflow.sh", '''
            record("ffmpeg")
            if "--nested-obs" in sys.argv:
                subprocess.run([os.environ["DOTFILES_DIR"] + "/scripts/macos/mac/070-obsMeetingManager.sh",
                                "from ffmpeg", "two words"], check=True, timeout=5)
        ''')

    def project_fixture(self, scripts):
        self.python_fixture(scripts / "project_session.py", '''
            record("project-helper")
            command, directory = sys.argv[1:]
            project = Path(directory)
            assert project.is_dir()
            if command == "root":
                if not (project / "livestream-project.json").is_file():
                    sys.exit(3)
                print(directory)
            elif command == "name":
                print(project.name)
            else:
                assert command == "launch", command
        ''')

    def invoke(self, script, env, *args, choice="120-processVideo.sh", success=True):
        (self.root / "choice").write_text(choice)
        (self.root / "events.jsonl").write_text("")
        result = subprocess.run(["/bin/bash", str(script), *args], env=env, cwd=self.root,
                                text=True, capture_output=True, timeout=10)
        if success:
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0)
        records = [json.loads(line) for line in (self.root / "events.jsonl").read_text().splitlines()]
        return result, records

    def assert_menu_dispatch(self, records, expected, kind):
        menu = next(item for item in records if item["kind"] == "fzf")
        self.assertEqual(menu["items"], ["070-obsMeetingManager.sh", "120-processVideo.sh"])
        self.assertIn("--color=fg:#123456", menu["argv"])
        self.assertIn("--listen=" + expected["FZF_AI_SOCKET"], shlex.split(menu["env"]["FZF_DEFAULT_OPTS"]))
        producer = next(item for item in records if item["kind"] == kind)
        if any(item["kind"] == "remote" for item in records):
            self.assertEqual(producer["env"]["PYTHONPATH"], expected["FFMPEG_CLIPS_SCRIPTS"])
            self.assertIsNone(producer["env"]["BASH_ENV"])
            self.assertIsNone(producer["env"]["ENV"])
        for key, value in expected.items():
            if key in KEYS and key != "FZF_DEFAULT_OPTS":
                self.assertEqual(producer["env"][key], value, key)
        if kind == "ffmpeg":
            self.assertEqual(producer["file"], expected["FFMPEG_CLIPS_SCRIPTS"] + "/run-workflow.sh")
        else:
            self.assertEqual(producer["file"], expected["OBS_MEETING_MANAGER_ROOT"] + "/scripts/macos/mac/obs/meeting/py/meeting_manager.py")
        return producer

    def test_remote_menu_dispatch_overrides_stale_server_roots_and_environment(self):
        for choice, kind in (("070-obsMeetingManager.sh", "obs"), ("120-processVideo.sh", "ffmpeg")):
            with self.subTest(choice=choice):
                _, records = self.invoke(REPO / MAC / "misc/555-skhdQatTask.sh", self.env, choice=choice)
                producer = self.assert_menu_dispatch(records, self.env, kind)
                self.assertEqual(producer["env"]["SERVICE_FIXTURE_ENABLED"], "yes")
                self.assertIn("--border", producer["env"]["FZF_DEFAULT_OPTS"])
                self.assertNotIn("stale-", producer["env"]["FZF_DEFAULT_OPTS"])

    def test_remote_dashboard_public_url_overrides_or_removes_stale_server_value(self):
        key = "FFMPEG_CLIPS_DASHBOARD_PUBLIC_URL"
        for value in ("https://dashboard.fixture.invalid/review", "", None):
            for choice, kind in (("070-obsMeetingManager.sh", "obs"), ("120-processVideo.sh", "ffmpeg")):
                with self.subTest(value=value, choice=choice):
                    env = dict(self.env)
                    if value is not None:
                        env[key] = value
                    _, records = self.invoke(REPO / MAC / "misc/555-skhdQatTask.sh", env, choice=choice)
                    producer = self.assert_menu_dispatch(records, {**env, key: value or None}, kind)
                    remote = next(item for item in records if item["kind"] == "remote")
                    if not value:
                        self.assertNotIn(key, remote["env"])
                    else:
                        self.assertEqual(remote["env"][key], value)
                    self.assertEqual(producer["env"][key], value or None)

    def test_remote_launch_ignores_caller_bootstrap_and_selects_optional_qat_config(self):
        config = self.root / "runtime kitty config.conf"
        config.write_text("# synthetic runtime config\n")
        bootstrap = self.root / "caller bootstrap.sh"
        bootstrap.write_text("# synthetic caller bootstrap\n")
        env = {
            **self.env, "QAT_INSTANCE_GROUP": "system-task-fixture-b", "QAT_KITTY_CONFIG": str(config),
            "PYTHONPATH": str(self.root / "wrong scripts"), "BASH_ENV": str(bootstrap), "ENV": str(bootstrap),
        }
        _, records = self.invoke(REPO / MAC / "misc/555-skhdQatTask.sh", env)
        expected = {**env, "PYTHONPATH": self.env["FFMPEG_CLIPS_SCRIPTS"], "BASH_ENV": None, "ENV": None}
        self.assert_menu_dispatch(records, expected, "ffmpeg")
        remote = next(item for item in records if item["kind"] == "remote")
        self.assertEqual(remote["command"][4:8], ["--override", "kitty_conf=" + str(config),
                                                "--instance-group", "system-task-fixture-b"])
        self.assertNotIn("BASH_ENV", remote["env"])
        self.assertNotIn("ENV", remote["env"])

    def test_relocated_launcher_keeps_normal_defaults_and_clears_stale_optional_values(self):
        home = Path(self.base_env["HOME"])
        obs = home / "github/dotfiles-private/scripts/macos/mac/obs-meeting-manager"
        ffmpeg = home / "github/ffmpeg-clips"
        self.producer_fixtures(obs, ffmpeg)
        expected = {
            **self.base_env, "DOTFILES_DIR": str(self.latest),
            "OBS_MEETING_MANAGER_ROOT": str(obs), "FFMPEG_CLIPS_ROOT": str(ffmpeg),
            "FFMPEG_CLIPS_SCRIPTS": str(ffmpeg / "scripts"),
            "FFMPEG_CLIPS_MEDIA_REQUEST": str(ffmpeg / "scripts/media-request/media-request.py"),
            "FZF_AI_SOCKET": str(self.root / "tmp/linkarzu-system-task-fzf.sock"),
        }
        for choice, kind in (("070-obsMeetingManager.sh", "obs"), ("120-processVideo.sh", "ffmpeg")):
            with self.subTest(choice=choice):
                _, records = self.invoke(self.latest / MAC / "misc/555-skhdQatTask.sh", self.base_env, choice=choice)
                producer = self.assert_menu_dispatch(records, expected, kind)
                self.assertIsNone(producer["env"]["FFMPEG_CLIPS_RUNTIME_ID"])
                self.assertIsNone(producer["env"]["FFMPEG_CLIPS_PYTHON"])
                self.assertNotIn("stale-", producer["env"]["FZF_DEFAULT_OPTS"])
                for key in (*ROOT_OPTIONS, "QAT_INSTANCE_GROUP", "QAT_KITTY_CONFIG"):
                    self.assertIsNone(producer["env"][key], key)

    def test_direct_menu_and_nested_wrappers_preserve_environment_and_arguments(self):
        env = dict(self.env)
        del env["DOTFILES_DIR"]
        del env["FZF_AI_SOCKET"]
        _, records = self.invoke(self.latest / MAC / "misc/240-systemTask.sh", env)
        expected = {**self.env, "FZF_AI_SOCKET": str(self.root / "tmp/linkarzu-system-task-fzf.sock")}
        self.assert_menu_dispatch(records, expected, "ffmpeg")
        for script, kind in (("070-obsMeetingManager.sh", "obs"), ("120-processVideo.sh", "ffmpeg")):
            with self.subTest(script=script):
                args = ("--nested-obs", "two words", "literal'quote")
                _, records = self.invoke(REPO / MAC / script, self.env, *args)
                producer = next(item for item in records if item["kind"] == kind)
                self.assertEqual(producer["argv"], list(args))
                for item in records:
                    for key in self.env.keys() & set(KEYS):
                        self.assertEqual(item["env"][key], self.env[key], (item["kind"], key))
                if kind == "ffmpeg":
                    nested = next(item for item in records if item["kind"] == "obs")
                    self.assertEqual(nested["argv"], ["from ffmpeg", "two words"])

    def test_tmux_reattachment_helpers_select_roots_and_interpreter(self):
        project = self.root / "synthetic-project"
        project.mkdir()
        (project / "livestream-project.json").write_text("{}")
        video = project / "fixture.mkv"
        video.touch()
        (self.root / "tmux-root").write_text(str(project))
        normal_scripts = Path(self.base_env["HOME"]) / "github/ffmpeg-clips/scripts"
        alternate_scripts = self.root / "explicit scripts 'checkout"
        for scripts in (self.ffmpeg / "scripts", normal_scripts, alternate_scripts):
            self.project_fixture(scripts)
        for mode in ("root", "scripts", "override", "defaults"):
            with self.subTest(mode=mode):
                env = dict(self.base_env if mode == "defaults" else self.env)
                if mode == "root":
                    del env["FFMPEG_CLIPS_SCRIPTS"]
                elif mode == "scripts":
                    del env["FFMPEG_CLIPS_ROOT"]
                elif mode == "override":
                    env["FFMPEG_CLIPS_SCRIPTS"] = str(alternate_scripts)
                scripts = normal_scripts if mode == "defaults" else alternate_scripts if mode == "override" else self.ffmpeg / "scripts"
                if mode != "defaults":
                    env["FFMPEG_CLIPS_PYTHON"] = str(self.bin / "selected python")
                checkout = self.latest if mode == "defaults" else REPO
                for source_helper in (False, True):
                    with self.subTest(source_helper=source_helper):
                        if source_helper:
                            _, records = self.invoke(self.reattach, env, str(checkout / TMUX_HELPER),
                                                     project.name, "", str(project / "fixture.kitty-session"))
                            expected_commands = ["root", "name", "launch"]
                            kitty = next(item for item in records if item["kind"] == "kitty")
                            self.assertEqual(kitty["file"], env["KITTY_BIN"])
                            self.assertEqual(kitty["argv"][3:], ["action", "goto_session", str(project / "fixture.kitty-session")])
                            tmux = next(item for item in records if item["kind"] == "tmux")
                            self.assertEqual(tmux["argv"], ["display-message", "-p", "-t", project.name + ":", "#{session_path}"])
                        else:
                            _, records = self.invoke(checkout / MAC / "misc/560-skhdTmuxSession.sh", env, str(video))
                            expected_commands = ["root", "launch"]
                        helpers = [item for item in records if item["kind"] == "project-helper"]
                        self.assertEqual([item["argv"] for item in helpers], [[command, str(project)] for command in expected_commands])
                        for item in helpers:
                            self.assertEqual(item["file"], str(scripts / "project_session.py"))
                            self.assertEqual(item["env"]["DOTFILES_DIR"], str(self.latest))
                            for key in env.keys() & set(KEYS):
                                self.assertEqual(item["env"][key], env[key], key)
                        interpreters = [item for item in records if item["kind"] in ("python", "selected-python")]
                        self.assertEqual(len(interpreters), len(expected_commands))
                        self.assertEqual({item["kind"] for item in interpreters}, {"python" if mode == "defaults" else "selected-python"})

    def test_generic_reattachment_keeps_existing_missing_root_guard(self):
        project = self.root / "synthetic-generic-project"
        project.mkdir()
        (self.root / "tmux-root").write_text(str(project))
        self.project_fixture(self.ffmpeg / "scripts")
        result, records = self.invoke(REPO / MAC / "misc/560-skhdTmuxSession.sh", self.env, str(project), success=False)
        self.assertIn("unavailable owning root", result.stderr)
        helpers = [item for item in records if item["kind"] == "project-helper"]
        self.assertEqual([item["argv"] for item in helpers], [["root", str(project)]] * 2)
        self.assertEqual({item["file"] for item in helpers}, {str(self.ffmpeg / "scripts/project_session.py")})
        self.assertEqual([item["argv"] for item in records if item["kind"] == "tmux"], [
            ["has-session", "-t", project.name],
            ["show-environment", "-t", "=" + project.name, "FFMPEG_CLIPS_PROJECT_ID"],
        ])
        self.assertFalse(any(item["kind"] == "kitty" for item in records))

    def test_marked_reattachment_refuses_missing_selected_helper_and_name_mismatch(self):
        project = self.root / "synthetic-project"
        project.mkdir()
        (project / "livestream-project.json").write_text("{}")
        missing = self.root / "missing-runtime/scripts"
        env = {**self.env, "FFMPEG_CLIPS_SCRIPTS": str(missing)}
        for source_helper in (False, True):
            with self.subTest(source_helper=source_helper):
                if source_helper:
                    result, records = self.invoke(self.reattach, env, str(REPO / TMUX_HELPER), project.name,
                                                 str(project), str(project / "fixture.kitty-session"), success=False)
                else:
                    result, records = self.invoke(REPO / MAC / "misc/560-skhdTmuxSession.sh", env, str(project), success=False)
                self.assertIn("Portable project session helper is missing: " + str(missing / "project_session.py"), result.stderr)
                self.assertFalse(any(item["kind"] == "project-helper" for item in records))
        self.project_fixture(self.ffmpeg / "scripts")
        result, records = self.invoke(self.reattach, self.env, str(REPO / TMUX_HELPER), "wrong-session",
                                     str(project), str(project / "fixture.kitty-session"), success=False)
        self.assertIn("Marked project requires exact session", result.stderr)
        self.assertEqual([item["argv"][0] for item in records if item["kind"] == "project-helper"], ["root", "name"])

    def test_session_helper_and_socket_type_validation(self):
        env = {**self.env, "KITTY_SOCKET": "unix:" + str(self.kitty_socket)}
        session = str(self.latest / "kitty/sessions/fixture session.kitty-session")
        _, records = self.invoke(REPO / MAC / "misc/550-skhdSession.sh", env, session)
        self.assertEqual(records[0]["argv"], ["@", "--to", "unix:" + str(self.kitty_socket),
                                             "action", "goto_session", session])
        regular = self.root / "not-a-socket"
        regular.write_text("fixture")
        for invalid in (regular, self.root, self.root / "missing"):
            for script in ("549-kittyMainSocket.sh", "550-skhdSession.sh", "555-skhdQatTask.sh"):
                with self.subTest(invalid=invalid.name, script=script):
                    result, records = self.invoke(REPO / MAC / "misc" / script,
                                                  {**self.env, "KITTY_SOCKET": str(invalid)},
                                                  session, success=False)
                    self.assertIn("not a Unix socket", result.stderr)
                    self.assertEqual(records, [])


unittest.main(verbosity=2)
PY
