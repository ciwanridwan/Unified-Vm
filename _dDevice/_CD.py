__author__ = 'fitrah.wahyudi.imam@gmail.com'


from _cConfig import _ConfigParser, _Global
from _cCommand import _Command
from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _tTools import _Tools
from time import sleep
import os
import sys
import subprocess
import json


LOGGER = logging.getLogger()
CD_PORT1 = _Global.CD_PORT1
CD_PORT2 = _Global.CD_PORT2
CD_PORT3 = _Global.CD_PORT3
CD_MID = ''
CD_TID = ''

CD_EXEC = os.path.join(sys.path[0], '_lLib', 'cd', 'card_disp.exe')
CD_EXEC_V2 = os.path.join(sys.path[0], '_lLib', 'cd', 'v2', 'card.exe')
V2_PATH = os.path.join(sys.path[0], '_lLib', 'cd', 'v2')
CD_INIT = os.path.join(sys.path[0], '_lLib', 'cd_init', 'start.exe')

CD = {
    "OPEN": "101",
    "INIT": "102",
    "MOVE": "103",
    "HOLD": "104",
    "STOP": "105"
}

CD_PORT_LIST = _Global.CD_PORT_LIST


class CDSignalHandler(QObject):
    __qualname__ = 'CDSignalHandler'
    SIGNAL_CD_MOVE = pyqtSignal(str)
    SIGNAL_CD_HOLD = pyqtSignal(str)
    SIGNAL_CD_STOP = pyqtSignal(str)
    SIGNAL_MULTIPLE_EJECT = pyqtSignal(str)
    SIGNAL_CD_READINESS = pyqtSignal(str)


CD_SIGNDLER = CDSignalHandler()
INIT_STATUS = False


def reinit_v2_config():
    with open(os.path.join(V2_PATH, 'card.ini'), 'w') as init:
        init.write('path='+V2_PATH)
        init.close()
    with open(os.path.join(V2_PATH, '101.card.ini'), 'w') as cd1:
        cd1.write('com='+CD_PORT1+os.linesep+'baud=9600')
        cd1.close()
    with open(os.path.join(V2_PATH, '102.card.ini'), 'w') as cd2:
        cd2.write('com='+CD_PORT2+os.linesep+'baud=9600')
        cd2.close()
    with open(os.path.join(V2_PATH, '103.card.ini'), 'w') as cd3:
        cd3.write('com='+CD_PORT3+os.linesep+'baud=9600')
        cd3.close()
    

def open_card_disp():
    if CD_PORT1 is None:
        LOGGER.debug(("[ERROR] open_card_disp port : ", CD_PORT1))
        _Global.CD1_ERROR = 'PORT_NOT_OPENED'
        return False
    param = CD["OPEN"] + "|" + CD_PORT1
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((param, result))
    # return True if '0' in status else False
    return True if response == 0 else False


def init_card_disp():
    global INIT_STATUS
    param = CD["INIT"] + "|"
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((param, result))
    INIT_STATUS = True if response == 0 else False
    return INIT_STATUS


def start_move_card_disp():
    attempt = 1
    _Tools.get_pool().apply_async(move_card_disp, (attempt, ))


MULTIPLE_EJECT = True if _ConfigParser.get_set_value('CD', 'multiple^eject', '0') == '1' else False


def start_get_multiple_eject_status():
    _Tools.get_pool().apply_async(get_multiple_eject_status,)


def get_multiple_eject_status():
    eject_status = 'AVAILABLE' if MULTIPLE_EJECT is True else 'N/A'
    print('pyt: MULTIPLE_EJECT_STATUS -> ' + eject_status)
    LOGGER.debug(('get_multiple_eject_status', eject_status))
    CD_SIGNDLER.SIGNAL_MULTIPLE_EJECT.emit(eject_status)


def start_multiple_eject(attempt):
    _Tools.get_pool().apply_async(simply_eject, (attempt, ))


def simply_eject(attempt):
    _cd_selected_port = None
    try:
        selected_port = CD_PORT_LIST[attempt]
        # LOGGER.info(('_cd_selected_port :', _cd_selected_port))
    except IndexError:
        LOGGER.warning(('Failed to Select CD Port', selected_port))
        CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|ERROR')
        return
    try:
        # command = CD_EXEC + " hold " + selected_port
        # Switch To V2
        command = CD_EXEC_V2 + " card " + str(attempt)
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
        output = output[0].split(";")
        response = json.loads(output[0])
        LOGGER.debug(('simply_eject', 'command', command, 'output', output, 'response', response))
        if 'ec' in response.keys():
            if response['ec'] > -1:
                CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|SUCCESS')
            else:
                set_false_output(attempt, 'DEVICE_NOT_OPEN|' + attempt, 'simply_eject')
                return
        else:
            set_false_output(attempt, 'DEVICE_NOT_OPEN|'+attempt, 'simply_eject')
            return
    except Exception as e:
        set_false_output(attempt, str(e) + '|' + attempt, 'simply_eject')


def eject_full_round(attempt):
    # attempt is defined from product status as address
    _cd_selected_port = None
    try:
        _cd_selected_port = CD_PORT_LIST[attempt]
        LOGGER.info(('_cd_selected_port :', _cd_selected_port))
    except IndexError:
        LOGGER.warning(('Failed to Select CD Port', _cd_selected_port))
        CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|ERROR')
        return
    try:
        # Open CD Port
        param = CD["OPEN"] + "|" + _cd_selected_port
        response, result = _Command.send_request(param=param, output=None)
        LOGGER.debug(("eject_full_round [OPEN] : ", param, result))
        # return True if '0' in status else False
        if response == 0:
            # Init CD Port
            sleep(1)
            param = CD["INIT"] + "|"
            response, result = _Command.send_request(param=param, output=None)
            LOGGER.debug(("eject_full_round [INIT] : ", param, result))
            if response == 0:
                # Eject From CD
                sleep(1)
                param = CD["MOVE"] + "|"
                response, result = _Command.send_request(param=param, output=None)
                LOGGER.debug(("eject_full_round [MOVE] : ", param, result))
                if response == 0:
                    CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|SUCCESS')
                else:
                    set_false_output(attempt, 'DEVICE_NOT_MOVE|'+attempt)
                    return
                # Stop/Close The Connection Session
                sleep(1)
                param = CD["STOP"] + "|"
                response, result = _Command.send_request(param=param, output=None)
                LOGGER.debug(("eject_full_round [STOP] : ", param, result))
            else:
                set_false_output(attempt, 'DEVICE_NOT_INIT|'+attempt)
                return
        else:
            set_false_output(attempt, 'DEVICE_NOT_OPEN|'+attempt)
            return
    except Exception as e:
        set_false_output(attempt, str(e) + '|' + attempt)


def set_false_output(attempt, error_message, method='eject_full_round'):
    if attempt == '101':
        _Global.CD1_ERROR = error_message
        _Global.upload_device_state('cd1', _Global.CD1_ERROR)

    if attempt == '102':
        _Global.CD2_ERROR = error_message
        _Global.upload_device_state('cd2', _Global.CD2_ERROR)

    if attempt == '103':
        _Global.CD3_ERROR = error_message
        _Global.upload_device_state('cd3', _Global.CD3_ERROR)

    LOGGER.warning((method, str(attempt), error_message))
    CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|ERROR')


def move_card_disp(attempt):
    if INIT_STATUS is not True:
        CD_SIGNDLER.SIGNAL_CD_MOVE.emit('ERROR')
        _Global.CD1_ERROR = 'DEVICE_NOT_INIT'
        return
    param = CD["HOLD"] + "|"
    if MULTIPLE_EJECT is True:
        param = CD["MOVE"] + "|"
    for x in range(attempt):
        response, result = _Command.send_request(param=param, output=None)
        LOGGER.debug(("move_card_disp : ", param, result, str(x)))
        if x == (attempt-1):
            if response == 0:
                CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|SUCCESS-' + str(x))
            else:
                _Global.CD1_ERROR = 'FAILED_TO_EJECT'
                CD_SIGNDLER.SIGNAL_CD_MOVE.emit('EJECT|ERROR-' + str(x))
        else:
            continue
        sleep(1)


def start_hold_card_disp():
    _Tools.get_pool().apply_async(hold_card_disp, )


def hold_card_disp():
    if INIT_STATUS is not True:
        CD_SIGNDLER.SIGNAL_CD_HOLD.emit('ERROR')
        _Global.CD1_ERROR = 'DEVICE_NOT_INIT'
        return
    param = CD["HOLD"] + "|"
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug(("hold_card_disp : ", param, result))
    if response == 0:
        CD_SIGNDLER.SIGNAL_CD_HOLD.emit('SUCCESS')
    else:
        _Global.CD1_ERROR = 'FAILED_TO_HOLD_EJECT'
        CD_SIGNDLER.SIGNAL_CD_HOLD.emit('ERROR')


def start_stop_card_disp():
    _Tools.get_pool().apply_async(stop_card_disp, )


def stop_card_disp():
    if INIT_STATUS is not True:
        CD_SIGNDLER.SIGNAL_CD_STOP.emit('ERROR')
        _Global.CD1_ERROR = 'DEVICE_NOT_INIT'
        return
    param = CD["STOP"] + "|"
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug(("stop_card_disp : ", param, result))
    if response == 0:
        CD_SIGNDLER.SIGNAL_CD_STOP.emit('SUCCESS')
    else:
        _Global.CD1_ERROR = 'DEVICE_NOT_STOP'
        CD_SIGNDLER.SIGNAL_CD_STOP.emit('ERROR')


def init_cd(com):
    command = CD_INIT + " init " + str(com)
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
    output = output[0].split(";")
    if '1' not in output:
        return True
    else:
        return False


def kiosk_get_cd_readiness():
    _Tools.get_pool().apply_async(get_cd_readiness,)


def get_cd_readiness():
    if _Global.digit_in(_Global.CD_PORT1) is True:
        _Global.CD_READINESS['port1'] = 'AVAILABLE' if init_cd(_Global.CD_PORT1) is True else 'N/A'
    if _Global.digit_in(_Global.CD_PORT2) is True:
        _Global.CD_READINESS['port2'] = 'AVAILABLE' if init_cd(_Global.CD_PORT2) is True else 'N/A'
    if _Global.digit_in(_Global.CD_PORT3) is True:
        _Global.CD_READINESS['port3'] = 'AVAILABLE' if init_cd(_Global.CD_PORT3) is True else 'N/A'
    CD_SIGNDLER.SIGNAL_CD_READINESS.emit(json.dumps(_Global.CD_READINESS))
    LOGGER.debug(('get_cd_readiness', json.dumps(_Global.CD_READINESS)))
