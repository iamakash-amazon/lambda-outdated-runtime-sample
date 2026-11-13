import importlib.util
import os
import sys

_HERE = os.path.dirname(__file__)


def load_plugin(name):
    path = os.path.join(_HERE, "plugin_%s.py" % name)
    module_name = "report_plugin_%s" % name
    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module
