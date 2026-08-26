import contextlib
import importlib.util
import io
import subprocess
import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from types import ModuleType, SimpleNamespace
from unittest.mock import Mock, patch


MODULE_PATH = Path(__file__).with_name("switch_scene.py")
SPEC = importlib.util.spec_from_file_location("switch_scene", MODULE_PATH)
switch_scene = importlib.util.module_from_spec(SPEC)
obs_stub = ModuleType("obsws_python")
obs_stub.ReqClient = Mock()
with patch.dict(sys.modules, {"obsws_python": obs_stub}):
    SPEC.loader.exec_module(switch_scene)


class SwitchSceneTests(unittest.TestCase):
    def run_main(
        self,
        client,
        scene_name="requested-scene",
        no_auth=True,
        banner=False,
        create_side_effect=None,
    ):
        if isinstance(client, Mock) and isinstance(
            client.get_current_program_scene.return_value, Mock
        ):
            client.get_current_program_scene.return_value = SimpleNamespace(
                current_program_scene_name=scene_name
            )
        stdout = io.StringIO()
        stderr = io.StringIO()
        with patch.object(
            switch_scene,
            "create_obs_client",
            return_value=client,
            side_effect=create_side_effect,
        ), patch.object(
            switch_scene.os.path, "exists", return_value=banner
        ), patch.object(
            sys,
            "argv",
            [str(MODULE_PATH), scene_name] + (["--no-auth"] if no_auth else []),
        ), contextlib.redirect_stdout(
            stdout
        ), contextlib.redirect_stderr(stderr):
            status = switch_scene.main()
        return status, stdout.getvalue(), stderr.getvalue()

    def test_success_returns_zero_and_reports_switched_scene(self):
        client = Mock()

        status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 0)
        self.assertIn("status=start expected=requested-scene", stdout)
        self.assertIn(
            "status=success attempt=1 expected=requested-scene observed=requested-scene",
            stdout,
        )
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))
        self.assertEqual(stderr, "")
        client.set_current_program_scene.assert_called_once_with("requested-scene")
        client.get_current_program_scene.assert_called_once_with()
        client.disconnect.assert_called_once_with()

    def test_delayed_success_polls_until_obs_reports_requested_scene(self):
        client = Mock()
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )
        client.get_current_program_scene.side_effect = [
            SimpleNamespace(current_program_scene_name="old-scene"),
            SimpleNamespace(current_program_scene_name="requested-scene"),
        ]

        with patch.object(switch_scene.time, "sleep") as sleep:
            status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 0)
        self.assertEqual(stderr, "")
        self.assertIn("status=waiting attempt=1", stdout)
        self.assertIn("status=success attempt=2", stdout)
        sleep.assert_called_once_with(switch_scene.SCENE_SWITCH_POLL_INTERVAL)

    def test_persistent_scene_mismatch_times_out(self):
        client = Mock()
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )

        with patch.object(switch_scene, "SCENE_SWITCH_TIMEOUT", 0):
            status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 1)
        self.assertNotIn("Switched to scene", stdout + stderr)
        self.assertIn("status=timeout", stderr)
        self.assertIn("observed=old-scene", stderr)
        self.assertIn("Error: OBS program scene could not be authoritatively verified", stderr)

    def test_request_exception_is_success_when_observed_scene_matches(self):
        client = Mock()
        client.set_current_program_scene.side_effect = TimeoutError("request timed out")

        status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 0)
        self.assertEqual(stderr, "")
        self.assertIn("status=uncertain request_status=error error_type=TimeoutError", stdout)
        self.assertIn("request_status=error-reconciled", stdout)
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))

    def test_request_exception_unresolved_returns_nonzero(self):
        client = Mock()
        client.set_current_program_scene.side_effect = TimeoutError("request timed out")
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )

        with patch.object(switch_scene, "SCENE_SWITCH_TIMEOUT", 0):
            status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 1)
        self.assertIn("status=uncertain", stdout)
        self.assertIn("status=timeout", stderr)
        self.assertIn("request_status=error", stderr)
        self.assertIn("request_error_type=TimeoutError", stderr)
        self.assertNotIn("request timed out", stdout + stderr)

    def test_successful_banner_update_is_atomic_and_triggers_sketchybar(self):
        client = Mock()
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            with patch.object(
                switch_scene.os.path,
                "expanduser",
                return_value=str(banner_path),
            ), patch.object(switch_scene, "trigger_sketchybar_update") as trigger:
                status, stdout, stderr = self.run_main(client, banner=True)
            banner_contents = banner_path.read_text(encoding="utf-8")
            remaining_files = list(banner_path.parent.iterdir())

        self.assertEqual(status, 0)
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))
        self.assertEqual(stderr, "")
        self.assertEqual(banner_contents, "requested-scene")
        self.assertEqual(remaining_files, [banner_path])
        trigger.assert_called_once_with("requested-scene")
        client.disconnect.assert_called_once_with()

    def test_sketchybar_failure_restores_marker_and_verifies_prior_label(self):
        banner_client = Mock()
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            with patch.object(
                switch_scene.os.path,
                "expanduser",
                return_value=str(banner_path),
            ), patch.object(
                switch_scene,
                "trigger_sketchybar_update",
                side_effect=[
                    RuntimeError("SketchyBar trigger failed with exit status 7."),
                    None,
                ],
            ) as trigger:
                status, stdout, stderr = self.run_main(banner_client, banner=True)

            banner_contents = banner_path.read_text(encoding="utf-8")

        self.assertEqual(status, 1)
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))
        self.assertIn("status=failure", stderr)
        self.assertIn("rollback=success", stderr)
        self.assertIn("marker_restored=true", stderr)
        self.assertIn("sketchybar_restored=true", stderr)
        self.assertEqual(banner_contents, "previous-scene")
        self.assertEqual(
            trigger.call_args_list,
            [
                unittest.mock.call("requested-scene"),
                unittest.mock.call("previous-scene", step="banner-rollback"),
            ],
        )
        banner_client.disconnect.assert_called_once_with()

    def test_sketchybar_failure_preserves_uncertain_rollback_evidence(self):
        client = Mock()
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_bytes(b"previous-scene")
            with patch.object(
                switch_scene.os.path, "expanduser", return_value=str(banner_path)
            ), patch.object(
                switch_scene,
                "trigger_sketchybar_update",
                side_effect=[
                    RuntimeError("SketchyBar banner state could not be verified."),
                    RuntimeError("SketchyBar rollback state could not be verified."),
                ],
            ):
                status, _stdout, stderr = self.run_main(client, banner=True)
            banner_contents = banner_path.read_bytes()

        self.assertEqual(status, 1)
        self.assertEqual(banner_contents, b"previous-scene")
        self.assertIn("rollback=failure-unverified", stderr)
        self.assertIn("marker_restored=true", stderr)
        self.assertIn("sketchybar_restored=false", stderr)
        self.assertIn("SketchyBar rollback state could not be verified", stderr)

    def test_sketchybar_banner_query_polls_until_drawing_is_on(self):
        responses = [
            subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
            subprocess.CompletedProcess(
                [],
                0,
                stdout='{"icon":{"drawing":"off"},"label":{"drawing":"on","value":"requested-scene"}}',
                stderr="",
            ),
            subprocess.CompletedProcess(
                [],
                0,
                stdout='{"icon":{"drawing":"on"},"label":{"drawing":"on","value":"requested-scene"}}',
                stderr="",
            ),
        ]
        with patch.object(
            switch_scene.subprocess, "run", side_effect=responses
        ) as run, patch.object(switch_scene.time, "sleep") as sleep:
            switch_scene.trigger_sketchybar_update("requested-scene")

        self.assertEqual(run.call_count, 3)
        self.assertEqual(run.call_args_list[-1].args[0], ["sketchybar", "--query", "custom_text"])
        sleep.assert_called_once_with(switch_scene.SCENE_SWITCH_POLL_INTERVAL)

    def test_sketchybar_banner_label_mismatch_times_out_and_fails_closed(self):
        responses = [
            subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
            subprocess.CompletedProcess(
                [],
                0,
                stdout='{"icon":{"drawing":"on"},"label":{"drawing":"on","value":"stale-scene"}}',
                stderr="",
            ),
        ]
        with patch.object(switch_scene, "SKETCHYBAR_VERIFY_TIMEOUT", 0), patch.object(
            switch_scene.subprocess, "run", side_effect=responses
        ), self.assertRaisesRegex(RuntimeError, "could not be verified"):
            switch_scene.trigger_sketchybar_update("requested-scene")

    def test_obs_rejection_returns_nonzero_without_success_output(self):
        client = Mock()
        client.set_current_program_scene.side_effect = RuntimeError("OBS rejected scene")
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )

        with patch.object(switch_scene, "SCENE_SWITCH_TIMEOUT", 0):
            status, stdout, stderr = self.run_main(client)

        self.assertEqual(status, 1)
        self.assertIn("status=uncertain", stdout)
        self.assertIn("status=timeout", stderr)
        self.assertNotIn("OBS rejected scene", stdout + stderr)
        self.assertNotIn("Switched to scene", stdout + stderr)
        client.disconnect.assert_called_once_with()

    def test_sketchybar_label_drawing_off_fails_closed(self):
        responses = [
            subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
            subprocess.CompletedProcess(
                [],
                0,
                stdout='{"icon":{"drawing":"on"},"label":{"drawing":"off","value":"requested-scene"}}',
                stderr="",
            ),
        ]
        with patch.object(switch_scene, "SKETCHYBAR_VERIFY_TIMEOUT", 0), patch.object(
            switch_scene.subprocess, "run", side_effect=responses
        ), self.assertRaisesRegex(RuntimeError, "label-drawing-off"):
            switch_scene.trigger_sketchybar_update("requested-scene")

    def test_component_diagnostics_declares_path_marks_invocation_and_rotates(self):
        stdout = io.StringIO()
        stderr = io.StringIO()
        original_stdout, original_stderr = sys.stdout, sys.stderr
        with tempfile.TemporaryDirectory() as temporary_directory:
            log_path = Path(temporary_directory) / "cache" / "scene-switcher.log"
            sys.stdout, sys.stderr = stdout, stderr
            diagnostics = switch_scene.install_diagnostics(
                "scene-switcher",
                log_path,
            )
            try:
                print("stdout evidence")
                print("stderr evidence", file=sys.stderr)
                diagnostics.finish("success", 0)
            finally:
                diagnostics.close()
                sys.stdout, sys.stderr = original_stdout, original_stderr
            logged = log_path.read_text(encoding="utf-8")

            rotation_path = log_path.with_name("rotation.log")
            sys.stdout, sys.stderr = io.StringIO(), io.StringIO()
            rotation = switch_scene.install_diagnostics(
                "rotation-test",
                rotation_path,
                max_bytes=350,
                backup_count=2,
            )
            try:
                for index in range(20):
                    print(f"rotation evidence {index:02d} " + "x" * 30)
                rotation.finish("success", 0)
            finally:
                rotation.close()
                sys.stdout, sys.stderr = original_stdout, original_stderr
            rotation_files = sorted(rotation_path.parent.glob("rotation.log*"))
            rotation_sizes = [path.stat().st_size for path in rotation_files]

            oversized_path = log_path.with_name("oversized.log")
            sys.stdout, sys.stderr = io.StringIO(), io.StringIO()
            oversized = switch_scene.install_diagnostics(
                "oversized-test",
                oversized_path,
                max_bytes=200,
                backup_count=3,
            )
            try:
                print("y" * 600, end="")
                oversized.finish("success", 0)
            finally:
                oversized.close()
                sys.stdout, sys.stderr = original_stdout, original_stderr
            oversized_sizes = [
                path.stat().st_size
                for path in oversized_path.parent.glob("oversized.log*")
            ]

        terminal_output = stdout.getvalue()
        self.assertIn(f'event=diagnostic-path path="{log_path}"', terminal_output)
        self.assertIn("event=invocation-start", terminal_output)
        self.assertIn("stdout evidence", terminal_output)
        self.assertEqual(stderr.getvalue(), "stderr evidence\n")
        self.assertIn("stdout evidence", logged)
        self.assertIn("stderr evidence", logged)
        self.assertIn('event=invocation-end status="success" exit_status=0', logged)
        marker = next(line for line in terminal_output.splitlines() if "event=invocation-start" in line)
        timestamp = marker.split(" ", 1)[0].removeprefix("timestamp=")
        self.assertIsNotNone(datetime.fromisoformat(timestamp).tzinfo)
        self.assertEqual(len(rotation_files), 3)
        self.assertTrue(all(size <= 350 for size in rotation_sizes))
        self.assertTrue(oversized_sizes)
        self.assertTrue(all(size <= 200 for size in oversized_sizes))

        cleanup_client = Mock()
        cleanup_client.set_current_program_scene.side_effect = RuntimeError(
            "primary OBS failure"
        )
        cleanup_client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )
        cleanup_client.disconnect.side_effect = RuntimeError("disconnect failure")

        with patch.object(switch_scene, "SCENE_SWITCH_TIMEOUT", 0):
            status, stdout, stderr = self.run_main(cleanup_client)

        self.assertEqual(status, 1)
        self.assertIn("status=timeout", stderr)
        self.assertNotIn("primary OBS failure", stdout + stderr)
        self.assertNotIn("disconnect failure", stdout + stderr)
        cleanup_client.disconnect.assert_called_once_with()

    def test_unresolved_scene_does_not_publish_banner(self):
        client = Mock()
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )
        with patch.object(switch_scene, "SCENE_SWITCH_TIMEOUT", 0), patch.object(
            switch_scene, "write_banner_atomic"
        ) as write_banner, patch.object(
            switch_scene, "trigger_sketchybar_update"
        ) as trigger:
            status, _stdout, _stderr = self.run_main(client, banner=True)

        self.assertEqual(status, 1)
        write_banner.assert_not_called()
        trigger.assert_not_called()

    def test_disconnect_only_failure_returns_nonzero_and_skips_banner(self):
        client = Mock()
        client.disconnect.side_effect = RuntimeError("disconnect failure")

        status, stdout, stderr = self.run_main(client, banner=True)

        self.assertEqual(status, 1)
        self.assertIn("status=success attempt=1", stdout)
        self.assertNotIn("Switched to scene", stdout)
        self.assertEqual(stderr, "Error: disconnect failure\n")
        client.set_current_program_scene.assert_called_once_with("requested-scene")
        client.disconnect.assert_called_once_with()

    def test_downstream_exception_redacts_retrieved_password(self):
        password = "SENTINEL-OBS-PASSWORD"
        client = Mock()
        client.set_current_program_scene.side_effect = RuntimeError(
            f"request failed with password={password}"
        )
        client.get_current_program_scene.return_value = SimpleNamespace(
            current_program_scene_name="old-scene"
        )
        with patch.object(switch_scene, "get_password", return_value=password), patch.object(
            switch_scene, "SCENE_SWITCH_TIMEOUT", 0
        ):
            status, stdout, stderr = self.run_main(client, no_auth=False)

        self.assertEqual(status, 1)
        self.assertIn("error_type=RuntimeError", stdout)
        self.assertIn("status=timeout", stderr)
        self.assertNotIn(password, stdout + stderr)
        client.disconnect.assert_called_once_with()

    def test_constructor_failure_disconnects_partial_client_and_preserves_error(self):
        primary_error = RuntimeError("constructor authentication failure")
        partial_client = None

        class FailingReqClient:
            def __init__(self, **kwargs):
                nonlocal partial_client
                partial_client = self
                self.disconnect = Mock(side_effect=RuntimeError("cleanup failure"))
                raise primary_error

        with patch.object(switch_scene.obs, "ReqClient", FailingReqClient):
            with self.assertRaisesRegex(RuntimeError, "constructor authentication failure"):
                switch_scene.create_obs_client(password="secret")

        partial_client.disconnect.assert_called_once_with()

        status, stdout, stderr = self.run_main(
            Mock(),
            create_side_effect=primary_error,
        )
        self.assertEqual(status, 1)
        self.assertEqual(stdout, "")
        self.assertEqual(stderr, "Error: constructor authentication failure\n")

    def test_credential_command_failure_is_redacted(self):
        sentinel = "SENTINEL-OP-SECRET"
        credential_client = Mock()
        credential_error = subprocess.CalledProcessError(
            9,
            ["op", "read"],
            output=f"unsafe output {sentinel}".encode(),
        )
        with patch.object(
            switch_scene.subprocess,
            "check_output",
            side_effect=credential_error,
        ):
            status, stdout, stderr = self.run_main(
                credential_client,
                no_auth=False,
            )

        self.assertEqual(status, 1)
        self.assertEqual(stdout, "")
        self.assertEqual(
            stderr,
            "Error: Unable to retrieve OBS password from 1Password "
            "(op read exited 9)\n",
        )
        self.assertNotIn(sentinel, stdout + stderr)
        credential_client.set_current_program_scene.assert_not_called()
        credential_client.disconnect.assert_not_called()

    def test_banner_temporary_creation_failure_is_redacted_and_skips_sketchybar(self):
        client = Mock()
        sentinel = "SENTINEL-BANNER-PATH"
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            with patch.object(
                switch_scene.os.path, "expanduser", return_value=str(banner_path)
            ), patch.object(
                switch_scene.tempfile, "mkstemp", side_effect=OSError(sentinel)
            ), patch.object(
                switch_scene, "trigger_sketchybar_update"
            ) as trigger:
                status, stdout, stderr = self.run_main(client, banner=True)

        self.assertEqual(status, 1)
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))
        self.assertEqual(
            stderr,
            "Partial failure: OBS switched to scene 'requested-scene', but the banner "
            "file could not be written; SketchyBar was not updated.\n",
        )
        self.assertNotIn(sentinel, stdout + stderr)
        self.assertNotIn("Traceback", stdout + stderr)
        trigger.assert_not_called()
        client.disconnect.assert_called_once_with()

    def test_banner_failure_preserves_previous_content_and_cleans_temporary(self):
        client = Mock()
        sentinel = "SENTINEL-BANNER-CONTENTS"
        with tempfile.TemporaryDirectory() as temporary_directory:
            banner_path = Path(temporary_directory) / "youtube-banner.txt"
            banner_path.write_text("previous-scene", encoding="utf-8")
            with patch.object(
                switch_scene.os.path,
                "expanduser",
                return_value=str(banner_path),
            ), patch.object(
                switch_scene.os, "replace", side_effect=OSError(sentinel)
            ), patch.object(
                switch_scene, "trigger_sketchybar_update"
            ) as trigger:
                status, stdout, stderr = self.run_main(client, banner=True)

            banner_contents = banner_path.read_text(encoding="utf-8")
            remaining_files = list(banner_path.parent.iterdir())

        self.assertEqual(status, 1)
        self.assertTrue(stdout.endswith("Switched to scene: requested-scene\n"))
        self.assertEqual(
            stderr,
            "Partial failure: OBS switched to scene 'requested-scene', but the banner "
            "file could not be written; SketchyBar was not updated.\n",
        )
        self.assertNotIn(sentinel, stdout + stderr)
        self.assertNotIn("Traceback", stdout + stderr)
        self.assertEqual(banner_contents, "previous-scene")
        self.assertEqual(remaining_files, [banner_path])
        trigger.assert_not_called()
        client.disconnect.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()
