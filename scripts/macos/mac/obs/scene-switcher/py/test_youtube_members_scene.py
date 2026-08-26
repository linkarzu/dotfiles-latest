import contextlib
import importlib.util
import io
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


MODULE_PATH = Path(__file__).with_name("youtube_members_scene.py")
SPEC = importlib.util.spec_from_file_location("youtube_members_scene", MODULE_PATH)
youtube_members_scene = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(youtube_members_scene)


class Client:
    def __init__(self, current_scene):
        self.current_scene = current_scene
        self.browser_url = "file:///overlay/index.html"
        self.scene_calls = []
        self.input_calls = []
        self.events = []

    def get_current_program_scene(self):
        return SimpleNamespace(current_program_scene_name=self.current_scene)

    def set_current_program_scene(self, scene_name):
        self.events.append("scene")
        self.scene_calls.append(scene_name)
        self.current_scene = scene_name

    def get_input_settings(self, **_kwargs):
        return SimpleNamespace(input_settings={"url": self.browser_url})

    def set_input_settings(self, **kwargs):
        self.events.append("page")
        self.input_calls.append(kwargs)
        self.browser_url = kwargs["settings"]["url"]


class YouTubeMembersSceneTests(unittest.TestCase):
    def test_password_failure_does_not_expose_command_output(self):
        secret = "SENTINEL-OBS-PASSWORD"
        error = subprocess.CalledProcessError(
            9,
            ["op", "read"],
            output=f"unsafe {secret}".encode(),
        )
        with patch.object(
            youtube_members_scene.subprocess,
            "check_output",
            side_effect=error,
        ), self.assertRaises(RuntimeError) as raised:
            youtube_members_scene.get_password()

        self.assertNotIn(secret, str(raised.exception))
        self.assertIn("exit_status=9", str(raised.exception))

    def test_entering_scene_resets_to_page_one(self):
        client = Client("another-scene")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            html_path = Path(temporary_directory) / "index.html"
            html_path.write_text("overlay", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path), patch.object(
                youtube_members_scene, "MEMBERS_HTML_PATH", html_path
            ):
                page, switched = youtube_members_scene.handle_press(client)

            saved_page = state_path.read_text(encoding="utf-8").strip()

        self.assertTrue(switched)
        self.assertEqual(page, 0)
        self.assertEqual(saved_page, "0")
        self.assertEqual(client.scene_calls, ["youtube-members"])
        self.assertEqual(client.events, ["page", "scene"])

    def test_entering_scene_page_failure_prevents_scene_switch(self):
        client = Client("another-scene")
        client.set_input_settings = lambda **_kwargs: None
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            html_path = Path(temporary_directory) / "index.html"
            html_path.write_text("overlay", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path), patch.object(
                youtube_members_scene, "MEMBERS_HTML_PATH", html_path
            ), patch.object(youtube_members_scene, "VERIFY_TIMEOUT", 0), self.assertRaisesRegex(
                RuntimeError, "authoritatively verified"
            ):
                youtube_members_scene.handle_press(client)

        self.assertEqual(client.scene_calls, [])
        self.assertFalse(state_path.exists())

    def test_repeated_press_advances_and_wraps_pages(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            state_path.write_text("0\n", encoding="utf-8")
            html_path = Path(temporary_directory) / "index.html"
            html_path.write_text("overlay", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path), patch.object(
                youtube_members_scene, "MEMBERS_HTML_PATH", html_path
            ):
                first_page, first_switched = youtube_members_scene.handle_press(client)
                second_page, second_switched = youtube_members_scene.handle_press(client)

        self.assertFalse(first_switched)
        self.assertFalse(second_switched)
        self.assertEqual((first_page, second_page), (1, 0))
        self.assertEqual(client.scene_calls, [])
        self.assertIn("page=members", client.input_calls[0]["settings"]["url"])
        self.assertIn("page=premium", client.input_calls[1]["settings"]["url"])

    def test_refresh_resets_active_scene_to_page_one(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            state_path.write_text("1\n", encoding="utf-8")
            html_path = Path(temporary_directory) / "index.html"
            html_path.write_text("overlay", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path), patch.object(
                youtube_members_scene, "MEMBERS_HTML_PATH", html_path
            ):
                page, switched = youtube_members_scene.handle_press(
                    client,
                    overlay_refreshed=True,
                )

            saved_page = state_path.read_text(encoding="utf-8").strip()

        self.assertFalse(switched)
        self.assertEqual(page, 0)
        self.assertEqual(saved_page, "0")

    def test_scene_switch_delayed_success_is_verified_before_page_commit(self):
        client = Client("another-scene")
        observations = iter(["another-scene", "another-scene", "youtube-members"])
        client.get_current_program_scene = lambda: SimpleNamespace(
            current_program_scene_name=next(observations)
        )
        client.set_current_program_scene = lambda scene: client.scene_calls.append(scene)

        with patch.object(youtube_members_scene.time, "sleep") as sleep:
            switched = youtube_members_scene.set_and_verify_scene(client)

        self.assertTrue(switched)
        self.assertEqual(client.scene_calls, ["youtube-members"])
        sleep.assert_called_once_with(youtube_members_scene.POLL_INTERVAL)

    def test_scene_switch_persistent_mismatch_times_out(self):
        client = Client("another-scene")
        client.set_current_program_scene = lambda scene: client.scene_calls.append(scene)

        with self.assertRaisesRegex(RuntimeError, "authoritatively verified"):
            youtube_members_scene.set_and_verify_scene(client, timeout=0)

        self.assertEqual(client.current_scene, "another-scene")

    def test_scene_request_error_reconciles_observed_success(self):
        client = Client("another-scene")

        def apply_then_raise(scene):
            client.current_scene = scene
            raise TimeoutError("sensitive request detail")

        client.set_current_program_scene = apply_then_raise

        self.assertTrue(youtube_members_scene.set_and_verify_scene(client, timeout=0))

    def test_scene_request_error_unresolved_does_not_commit_page(self):
        client = Client("another-scene")
        client.set_current_program_scene = lambda _scene: (_ for _ in ()).throw(
            TimeoutError("sensitive request detail")
        )
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            state_path.write_text("1\n", encoding="utf-8")
            html_path = Path(temporary_directory) / "index.html"
            html_path.write_text("overlay", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path), patch.object(
                youtube_members_scene, "MEMBERS_HTML_PATH", html_path
            ), patch.object(youtube_members_scene, "VERIFY_TIMEOUT", 0):
                with self.assertRaisesRegex(RuntimeError, "authoritatively verified"):
                    youtube_members_scene.handle_press(client)

            saved_page = state_path.read_text(encoding="utf-8")

        self.assertEqual(saved_page, "1\n")

    def test_different_csv_requires_regeneration(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            old_csv = root / "Your members old.csv"
            new_csv = root / "Your members new.csv"
            members_json = root / "members.json"
            old_csv.write_text("old", encoding="utf-8")
            new_csv.write_text("new", encoding="utf-8")
            members_json.write_text(json.dumps({"sourceCsv": str(old_csv)}), encoding="utf-8")

            with patch.object(youtube_members_scene, "MEMBERS_JSON_PATH", members_json):
                needs_regeneration = youtube_members_scene.overlay_needs_regeneration(new_csv)

        self.assertTrue(needs_regeneration)

    def test_changed_overlay_is_reloaded_without_regeneration(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            downloads = root / "Downloads"
            downloads.mkdir()
            csv_path = downloads / "Your members current.csv"
            csv_path.write_text("current", encoding="utf-8")
            members_json = root / "members.json"
            members_json.write_text(json.dumps({"sourceCsv": str(csv_path)}), encoding="utf-8")
            html_path = root / "index.html"
            html_path.write_text("new overlay", encoding="utf-8")
            loaded_mtime_path = root / "loaded-overlay-mtime.txt"
            loaded_mtime_path.write_text("0\n", encoding="utf-8")
            expected_mtime = html_path.stat().st_mtime_ns

            with patch.object(youtube_members_scene, "DOWNLOADS_DIR", downloads), patch.object(
                youtube_members_scene, "MEMBERS_JSON_PATH", members_json
            ), patch.object(youtube_members_scene, "MEMBERS_HTML_PATH", html_path), patch.object(
                youtube_members_scene, "LOADED_OVERLAY_MTIME_PATH", loaded_mtime_path
            ), patch.object(youtube_members_scene, "regenerate_overlay") as regenerate:
                refreshed = youtube_members_scene.refresh_overlay_if_needed(client)

            saved_mtime = int(loaded_mtime_path.read_text(encoding="utf-8").strip())

        self.assertTrue(refreshed)
        regenerate.assert_not_called()
        self.assertIn("page=premium", client.input_calls[0]["settings"]["url"])
        self.assertEqual(saved_mtime, expected_mtime)

    def test_changed_csv_regenerates_then_reloads_obs(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            downloads = root / "Downloads"
            downloads.mkdir()
            latest_csv = downloads / "Your members current.csv"
            latest_csv.write_text("current", encoding="utf-8")
            old_csv = root / "Your members old.csv"
            old_csv.write_text("old", encoding="utf-8")
            members_json = root / "members.json"
            members_json.write_text(json.dumps({"sourceCsv": str(old_csv)}), encoding="utf-8")
            html_path = root / "index.html"
            html_path.write_text("old overlay", encoding="utf-8")
            loaded_mtime_path = root / "loaded-overlay-mtime.txt"
            loaded_mtime_path.write_text("0\n", encoding="utf-8")

            def regenerate():
                members_json.write_text(
                    json.dumps({"sourceCsv": str(latest_csv)}),
                    encoding="utf-8",
                )
                html_path.write_text("regenerated overlay", encoding="utf-8")

            with patch.object(youtube_members_scene, "DOWNLOADS_DIR", downloads), patch.object(
                youtube_members_scene, "MEMBERS_JSON_PATH", members_json
            ), patch.object(youtube_members_scene, "MEMBERS_HTML_PATH", html_path), patch.object(
                youtube_members_scene, "LOADED_OVERLAY_MTIME_PATH", loaded_mtime_path
            ), patch.object(
                youtube_members_scene,
                "regenerate_overlay",
                side_effect=regenerate,
            ) as regenerate_mock:
                refreshed = youtube_members_scene.refresh_overlay_if_needed(client)

        self.assertTrue(refreshed)
        regenerate_mock.assert_called_once_with()
        self.assertIn("page=premium", client.input_calls[0]["settings"]["url"])

    def test_unchanged_overlay_keeps_page_cycling_fast(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            downloads = root / "Downloads"
            downloads.mkdir()
            csv_path = downloads / "Your members current.csv"
            csv_path.write_text("current", encoding="utf-8")
            members_json = root / "members.json"
            members_json.write_text(json.dumps({"sourceCsv": str(csv_path)}), encoding="utf-8")
            html_path = root / "index.html"
            html_path.write_text("current overlay", encoding="utf-8")
            loaded_mtime_path = root / "loaded-overlay-mtime.txt"
            loaded_mtime_path.write_text(
                f"{html_path.stat().st_mtime_ns}\n",
                encoding="utf-8",
            )

            with patch.object(youtube_members_scene, "DOWNLOADS_DIR", downloads), patch.object(
                youtube_members_scene, "MEMBERS_JSON_PATH", members_json
            ), patch.object(youtube_members_scene, "MEMBERS_HTML_PATH", html_path), patch.object(
                youtube_members_scene, "LOADED_OVERLAY_MTIME_PATH", loaded_mtime_path
            ), patch.object(youtube_members_scene, "regenerate_overlay") as regenerate:
                refreshed = youtube_members_scene.refresh_overlay_if_needed(client)

        self.assertFalse(refreshed)
        regenerate.assert_not_called()

    def test_refresh_ambiguity_does_not_commit_loaded_mtime(self):
        client = Client("youtube-members")
        client.set_input_settings = lambda **_kwargs: None
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            downloads = root / "Downloads"
            downloads.mkdir()
            csv_path = downloads / "Your members current.csv"
            csv_path.write_text("current", encoding="utf-8")
            members_json = root / "members.json"
            members_json.write_text(json.dumps({"sourceCsv": str(csv_path)}), encoding="utf-8")
            html_path = root / "index.html"
            html_path.write_text("new overlay", encoding="utf-8")
            loaded_mtime_path = root / "loaded-overlay-mtime.txt"
            loaded_mtime_path.write_text("0\n", encoding="utf-8")

            with patch.object(youtube_members_scene, "DOWNLOADS_DIR", downloads), patch.object(
                youtube_members_scene, "MEMBERS_JSON_PATH", members_json
            ), patch.object(youtube_members_scene, "MEMBERS_HTML_PATH", html_path), patch.object(
                youtube_members_scene, "LOADED_OVERLAY_MTIME_PATH", loaded_mtime_path
            ), patch.object(youtube_members_scene, "regenerate_overlay"), self.assertRaisesRegex(
                RuntimeError, "authoritatively verified"
            ), patch.object(youtube_members_scene, "VERIFY_TIMEOUT", 0):
                youtube_members_scene.refresh_overlay_if_needed(client)

            saved_mtime = loaded_mtime_path.read_text(encoding="utf-8")

        self.assertEqual(saved_mtime, "0\n")

    def test_browser_page_delayed_success_is_polled(self):
        client = Client("youtube-members")
        observed_urls = []

        def set_without_immediate_observation(**kwargs):
            client.input_calls.append(kwargs)
            observed_urls.append(kwargs["settings"]["url"])

        queries = 0

        def delayed_settings(**_kwargs):
            nonlocal queries
            queries += 1
            url = observed_urls[0] if observed_urls and queries >= 3 else client.browser_url
            return SimpleNamespace(input_settings={"url": url})

        client.set_input_settings = set_without_immediate_observation
        client.get_input_settings = delayed_settings
        with patch.object(youtube_members_scene.time, "sleep") as sleep:
            youtube_members_scene.set_and_verify_browser_page(client, 1, 123)

        self.assertEqual(queries, 3)
        sleep.assert_called_once_with(youtube_members_scene.POLL_INTERVAL)

    def test_browser_page_request_error_reconciles_observed_success(self):
        client = Client("youtube-members")

        def apply_then_raise(**kwargs):
            client.browser_url = kwargs["settings"]["url"]
            raise TimeoutError("sensitive browser request detail")

        client.set_input_settings = apply_then_raise

        youtube_members_scene.set_and_verify_browser_page(client, 1, 123, timeout=0)

    def test_failed_regeneration_does_not_reload_obs(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            downloads = root / "Downloads"
            downloads.mkdir()
            old_csv = downloads / "Your members old.csv"
            new_csv = downloads / "Your members new.csv"
            old_csv.write_text("old", encoding="utf-8")
            new_csv.write_text("new", encoding="utf-8")
            members_json = root / "members.json"
            members_json.write_text(json.dumps({"sourceCsv": str(old_csv)}), encoding="utf-8")
            html_path = root / "index.html"
            html_path.write_text("old overlay", encoding="utf-8")
            loaded_mtime_path = root / "loaded-overlay-mtime.txt"

            with patch.object(youtube_members_scene, "DOWNLOADS_DIR", downloads), patch.object(
                youtube_members_scene, "MEMBERS_JSON_PATH", members_json
            ), patch.object(youtube_members_scene, "MEMBERS_HTML_PATH", html_path), patch.object(
                youtube_members_scene, "LOADED_OVERLAY_MTIME_PATH", loaded_mtime_path
            ), patch.object(
                youtube_members_scene,
                "regenerate_overlay",
                side_effect=RuntimeError("generation failed"),
            ):
                with self.assertRaisesRegex(RuntimeError, "generation failed"):
                    youtube_members_scene.refresh_overlay_if_needed(client)

    def test_banner_is_published_atomically_after_bounded_query_verification(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            responses = [
                subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
                subprocess.CompletedProcess(
                    [],
                    0,
                    stdout='{"icon":{"drawing":"off"},"label":{"drawing":"on","value":"youtube-members"}}',
                    stderr="",
                ),
                subprocess.CompletedProcess(
                    [],
                    0,
                    stdout='{"icon":{"drawing":"on"},"label":{"drawing":"on","value":"youtube-members"}}',
                    stderr="",
                ),
            ]
            with patch.object(
                youtube_members_scene, "BANNER_PATH", banner_path
            ), patch.object(
                youtube_members_scene.subprocess, "run", side_effect=responses
            ), patch.object(youtube_members_scene.time, "sleep") as sleep:
                youtube_members_scene.update_banner()

            contents = banner_path.read_text(encoding="utf-8")
            leftovers = list(banner_path.parent.glob(f".{banner_path.name}.*.tmp"))

        self.assertEqual(contents, youtube_members_scene.SCENE_NAME)
        self.assertEqual(leftovers, [])
        sleep.assert_called_once_with(youtube_members_scene.POLL_INTERVAL)

    def test_banner_trigger_failure_reports_unverified_rollback_and_fails(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            rejected = subprocess.CompletedProcess([], 7, stdout=b"", stderr=b"")
            stderr = io.StringIO()
            with patch.object(
                youtube_members_scene, "BANNER_PATH", banner_path
            ), patch.object(
                youtube_members_scene.subprocess, "run", return_value=rejected
            ) as run, contextlib.redirect_stderr(stderr), self.assertRaisesRegex(
                RuntimeError, "authoritatively verified"
            ):
                youtube_members_scene.update_banner()

            contents = banner_path.read_text(encoding="utf-8")
            leftovers = list(banner_path.parent.glob(f".{banner_path.name}.*.tmp"))

        self.assertEqual(contents, "previous-scene")
        self.assertEqual(leftovers, [])
        self.assertEqual(run.call_count, 2)
        self.assertIn("rollback=failure-unverified", stderr.getvalue())
        self.assertIn("marker_restored=true", stderr.getvalue())
        self.assertIn("sketchybar_restored=false", stderr.getvalue())

    def test_banner_label_mismatch_rolls_back_marker_and_verified_sketchybar_state(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            responses = [
                subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
                subprocess.CompletedProcess(
                    [],
                    0,
                    stdout='{"icon":{"drawing":"on"},"label":{"drawing":"on","value":"stale-scene"}}',
                    stderr="",
                ),
                subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
                subprocess.CompletedProcess(
                    [],
                    0,
                    stdout='{"icon":{"drawing":"on"},"label":{"drawing":"on","value":"previous-scene"}}',
                    stderr="",
                ),
            ]
            stderr = io.StringIO()
            with patch.object(
                youtube_members_scene, "BANNER_PATH", banner_path
            ), patch.object(
                youtube_members_scene, "SKETCHYBAR_VERIFY_TIMEOUT", 0
            ), patch.object(
                youtube_members_scene.subprocess, "run", side_effect=responses
            ) as run, contextlib.redirect_stderr(stderr), self.assertRaisesRegex(
                RuntimeError, "authoritatively verified"
            ):
                youtube_members_scene.update_banner()

            contents = banner_path.read_text(encoding="utf-8")

        self.assertEqual(contents, "previous-scene")
        self.assertEqual(run.call_count, 4)
        self.assertIn("rollback=success", stderr.getvalue())
        self.assertIn("sketchybar_restored=true", stderr.getvalue())

    def test_banner_label_drawing_off_fails_closed(self):
        responses = [
            subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
            subprocess.CompletedProcess(
                [],
                0,
                stdout='{"icon":{"drawing":"on"},"label":{"drawing":"off","value":"youtube-members"}}',
                stderr="",
            ),
        ]
        with patch.object(
            youtube_members_scene.subprocess, "run", side_effect=responses
        ), self.assertRaisesRegex(RuntimeError, "label-drawing-off"):
            youtube_members_scene.trigger_and_verify_banner(
                youtube_members_scene.SCENE_NAME,
                timeout=0,
            )

    def test_banner_failure_log_preserves_safe_authoritative_evidence(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            stderr = io.StringIO()
            with patch.object(youtube_members_scene, "BANNER_PATH", banner_path), patch.object(
                youtube_members_scene,
                "trigger_and_verify_banner",
                side_effect=[
                    RuntimeError(
                        "SketchyBar banner state could not be verified "
                        "(icon-drawing-on label-drawing-off label-matches-true)."
                    ),
                    None,
                ],
            ), contextlib.redirect_stderr(stderr), self.assertRaises(RuntimeError):
                youtube_members_scene.update_banner()

        evidence = stderr.getvalue()
        self.assertIn("label-drawing-off", evidence)
        self.assertIn("rollback=success", evidence)



if __name__ == "__main__":
    unittest.main()
