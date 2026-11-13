import re

_PART = re.compile(r"(\d+|[a-z]+|\.)", re.IGNORECASE)


def _version_key(version):
    """Ordering key equivalent to the removed distutils LooseVersion."""
    parts = []
    for part in _PART.split(version):
        if part and part != ".":
            parts.append(int(part) if part.isdigit() else part)
    return parts


def newest(versions):
    return str(max(versions, key=_version_key))
