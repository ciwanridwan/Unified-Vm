__author__ = 'fitrah.wahyudi.imam@gmail.com'

import sys
import configparser
FILE_NAME = sys.path[0] + '/setting.ini'

conf = None


def init():
    global conf
    conf = configparser.ConfigParser()
    conf.read(FILE_NAME)


def get_value(section, option):
    if conf is None:
        init()
    try:
        return conf.get(section, option)
    except configparser.NoOptionError:
        return None
    except configparser.NoSectionError:
        return None


def get_set_value(section, option, default=None):
    if conf is None:
        init()
    try:
        return conf.get(section, option)
    except configparser.NoOptionError:
        set_value(section, option, default)
        return conf.get(section, option)
    except configparser.NoSectionError:
        set_value(section, option, default)
        return conf.get(section, option)


def set_value(section, option, value):
    if conf is None:
        init()
    if section not in conf.sections():
        add_section(section)
    conf.set(section, option, value)
    save_file()


def add_section(section):
    conf.add_section(section)


def save_file():
    conf.write(open(FILE_NAME, 'w'))
