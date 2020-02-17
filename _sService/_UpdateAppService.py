__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
import os


class UpdateAppSignalHandler(QObject):
    __qualname__ = 'UpdateAppSignalHandler'
    SIGNAL_UPDATE_APP = pyqtSignal(str)


UPDATEAPP_SIGNDLER = UpdateAppSignalHandler()
LOGGER = logging.getLogger()

HOST = 'git.mdd.co.id:44195'
REPO = 'https://{}:{}@{}/mdd_dev/mandiri-kiosk.git'.format(_Global.REPO_USERNAME, _Global.REPO_PASSWORD, HOST)


def check_init():
    return _Helper.os_command(command='git init', key='/.git')


def check_origin():
    return _Helper.os_command(command='git remote -v', key=HOST)


def add_origin():
    command = 'git remote add origin {}'.format(REPO)
    return _Helper.os_command(command=command, key='fatal', reverse=True)


def set_credential():
    return _Helper.os_command(command='git config credential.helper store', key='error', reverse=True)


def pull(origin='master'):
    command = 'git pull -f "{}" {}'.format(REPO, origin)
    return _Helper.os_command(command=command, key='error', reverse=True)


def start_do_update():
    _Helper.get_pool().apply_async(do_update)


ORIGIN = 'develop'


def checkout_branch_by_app_env():
    global ORIGIN
    ORIGIN = 'develop'
    if _Global.LIVE_MODE:
        ORIGIN = 'master'
    UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|DEFINE_BRANCH_'+ORIGIN.upper())
    return _Helper.execute_console(" git stash && git checkout "+ORIGIN+" && git stash pop ")


def pull_branch():
    UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|PULLING_BRANCH_'+ORIGIN.upper())
    return _Helper.execute_console(" git pull -f ")


def do_update():
    # if not check_init():
    #     UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_CHECK_INIT')
    #     LOGGER.warning(('step-1', 'APP_UPDATE|FAILED_CHECK_INIT'))
    #     return 'APP_UPDATE|FAILED_CHECK_INIT'
    # LOGGER.info(('step-1', 'APP_UPDATE|SUCCESS_CHECK_INIT'))
    # if not check_origin():
    #     if not add_origin():
    #         UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_ADD_ORIGIN')
    #         LOGGER.warning(('step-2', 'APP_UPDATE|FAILED_ADD_ORIGIN'))
    #         return 'APP_UPDATE|FAILED_ADD_ORIGIN'
    #     # set_credential()
    # LOGGER.info(('step-2', 'APP_UPDATE|SUCCESS_CHECK_ORIGIN'))
    # if not pull():
    #     UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|FAILED_PULLING')
    #     LOGGER.warning(('step-3', 'APP_UPDATE|FAILED_PULLING'))
    #     return 'APP_UPDATE|FAILED_PULLING'
    __checkout = checkout_branch_by_app_env()
    if len(__checkout) > 1:
        for c in __checkout:
            UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|'+c.upper())
    __pull = pull_branch()
    if len(__pull) > 1:
        for p in __pull:
            UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|'+p.upper())
    # LOGGER.info(('step-3', 'APP_UPDATE|SUCCESS_PULLING'))
    LOGGER.info(('step-4', 'APP_UPDATE|SUCCESS'))
    UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.emit('APP_UPDATE|SUCCESS')
    return 'APP_UPDATE|SUCCESS'

