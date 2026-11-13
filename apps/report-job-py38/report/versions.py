import re

_COMPONENT_RE = re.compile(r"(\d+|[a-z]+|\.)")


def _version_key(version):
    # Same component split as the removed distutils.version.LooseVersion.
    parts = []
    for part in _COMPONENT_RE.split(version):
        if part and part != ".":
            parts.append(int(part) if part.isdigit() else part)
    return parts


def newest(versions):
    return max(versions, key=_version_key)
