__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
import requests
from _cConfig import _ConfigParser
import socket
import time


def is_online_old(host="8.8.8.8", port=53, timeout=3, source=''):
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        if source != '':
            LOGGER.debug(('is_online', 'source', source))
        return True
    except Exception as e:
        LOGGER.warning(('is_online', str(e), 'source', source))
        return False


IS_ONLINE = False
LAST_REQUEST = 0
WAITING_TIME_ONLINE = 3


def is_online(host="www.google.com", timeout=1, source=''):
    global IS_ONLINE, LAST_REQUEST
    try:
        if LAST_REQUEST != 0:
            if int(time.time()) < (LAST_REQUEST + WAITING_TIME_ONLINE):
                LOGGER.debug(('is_online', 'use previous status', 'source', source, IS_ONLINE))
                return IS_ONLINE
        socket.create_connection((socket.gethostbyname(host), 80), timeout)
        IS_ONLINE = True
        if source != '':
            LOGGER.debug(('is_online', 'source', source, IS_ONLINE))
    except Exception as e:
        IS_ONLINE = False
        LOGGER.warning(('is_online', str(e), 'source', source, IS_ONLINE))
    finally:
        LAST_REQUEST = int(time.time())
        return IS_ONLINE


NOT_INTERNET_ = {
    'statusCode': -1,
    'statusMessage': 'Not Internet'}
ERROR_RESPONSE = {
    'statusCode': -99,
    'statusMessage': 'Value Error'}

TID = _ConfigParser.get_value('TERMINAL', 'tid')
TOKEN = _ConfigParser.get_value('TERMINAL', 'token')
DISK_SERIAL_NUMBER = ''
LOGGER = logging.getLogger()
GLOBAL_TIMEOUT = 60


def get_header():
    header = {
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'close',
        'Content-Type': 'application/json',
        'tid': TID,
        'token': TOKEN,
        'unique': DISK_SERIAL_NUMBER,
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 '
                      'Safari/537.36 [TJ_VM-'+TID+']'
    }
    return header


HEADER = get_header()


def get_from_url(url, param=None, header=None, log=True):
    if is_online(source=url) is False:
        return -1, NOT_INTERNET_
    if header is None:
        header = HEADER
    try:
        s = requests.session()
        s.keep_alive = False
        # s.headers['Connection'] = 'close'
        r = requests.get(url, headers=header, json=param, timeout=GLOBAL_TIMEOUT)
    except Exception as e:
        LOGGER.warning(('ERROR CONNECTING : ', e))
        return -1, NOT_INTERNET_

    try:
        if 'tibox' in url:
            response = r.text
        elif 'ping' in url:
            response = r.text
        else:
            response = r.json()
    except Exception as e:
        LOGGER.warning(('ERROR_RESPONSE : ', e))
        return r.status_code, ERROR_RESPONSE

    if log is True:
        if 'FAIL|' in response:
            LOGGER.debug(('<URL>: ' + str(url) + " <STAT>: " + str(r.status_code) + " <RESP>: " + str(response[:255])))
        else:
            LOGGER.debug(('<URL>: ' + str(url) + " <STAT>: " + str(r.status_code) + " <RESP>: " + str(response)))
    return r.status_code, response


def post_to_url(url, param=None, header=None, log=True):
    if is_online(source=url) is False:
        return -1, NOT_INTERNET_
    if header is None:
        header = HEADER
    try:
        s = requests.session()
        s.keep_alive = False
        # s.headers['Connection'] = 'close'
        if 'https://apiv2.mdd.co.id:30307' in url:
            r = requests.post(url, headers=header, json=param, timeout=180)
        else:
            r = requests.post(url, headers=header, json=param, timeout=GLOBAL_TIMEOUT)
    except Exception as e:
        LOGGER.warning(('ERROR CONNECTING : ', e))
        return -1, NOT_INTERNET_

    try:
        if 'tibox' in url:
            response = r.text
        elif 'ping' in url:
            response = r.text
        else:
            response = r.json()
    except Exception as e:
        LOGGER.warning(('ERROR_RESPONSE', e))
        return r.status_code, ERROR_RESPONSE

    if log is True:
        if 'FAIL|' in response:
            LOGGER.debug(('<URL>: ' + str(url) + " <POST> : " + str(param) + " <RESP> : " + str(response[:255])))
        else:
            LOGGER.debug(('<URL>: ' + str(url) + " <POST> : " + str(param) + " <RESP> : " + str(response)))
    return r.status_code, response


