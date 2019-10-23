__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Global
from _tTools import _Tools
from _nNetwork import _NetworkAccess
import hashlib
import os
import sys


class UpdateAppSignalHandler(QObject):
    __qualname__ = 'UpdateAppSignalHandler'
    SIGNAL_UPDATE_APP = pyqtSignal(str)


UPDATEAPP_SIGNDLER = UpdateAppSignalHandler()
LOGGER = logging.getLogger()

PORT = '' if _Global.LIVE_MODE is False else ':44195'
HOST = 'git.mdd.co.id%s'.format(PORT)
REPO = 'https://%s:%s@%s/mdd_dev/mandiri-kiosk.git'.format(_Global.REPO_USERNAME, _Global.REPO_PASSWORD, HOST)


def check_init():
    return _Tools.os_command(command='git init', key='Git Repository')


def check_origin():
    return _Tools.os_command(command='git remote -v', key=HOST)


def add_origin():
    return _Tools.os_command(command='git remote add origin %s'.format(REPO), key='fatal', reverse=True)


def set_credential():
    return _Tools.os_command(command='git config credential.helper store', key='error', reverse=True)


def pull(origin='master'):
    return _Tools.os_command(command='git pull -f origin %s'.format(origin), key='error', reverse=True)


def start_do_update():
    _Tools.get_pool().apply_async(do_update)


def do_update():
    if not check_init():
        UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_CHECK_INIT')
        return 'APP_UPDATE|FAILED_CHECK_INIT'
    if not check_origin():
        if not add_origin():
            UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_ADD_ORIGIN')
            return 'APP_UPDATE|FAILED_ADD_ORIGIN'
        set_credential()
    if not pull():
        UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_PULLING')
        return 'APP_UPDATE|FAILED_PULLING'
    UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|SUCCESS')
    return 'APP_UPDATE|SUCCESS'

