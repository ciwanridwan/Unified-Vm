__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
from multiprocessing.dummy import Pool as ThreadPool
import uuid
import time
import datetime
from _cConfig import _ConfigParser
import random
import binascii
from _nNetwork import _NetworkAccess

LOGGER = logging.getLogger()
POOL = ThreadPool(16)


def get_pool():
    return POOL
    

def get_global_port(device_name, default_baud_rate, default_port, default_timeout=1):
    baudrate = default_baud_rate
    port = default_port
    timeout = default_timeout
    if _ConfigParser.get_value(device_name, 'baudrate'):
        baudrate = int(_ConfigParser.get_value(device_name, 'baudrate'))
    if _ConfigParser.get_value(device_name, 'port'):
        port = _ConfigParser.get_value(device_name, 'port')
    if _ConfigParser.get_value(device_name, 'timeout'):
        timeout = int(_ConfigParser.get_value(device_name, 'timeout'))
    __RES = {'baudrate': baudrate, 'port': port, 'timeout': timeout}
    LOGGER.debug((device_name, __RES))
    return __RES


def now():
    return int(time.time()) * 1000


def today():
    now_time = time.time()
    midnight = now_time - now_time % 86400 + time.timezone
    return int(midnight) * 1000


def today_time():
    now_time = time.time()
    midnight = now_time - now_time % 86400 + time.timezone
    return int(midnight)


def time_string(f='%Y-%m-%d %H:%M:%S'):
    return datetime.datetime.now().strftime(f)


def get_uuid():
    return str(uuid.uuid1().hex)


def get_value_from(key, map_, default_value=None):
    if map_ is None:
        return default_value
    if key in map_.keys():
        return map_[key]
    return default_value


def get_random_chars(length=3, chars='ABCDEFGHJKMNPQRSTUVWXYZ'):
    random_ = ''
    i = 0
    while i < length:
        random_ += random.choice(chars)
        i += 1
    return random_


def file2crc32(filename):
    try:
        buf = open(filename, 'rb').read()
        buf = (binascii.crc32(buf) & 0xFFFFFFFF)
        return "%08X" % buf
    except Exception as e:
        LOGGER.warning(('file2crc32', filename, str(e)))
        return False


def is_online(source=''):
    return _NetworkAccess.is_online(source=source)

