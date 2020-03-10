__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
import sys
import os
import threading
from _cConfig import _ConfigParser
import sqlite3
from _tTools import _Helper

LOCK = threading.Lock()
LOGGER = logging.getLogger()
DB = _ConfigParser.get_value('TERMINAL', 'DB')
DEBUG = True if _ConfigParser.get_set_value('TERMINAL', 'DB^DEBUG', '0') == '1' else False


def row_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return dict(((k, v) for k, v in d.items() if v is not None))


def get_conn():
    conn = sqlite3.connect(sys.path[0] + '/_dDB/' + DB)
    conn.row_factory = row_factory
    return conn


def get_query(sql, parameter, log=True):
    try:
        LOCK.acquire()
        conn__ = get_conn()
        cursor = conn__.cursor().execute(sql, parameter)
        result = cursor.fetchall()
        if DEBUG is True:
            LOGGER.info((sql, len(result)))
        if log is True and DEBUG is True:
            LOGGER.info(result)
    finally:
        LOCK.release()
    return result


def delete_row(sql):
    try:
        LOCK.acquire()
        LOGGER.info(sql)
        print('pyt: [WARNING] ' + str(sql) + ' ' + _Helper.time_string())
        conn__ = sqlite3.connect(sys.path[0] + '/_dDB/' + DB)
        conn__.cursor().execute(sql)
        conn__.commit()
    finally:
        LOCK.release()


def insert_update(sql, parameter, log=True):
    try:
        LOCK.acquire()
        if log is True and DEBUG is True:
            LOGGER.info((sql, str(parameter)))
        conn__ = get_conn()
        conn__.execute(sql, parameter)
        conn__.commit()
    finally:
        LOCK.release()


def init_db():
    try:
        LOCK.acquire()
        conn__ = get_conn()
        with open(sys.path[0] + '/_dDB/_KioskDB.sql') as f:
            conn__.cursor().executescript(f.read())
    finally:
        LOCK.release()


def adjust_db(db):
    if DEBUG is True:
        LOGGER.info(('[DB_ADJUSTMENT] for : ', str(db)))
    ___CONN = sqlite3.connect(sys.path[0] + '/_dDB/' + DB)
    with open(os.path.join(sys.path[0], '_dDB', db)) as d:
        ___CONN.cursor().executescript(d.read())


if __name__ == '__main__':
    __CONN = sqlite3.connect(sys.path[0] + '/_dDB/' + DB)
    with open('_KioskDB.sql') as f:
        __CONN.cursor().executescript(f.read())
