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


class UserSignalHandler(QObject):
    __qualname__ = 'UserSignalHandler'
    SIGNAL_USER_LOGIN = pyqtSignal(str)


US_SIGNDLER = UserSignalHandler()
LOGGER = logging.getLogger()
SALT = '|KIOSK'
# Will turn back None when IDLE status is START from Sync
USER = None

SECRET_LOGIN_OFFLINE = open(os.path.join(sys.path[0], '_sService', 'offline.user'), 'r').read().strip()


def check_user_offline_hash(user, password):
    __hash_user_offline = hashlib.md5((user.lower()+'|'+password.lower()).encode('utf-8')).hexdigest()
    LOGGER.debug(('user', user, 'password', password, 'secret_hash', SECRET_LOGIN_OFFLINE,
                  'offline_hash', __hash_user_offline))
    if __hash_user_offline == SECRET_LOGIN_OFFLINE:
        return True
    else:
        return False


def get_kiosk_login(username, password):
    _Tools.get_pool().apply_async(kiosk_login, (username, password,))


def kiosk_login(username, password):
    global USER
    try:
        _param = {
            'username': username.lower(),
            'password': hashlib.md5((password.lower()+SALT).encode('utf-8')).hexdigest()
        }
        status, response = _NetworkAccess.post_to_url(url=_Global.BACKEND_URL + 'user/kiosk-login', param=_param)
        LOGGER.info(('kiosk_login', str(_param), str(status), str(response)))
        if status == 200 and response['result'] == 'OK':
            USER = response['data']
            # "data": {
            #     "user_id": 6,
            #     "group_id": 5,
            #     "username": "wahyudi",
            #     "first_name": "Wahyudi",
            #     "active": 1,
            #     "isAbleTerminal": 1,
            #     "isAbleCollect": 0,
            #     "last_activity": 1552546792
            #     }
            US_SIGNDLER.SIGNAL_USER_LOGIN.emit('SUCCESS|'+json.dumps(USER))
        else:
            if 'statusCode' in response.keys():
                if response['statusCode'] == -1:
                    if check_user_offline_hash(username, password) is True:
                        USER = {
                            "user_id": 99999,
                            "group_id": 0,
                            "username": "0ffl1ne",
                            "first_name": "Offline",
                            "active": 1,
                            "isAbleTerminal": 1,
                            "isAbleCollect": 1,
                            "last_activity": _Tools.now()
                            }
                        US_SIGNDLER.SIGNAL_USER_LOGIN.emit('SUCCESS|' + json.dumps(USER))
                    else:
                        US_SIGNDLER.SIGNAL_USER_LOGIN.emit('LOGIN|OFFLINE')
                else:
                    US_SIGNDLER.SIGNAL_USER_LOGIN.emit('LOGIN|ERROR')
            else:
                US_SIGNDLER.SIGNAL_USER_LOGIN.emit('LOGIN|ERROR')
    except Exception as e:
        LOGGER.warning(('kiosk_login', e))
        US_SIGNDLER.SIGNAL_USER_LOGIN.emit('LOGIN|UNKNOWN_ERROR')


def reset_offline_user(hash_data):
    try:
        with open(os.path.join(sys.path[0], '_sService', 'offline.user'), 'w') as s:
            s.write(hash_data)
            s.close()
        return 'CHANGE_OFFLINE_USER_SUCCESS'
    except Exception as e:
        LOGGER.warning(('reset_offline_user', str(e)))
        return 'CHANGE_OFFLINE_USER_FAILED'
