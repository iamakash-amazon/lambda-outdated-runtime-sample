from collections import Mapping  # removed in Python 3.10: use collections.abc.Mapping


def deep_merge(base, extra):
    out = dict(base)
    for key, value in extra.items():
        if isinstance(value, Mapping) and isinstance(out.get(key), Mapping):
            out[key] = deep_merge(out[key], value)
        else:
            out[key] = value
    return out
