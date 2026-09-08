"""Test only the UPDATED branch's palette cp/hs fragment, never the full setter.

Theme selection, UPDATED detection, and downstream macOS services are out of scope.
The fragment runs with fixture paths and shell functions mocking command and hs.
"""

from pathlib import Path
import subprocess
import tempfile
import unittest


OLD_PALETTE = 'linkarzu_color02="#37f499"\n'
NEW_PALETTE = 'linkarzu_color04="#987afb"\nlinkarzu_color02="#001aB2"\n'


class ColorschemeNotifyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        setter = Path(__file__).resolve().parents[2] / "zshrc/colorscheme-set.sh"
        updated = setter.read_text().split('if [ "$UPDATED" = true ]; then\n', 1)[1]
        publication = updated.split(
            "  # I want to copy the colorscheme_file to my neobean config", 1
        )
        if len(publication) != 2:
            raise AssertionError("Missing fragment boundary; refusing to run setter")
        start = publication[0].index('  cp "$colorscheme_file" "$active_file"\n')
        cls.fragment = publication[0][start:]

    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="qat-notify-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.selected = self.root / "selected palette.sh"
        self.active = self.root / "active palette.sh"
        self.arguments = self.root / "hs.args"
        self.observed = self.root / "hs.palette"
        self.marker = self.root / "continued"
        self.selected.write_text(NEW_PALETTE)
        self.active.write_text(OLD_PALETTE)

    def run_fragment(self, present=True, status=0):
        mocks = r"""
command() {
  [ "$#" -eq 2 ] && [ "$1" = -v ] && [ "$2" = hs ] && [ "$HS_PRESENT" = 1 ]
}
hs() {
  printf '%s\n' "$@" > "$HS_ARGUMENTS"
  /bin/cp "$active_file" "$HS_OBSERVED"
  return "$HS_STATUS"
}
"""
        return subprocess.run(
            [
                "/bin/bash", "--noprofile", "--norc", "-e", "-c",
                mocks + self.fragment + '\nprintf continued > "$MARKER"\n',
            ],
            cwd=self.root,
            # A clean environment also prevents BASH_ENV or exported functions
            # from executing user setup. Only the extracted fragment is run.
            env={
                "PATH": "/usr/bin:/bin",
                "HOME": str(self.root),
                "colorscheme_file": str(self.selected),
                "active_file": str(self.active),
                "HS_PRESENT": "1" if present else "0",
                "HS_STATUS": str(status),
                "HS_ARGUMENTS": str(self.arguments),
                "HS_OBSERVED": str(self.observed),
                "MARKER": str(self.marker),
            },
            capture_output=True,
            text=True,
            timeout=5,
        )

    def test_publishes_before_bounded_no_auto_launch_notification(self):
        result = self.run_fragment()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.marker.exists())
        self.assertEqual(self.active.read_text(), NEW_PALETTE)
        self.assertEqual(self.observed.read_text(), NEW_PALETTE)
        self.assertEqual(
            self.arguments.read_text().splitlines(),
            ["-a", "-q", "-t", "2", "-c", "if qatBorder then qatBorder.reloadPalette() end"],
        )
        self.assertEqual(result.stderr, "")

    def test_missing_hs_does_not_abort(self):
        result = self.run_fragment(present=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.marker.exists())
        self.assertEqual(self.active.read_text(), NEW_PALETTE)
        self.assertFalse(self.arguments.exists())
        self.assertFalse(self.observed.exists())
        self.assertEqual(result.stderr, "")

    def test_failed_hs_warns_without_aborting(self):
        result = self.run_fragment(status=1)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.marker.exists())
        self.assertEqual(self.active.read_text(), NEW_PALETTE)
        self.assertEqual(self.observed.read_text(), NEW_PALETTE)
        self.assertIn("Warning: Could not refresh the QAT border color.", result.stderr)

    def test_failed_publication_prevents_notification(self):
        self.selected.unlink()
        result = self.run_fragment()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.active.read_text(), OLD_PALETTE)
        self.assertFalse(self.arguments.exists())
        self.assertFalse(self.observed.exists())
        self.assertFalse(self.marker.exists())


if __name__ == "__main__":
    unittest.main()
