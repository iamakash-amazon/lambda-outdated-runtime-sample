import configparser
import os

_INI = os.path.join(os.path.dirname(os.path.dirname(__file__)), "settings.ini")


def load_settings():
    parser = configparser.SafeConfigParser()  # removed in Python 3.12: use ConfigParser
    parser.read(_INI)
    return {section: dict(parser.items(section)) for section in parser.sections()}
