"""Nightly report job (Python 3.13, upgraded from Python 3.8).

Changes made for the runtime upgrade:
  - collections.Mapping -> collections.abc.Mapping (report/merge.py).
  - distutils LooseVersion -> local version key, no new dependency (report/versions.py).
  - imp.load_source -> importlib.util.spec_from_file_location (report/plugins.py).
  - configparser.SafeConfigParser -> configparser.ConfigParser (report/config.py).
  - unittest assertEquals / assertRegexpMatches -> assertEqual / assertRegex (tests/).
  - datetime.utcnow() -> datetime.now(timezone.utc); get_event_loop() -> asyncio.run() (report/clock.py).
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
