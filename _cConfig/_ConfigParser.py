__author__ = 'fitrah.wahyudi.imam@gmail.com'

import sys
import configparser
import os
from shutil import copyfile
import threading

LOCK = threading.Lock()

FILE_SETTING = sys.path[0] + '/setting.ini'
BACKUP_FILE = FILE_SETTING+'.bak'

if not os.path.exists(BACKUP_FILE) and os.stat(FILE_SETTING).st_size != 0:
    copyfile(FILE_SETTING, BACKUP_FILE)


TEMP_SETTING = sys.path[0] + '/_tTmp/temporary.ini'
if not os.path.exists(TEMP_SETTING) and os.stat(FILE_SETTING).st_size != 0:
    copyfile(FILE_SETTING, TEMP_SETTING)
BACKUP_TEMP_FILE = TEMP_SETTING+'.bak'
if not os.path.exists(BACKUP_TEMP_FILE) and os.stat(TEMP_SETTING).st_size != 0:
    copyfile(TEMP_SETTING, BACKUP_TEMP_FILE)


CONF = None
TEMP_CONF = None


def init():
    global CONF
    check_setting = open(FILE_SETTING, 'r').readlines()
    if os.stat(FILE_SETTING).st_size == 0 or len(check_setting) < 10:
        copyfile(BACKUP_FILE, FILE_SETTING)
    else:
        # Re-write Backup File
        copyfile(FILE_SETTING, BACKUP_FILE)
    CONF = configparser.ConfigParser()
    CONF.read(FILE_SETTING)


def init_temp():
    global TEMP_CONF
    check_setting = open(TEMP_SETTING, 'r').readlines()
    if os.stat(TEMP_SETTING).st_size == 0 or len(check_setting) < 10:
        copyfile(BACKUP_TEMP_FILE, TEMP_SETTING)
    else:
        # Re-write Backup File
        copyfile(TEMP_SETTING, BACKUP_TEMP_FILE)
    TEMP_CONF = configparser.ConfigParser()
    TEMP_CONF.read(TEMP_SETTING)


def get_value_temp(section, option):
    if TEMP_CONF is None:
        init_temp()
    try:
        return TEMP_CONF.get(section, option)
    except configparser.NoOptionError:
        return None
    except configparser.NoSectionError:
        return None


def get_value(section, option):
    if section == 'TEMPORARY':
        return get_value_temp(section, option)
    if CONF is None:
        init()
    try:
        return CONF.get(section, option)
    except configparser.NoOptionError:
        return None
    except configparser.NoSectionError:
        return None


def get_set_value(section, option, default=None):
    if section == 'TEMPORARY':
        return get_set_value_temp(section, option, default)
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


def get_set_value_temp(section, option, default=None):
    if TEMP_CONF is None:
        init_temp()
    try:
        return TEMP_CONF.get(section, option)
    except configparser.NoOptionError:
        set_value_temp(section, option, default)
        return TEMP_CONF.get(section, option)
    except configparser.NoSectionError:
        set_value_temp(section, option, default)
        return TEMP_CONF.get(section, option)


def set_value(section, option, value):
    if section == 'TEMPORARY':
        return set_value_temp(section, option, value)
    if CONF is None:
        init()
    if section not in CONF.sections():
        add_section(section)
    try:
        LOCK.acquire()
        CONF.set(section, option, value)
        save_file()
    finally:
        LOCK.release()


def set_value_temp(section, option, value):
    if TEMP_CONF is None:
        init_temp()
    if section not in TEMP_CONF.sections():
        add_section_temp(section)
    try:
        LOCK.acquire()
        TEMP_CONF.set(section, option, value)
        save_file_temp()
    finally:
        LOCK.release()


def add_section(section):
    CONF.add_section(section)


def save_file():
    CONF.write(open(FILE_SETTING, 'w'))


def add_section_temp(section):
    TEMP_CONF.add_section(section)


def save_file_temp():
    TEMP_CONF.write(open(TEMP_SETTING, 'w'))
