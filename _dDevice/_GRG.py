__author__ = 'fitrah.wahyudi.imam@gmail.com'

from _cCommand import _Command
from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _dDAO import _DAO
import json
from _cConfig import _Common
from _tTools import _Helper
from time import sleep
import sys
import os
import subprocess


LOGGER = logging.getLogger()
COLLECTED_CASH = 0
TEST_MODE = _Common.TEST_MODE

CONFIG_GRG = os.path.join(sys.path[0], '_lLib', 'grg', 'GRGDTATM_CommCfg.ini')
EXEC_GRG = os.path.join(sys.path[0], '_lLib', 'grg', 'bill.exe')
LOG_GRG = os.path.join(sys.path[0], 'log')


GRG = {
    "SET": "501",
    "RECEIVE": "502",
    "STOP": "503",
    "STATUS": "504",
    "STORE": "505",
    "REJECT": "506",
    "GET_STATE": "507"
}

GRG_PORT = _Common.GRG_PORT


class GRGSignalHandler(QObject):
    __qualname__ = 'GRGSignalHandler'
    SIGNAL_GRG_RECEIVE = pyqtSignal(str)
    SIGNAL_GRG_STOP = pyqtSignal(str)
    SIGNAL_GRG_STATUS = pyqtSignal(str)
    SIGNAL_GRG_INIT = pyqtSignal(str)


GRG_SIGNDLER = GRGSignalHandler()
OPEN_STATUS = False
CASH_HISTORY = []
MAX_EXECUTION_TIME = 150
IS_RECEIVING = False


def rewrite_config_init():
    __config = '''
[BILLDEPOSITDEV]
COMMTYPE =1
ComID =''' + GRG_PORT.replace('COM', '') + '''
ComBaud =19200
ComBoardPort =
ComBoardPortBaud =
DevCommLogID =2100
DevTraceLogID =2101
IniCfgFileName=BillDepositDevCfg.ini'''
    with open(CONFIG_GRG, 'w') as c:
        c.write(__config)
        c.close()
    command = EXEC_GRG + ' init'
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    LOGGER.debug(('grg_init in when rewrite_config_init', 'command', command, 'output', str(process)))


def start_init_grg():
    sleep(1)
    _Helper.get_pool().apply_async(init_grg, )


def init_grg():
    global OPEN_STATUS
    if GRG_PORT is None:
        LOGGER.debug(("init_grg port : ", GRG_PORT))
        _Common.BILL_ERROR = 'GRG_PORT_NOT_DEFINED'
        return False
    param = GRG["SET"] + '|' + GRG_PORT.replace('COM', '')
    response, result = _Command.send_request(param=param, output=None)
    if response == 0:
        OPEN_STATUS = True
    else:
         _Common.BILL_ERROR = 'FAILED_INIT_GRG'
    LOGGER.info(("Starting GRG in Standby_Mode : ", str(OPEN_STATUS)))
    GRG_SIGNDLER.SIGNAL_GRG_INIT.emit('INIT_GRG|DONE')
    return OPEN_STATUS

# Received=IDR|Denomination=5000|Version=2|SerialNumber=1|Go=0


KEY_RECEIVED = 'Received=IDR'
CODE_JAM = '14439'
TIMEOUT_BAD_NOTES = 'acDevReturn:|acReserve:|'
SMALL_NOTES_NOT_ALLOWED = ['1000', '2000', '5000']
UNKNOWN_ITEM = 'Received=CNY|Denomination=0|'

DIRECT_PRICE_MODE = False
DIRECT_PRICE_AMOUNT = 0


def start_set_direct_price(price):
    _Helper.get_pool().apply_async(set_direct_price, (price,))


def set_direct_price(price):
    global DIRECT_PRICE_AMOUNT, DIRECT_PRICE_MODE, CASH_HISTORY, COLLECTED_CASH
    DIRECT_PRICE_MODE = True
    DIRECT_PRICE_AMOUNT = int(price)
    COLLECTED_CASH = 0
    CASH_HISTORY = []


def start_grg_receive_note():
    _Helper.get_pool().apply_async(start_receive_note)


def simply_exec_grg(amount=None):
    global COLLECTED_CASH, CASH_HISTORY
    if amount is None:
        amount = DIRECT_PRICE_AMOUNT
    try:
        r = _Helper.time_string('%Y%m%d%H%M%S%f')
        command = 'start /B ' + EXEC_GRG + ' input ' + str(amount) + ' ' + str(r) + ' ' + str(MAX_EXECUTION_TIME)
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        reply = process.communicate()[0].decode('utf-8').strip().split("\r\n")
        LOGGER.debug(('simply_eject', 'command', command, 'output', str(reply)))
        output = os.path.join(LOG_GRG, r+'.json')
        attempt = 0
        while True:
            attempt += 1
            if os.path.isfile(output):
                output = open(output, 'r').readlines()
                LOGGER.debug('output_file', output)
                result = json.loads(output[0])
                if len(result['money']) > 0:
                    cash_in = str(result['money'][-1]['denom'])
                    if COLLECTED_CASH < DIRECT_PRICE_AMOUNT:
                        CASH_HISTORY.append(str(cash_in))
                        COLLECTED_CASH += int(cash_in)
                        GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|' + str(COLLECTED_CASH))
                        LOGGER.info(('Cash Status:', json.dumps({'ADD': cash_in,
                                                                 'COLLECTED': COLLECTED_CASH,
                                                                 'HISTORY': CASH_HISTORY})))
                    if COLLECTED_CASH >= DIRECT_PRICE_AMOUNT:
                        GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|COMPLETE')
                        break
            if attempt == MAX_EXECUTION_TIME:
                LOGGER.warning(('[BREAK] start_receive_note', str(attempt), str(MAX_EXECUTION_TIME)))
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|TIMEOUT')
                break
            sleep(1)
    except Exception as e:
        LOGGER.warning(('simply_exec_grg', str(e)))
        GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|ERROR')


def start_receive_note():
    global COLLECTED_CASH, CASH_HISTORY, IS_RECEIVING
    try:
        attempt = 0
        IS_RECEIVING = True
        while True:
            attempt += 1
            param = GRG["RECEIVE"] + '|'
            _response, _result = _Command.send_request(param=param, output=None)
            _Helper.dump([_response, _result])
            if _response == 0 and KEY_RECEIVED in _result:
                cash_in = _result.split('|')[1].split('=')[1]
                _Common.log_to_config('GRG', 'last^money^inserted', str(cash_in))
                if cash_in in SMALL_NOTES_NOT_ALLOWED:
                    sleep(.25)
                    param = GRG["REJECT"] + '|'
                    _Command.send_request(param=param, output=None)
                    GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|EXCEED')
                    break
                if is_exceed_payment(DIRECT_PRICE_AMOUNT, cash_in, COLLECTED_CASH) is True:
                    GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|EXCEED')
                    sleep(.25)
                    param = GRG["REJECT"] + '|'
                    _Command.send_request(param=param, output=None)
                    LOGGER.info(('Exceed Payment Detected :', json.dumps({'ADD': cash_in,
                                                                          'COLLECTED': COLLECTED_CASH,
                                                                          'TARGET': DIRECT_PRICE_AMOUNT})))
                    break
                # if COLLECTED_CASH >= _MEI.DIRECT_PRICE_AMOUNT:
                #     GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|COMPLETE')
                #     break
                # Call Store Function Here
                CASH_HISTORY.append(str(cash_in))
                COLLECTED_CASH += int(cash_in)
                _Helper.dump([str(CASH_HISTORY), COLLECTED_CASH])
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|'+str(COLLECTED_CASH))
                _Command.send_request(param=GRG["STORE"]+'|', output=None)
                LOGGER.info(('Cash Status:', json.dumps({
                    'ADD': cash_in,
                    'COLLECTED': COLLECTED_CASH,
                    'HISTORY': CASH_HISTORY})))
                if COLLECTED_CASH >= DIRECT_PRICE_AMOUNT:
                    GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|COMPLETE')
                    break
                # else:
                #     sleep(.25)
                #     param = GRG["RECEIVE"] + '|'
                #     _Command.send_request(param=param, output=None)
            if TIMEOUT_BAD_NOTES in _result or UNKNOWN_ITEM in _result:
                _Common.log_to_config('GRG', 'last^money^inserted', 'UNKNOWN')
                if TIMEOUT_BAD_NOTES in _result:
                    _Command.send_request(param=GRG["STOP"]+'|', output=None)
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|BAD_NOTES')
                break
            if CODE_JAM in _result:
                _Common.log_to_config('GRG', 'last^money^inserted', 'UNKNOWN')
                _Common.BILL_ERROR = 'GRG_DEVICE_JAM'
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|JAMMED')
                LOGGER.warning(('GRG Jammed Detected :', json.dumps({'HISTORY': CASH_HISTORY,
                                                                     'COLLECTED': COLLECTED_CASH,
                                                                     'TARGET': DIRECT_PRICE_AMOUNT})))
                # Call API To Force Update Into Server
                _Common.upload_device_state('mei', _Common.BILL_ERROR)
                sleep(1)
                init_grg()
                break
            if attempt == MAX_EXECUTION_TIME:
                LOGGER.warning(('[BREAK] start_receive_note', str(attempt), str(MAX_EXECUTION_TIME)))
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|TIMEOUT')
                break
            if IS_RECEIVING is False:
                LOGGER.warning(('[BREAK] start_receive_note by Event', str(IS_RECEIVING)))
                GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|TIMEOUT')
                break
            sleep(1)
    except Exception as e:
        _Common.log_to_config('GRG', 'last^money^inserted', 'UNKNOWN')
        _Common.BILL_ERROR = 'FAILED_RECEIVE_GRG'
        GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.emit('RECEIVE_GRG|ERROR')
        LOGGER.warning(e)


def is_exceed_payment(target, value_in, current_value):
    if _Common.ALLOW_EXCEED_PAYMENT is True:
        return False
    actual = int(value_in) + int(current_value)
    if actual > int(target):
        return True
    else:
        return False


def stop_grg_receive_note():
    # log_book_cash('', get_collected_cash())
    sleep(1)
    _Helper.get_pool().apply_async(stop_receive_note)


def stop_receive_note():
    global COLLECTED_CASH, CASH_HISTORY, IS_RECEIVING
    IS_RECEIVING = False
    try:
        param = GRG["STOP"] + '|'
        response, result = _Command.send_request(param=param, output=None)
        if response == 0:
            cash_received = {
                'history': get_cash_history(),
                'total': get_collected_cash()
            }
            GRG_SIGNDLER.SIGNAL_GRG_STOP.emit('STOP_GRG|SUCCESS-'+json.dumps(cash_received))
        else:
            GRG_SIGNDLER.SIGNAL_GRG_STOP.emit('STOP_GRG|ERROR')
            LOGGER.warning(('stop_receive_note', str(response), str(result)))
        COLLECTED_CASH = 0
        CASH_HISTORY = []
    except Exception as e:
        _Common.BILL_ERROR = 'FAILED_STOP_GRG'
        GRG_SIGNDLER.SIGNAL_GRG_STOP.emit('STOP_GRG|ERROR')
        LOGGER.warning(e)


def start_get_status_grg():
    _Helper.get_pool().apply_async(get_status_grg)


def get_status_grg():
    try:
        param = GRG["STATUS"] + '|'
        response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
        LOGGER.debug(('get_status_grg', str(response), str(result)))
        if response == 0 and result is not None:
            GRG_SIGNDLER.SIGNAL_GRG_STATUS.emit('STATUS_GRG|'+result)
        else:
            GRG_SIGNDLER.SIGNAL_GRG_STATUS.emit('STATUS_GRG|ERROR')
            LOGGER.warning(('get_status_grg', str(response), str(result)))
    except Exception as e:
        _Common.BILL_ERROR = 'FAILED_STATUS_GRG'
        GRG_SIGNDLER.SIGNAL_GRG_STATUS.emit('STATUS_GRG|ERROR')
        LOGGER.warning(e)


def start_log_book_cash(pid, amount):
    _Helper.get_pool().apply_async(log_book_cash, (pid, amount,))


def log_book_cash(pid, amount):
    param = {
        'csid': pid[::-1],
        'pid': pid,
        'tid': _Common.TID,
        'amount': amount
    }
    try:
        _DAO.insert_cash(param=param)
        LOGGER.info(('log_book_cash : ', param))
    except Exception as e:
        LOGGER.warning(e)


def get_collected_cash():
    return str(COLLECTED_CASH)


def get_cash_history():
    return '|'.join(CASH_HISTORY)


def get_total_cash():
    total_cash = 0
    for cash in CASH_HISTORY:
        total_cash += int(cash)
    return total_cash

