import re

_COMPONENT_RE = re.compile(r"(\d+|[a-z]+|\.)")


def _version_key(vstring):
    # Same parsing as the removed distutils.version.LooseVersion.
    parts = [p for p in _COMPONENT_RE.split(vstring) if p and p != "."]
    return tuple(int(p) if p.isdigit() else p for p in parts)


def newest(versions):
    return str(max(versions, key=_version_key))
