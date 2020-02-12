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
import subprocess
from sys import _getframe as whois

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
    midnight = now_time - (now_time % 86400) + time.timezone
    return int(midnight)


TIME_FORMAT = '%Y-%m-%d %H:%M:%S'


def convert_epoch(t = None, f=''):
    if t is None:
        t = time.time()
    if len(f) == 0:
        f = TIME_FORMAT
    return datetime.datetime.fromtimestamp(t).strftime(f)


def time_string(f=''):
    if len(f) == 0:
        f = TIME_FORMAT
    return datetime.datetime.now().strftime(f)


def get_uuid():
    return str(uuid.uuid1().hex)


def get_value_from(__key, __map, __default=None):
    if __map is None:
        return __default
    if __key in __map.keys():
        return __map[__key]
    return __default


def get_random_chars(length=3, chars='ABCDEFGHJKMNPQRSTUVWXYZ'):
    __random = ''
    i = 0
    while i < length:
        __random += random.choice(chars)
        i += 1
    return __random


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


def get_ds(string, length=4, log=False):
    salt = 'MDDCOID'
    __ = str(abs(hash(string+salt)) % (10 ** length))
    if len(__) != length:
        __ = (__[0] * (length-len(__))) + __
    if log is True:
        LOGGER.debug(('length', length, 'hash', __, 'string', str(string+salt)))
    return __


def reverse_hexdec(string):
    __hex1 = string[46:54]
    __hex2 = string[54:62]
    __front = string[:46]
    __back = string[62:]
    __dec1 = int("".join(map(str.__add__, __hex1[-2::-2], __hex1[-1::-2])), 16)
    __dec2 = int("".join(map(str.__add__, __hex2[-2::-2], __hex2[-1::-2])), 16)
    return str(__front) + str(__dec1).zfill(8) + str(__dec2).zfill(8) + str(__back)


def dump(s, iterate=False):
    caller = whois(1).f_code.co_name
    if type(s) == str:
        print('pyt: DUMP [' + str(caller) + '] >>> ' + str(type(s)) + ' >>> ' + str(s))
    elif type(s) == list:
        if iterate is True:
            for l in s:
                print('pyt: DUMP [' + str(caller) + '] >>> ' + str(type(l)) + ' >>> ' + str(l))
        else:
            print('pyt: DUMP [' + str(caller) + '] >>> ' + str(type(s)) + ' >>> ' + str(s))
    else:
        print('pyt: DUMP [' + str(caller) + '] >>> ' + str(type(s)) + ' >>> ' + str(s))


def os_command(command, key, reverse=False):
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    response = process.communicate()[0].decode('utf-8').strip().split("\r\n")
    dump(command)
    dump(response)
    if len(response) > 0:
        if not reverse and key in response[-1]:
            return True
        elif reverse is True and key not in response:
            return True
        else:
            return False
    else:
        return False


