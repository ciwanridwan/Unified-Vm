__author__ = 'fitrah.wahyudi.imam@gmail.com'

import sys
import configparser
import os
from shutil import copyfile

FILE_NAME = sys.path[0] + '/setting.ini'
BACKUP_FILE = FILE_NAME+'.bak'

if not os.path.exists(BACKUP_FILE):
    copyfile(FILE_NAME, BACKUP_FILE)


CONF = None


def init():
    global CONF
    check_setting = open(FILE_NAME, 'r').readlines()
    if os.stat(FILE_NAME).st_size == 0 or len(check_setting) < 10:
        copyfile(BACKUP_FILE, FILE_NAME)
    CONF = configparser.ConfigParser()
    CONF.read(FILE_NAME)


def get_value(section, option):
    if CONF is None:
        init()
    try:
        return CONF.get(section, option)
    except configparser.NoOptionError:
        return None
    except configparser.NoSectionError:
        return None


def get_set_value(section, option, default=None):
    if CONF is None:
        init()
    try:
        return CONF.get(section, option)
    except configparser.NoOptionError:
        set_value(section, option, default)
        return CONF.get(section, option)
    except configparser.NoSectionError:
        set_value(section, option, default)
        return CONF.get(section, option)


def set_value(section, option, value):
    if CONF is None:
        init()
    if section not in CONF.sections():
        add_section(section)
    CONF.set(section, option, value)
    save_file()


def add_section(section):
    CONF.add_section(section)


def save_file():
    CONF.write(open(FILE_NAME, 'w'))
