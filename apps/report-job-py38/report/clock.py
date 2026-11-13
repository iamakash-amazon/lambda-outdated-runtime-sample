import asyncio
import datetime


def stamp():
    return datetime.datetime.utcnow().isoformat() + "Z"  # deprecated in 3.12: use datetime.now(timezone.utc)


async def _now():
    return stamp()


def run_at():
    loop = asyncio.get_event_loop()  # deprecated with no running loop: use asyncio.run()
    return loop.run_until_complete(_now())
