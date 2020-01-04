__author__ = "fitrah.wahyudi.imam@gmail.com"

from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _cCommand import _Command
from _tTools import _Helper
from _tTools import _PrintTool
from _tTools import _EDCTool
from _dDAO import _DAO
from _sService import _KioskService
from _cConfig import _ConfigParser, _Global
from _nNetwork import _NetworkAccess
from time import sleep, time
import json
import re
from datetime import datetime

LOGGER = logging.getLogger()
EDC_PORT = _Global.EDC_PORT
EDC = {
    "OPEN": "201",
    "SALE": "202",
    "PINPAD": "203",
    "INVOICE": "204",
    "SETTLE_DEBIT": "205",
    "STOP": "206",
    "SETTLE_CREDIT": "207",
    "GET_STATE": "208"
}

TEST_MODE = _Global.TEST_MODE


class EDCSignalHandler(QObject):
    __qualname__ = 'EDCSignalHandler'
    # SIGNAL_INIT_EDC = pyqtSignal(str)
    SIGNAL_SALE_EDC = pyqtSignal(str)
    SIGNAL_GET_SETTLEMENT_EDC = pyqtSignal(str)
    SIGNAL_PROCESS_SETTLEMENT_EDC = pyqtSignal(str)
    SIGNAL_VOID_SETTLEMENT_EDC = pyqtSignal(str)


E_SIGNDLER = EDCSignalHandler()
EDC_PAYMENT_RESULT = dict()
OPEN_STATUS = False
STANDBY_MODE = True


def init_edc_with_handle():
    global OPEN_STATUS
    if EDC_PORT is None:
        LOGGER.debug(("[ERROR] init_edc port : ", EDC_PORT))
        _Global.EDC_ERROR = 'PORT_NOT_OPENED'
        return False
    param = EDC["OPEN"] + "|" + re.sub("\D", "", EDC_PORT)
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((param, response, result))
    OPEN_STATUS = True if response == 0 else False
    return OPEN_STATUS


def create_sale_edc(amount):
    _Helper.get_pool().apply_async(sale_edc, (amount,))


def create_sale_edc_with_struct_id(amount, trxid):
    _Helper.get_pool().apply_async(sale_edc, (amount, trxid,))


IS_PIR = True if _ConfigParser.get_set_value('TERMINAL', 'pir^usage', '0') == '1' else False
INIT_AMOUNT = '0'


def sale_edc(amount, trxid=None):
    global OPEN_STATUS, INIT_AMOUNT, EDC_PAYMENT_RESULT
    try:
        # _Command.clear_content_of(_Command.MI_GUI, 'PRE_SALE|'+str(amount))
        # _Command.clear_content_of(_Command.MO_REPORT, 'PRE_SALE|'+str(amount))
        if OPEN_STATUS is False:
            OPEN_STATUS = init_edc_with_handle()
        if OPEN_STATUS is True:
            amount = amount.replace('.00', '')
            INIT_AMOUNT = amount
            if IS_PIR is True:
                amount = str(int(int(amount)/1000))
            param = EDC["SALE"] + "|" + str(amount)
            response, result = _Command.send_request(param=param,
                                                     output=_Command.MO_REPORT,
                                                     flushing=_Command.MO_REPORT)
            LOGGER.debug((response, result))
            if _Global.TEST_MODE is True and _Global.empty(result):
                result = '02||00|'+str(amount)+'||000001|6011********9999|2612|20161003125804|123456|12345678|123456789012345|111111|000001'
            if response == 0 and ('|00|' + amount) in result:
                '''
                1. Transaction Type 		            0x11 
                2. Pinpad 					            0x12 
                3. Response Code 			            0x13 
                4. Amount 					            0x14 
                5. Other Amount 			            0x15 
                6. Invoice No 					        0x16 
                7. Card No (PAN) – Masking with “*”     0x17 
                8. Expire Date (YYMM) 				    0x18 
                9. Transaction Date Time (YYMMDDhhmmss) 0x19 
                10. Approval Code 				        0x20 
                11. TID 						        0x21 
                12. MID 						        0x22 
                13. Reference Number 				    0x23 
                14. Batch Number 					    0x24
                02||00|75000||000001|6011********9999|2612|20161003125804|123456|12345678|123456789012345|111111|000001
                '''
                param = result.split('|')
                EDC_PAYMENT_RESULT['raw'] = result
                EDC_PAYMENT_RESULT['card_type'] = _EDCTool.get_type(param[6])
                if trxid is None:
                    EDC_PAYMENT_RESULT['struck_id'] = _Helper.get_uuid()[:12]
                else:
                    EDC_PAYMENT_RESULT['struck_id'] = trxid.upper()
                EDC_PAYMENT_RESULT['amount'] = param[3]
                if IS_PIR is True:
                    EDC_PAYMENT_RESULT['amount'] = INIT_AMOUNT
                EDC_PAYMENT_RESULT['res_code'] = param[2]
                EDC_PAYMENT_RESULT['inv_no'] = param[5]
                EDC_PAYMENT_RESULT['card_no'] = param[6]
                _KioskService.CARD_NO = param[6]
                EDC_PAYMENT_RESULT['exp_date'] = param[7]
                EDC_PAYMENT_RESULT['trans_date'] = param[8]
                EDC_PAYMENT_RESULT['app_code'] = param[9]
                EDC_PAYMENT_RESULT['tid'] = param[10]
                EDC_PAYMENT_RESULT['mid'] = param[11]
                EDC_PAYMENT_RESULT['ref_no'] = param[12]
                EDC_PAYMENT_RESULT['batch_no'] = param[13].strip().replace('#', '')
                E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|SUCCESS|'+json.dumps(EDC_PAYMENT_RESULT))
                # LOGGER.info(('DEBIT/CREDIT payment status', json.dumps(EDC_PAYMENT_RESULT)))
                _KioskService.python_dump(EDC_PAYMENT_RESULT)
                # edc_settlement()
                try:
                    _EDCTool.generate_edc_receipt(EDC_PAYMENT_RESULT)
                except Exception as e:
                    LOGGER.warning(str(e))
                store_settlement()
                # send_edc_server(EDC_PAYMENT_RESULT)
            else:
                _Global.EDC_ERROR = 'SALE_ERROR'
                E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|ERROR')
        else:
            _Global.EDC_ERROR = 'PORT_NOT_OPENED'
            E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|ERROR')
            LOGGER.warning(("OPEN_STATUS", str(OPEN_STATUS)))
    except Exception as e:
        _Global.EDC_ERROR = 'SALE_ERROR'
        E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|ERROR')
        LOGGER.warning(str(e))


IS_CANCELLED = False
MAX_ATTEMPTS = 300
CARD_ERROR = ['04', '43', '36', '41', '65', '67', '51', '33', 'P3', 'P4', 'P5', 'P6']
PIN_ERROR = ['55', '75', '54', '38']
SERVER_ERROR = ['03', '89', '57', '58', '31', '30', '27', '25', '12', '13', '14', 'P7', 'P8', 'P0', 'P1', 'P2', '91',
                '92', '94', '95', '99']
NORMAL_CASE = ['CI', 'PI', 'DO', 'TC', 'CO']


def define_error(txt):
    if txt is None:
        return 'UNKNOWN'
    elif txt in CARD_ERROR:
        return 'CARD_ERROR'
    elif txt in PIN_ERROR:
        return 'PIN_ERROR'
    elif txt in SERVER_ERROR:
        return 'SERVER_ERROR'
    elif txt in NORMAL_CASE:
        return 'NORMAL_CASE'
    else:
        return 'UNKNOWN'


def handling_card(amount, trxid=None):
    global EDC_PAYMENT_RESULT, IS_CANCELLED
    attempt = 0
    result_list = []
    pid = '[' + _Helper.get_random_chars(5, '1234567890') + ']'
    while True:
        attempt += 1
        if OPEN_STATUS is False:
            # disconnect_edc()
            LOGGER.info(('[Break] by OPEN_STATUS:', str(OPEN_STATUS)))
            break
        if IS_CANCELLED is True:
            LOGGER.info(('[Break] by IS_CANCELLED:', str(IS_CANCELLED)))
            IS_CANCELLED = False
            break
        if attempt >= MAX_ATTEMPTS:
            LOGGER.info(('[Break] by MAX_ATTEMPTS:', str(MAX_ATTEMPTS)))
            break
        # response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, module='EDC_Handling_Card'+pid)
        response, result = _Command.send_request(param=EDC["GET_STATE"])

        if response == 0:
            if result not in result_list:
                result_list.append(result)

            if ('|00|' + amount) in result:
                '''
                1. Transaction Type 		            0x11 
                2. Pinpad 					            0x12 
                3. Response Code 			            0x13 
                4. Amount 					            0x14 
                5. Other Amount 			            0x15 
                6. Invoice No 					        0x16 
                7. Card No (PAN) – Masking with “*”     0x17 
                8. Expire Date (YYMM) 				    0x18 
                9. Transaction Date Time (YYMMDDhhmmss) 0x19 
                10. Approval Code 				        0x20 
                11. TID 						        0x21 
                12. MID 						        0x22 
                13. Reference Number 				    0x23 
                14. Batch Number 					    0x24
                02||00|75000||000001|6011********9999|2612|20161003125804|123456|12345678|123456789012345|111111|000001
                '''
                param = result.split('|')
                EDC_PAYMENT_RESULT['raw'] = result
                EDC_PAYMENT_RESULT['card_type'] = _EDCTool.get_type(param[6])
                if trxid is None:
                    EDC_PAYMENT_RESULT['struck_id'] = _Helper.get_uuid()[:12]
                else:
                    EDC_PAYMENT_RESULT['struck_id'] = trxid.upper()
                EDC_PAYMENT_RESULT['amount'] = param[3]
                if IS_PIR is True:
                    EDC_PAYMENT_RESULT['amount'] = INIT_AMOUNT
                EDC_PAYMENT_RESULT['res_code'] = param[2]
                EDC_PAYMENT_RESULT['inv_no'] = param[5]
                EDC_PAYMENT_RESULT['card_no'] = param[6]
                _KioskService.CARD_NO = param[6]
                EDC_PAYMENT_RESULT['exp_date'] = param[7]
                EDC_PAYMENT_RESULT['trans_date'] = param[8]
                EDC_PAYMENT_RESULT['app_code'] = param[9]
                EDC_PAYMENT_RESULT['tid'] = param[10]
                EDC_PAYMENT_RESULT['mid'] = param[11]
                EDC_PAYMENT_RESULT['ref_no'] = param[12]
                EDC_PAYMENT_RESULT['batch_no'] = param[13].replace('\n', '').replace('#', '')
                E_SIGNDLER.SIGNAL_SALE_EDC.emit('SUCCESS|'+json.dumps(EDC_PAYMENT_RESULT))
                LOGGER.info(('DEBIT/CREDIT payment status', json.dumps(EDC_PAYMENT_RESULT), str(result_list)))
                # edc_settlement()
                _EDCTool.generate_edc_receipt(EDC_PAYMENT_RESULT)
                store_settlement()
                # send_edc_server(EDC_PAYMENT_RESULT)
                break
            else:
                '''
                05||CI|||||||||||
                05||PI|||||||||||
                01||DO|||||||||||
                02||TC|||||||||||
                05||CO|||||||||||
                05||CR|||||||||||

                '''
                if '05||SR|' in result:
                    E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|SR')
                    LOGGER.debug(('[Temporary Break] for Settlement', 'SALE|SR'))
                    break
                elif 'CI' in result:
                    result = 'CI'
                elif 'PI' in result:
                    result = 'PI'
                elif 'DO' in result:
                    result = 'DO'
                elif 'TC' in result:
                    result = 'TC'
                    IS_CANCELLED = True
                elif 'CO' in result:
                    result = 'CO'
                elif 'CR' in result:
                    result = 'CR'
                    IS_CANCELLED = True
                    if len(result_list) < 2:
                        result_list.append(result_list[-1])
                    error_code = result_list[-2][4:6]
                    result += '#'+define_error(error_code)
                E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|'+result)
                LOGGER.debug(('EDC Result :', 'SALE|'+result))
        sleep(1)


def start_disconnect_edc():
    _Helper.get_pool().apply_async(disconnect_edc)


def disconnect_edc():
    global OPEN_STATUS, IS_CANCELLED
    param = EDC['STOP'] + '|'
    try:
        if not STANDBY_MODE:
            response, result = _Command.send_request(param=param, output=None)
            # sleep(1)
            _KioskService.K_SIGNDLER.SIGNAL_GENERAL.emit('CLOSE_LOADING')
            if response == 0:
                OPEN_STATUS = False
                IS_CANCELLED = False
                LOGGER.info(("disconnect_edc : ", str(response), result))
            else:
                _Global.EDC_ERROR = 'FAILED_TO_DISCONNECT'
                LOGGER.warning(("RESPONSE : ", str(response), result))
        else:
            _Global.EDC_ERROR = 'FAILED_TO_STANDBY'
            LOGGER.debug(("Switch EDC to Standby Mode: ", STANDBY_MODE))
    except Exception as e:
        _Global.EDC_ERROR = 'FAILED_TO_DISCONNECT'
        LOGGER.warning(str(e))


def store_settlement():
    try:
        param_settlement = {
            "sid": _Helper.get_uuid(),
            "tid": EDC_PAYMENT_RESULT['tid'] + '|' + EDC_PAYMENT_RESULT['mid'],
            "bid": EDC_PAYMENT_RESULT['inv_no'] + '|' + EDC_PAYMENT_RESULT['card_no'],
            "filename": EDC_PAYMENT_RESULT['raw'],
            "status": "EDC|OPEN",
            "amount": EDC_PAYMENT_RESULT['amount'],
            "row": 1
        }
        _DAO.insert_settlement(param=param_settlement)
    except Exception as e:
        LOGGER.warning(str(e))


def start_edc_settlement():
    LOGGER.info("[START] define_edc_settlement")
    _Helper.get_pool().apply_async(define_edc_settlement)


def backend_edc_settlement():
    global SETTLEMENT_TYPE_COUNT, SETTLEMENTS_DATA
    SETTLEMENTS_DATA = _DAO.check_settlement()
    SETTLEMENT_TYPE_COUNT = card_type_count()
    settlement_method = card_type_settle()
    LOGGER.debug(("define_edc_settlement [DATA, COUNT, TYPE]", str(SETTLEMENTS_DATA), str(SETTLEMENT_TYPE_COUNT),
                 str(settlement_method)))
    if SETTLEMENT_TYPE_COUNT == 0:
        LOGGER.warning(("define_edc_settlement [DATA, COUNT, TYPE]", str(SETTLEMENTS_DATA), str(SETTLEMENT_TYPE_COUNT),
                        str(settlement_method)))
        return 'TRX_NOT_FOUND'
    elif settlement_method[0] == 'DEBIT CARD':
        edc_settlement()
        return 'TRIGGERED_FOR_DEBIT'
    elif settlement_method[0] == 'CREDIT CARD':
        edc_settlement_credit()
        return 'TRIGGERED_FOR_CREDIT'


def define_edc_settlement():
    global SETTLEMENT_TYPE_COUNT, SETTLEMENTS_DATA
    SETTLEMENTS_DATA = _DAO.check_settlement()
    SETTLEMENT_TYPE_COUNT = card_type_count()
    settlement_method = card_type_settle()
    LOGGER.debug(("define_edc_settlement [DATA, COUNT, TYPE]", str(SETTLEMENTS_DATA), str(SETTLEMENT_TYPE_COUNT),
                 str(settlement_method)))
    if SETTLEMENT_TYPE_COUNT == 0:
        E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
        return
    elif settlement_method[0] == 'DEBIT CARD':
        edc_settlement()
    elif settlement_method[0] == 'CREDIT CARD':
        edc_settlement_credit()


EDC_TESTING_MODE = False


def edc_settlement():
    global OPEN_STATUS
    param = EDC['SETTLE_DEBIT'] + '|'
    try:
        # Add Clear of Content
        # _Command.clear_content_of(_Command.MO_REPORT, '['+_Tools.get_random_chars(5, '1234567890')+']')

        if OPEN_STATUS is False:
            if EDC_TESTING_MODE is True:
                OPEN_STATUS = EDC_TESTING_MODE
            else:
                OPEN_STATUS = init_edc_with_handle()
        if OPEN_STATUS is True:
            response, result = _Command.send_request(param=param, output=None, flushing=_Command.MO_REPORT)
            if response == 0 or EDC_TESTING_MODE is True:
                # handling_settlement('DEBIT')
                E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT_DEBIT|PROCESSED')
                LOGGER.info(("edc_settlement", str(response), result))
            else:
                _Global.EDC_ERROR = 'FAILED_TO_DEBIT_SETTLEMENT'
                LOGGER.warning(("RESPONSE :", str(response), result))
        else:
            _Global.EDC_ERROR = 'FAILED_TO_SETTLEMENT'
            E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
            LOGGER.warning(("OPEN_STATUS:", str(OPEN_STATUS)))
    except Exception as e:
        _Global.EDC_ERROR = 'FAILED_TO_SETTLEMENT'
        E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
        LOGGER.warning(str(e))


def edc_settlement_credit():
    global OPEN_STATUS
    param = EDC['SETTLE_CREDIT'] + '|'
    try:
        # Add Clear of Content
        # _Command.clear_content_of(_Command.MO_REPORT, '['+_Tools.get_random_chars(5, '1234567890')+']')

        if OPEN_STATUS is False:
            if EDC_TESTING_MODE is True:
                OPEN_STATUS = EDC_TESTING_MODE
            else:
                OPEN_STATUS = init_edc_with_handle()
        if OPEN_STATUS is True:
            response, result = _Command.send_request(param=param, output=None, flushing=_Command.MO_REPORT)
            if response == 0 or EDC_TESTING_MODE is True:
                # handling_settlement('CREDIT')
                E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT_CREDIT|PROCESSED')
                LOGGER.info(("edc_settlement", str(response), result))
            else:
                _Global.EDC_ERROR = 'FAILED_TO_CREDIT_SETTLEMENT'
                LOGGER.warning(("RESPONSE :", str(response), result))
        else:
            _Global.EDC_ERROR = 'FAILED_TO_SETTLEMENT'
            E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
            LOGGER.warning(("OPEN_STATUS:", str(OPEN_STATUS)))
    except Exception as e:
        _Global.EDC_ERROR = 'FAILED_TO_SETTLEMENT'
        E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
        LOGGER.warning(str(e))


SETTLE_CODE = '03||00|'
TIMEOUT_CODE = '03||TO|'
FINAL_BREAK_CODE = '02||'
NOT_FOUND = '03||NF|'
NEED_RETRY = '03||SR|'
FORCE_SETTLEMENT = True if _ConfigParser.get_set_value('TERMINAL', 'force^settlement', '0') == '1' else False
LOOP_DELAY = 5


# TODO: Settlement Handler Enhancement
def handling_settlement(mode):
    global SETTLE_CODE, TIMEOUT_CODE, NOT_FOUND, NEED_RETRY, SETTLEMENT_PARAM
    if mode == 'CREDIT':
        SETTLE_CODE = '06||00|'
        TIMEOUT_CODE = '06||TO|'
        NOT_FOUND = '06||NF|'
        NEED_RETRY = '06||SR|'
    attempt = 0
    pid = '[' + mode +'-' + _Helper.get_random_chars(5, '1234567890') + ']'
    # Clearing Previous Response
    # _Command.clear_content_of(_Command.MO_REPORT, pid)
    # _Command.clear_content_of(_Command.MO_STATUS, pid)
    settle_result_history = []
    if FORCE_SETTLEMENT is True:
        mark_settlement_data()
        LOGGER.info('[Break] by Settlement Success in Force Mode')
        return
    while True:
        attempt += 1
        if OPEN_STATUS is False:
            E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
            LOGGER.info(('[Break] by OPEN STATUS:', str(mode), str(OPEN_STATUS), str(settle_result_history)))
            break
        if attempt == (MAX_ATTEMPTS/LOOP_DELAY):
            E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|ERROR')
            LOGGER.info(('[Break] by MAX_ATTEMPTS:', str(mode), str(MAX_ATTEMPTS/LOOP_DELAY), str(settle_result_history)))
            break

        response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, module='EDC_Settlement'+pid)

        if response == 0:
            LOGGER.debug(('[Settlement Type Count]', str(SETTLEMENT_TYPE_COUNT)))
            if result != "" and result not in settle_result_history:
                settle_result_history.append(result)

            elif SETTLE_CODE in result and len(settle_result_history) > 0:
                if result.split('|')[0] == '03':
                    SETTLEMENT_PARAM['row_debit'] = result.split('|')[4]
                    SETTLEMENT_PARAM['amount_debit'] = result.split('|')[3]
                elif result.split('|')[0] == '06':
                    SETTLEMENT_PARAM['row_credit'] = result.split('|')[4]
                    SETTLEMENT_PARAM['amount_credit'] = result.split('|')[3]
                LOGGER.debug(('[Mapping Settlement]', str(mode), str(result), str(SETTLEMENT_PARAM)))
                mark_settlement_data(printout=False, mode=mode)
                E_SIGNDLER.SIGNAL_SALE_EDC.emit('SALE|RECOVERY')
                LOGGER.info(('[Final Break] SETTLED by : ', str(mode), result, str(settle_result_history)))
                break

            elif NOT_FOUND in result and len(settle_result_history) > 0:
                # mark_settlement_data(printout=False, mode=mode)
                if SETTLEMENT_TYPE_COUNT == 1:
                    E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|SUCCESS')
                    sleep(2)
                    E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|FINISH')
                else:
                    E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('EDC_SETTLEMENT|NOT_FOUND')
                LOGGER.info(('[Final Break] NOT FOUND by: ', str(mode), result, str(settle_result_history)))
                break

        sleep(LOOP_DELAY)


SETTLEMENTS_DATA = None
SETTLEMENTS_TXT = '\r\n'
SETTLEMENTS_SUM = 0
SETTLEMENT_TYPE_COUNT = 1
SETTLEMENT_DEBIT = []
SETTLEMENT_CREDIT = []
SETTLEMENT_PARAM = {}


def reset_to_default():
    global SETTLEMENTS_DATA, SETTLEMENTS_TXT, SETTLEMENTS_SUM, SETTLEMENT_TYPE_COUNT, SETTLEMENT_DEBIT, \
        SETTLEMENT_CREDIT, SETTLEMENT_PARAM
    SETTLEMENTS_DATA = None
    SETTLEMENTS_TXT = '\r\n'
    SETTLEMENTS_SUM = 0
    SETTLEMENT_TYPE_COUNT = 1
    SETTLEMENT_CREDIT = []
    SETTLEMENT_DEBIT = []
    SETTLEMENT_PARAM = {}


def card_type_count():
    global SETTLEMENT_TYPE_COUNT, SETTLEMENT_CREDIT, SETTLEMENT_DEBIT
    type_count = []
    if SETTLEMENTS_DATA is None:
        return SETTLEMENT_TYPE_COUNT
    for settle in SETTLEMENTS_DATA:
        card_no = settle['filename'].split('|')[6]
        card_type = _EDCTool.get_type(card_no)
        if card_type == 'CREDIT CARD':
            SETTLEMENT_CREDIT.append(settle)
        if card_type == 'DEBIT CARD':
            SETTLEMENT_DEBIT.append(settle)
        if card_type not in type_count:
            type_count.append(card_type)
    SETTLEMENT_TYPE_COUNT = len(type_count)
    return SETTLEMENT_TYPE_COUNT


def card_type_settle():
    type_count = []
    if SETTLEMENTS_DATA is None:
        return type_count
    for settle in SETTLEMENTS_DATA:
        card_no = settle['filename'].split('|')[6]
        card_type = _EDCTool.get_type(card_no)
        if card_type not in type_count:
            type_count.append(card_type)
    return type_count


def start_get_settlement():
    _Helper.get_pool().apply_async(get_settlement_data)


def get_settlement_data():
    global SETTLEMENTS_DATA, SETTLEMENTS_SUM, SETTLEMENTS_TXT
    SETTLEMENTS_DATA = None
    SETTLEMENTS_TXT = '\r\n'
    SETTLEMENTS_SUM = 0

    try:
        SETTLEMENTS_DATA = _DAO.check_settlement()
        if len(SETTLEMENTS_DATA) == 0:
            E_SIGNDLER.SIGNAL_GET_SETTLEMENT_EDC.emit('NOT_FOUND')
            return
        for settle in SETTLEMENTS_DATA:
            SETTLEMENTS_SUM += int(settle['amount'])

        E_SIGNDLER.SIGNAL_GET_SETTLEMENT_EDC.emit(json.dumps({
            'total': str(len(SETTLEMENTS_DATA)),
            'summary': str(SETTLEMENTS_SUM)
        }))
    except Exception as e:
        E_SIGNDLER.SIGNAL_GET_SETTLEMENT_EDC.emit('ERROR')
        LOGGER.warning(str(e))


def mark_settlement_data(printout=True, mode='DEBIT CARD'):
    global SETTLEMENTS_DATA, SETTLEMENTS_TXT, SETTLEMENT_PARAM
    # SETTLEMENTS_DATA = _DAO.check_settlement()
    if len(SETTLEMENTS_DATA) == 0 or SETTLEMENTS_DATA is None:
        return
    # Pre-adjust Settlement Text with TID & MID
    tid_settle = SETTLEMENTS_DATA[0]['tid'].split('|')[0]
    SETTLEMENTS_TXT += ('   TID EDC :   ' + tid_settle + '\r\n')
    mid_settle = SETTLEMENTS_DATA[0]['tid'].split('|')[1]
    SETTLEMENTS_TXT += ('   MID EDC :   ' + mid_settle + '\r\n\r\n')
    SETTLEMENTS_TXT += '   ===================================\r\n'
    SETTLEMENTS_TXT += '    NO | INV.NO | CARD.NO | AMOUNT\r\n'
    SETTLEMENTS_TXT += '   ===================================\r\n\r\n'

    n = 0
    list_settlement = []

    __now = datetime.now()

    SETTLEMENT_PARAM['b_tid'] = tid_settle
    SETTLEMENT_PARAM['b_mid'] = mid_settle
    SETTLEMENT_PARAM['host_date'] = __now.strftime('%m%d')
    SETTLEMENT_PARAM['host_time'] = __now.strftime('%H%M%S')

    if mode == 'DEBIT':
        __data_to_settle = SETTLEMENT_DEBIT
        SETTLEMENT_PARAM['acq_name'] = 'BNI_DEBIT'
        # send_edc_server(SETTLEMENT_PARAM, 'SETTLEMENT')
    elif mode == 'CREDIT':
        SETTLEMENT_PARAM['acq_name'] = 'BNI_CREDIT'
        __data_to_settle = SETTLEMENT_CREDIT
        # send_edc_server(SETTLEMENT_PARAM, 'SETTLEMENT')
    else:
        __data_to_settle = SETTLEMENTS_DATA

    for settle in __data_to_settle:
        list_settlement.append(settle['filename'])
        n += 1
        param_settle = {
            'sid': settle['sid'],
            'status': 'EDC|SETTLED'
        }
        LOGGER.info(("[UPDATE STATUS] mark_settlement_data", str(mode), str(__data_to_settle)))
        SETTLEMENTS_TXT += ('   '+str(n)+'|'+settle['bid']+'|'+str(settle['amount'])+'\r\n')
        _DAO.update_settlement(param_settle)

    SETTLEMENTS_TXT += '\r\n'
    SETTLEMENTS_TXT += ('   ----------------('+str(len(SETTLEMENTS_DATA))+') TRX\r\n')
    SETTLEMENTS_TXT += ('   ----------------('+str(SETTLEMENTS_SUM)+') IDR\r\n')

    # LOGGER.info(('settlement_text: ', SETTLEMENTS_TXT))
    # Print Settlement Receipt
    if printout is True:
        _PrintTool.print_global(input_text=SETTLEMENTS_TXT, use_for='EDC_SETTLEMENT')

    # Post Update Settlement - DISABLED
    # post_mark_settlement(list_settlement, _Tools.now())
    sleep(1)
    if SETTLEMENT_TYPE_COUNT == 1:
        # SETTLEMENT_PARAM['b_tid'] = tid_settle
        # SETTLEMENT_PARAM['b_mid'] = mid_settle
        post_mark_settlement_direct(SETTLEMENT_PARAM)
        E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('SUCCESS')
        sleep(2)
        E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.emit('FINISH')
        reset_to_default()
        LOGGER.info(("[FINISH] reset_to_default", str(mode)))
    else:
        LOGGER.info(("[RECALL] define_edc_settlement", str(mode)))
        define_edc_settlement()


def post_mark_settlement(l, t):
    try:
        param = {
            "stid": '^^^'.join(l),
            "updatedAt": t
        }
        status, response = _NetworkAccess.post_to_url(_KioskService.BACKEND_URL + 'settlement/mark', param)
        LOGGER.info(("post_mark_settlement : ", response))
    except Exception as e:
        LOGGER.warning(("post_mark_settlement : ", e))


def post_mark_settlement_direct(param):
    try:
        status, response = _NetworkAccess.post_to_url(_KioskService.BACKEND_URL + 'settlement/mark-direct', param)
        LOGGER.info(("post_mark_settlement : ", response))
    except Exception as e:
        LOGGER.warning(("post_mark_settlement : ", e))


def start_void_data():
    _Helper.get_pool().apply_async(void_settlement_data)


def void_settlement_data():
    try:
        all_void = _DAO.check_settlement()
        if len(all_void) == 0:
            E_SIGNDLER.SIGNAL_VOID_SETTLEMENT_EDC.emit('NOT_FOUND')
            return
        for void in all_void:
            param_void = {
                'sid': void['sid'],
                'status': 'EDC|VOID'
            }
            _DAO.update_settlement(param_void)
        E_SIGNDLER.SIGNAL_VOID_SETTLEMENT_EDC.emit('SUCCESS')
        LOGGER.info(('SUCCESS for : ', str(all_void)))
        return 'VOID_SETTLEMENT_SUCCESS'
    except Exception as e:
        E_SIGNDLER.SIGNAL_VOID_SETTLEMENT_EDC.emit('ERROR')
        LOGGER.warning(str(e))
        return 'VOID_SETTLEMENT_ERROR'


def get_payment_result():
    return EDC_PAYMENT_RESULT


DUMMY_EDC_RESPONSE = {
    "ref_no": "000011000224", "amount": "999000", "card_no": "4105********1281", "batch_no": "000001",
    "tid": "123123123", "app_code": "123456", "exp_date": "2000", "res_code": "00",
    "raw": "02||00|1755 400||000183|4105********1281|2004|201806 05141304|005002|12001429|000100012000014|000011000224|000001#",
    "trans_date": "20180605141304", "inv_no": "001234", "mid": "000012301230123", "card_type": "CREDIT CARD",
    "struck_id": "abcdef123456"}


def start_dummy_edc_receipt():
    _Helper.get_pool().apply_async(_EDCTool.generate_edc_receipt, (DUMMY_EDC_RESPONSE,))


def standardize_param(param, trx):
    new_param = dict()
    if param is None or len(param) == 0:
        return new_param
    # {"exp_date": "2207", "struck_id": "c76c9 7e42486", "mid": "000100012000014", "res code": "00", "app_code": "392509",
    # "card_no": "5264********3342", "ref_no": "000000010027", "tid": "12001481", "trans_date": "20190130185829",
    # "raw": "02||00|4 16||000014|5264********3342|2207|2019013 0185829|392509|12001481|000100012000014|000000010027|000005#",
    # "inv_no": "000014 ", "amount": "416400", "card_type": "DEBIT CARD", "batch_no": "000005"}
    # trx command = [10 -> Sale, 11 -> Refund, 20 -> Void Sale, 21 -> Void Refund, 30 -> Settlement]
    edc_command = {'SALE': '10', 'SETTLEMENT': '30'}
    new_param['trx_type'] = edc_command[trx]
    new_param['device_timestamp'] = str(int(time()))
    if trx == 'SALE':
        # new_param['tid'] = param['tid']
        # new_param['mid'] = param['mid']
        new_param['acq_name'] = 'BNI_CREDIT' if _EDCTool.get_type(param['card_no']) == 'CREDIT CARD' else 'BNI_DEBIT'
        new_param['invoice_num'] = param['inv_no']
        new_param['approval_code'] = param['app_code']
        new_param['rrn'] = param['ref_no']
        new_param['trx_host_date'] = param['trans_date'][4:8]
        new_param['trx_host_time'] = param['trans_date'][8:]
        new_param['pan'] = param['card_no']
        # new_param['is_on_us'] = '1'
        new_param['is_debit'] = '0' if _EDCTool.get_type(param['card_no']) == 'CREDIT CARD' else '1'
        # new_param['entry_mode'] = '051'
        new_param['base_amount'] = param['amount'].zfill(12)
        new_param['tip_amount'] = '0'.zfill(12)
    elif trx == 'SETTLEMENT':
        # new_param['tid'] = param['b_tid']
        # new_param['mid'] = param['b_mid']
        new_param['acq_name'] = param['acq_name']
        new_param['batch_num'] = '1'.zfill(6)
        new_param['settlement_host_date'] = param['host_date']
        new_param['settlement_host_time'] = param['host_time']
        if param['acq_name'] == 'BNI_CREDIT':
            new_param['num_of_sale_trx'] = param['row_credit']
            new_param['total_sale_base_amount'] = param['amount_credit']
        elif param['acq_name'] == 'BNI_DEBIT':
            new_param['num_of_sale_trx'] = param['row_debit']
            new_param['total_sale_base_amount'] = param['amount_debit']
        new_param['num_of_refund_trx'] = '0'
        new_param['total_sale_refund_amount'] = '0'.zfill(12)
        new_param['total_tip_amount'] = '0'.zfill(12)
    return new_param


def send_edc_server(param, trx='10'):
    edc_server = _ConfigParser.get_value('TERMINAL', 'edc^server')
    if len(param) < 1 or edc_server is None or len(edc_server) < 1:
        LOGGER.warning('Failed to Send_Data to EDC Server')
        return False
    try:
        __param = standardize_param(param, trx)
        __url = edc_server + '/EDCServerHost/v1/reporting/debit_credit'
        status, response = _NetworkAccess.post_to_url(__url, __param)
        LOGGER.info(("send_edc_server : ", response))
        return True
    except Exception as e:
        LOGGER.warning(("send_edc_server : ", e))
        return False




