import importlib.util
import json
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
        self.scene_calls = []
        self.vendor_calls = []
        self.property_calls = []

    def get_current_program_scene(self):
        return SimpleNamespace(current_program_scene_name=self.current_scene)

    def set_current_program_scene(self, scene_name):
        self.scene_calls.append(scene_name)

    def call_vendor_request(self, *args):
        self.vendor_calls.append(args)

    def press_input_properties_button(self, *args):
        self.property_calls.append(args)


class YouTubeMembersSceneTests(unittest.TestCase):
    def test_entering_scene_resets_to_page_one(self):
        client = Client("another-scene")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path):
                page, switched = youtube_members_scene.handle_press(client)

            saved_page = state_path.read_text(encoding="utf-8").strip()

        self.assertTrue(switched)
        self.assertEqual(page, 0)
        self.assertEqual(saved_page, "0")
        self.assertEqual(client.scene_calls, ["youtube-members"])
        self.assertEqual(client.vendor_calls, [])

    def test_repeated_press_advances_and_wraps_pages(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            state_path.write_text("0\n", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path):
                first_page, first_switched = youtube_members_scene.handle_press(client)
                second_page, second_switched = youtube_members_scene.handle_press(client)

        self.assertFalse(first_switched)
        self.assertFalse(second_switched)
        self.assertEqual((first_page, second_page), (1, 0))
        self.assertEqual(client.scene_calls, [])
        self.assertEqual(client.vendor_calls[0][0:2], ("obs-browser", "emit_event"))
        self.assertEqual(client.vendor_calls[0][2]["event_data"]["page"], 1)
        self.assertEqual(client.vendor_calls[1][2]["event_data"]["page"], 0)

    def test_refresh_resets_active_scene_to_page_one(self):
        client = Client("youtube-members")
        with tempfile.TemporaryDirectory() as temporary_directory:
            state_path = Path(temporary_directory) / "page.txt"
            state_path.write_text("1\n", encoding="utf-8")
            with patch.object(youtube_members_scene, "PAGE_STATE_PATH", state_path):
                page, switched = youtube_members_scene.handle_press(
                    client,
                    overlay_refreshed=True,
                )

            saved_page = state_path.read_text(encoding="utf-8").strip()

        self.assertFalse(switched)
        self.assertEqual(page, 0)
        self.assertEqual(saved_page, "0")
        self.assertEqual(client.vendor_calls, [])

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
        self.assertEqual(client.property_calls, [("members", "refreshnocache")])
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
        self.assertEqual(client.property_calls, [("members", "refreshnocache")])

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
        self.assertEqual(client.property_calls, [])

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

        self.assertEqual(client.property_calls, [])


if __name__ == "__main__":
    unittest.main()
