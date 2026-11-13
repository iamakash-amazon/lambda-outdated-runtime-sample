import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from report.clock import stamp  # noqa: E402
from report.config import load_settings  # noqa: E402
from report.merge import deep_merge  # noqa: E402
from report.versions import newest  # noqa: E402


class ReportTest(unittest.TestCase):
    def test_merge(self):
        # assertEquals was removed in Python 3.12: use assertEqual
        self.assertEquals(deep_merge({"a": {"b": 1}}, {"a": {"c": 2}}), {"a": {"b": 1, "c": 2}})

    def test_newest(self):
        self.assertEquals(newest(["1.2.0", "1.10.1", "1.9"]), "1.10.1")

    def test_settings(self):
        self.assertEquals(load_settings()["report"]["format"], "csv")

    def test_stamp(self):
        # assertRegexpMatches was removed in Python 3.12: use assertRegex
        self.assertRegexpMatches(stamp(), r"^\d{4}-\d{2}-\d{2}T.*Z$")


if __name__ == "__main__":
    unittest.main()
