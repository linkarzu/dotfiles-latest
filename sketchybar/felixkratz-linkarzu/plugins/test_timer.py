import importlib.util
import signal
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import call, patch


MODULE_PATH = Path(__file__).with_name("timer.py")
SPEC = importlib.util.spec_from_file_location("timer", MODULE_PATH)
timer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(timer)


class TimerTests(unittest.TestCase):
    def test_parse_sequence_rejects_nonpositive_duration(self):
        with self.assertRaisesRegex(ValueError, "greater than zero"):
            timer.parse_sequence("Sit:0")

    def test_stop_running_verifies_process_exit_before_removing_pid(self):
        running_checks = iter([True] * 23)
        with (
            patch.object(timer, "read_pid", return_value=123),
            patch.object(timer.os, "getpid", return_value=456),
            patch.object(timer, "is_timer_process", return_value=True),
            patch.object(timer, "is_process_running", side_effect=lambda _pid: next(running_checks)),
            patch.object(timer.os, "kill") as kill,
            patch.object(timer.os, "remove") as remove,
            patch.object(timer.time, "sleep"),
            self.assertRaisesRegex(RuntimeError, "did not stop"),
        ):
            timer.stop_running(clear_label=False)

        self.assertEqual(kill.call_args_list[-1].args, (123, signal.SIGKILL))
        remove.assert_not_called()

    def test_stop_running_removes_pid_after_verified_exit(self):
        running_checks = iter([True, False, False, False])
        with (
            patch.object(timer, "read_pid", return_value=123),
            patch.object(timer.os, "getpid", return_value=456),
            patch.object(timer, "is_timer_process", return_value=True),
            patch.object(timer, "is_process_running", side_effect=lambda _pid: next(running_checks)),
            patch.object(timer.os, "kill") as kill,
            patch.object(timer.os, "remove") as remove,
            patch.object(timer.time, "sleep"),
        ):
            timer.stop_running(clear_label=False)

        kill.assert_called_once_with(123, signal.SIGTERM)
        remove.assert_has_calls([call(timer.PID_FILE), call(timer.READY_FILE)])

    def test_first_successful_label_update_marks_timer_ready(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            pid_file = Path(temporary_directory) / "timer.pid"
            ready_file = Path(temporary_directory) / "timer.ready"
            with (
                patch.object(timer, "PID_FILE", str(pid_file)),
                patch.object(timer, "READY_FILE", str(ready_file)),
                patch.object(timer.subprocess, "run"),
            ):
                timer.write_pid()
                timer.set_timer_label("Sit: 30:00")

            self.assertEqual(ready_file.read_text(encoding="utf-8"), str(timer.os.getpid()))

    def test_failed_label_update_does_not_mark_timer_ready(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            pid_file = Path(temporary_directory) / "timer.pid"
            ready_file = Path(temporary_directory) / "timer.ready"
            with (
                patch.object(timer, "PID_FILE", str(pid_file)),
                patch.object(timer, "READY_FILE", str(ready_file)),
                patch.object(
                    timer.subprocess,
                    "run",
                    side_effect=subprocess.CalledProcessError(1, ["sketchybar"]),
                ),
                self.assertRaises(subprocess.CalledProcessError),
            ):
                timer.write_pid()
                timer.set_timer_label("Sit: 30:00")

            self.assertFalse(ready_file.exists())


if __name__ == "__main__":
    unittest.main()
