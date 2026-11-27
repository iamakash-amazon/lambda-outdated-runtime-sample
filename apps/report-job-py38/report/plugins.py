import importlib.machinery
import importlib.util
import os
import sys

_HERE = os.path.dirname(__file__)


def load_plugin(name):
    path = os.path.join(_HERE, "plugin_%s.py" % name)
    module_name = "report_plugin_%s" % name
    loader = importlib.machinery.SourceFileLoader(module_name, path)
    spec = importlib.util.spec_from_loader(module_name, loader)
    module = importlib.util.module_from_spec(spec)
    previous = sys.modules.get(module_name)
    sys.modules[module_name] = module
    try:
        spec.loader.exec_module(module)
    except BaseException:
        if previous is None:
            sys.modules.pop(module_name, None)
        else:
            sys.modules[module_name] = previous
        raise
    return module
