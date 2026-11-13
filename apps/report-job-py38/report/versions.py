from distutils.version import LooseVersion  # distutils was removed in Python 3.12


def newest(versions):
    return str(max(LooseVersion(v) for v in versions))
