__author__ = 'fitrah.wahyudi.imam@gmail.com'

from _cCommand import _Command
from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _dDAO import _DAO
import json
from _tTools import _Tibox
from _cConfig import _Global
from _tTools import _Tools
from time import sleep
from _sService import _KioskService
from _nNetwork import _NetworkAccess


LOGGER = logging.getLogger()
MEI_PORT = _Global.MEI_PORT
COLLECTED_CASH = 0
AMOUNT = int(_Tibox.INIT_FARE)
TYPE_POWER = '3'
IS_SAVED = False
IS_STANDBY_MODE = False
WAITING_TIME = 1
TEST_MODE = _Global.TEST_MODE


MEI = {
    "OPEN": "301",
    "ACCEPT": "302",
    "DIS_ACCEPT": "303",
    "STACK": "304",
    "RETURN": "305",
    "STORE_ES": "306",
    "RETURN_ES": "307",
    "DISPENSE_COU": "308",
    "FLOAT_DOWN_COU": "309",
    "DISPENSE_VAL": "310",
    "FLOAT_DOWN_ALL": "311",
    "RETURN_STAT": "312",
    "UNKNOWN2": "313",
    "UNKNOWN3": "314",
    "STOP": "315"
}

GRG = {
    "SET": "501",
    "RECEIVE": "502",
    "STOP": "503",
    "STATUS": "504"
}

GRG_PORT = _Global.GRG_PORT


class MEISignalHandler(QObject):
    __qualname__ = 'MEISignalHandler'
    SIGNAL_INIT_MEI = pyqtSignal(str)
    SIGNAL_ACCEPT_MEI = pyqtSignal(str)
    SIGNAL_DIS_ACCEPT_MEI = pyqtSignal(str)
    SIGNAL_STACK_MEI = pyqtSignal(str)
    SIGNAL_RETURN_MEI = pyqtSignal(str)
    SIGNAL_STORE_ES_MEI = pyqtSignal(str)
    SIGNAL_RETURN_ES_MEI = pyqtSignal(str)
    SIGNAL_DISPENSE_COU_MEI = pyqtSignal(str)
    SIGNAL_FLOAT_DOWN_COU_MEI = pyqtSignal(str)
    SIGNAL_DISPENSE_VAL_MEI = pyqtSignal(str)
    SIGNAL_FLOAT_DOWN_ALL_MEI = pyqtSignal(str)
    SIGNAL_RETURN_STATUS = pyqtSignal(str)
    SIGNAL_GRG_RECEIVE = pyqtSignal(str)
    SIGNAL_GRG_STOP = pyqtSignal(str)
    SIGNAL_GRG_STATUS = pyqtSignal(str)


M_SIGNDLER = MEISignalHandler()
OPEN_STATUS = False
# Additional Config Param for several slot function
# AUTO_FLOAT_DOWN = True
DISABLE_ACCEPT = True
CASH_HISTORY = []
STANDBY_FLAG = True
IS_PAID = False
# Default Loop Duration 10 minutes, 2 hits in every second
MAX_EXECUTION_TIME = 300


def init_mei():
    global OPEN_STATUS, IS_STANDBY_MODE
    if MEI_PORT is None:
        LOGGER.debug(("init_mei port : ", MEI_PORT))
        _Global.MEI_ERROR = 'FAILED_TO_OPENED'
        return False
    _Command.get_response_with_handle(out=_Command.MO_STATUS, module='MEI_Connection_Init', flush=True)
    param = MEI["OPEN"] + "|" + MEI_PORT + "|" + TYPE_POWER
    response, result = _Command.send_command_with_handle(param=param, output=None)
    if response == 0:
        sleep(1)
        _, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, module='MEI_Connection_Init')
        LOGGER.info(("MO_REPORT in init_mei() : ", str(result)))
    OPEN_STATUS = True if response == 0 and 'DeviceState|4|7' in result else False
    if OPEN_STATUS is True:
        IS_STANDBY_MODE = True
    LOGGER.info(("Starting MEI in Standby_Mode : ", str(OPEN_STATUS)))
    return OPEN_STATUS


def start_mei_standby_mode():
    _Tools.get_pool().apply_async(mei_standby_mode)


def mei_standby_mode():
    if STANDBY_FLAG is True:
        print('pyt: [info] Starting MEI in Standby_Mode')
        init_mei()


def start_disconnect_mei():
    _Tools.get_pool().apply_async(disconnect_mei)


EXIT_KEY1 = 'COMPLETE'
EXIT_KEY2 = 'RETURN'
EXIT_KEY3 = 'DeviceState|19|7'
IS_ACCEPTING = False
IS_RETURNING = False


def disconnect_mei():
    global OPEN_STATUS, IS_PAID, IS_ACCEPTING

    if STANDBY_FLAG is True:
        if IS_ACCEPTING is True:
            dis_accept_mei()
        sleep(WAITING_TIME * 2)
        _KioskService.K_SIGNDLER.SIGNAL_GENERAL.emit('CLOSE_LOADING')
        LOGGER.debug(("Change MEI to Standby_Mode : ", STANDBY_FLAG))
        return
    else:

        r = '['+_Tools.get_random_chars(5, '1234567890')+']'
        try:
            if OPEN_STATUS is True:
                while True:
                    response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, module='MEI_Disconnect'+r)
                    if response == 0 and IS_RETURNING is False:
                        break
                    sleep(WAITING_TIME)
                param = MEI['STOP'] + '|'
                response, result = _Command.send_command_with_handle(param=param, output=None)
                sleep(WAITING_TIME)
                _KioskService.K_SIGNDLER.SIGNAL_GENERAL.emit('CLOSE_LOADING')
                if response == 0:
                    OPEN_STATUS = False
                    # LOGGER.info(("[INFO] disconnect_mei : ", result))
                else:
                    _Global.MEI_ERROR = 'FAILED_TO_DISCONNECT'
                    LOGGER.warning((response, result))
            else:
                LOGGER.warning("OPEN_STATUS")
        except Exception as e:
            _Global.MEI_ERROR = 'FAILED_TO_DISCONNECT'
            LOGGER.warning(e)


def log_book_cash():
    # global IS_SAVED
    param = {
        'csid': _Tools.get_uuid(),
        'pid': _Tibox.PID,
        'tid': _Tibox.TID,
        'amount': COLLECTED_CASH
    }
    try:
        _DAO.insert_cash(param=param)
        # IS_SAVED = True
        LOGGER.info(('insert_log cash : ', param))
    except Exception as e:
        LOGGER.warning(e)


def start_accept_mei():
    _Tools.get_pool().apply_async(accept_mei)


def accept_mei(mode=None):
    global COLLECTED_CASH, CASH_HISTORY, IS_RETURNED, IS_ACCEPTING, IS_PAID, IS_STANDBY_MODE, OPEN_STATUS
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    try:
        _Command.get_response_with_handle(out=_Command.MO_BALANCE, module='MEI_Accept_Re-Init'+r, flush=True)
        if OPEN_STATUS is False:
            init_mei()
        print('pyt: mei_open : ', OPEN_STATUS)
        if OPEN_STATUS is True:
            param = MEI["ACCEPT"] + "|"
            if mode is None:
                response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_BALANCE)
                if response == 0:
                    if len(result) == 0:
                        result = "Waiting For Cash..."
                    IS_RETURNED = False
                    IS_PAID = False
                    IS_ACCEPTING = True
                    IS_STANDBY_MODE = False
                    M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit('ACCEPT|' + str(result))
                    # handling_cash()
                    if MODE_55 is False:
                        COLLECTED_CASH = 0
                        CASH_HISTORY = []
                        handling_cash2()
                    else:
                        handling_cash55()
                else:
                    _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
                    M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ACCEPT|ERROR")
                    LOGGER.warning((str(response), str(result)))
            elif mode == 'RECONNECTING':
                response, result = _Command.send_command_with_handle(param=param)
                print('pyt: reconnecting mei acceptance : ', result)
        else:
            _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
            M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ACCEPT|ERROR")
            LOGGER.warning("OPEN_STATUS")
    except Exception as e:
        # OPEN_STATUS = False
        if 'OSError' in str(e) or 'Invalid argument' in str(e):
            # M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
            # LOGGER.warning(("[ERROR] accept_mei : ", 'Please Check MDDTopUpService'))
            try:
                if MODE_55 is False:
                    handling_cash2()
                else:
                    handling_cash55()
            except Exception as e:
                if 'OSError' in str(e) or 'Invalid argument' in str(e):
                    M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
                    LOGGER.warning((e, 'Please Check MDDTopUpService'))
                else:
                    _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
                    M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ACCEPT|ERROR")
                    LOGGER.warning(e)
        else:
            _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
            M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ACCEPT|ERROR")
            LOGGER.warning(e)


def retry_accept_mei():
    global COLLECTED_CASH, CASH_HISTORY, IS_RETURNED, IS_ACCEPTING
    try:
        param = MEI["ACCEPT"] + "|"
        response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_BALANCE)
        if response == 0:
            if len(result) == 0:
                result = "Waiting For Cash #2..."
            COLLECTED_CASH = 0
            CASH_HISTORY = []
            IS_RETURNED = False
            IS_ACCEPTING = True
            M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit('ACCEPT|' + str(result))
            handling_cash2()
        else:
            _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
            M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ACCEPT|ERROR")
            LOGGER.warning(("#2", response, result))
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_ACCEPT'
        M_SIGNDLER.SIGNAL_ACCEPT_MEI.emit("ERROR")
        LOGGER.warning(("#2", e))


GRAB_KEY = 'DocumentEvent|ESCROWED'


def handling_cash():
    global COLLECTED_CASH, OPEN_STATUS
    latency = []
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    while True:
        # Disabling Flushing GRAB_KEY in Stacking
        # response, result, timestamp = _Command.get_response_with_handle(out=_Command.MO_REPORT,
        #                                                                 timestamp=True, flush=GRAB_KEY)
        try:
            response, result, timestamp = _Command.get_response_with_handle(out=_Command.MO_REPORT, timestamp=True,
                                                                            module='MEI_Handling_Cash'+r)
        except OSError:
            continue
        if response == 0 and GRAB_KEY in result and timestamp not in latency:
            latency.append(timestamp)
            response_, result_ = _Command.get_response_with_handle(out=_Command.MO_BALANCE)
            print("pyt: report=> ", str(result), ", balance=>", str(result_), ", with timestamp=>", str(timestamp))
            if response_ == 0 and '000' in result_:
                result_ = result_.split('#')[0]
                if int(COLLECTED_CASH) < int(_Tibox.ROUNDED_FARE):
                    COLLECTED_CASH += int(result_)
                    print("pyt: get_total_cash_from_mei ", str(COLLECTED_CASH))
                    stack_mei(file_output=_Command.MO_BALANCE)
                if int(COLLECTED_CASH) >= int(_Tibox.ROUNDED_FARE):
                    break
        if OPEN_STATUS is False or IS_RETURNED is True or 'RETURN' in result:
            break
        sleep(WAITING_TIME)


DIRECT_PRICE_MODE = False
DIRECT_PRICE_AMOUNT = 0


def start_set_direct_price(price):
    _Tools.get_pool().apply_async(set_direct_price, (price,))


def set_direct_price(price):
    global DIRECT_PRICE_AMOUNT, DIRECT_PRICE_MODE
    DIRECT_PRICE_MODE = True
    DIRECT_PRICE_AMOUNT = int(price)


def handling_cash2():
    global COLLECTED_CASH, OPEN_STATUS, CASH_HISTORY, MODE_55
    latency2 = []
    if DIRECT_PRICE_MODE is True:
        _amount = DIRECT_PRICE_AMOUNT
    else:
        _amount = int(_Tibox.ROUNDED_FARE)
    t = 0
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    # previous_cash_in = CASH_HISTORY[-1] if len(CASH_HISTORY) > 1 else '0'
    LOGGER.info('START COUNTING {} =========================================================='.format(r))
    while True:
        # Disabling Flushing GRAB_KEY in Stacking
        # response, result, timestamp = _Command.get_response_with_handle(out=_Command.MO_REPORT,
        #                                                                 timestamp=True, flush=GRAB_KEY)
        try:
            response, result, timestamp = _Command.get_response_with_handle(out=_Command.MO_BALANCE, timestamp=True,
                                                                            module='MEI_Handling_Cash2'+r, flush=True)
        except OSError:
            LOGGER.debug(('retry in failure', 'new PID', str(r)))
            continue
        if response == 0 and GRAB_KEY in result and timestamp not in latency2:
            latency2.append(timestamp)
            result_ = result.split('#')[0]
            cash_in_ = result_.split('|')[1].split('_')[1]
            cash_in = cash_in_.replace('#', '')
            if '000' in cash_in:
                # Adjust Function in Stacking Received Notes
                if int(COLLECTED_CASH) < _amount:
                    __r, __s = _Command.send_command_with_handle(param=MEI["STACK"] + "|", output=_Command.MO_REPORT)
                    LOGGER.info(('Stacking Status: ', str(__s)))
                    if __r == 0 and 'STACKED' in __s:
                        CASH_HISTORY.append(str(cash_in))
                        COLLECTED_CASH += int(cash_in)
                        M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|' + str(COLLECTED_CASH))
                        LOGGER.info(('Cash Status:', json.dumps({'ADD': cash_in,
                                                                 'COLLECTED': COLLECTED_CASH,
                                                                 'HISTORY': CASH_HISTORY})))
                    else:
                        LOGGER.warning(('No Response from service when sending:', str(__s)))
                if int(COLLECTED_CASH) >= _amount:
                    M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|COMPLETE')
                    LOGGER.debug(('[Break] COLLECTED_CASH:', str(COLLECTED_CASH)))
                    LOGGER.info('END COUNTING {} =========================================================='.format(r))
                    break
                if len(CASH_HISTORY) >= 55:
                    M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|LIMIT_55')
                    MODE_55 = True
                    LOGGER.debug(('[Break] LENGTH CASH_HISTORY:', str(len(CASH_HISTORY))))
                    LOGGER.info('END COUNTING {} =========================================================='.format(r))
                    break
        if OPEN_STATUS is False:
            LOGGER.debug(('[Break] OPEN_STATUS:', OPEN_STATUS))
            break
        if IS_RETURNED is True:
            LOGGER.debug(('[Break] IS_RETURNED:', IS_RETURNED))
            break
        if IS_ACCEPTING is False:
            LOGGER.debug(('[Break] IS_ACCEPTING:', IS_ACCEPTING))
            break
        if IS_STORING is True:
            LOGGER.debug(('[Break] IS_STORING:', IS_STORING))
            break
        if t >= MAX_EXECUTION_TIME:
            LOGGER.debug(('[Break] MAX_EXECUTION_TIME:', str(MAX_EXECUTION_TIME)))
            break
        sleep(WAITING_TIME)


MODE_55 = False
MODE_55_STORE = False


def handling_cash55():
    global COLLECTED_CASH, OPEN_STATUS, CASH_HISTORY, MODE_55_STORE
    latency3 = []
    t = 0
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    if DIRECT_PRICE_MODE is True:
        _amount = DIRECT_PRICE_AMOUNT
    else:
        _amount = int(_Tibox.ROUNDED_FARE)
    LOGGER.info('START COUNTING {} =========================================================='.format(r))
    # previous_cash_in = CASH_HISTORY[-1] if len(CASH_HISTORY) > 1 else '0'
    while True:
        try:
            response, result, timestamp = _Command.get_response_with_handle(out=_Command.MO_BALANCE, timestamp=True,
                                                                            module='MEI_Handling_Cash55'+r, flush=True)
        except OSError:
            LOGGER.debug(('retry in failure', 'new PID', str(r)))
            # re-count the exceded due to PID changement
            # COLLECTED_CASH -= int(previous_cash_in)
            # CASH_HISTORY = CASH_HISTORY.pop()
            continue
        if response == 0 and GRAB_KEY in result and timestamp not in latency3:
            latency3.append(timestamp)
            result_ = result.split('#')[0]
            cash_in_ = result_.split('|')[1].split('_')[1]
            cash_in = cash_in_.replace('#', '')
            if '000' in cash_in:
                if int(COLLECTED_CASH) < _amount:
                    # Adjust Function in Stacking Received Notes
                    __r, __s = _Command.send_command_with_handle(param=MEI["STACK"] + "|", output=_Command.MO_REPORT)
                    LOGGER.info(('Stacking Status: ', str(__s)))
                    if __r == 0 and 'STACKED' in __s:
                        CASH_HISTORY.append(str(cash_in))
                        COLLECTED_CASH += int(cash_in)
                        M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|' + str(COLLECTED_CASH))
                        LOGGER.info(('Cash Status:', json.dumps({'ADD': cash_in,
                                                                 'COLLECTED': COLLECTED_CASH,
                                                                 'HISTORY': CASH_HISTORY})))
                    else:
                        LOGGER.warning(('No Response from service when sending:', str(__s)))
                if int(COLLECTED_CASH) >= _amount:
                    MODE_55_STORE = True
                    M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|COMPLETE')
                    LOGGER.debug(('[Break] COLLECTED_CASH:', str(COLLECTED_CASH)))
                    LOGGER.info('END COUNTING {} =========================================================='.format(r))
                    break
        if OPEN_STATUS is False:
            LOGGER.debug(('[Break] OPEN_STATUS:', OPEN_STATUS))
            break
        if IS_RETURNED is True:
            LOGGER.debug(('[Break] IS_RETURNED:', IS_RETURNED))
            break
        if IS_ACCEPTING is False:
            LOGGER.debug(('[Break] IS_ACCEPTING:', IS_ACCEPTING))
            break
        if IS_STORING is True:
            LOGGER.debug(('[Break] IS_STORING:', IS_STORING))
            break
        if t >= MAX_EXECUTION_TIME:
            LOGGER.debug(('[Break] MAX_EXECUTION_TIME:', str(MAX_EXECUTION_TIME)))
            break
        sleep(WAITING_TIME)


def start_dis_accept_mei():
    _Tools.get_pool().apply_async(dis_accept_mei)


def dis_accept_mei():
    global IS_ACCEPTING, IS_STANDBY_MODE
    try:
        if OPEN_STATUS is True:
            param = MEI["DIS_ACCEPT"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                # sleep(1)
                M_SIGNDLER.SIGNAL_DIS_ACCEPT_MEI.emit('DIS_ACCEPT|SUCCESS')
                IS_ACCEPTING = False
                IS_STANDBY_MODE = True
            else:
                _Global.MEI_ERROR = 'FAILED_TO_DISACCEPT'
                LOGGER.warning((str(response), result))
                M_SIGNDLER.SIGNAL_DIS_ACCEPT_MEI.emit("DIS_ACCEPT|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_DISACCEPT'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_DIS_ACCEPT_MEI.emit("DIS_ACCEPT|ERROR")
    except Exception as e:
        if 'OSError' in str(e) or 'Invalid argument' in str(e):
            M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
            LOGGER.warning((e, 'Please Check MDDTopUpService'))
        else:
            _Global.MEI_ERROR = 'FAILED_TO_DISACCEPT'
            M_SIGNDLER.SIGNAL_DIS_ACCEPT_MEI.emit("DIS_ACCEPT|ERROR")
            LOGGER.warning(e)


def start_stack_mei():
    _Tools.get_pool().apply_async(stack_mei)


def stack_mei(file_output=_Command.MO_REPORT):
    try:
        if OPEN_STATUS is True:
            param = MEI["STACK"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=file_output)
            if response == 0 and '000' in result:
                result = result.split('#')[0]
                CASH_HISTORY.append(str(result))
                M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|' + str(result))
                print('pyt : stack_mei for denom : ', str(result))
            else:
                result = '0'
                M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|' + str(result))
                LOGGER.warning((str(response), result))
        else:
            _Global.MEI_ERROR = 'FAILED_TO_STACK'
            LOGGER.warning("OPEN_STATUS ")
            M_SIGNDLER.SIGNAL_STACK_MEI.emit("STACK|ERROR")
    except Exception as e:
        if 'OSError' in str(e) or 'Invalid argument' in str(e):
            M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
            LOGGER.warning((e, 'Please Check MDDTopUpService'))
        else:
            _Global.MEI_ERROR = 'FAILED_TO_STACK'
            M_SIGNDLER.SIGNAL_STACK_MEI.emit("STACK|ERROR")
            LOGGER.warning(e)


def handling_stack_cash(res):
    global CASH_HISTORY, CANCEL_STORE_ES
    t = 0
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    while True:
        try:
            _response, _result = _Command.get_response_with_handle(out=_Command.MO_REPORT,
                                                                   module='MEI_Handling_Stack_Cash'+r)
        except OSError:
            continue
        if _response == 0 and GRAB_KEY_STORE in _result:
            res = res.split('#')[0]
            CASH_HISTORY.append(str(res))
            M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|' + str(res))
            print('pyt : stack_mei for denom : ', str(res))
            LOGGER.debug(('handling_stack_cash', 'break GRAB_KEY_STORE:', GRAB_KEY_STORE))
            break
        elif _response == 0 and 'RETURNED' in _result:
            M_SIGNDLER.SIGNAL_STACK_MEI.emit("STACK|REJECTED")
            CANCEL_STORE_ES = True
            LOGGER.debug(('handling_stack_cash', 'break CANCEL_STORE_ES:', CANCEL_STORE_ES))
            break
        if t >= MAX_EXECUTION_TIME:
            LOGGER.debug(('handling_stack_cash', 'break MAX_EXECUTION_TIME:', str(MAX_EXECUTION_TIME)))
            break
        sleep(WAITING_TIME)


def start_return_mei():
    _Tools.get_pool().apply_async(return_mei)


def return_mei(file_output=_Command.MO_REPORT):
    try:
        if OPEN_STATUS is True:
            param = MEI["RETURN"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=file_output)
            if response == 0:
                M_SIGNDLER.SIGNAL_RETURN_MEI.emit('RETURN|' + str(result))
            else:
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_RETURN_MEI.emit("RETURN|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_RETURN'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_RETURN_MEI.emit("RETURN|ERROR")
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_RETURN'
        M_SIGNDLER.SIGNAL_RETURN_MEI.emit("RETURN|ERROR")
        LOGGER.warning(e)


def start_store_es_mei():
    _Tools.get_pool().apply_async(store_es_mei)


GRAB_KEY_STORE = 'STACKED_CUSTOMER_TO_ESCROW_STORAGE'
CANCEL_STORE_ES = False
GRAB_KEY_STORE_ES1 = 'STORING_COMPLETE'
GRAB_KEY_STORE_ES2 = 'STACKED_ESCROW_STORAGE_TO_INVENTORY'
IS_STORING = False


def store_es_mei():
    global IS_STORING
    try:
        if OPEN_STATUS is True:
            # sleep(WAITING_TIME*4)
            IS_STORING = True
            param = MEI["STORE_ES"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                handling_storing_cash()
            else:
                _Global.MEI_ERROR = 'FAILED_TO_STORE_ES'
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit("STORE_ES|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_STORE_ES'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit("STORE_ES|ERROR")
    except Exception as e:
        if 'OSError' in str(e) or 'Invalid argument' in str(e):
            M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
            LOGGER.warning((e, 'Please Check MDDTopUpService'))
        else:
            _Global.MEI_ERROR = 'FAILED_TO_STORE_ES'
            M_SIGNDLER.SIGNAL_RETURN_MEI.emit("STORE_ES|ERROR")
            LOGGER.warning(e)


ESCAPE_OUT_OF_SERVICE = 'OUT_OF_SERVICE'


def handling_storing_cash():
    global CANCEL_STORE_ES, IS_PAID, MODE_55_STORE, MODE_55, IS_STORING, DIRECT_PRICE_AMOUNT, DIRECT_PRICE_MODE
    t = 0
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'

    while True:
        if MODE_55 is False:
            module_mode = 'MEI_Handling_Storing_Cash'+r
        else:
            module_mode = 'MEI_Handling_Storing_Cash_Mode55'+r
        try:
            response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, flush=GRAB_KEY_RETURN_ES1,
                                                                 module=module_mode)
        except OSError:
            continue
        # M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit('STORE_ES|' + str(result))
        if response == 0 and (GRAB_KEY_STORE_ES1 in result or ESCAPE_OUT_OF_SERVICE in result):
            IS_STORING = False
            IS_PAID = True
            DIRECT_PRICE_AMOUNT = 0
            DIRECT_PRICE_MODE = False
            _KioskService.MEI_HISTORY = '|'.join(CASH_HISTORY)
            if MODE_55 is True:
                if MODE_55_STORE is True:
                    M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit("STORE_ES|SUCCESS")
                    MODE_55 = False
                    MODE_55_STORE = False
                else:
                    M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit('STORE_ES|SUCCESS_55')
                    _param_ = _Tibox.save_trx_local('', 'MEI', get_cash_history())
                    _Tibox.save_cash_local(get_total_cash())
                    _Tibox.save_trx_server(_param_)
                    handling_cash55()
            else:
                cash_received = {
                    'history': get_cash_history(),
                    'total': get_collected_cash()
                }

                M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit("STORE_ES|SUCCESS-"+json.dumps(cash_received))
            LOGGER.debug(('handling_storing_cash', module_mode, 'break GRAB_KEY_STORE_ES1:', GRAB_KEY_STORE_ES1))
            break
        if CANCEL_STORE_ES is True:
            CANCEL_STORE_ES = False
            LOGGER.debug(('handling_storing_cash', module_mode, 'break CANCEL_STORE_ES:', CANCEL_STORE_ES))
            break
        if OPEN_STATUS is False:
            LOGGER.debug(('handling_storing_cash', module_mode, 'break OPEN_STATUS:', OPEN_STATUS))
            break
        if IS_RETURNING is True:
            LOGGER.debug(('handling_storing_cash', module_mode, 'break IS_RETURNING:', IS_RETURNING))
            break
        if t >= MAX_EXECUTION_TIME/2:
            LOGGER.debug(('handling_storing_cash', module_mode, 'break MAX_EXECUTION_TIME:', str(MAX_EXECUTION_TIME/2)))
            break
        sleep(WAITING_TIME)


IS_RETURNED = False


def start_return_es_mei():
    _Tools.get_pool().apply_async(return_es_mei)


def return_es_mei():
    global IS_RETURNED
    try:
        if OPEN_STATUS is True:
            param = MEI["RETURN_ES"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                IS_RETURNED = True
                # M_SIGNDLER.SIGNAL_RETURN_ES_MEI.emit('RETURN_ES|' + str(result))
                handling_return_es()
            else:
                _Global.MEI_ERROR = 'FAILED_TO_RETURN_ES'
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_RETURN_ES_MEI.emit("RETURN_ES|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_RETURN_ES'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_RETURN_ES_MEI.emit("RETURN_ES|ERROR")
    except Exception as e:
        if 'OSError' in str(e) or 'Invalid argument' in str(e):
            M_SIGNDLER.SIGNAL_STACK_MEI.emit('STACK|OSERROR')
            LOGGER.warning((e, 'Please Check MDDTopUpService'))
        else:
            _Global.MEI_ERROR = 'FAILED_TO_RETURN_ES'
            M_SIGNDLER.SIGNAL_RETURN_ES_MEI.emit("RETURN_ES|ERROR")
            LOGGER.warning(e)


GRAB_KEY_RETURN_ES1 = 'RETURNING_COMPLETE'
GRAB_KEY_RETURN_ES2 = 'RETURNED'


def handling_return_es():
    global COLLECTED_CASH, CASH_HISTORY, IS_RETURNING, IS_STANDBY_MODE, MODE_55
    IS_RETURNING = True
    t = 0
    r = '['+_Tools.get_random_chars(5, '1234567890')+']'
    while True:
        try:
            response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT,
                                                             module='MEI_Handling_Return_Escrow'+r)
        except OSError:
            continue
        M_SIGNDLER.SIGNAL_STORE_ES_MEI.emit('RETURN_ES|' + str(result))
        if response == 0 and GRAB_KEY_RETURN_ES1 in result:
            IS_RETURNING = False
            MODE_55 = False
            disconnect_mei()
            COLLECTED_CASH = 0
            CASH_HISTORY = []
            LOGGER.debug(('handling_return_es', 'break GRAB_KEY_RETURN_ES1:', GRAB_KEY_RETURN_ES1))
            break
        if OPEN_STATUS is False:
            LOGGER.debug(('handling_return_es', 'break OPEN_STATUS:', OPEN_STATUS))
            break
        if t >= MAX_EXECUTION_TIME:
            LOGGER.debug(('handling_return_es', 'break MAX_EXECUTION_TIME:', str(MAX_EXECUTION_TIME)))
            break
        sleep(WAITING_TIME)


def start_dispense_cou_mei():
    _Tools.get_pool().apply_async(dispense_cou_mei)


def dispense_cou_mei():
    try:
        if OPEN_STATUS is True:
            param = MEI["DISPENSE_COU"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                M_SIGNDLER.SIGNAL_DISPENSE_COU_MEI.emit('DISPENSE_COU|' + str(result))
            else:
                _Global.MEI_ERROR = 'FAILED_TO_DISPENSE'
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_DISPENSE_COU_MEI.emit("DISPENSE_COU|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_DISPENSE'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_DISPENSE_COU_MEI.emit("DISPENSE_COU|ERROR")
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_DISPENSE'
        M_SIGNDLER.SIGNAL_DISPENSE_COU_MEI.emit("DISPENSE_COU|ERROR")
        LOGGER.warning(e)


def start_float_down_cou_mei():
    _Tools.get_pool().apply_async(float_down_cou_mei)


def float_down_cou_mei():
    try:
        if OPEN_STATUS is True:
            param = MEI["FLOAT_DOWN_COU"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                M_SIGNDLER.SIGNAL_FLOAT_DOWN_COU_MEI.emit('FLOAT_DOWN_COU|' + str(result))
            else:
                _Global.MEI_ERROR = 'FAILED_TO_FLOAT_DOWN'
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_FLOAT_DOWN_COU_MEI.emit("FLOAT_DOWN_COU|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_FLOAT_DOWN'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_FLOAT_DOWN_COU_MEI.emit("FLOAT_DOWN_COU|ERROR")
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_FLOAT_DOWN'
        M_SIGNDLER.SIGNAL_FLOAT_DOWN_COU_MEI.emit("FLOAT_DOWN_COU|ERROR")
        LOGGER.warning(e)


def start_dispense_val_mei(amount):
    _Tools.get_pool().apply_async(dispense_val_mei, (amount,))


def dispense_val_mei(amount):
    try:
        if OPEN_STATUS is True:
            param = MEI["DISPENSE_VAL"] + "|" + amount
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                M_SIGNDLER.SIGNAL_DISPENSE_VAL_MEI.emit('DISPENSE_VAL|' + str(result))
            else:
                _Global.MEI_ERROR = 'FAILED_TO_DISPENSE_VAL'
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_DISPENSE_VAL_MEI.emit("DISPENSE_VAL|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_DISPENSE_VAL'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_DISPENSE_VAL_MEI.emit("DISPENSE_VAL|ERROR")
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_DISPENSE_VAL'
        M_SIGNDLER.SIGNAL_DISPENSE_VAL_MEI.emit("DISPENSE_VAL|ERROR")
        LOGGER.warning(e)


def start_float_down_all_mei():
    _Tools.get_pool().apply_async(float_down_all_mei)


def float_down_all_mei():
    try:
        if OPEN_STATUS is True:
            param = MEI["FLOAT_DOWN_ALL"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                M_SIGNDLER.SIGNAL_FLOAT_DOWN_ALL_MEI.emit('FLOAT_DOWN_ALL|' + str(result))
            else:
                LOGGER.warning((response, result))
                _Global.MEI_ERROR = 'FAILED_TO_FLOATDOWN_ALL'
                M_SIGNDLER.SIGNAL_FLOAT_DOWN_ALL_MEI.emit("FLOAT_DOWN_ALL|ERROR")
        else:
            _Global.MEI_ERROR = 'FAILED_TO_FLOATDOWN_ALL'
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_FLOAT_DOWN_ALL_MEI.emit("FLOAT_DOWN_ALL|ERROR")
    except Exception as e:
        _Global.MEI_ERROR = 'FAILED_TO_FLOATDOWN_ALL'
        M_SIGNDLER.SIGNAL_FLOAT_DOWN_ALL_MEI.emit("FLOAT_DOWN_ALL|ERROR")
        LOGGER.warning(e)


def start_get_return_note():
    _Tools.get_pool().apply_async(get_return_note)


def get_return_note():
    try:
        if OPEN_STATUS is True:
            param = MEI["RETURN_STAT"] + "|"
            response, result = _Command.send_command_with_handle(param=param, output=_Command.MO_REPORT)
            if response == 0:
                M_SIGNDLER.SIGNAL_RETURN_STATUS.emit('RETURN_STAT|' + str(result))
            else:
                LOGGER.warning((response, result))
                M_SIGNDLER.SIGNAL_RETURN_STATUS.emit("RETURN_STAT|ERROR")
        else:
            LOGGER.warning("OPEN_STATUS")
            M_SIGNDLER.SIGNAL_RETURN_STATUS.emit("RETURN_STAT|ERROR")
    except Exception as e:
        M_SIGNDLER.SIGNAL_RETURN_STATUS.emit("RETURN_STAT|ERROR")
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


def start_mei_create_payment(payment):
    _Tools.get_pool().apply_async(mei_create_payment, (payment, ))


def mei_create_payment(payment):
    check_cash = get_total_cash()
    if int(_Tibox.ROUNDED_FARE) > check_cash:
        LOGGER.info(('mei_create_payment to vedaleon: ', str(_Tibox.ROUNDED_FARE), '<>', str(check_cash)))
        return
    else:
        url_ = 'p_check_paid.php?val=' + payment + '&&tid=' + _Tibox.TID + '&&id=' + _Tibox.ID
        try:
            trying = 0
            while True:
                trying += 1
                status, response = _NetworkAccess.get_from_url(url=_Tibox.TIBOX_URL + url_, header=_Tibox.HEADER)
                if status == 200 and 'OK' in response:
                    _Tibox.TXT_BOOKING_STATUS = 'SUCCESS'
                    LOGGER.info(('to vedaleon: ', str(response)))
                    _Tibox.T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('SUCCESS')
                    break
                if trying == 3:
                    LOGGER.warning(('to vedaleon: ', str(response)))
                    _Tibox.T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('ERROR')
                    break
                sleep(2)
        except Exception as e:
            LOGGER.warning(e)
            _Tibox.T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('ERROR')
