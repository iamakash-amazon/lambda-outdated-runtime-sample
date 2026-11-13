import asyncio
import datetime


def stamp():
    now = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)
    return now.isoformat() + "Z"


async def _now():
    return stamp()


def run_at():
    return asyncio.run(_now())
