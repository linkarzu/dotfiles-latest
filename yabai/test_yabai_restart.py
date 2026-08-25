#!/usr/bin/env python3

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("yabai_restart.sh")


class YabaiRestartTests(unittest.TestCase):
    def run_restart(self, yabai_script: str, *, ready_timeout: str = "1"):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            marker = temp / "config-ready"
            restart_log = temp / "restart.log"
            yabai_log = temp / "yabai.log"
            notification_log = temp / "notification.log"
            yabai = temp / "yabai"
            osascript = temp / "osascript"
            yabai.write_text(yabai_script, encoding="utf-8")
            osascript.write_text(
                f"#!/usr/bin/env bash\nprintf '%s\\n' \"$*\" >>{notification_log!s}\n",
                encoding="utf-8",
            )
            yabai.chmod(0o755)
            osascript.chmod(0o755)
            environment = {
                **os.environ,
                "YABAI_BIN": str(yabai),
                "OSASCRIPT_BIN": str(osascript),
                "YABAI_CONFIG_READY_MARKER": str(marker),
                "YABAI_RESTART_LOG": str(restart_log),
                "YABAI_RESTART_READY_TIMEOUT_SECONDS": ready_timeout,
                "YABAI_RESTART_POLL_SECONDS": "0.01",
                "TEST_MARKER": str(marker),
                "TEST_YABAI_LOG": str(yabai_log),
            }
            completed = subprocess.run(
                [str(SCRIPT)],
                text=True,
                capture_output=True,
                check=False,
                timeout=5,
                env=environment,
            )
            return (
                completed,
                restart_log.read_text(encoding="utf-8"),
                yabai_log.read_text(encoding="utf-8") if yabai_log.exists() else "",
                notification_log.read_text(encoding="utf-8") if notification_log.exists() else "",
            )

    def test_success_requires_marker_and_two_queries(self):
        completed, restart_log, yabai_log, notification_log = self.run_restart(
            """#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_YABAI_LOG"
if [[ "$1" == "--restart-service" ]]; then
  touch "$TEST_MARKER"
  exit 0
fi
exit 0
"""
        )

        self.assertEqual(completed.returncode, 0)
        self.assertEqual(yabai_log.count("-m query --windows"), 2)
        self.assertIn("config-complete-and-two-consecutive-window-queries", restart_log)
        self.assertIn("Yabai restarted", notification_log)

    def test_restart_command_failure_stops_before_queries(self):
        completed, restart_log, yabai_log, notification_log = self.run_restart(
            """#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_YABAI_LOG"
exit 7
"""
        )

        self.assertEqual(completed.returncode, 7)
        self.assertNotIn("-m query --windows", yabai_log)
        self.assertIn("status=failure operation=restart-command exit_status=7", restart_log)
        self.assertIn("Yabai restart failed", notification_log)

    def test_readiness_timeout_stops_and_reports_last_observation(self):
        completed, restart_log, _yabai_log, notification_log = self.run_restart(
            """#!/usr/bin/env bash
exit 0
"""
        )

        self.assertEqual(completed.returncode, 1)
        self.assertIn("status=timeout", restart_log)
        self.assertIn("observed=config-incomplete", restart_log)
        self.assertIn("Yabai restart failed", notification_log)


if __name__ == "__main__":
    unittest.main()
