import imp  # removed in Python 3.12: use importlib
import os

_HERE = os.path.dirname(__file__)


def load_plugin(name):
    path = os.path.join(_HERE, "plugin_%s.py" % name)
    return imp.load_source("report_plugin_%s" % name, path)
