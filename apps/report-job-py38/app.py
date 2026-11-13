"""Nightly report job (Python 3.8).

Upgrade traps (what a runtime upgrade must change):
  - collections.Mapping: removed in Python 3.10 (report/merge.py).
  - distutils: removed in Python 3.12 (report/versions.py).
  - imp: removed in Python 3.12 (report/plugins.py).
  - configparser.SafeConfigParser: removed in Python 3.12 (report/config.py).
  - unittest assertEquals / assertRegexpMatches: removed in Python 3.12 (tests/).
  - datetime.utcnow(): deprecated in 3.12; asyncio.get_event_loop() with no loop: deprecated (report/clock.py).
"""
import json

import boto3

from report.clock import run_at, stamp
from report.config import load_settings
from report.merge import deep_merge
from report.plugins import load_plugin
from report.versions import newest


def handler(event, context):
    settings = load_settings()
    overrides = (event or {}).get("overrides", {})
    merged = deep_merge(settings, overrides)
    who = boto3.client("sts").get_caller_identity()["Account"]
    plugin = load_plugin("summary")
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "account": who,
                "generated": stamp(),
                "ran_at": run_at(),
                "newest_schema": newest(["1.2.0", "1.10.1", "1.9"]),
                "settings": merged,
                "summary": plugin.summarize(merged),
            }
        ),
    }
