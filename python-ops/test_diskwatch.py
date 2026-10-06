import json
import unittest
from unittest import mock

import diskwatch


class DiskwatchTest(unittest.TestCase):
    def test_ok_below_threshold(self):
        with mock.patch("diskwatch.shutil.disk_usage", return_value=(100, 50, 50)):
            rows = diskwatch.check(["/"], 90)
        self.assertEqual(rows, [{"path": "/", "used_pct": 50.0, "ok": True}])

    def test_fails_above_threshold(self):
        with mock.patch("diskwatch.shutil.disk_usage", return_value=(100, 95, 5)):
            self.assertFalse(diskwatch.check(["/"], 90)[0]["ok"])

    def test_missing_path_is_reported(self):
        rows = diskwatch.check(["/definitely/not/here"], 90)
        self.assertFalse(rows[0]["ok"])
        self.assertIn("error", rows[0])

    def test_exit_codes(self):
        with mock.patch("diskwatch.shutil.disk_usage", return_value=(100, 95, 5)), \
                mock.patch("builtins.print") as p:
            self.assertEqual(diskwatch.main(["/"]), 1)
            self.assertFalse(json.loads(p.call_args[0][0])[0]["ok"])
        self.assertEqual(diskwatch.main(["--threshold", "0"]), 2)


if __name__ == "__main__":
    unittest.main()
