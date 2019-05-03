__author__ = 'fitrah.wahyudi.imam@gmail.com'


from _cConfig import _ConfigParser, _Global
from _cCommand import _Command
from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _tTools import _Tools
from time import sleep
import json

LOGGER = logging.getLogger()
QPROX_PORT = _Global.QPROX_PORT
MID_MAN = _Global.MID_MAN
TID_MAN = _Global.TID_MAN
SAM_MAN = _Global.SAM_MAN
MID_BNI = _Global.MID_BNI
TID_BNI = _Global.TID_BNI
MC_BNI = _Global.MC_BNI
SAM1_BNI = _Global.SAM1_BNI
SAM2_BNI = _Global.SAM2_BNI
MID_BRI = _Global.MID_BRI
TID_BRI = _Global.TID_BRI
PROCODE_BRI = _Global.PROCODE_BRI
MID_BCA = _Global.MID_BCA
TID_BCA = _Global.TID_BCA

BANKS = _Global.BANKS
# print(BANKS)

BNI_SAM_SLOT = {
    '1': SAM1_BNI,
    '2': SAM2_BNI
}


QPROX = {
    "OPEN": "000",
    "INIT": "001",
    "AUTH": "002",
    "BALANCE": "003",
    "TOPUP": "004",
    "KA_INFO": "005",
    "CREATE_ONLINE_INFO": "006",
    "INIT_ONLINE": "007",
    "DEBIT": "008",
    "UNKNOWN": "009",
    "STOP": "010",
    "UPDATE_TID_BNI": "011",
    "INIT_BNI": "012",
    "TOPUP_BNI": "013",
    "KA_INFO_BNI": "014",
    "PURSE_DATA_BNI": "015", #Get Card Info For Topup Modal
    "SEND_CRYPTO": "016", #Send Cryptogram For Topup Modal
    "REFILL_ZERO": "018", #Refill Zero To Fix Error Update Balance Failure
}


BNI_CARD_NO_SLOT_1 = ''
BNI_CARD_NO_SLOT_2 = ''


class QSignalHandler(QObject):
    __qualname__ = 'QSignalHandler'
    SIGNAL_INIT_QPROX = pyqtSignal(str)
    SIGNAL_DEBIT_QPROX = pyqtSignal(str)
    SIGNAL_AUTH_QPROX = pyqtSignal(str)
    SIGNAL_BALANCE_QPROX = pyqtSignal(str)
    SIGNAL_TOPUP_QPROX = pyqtSignal(str)
    SIGNAL_KA_INFO_QPROX = pyqtSignal(str)
    SIGNAL_ONLINE_INFO_QPROX = pyqtSignal(str)
    SIGNAL_INIT_ONLINE_QPROX = pyqtSignal(str)
    SIGNAL_STOP_QPROX = pyqtSignal(str)
    SIGNAL_GET_TOPUP_READINESS = pyqtSignal(str)
    SIGNAL_REFILL_ZERO = pyqtSignal(str)


QP_SIGNDLER = QSignalHandler()
OPEN_STATUS = False
TEST_MODE = _Global.TEST_MODE


def send_cryptogram(card_info, cyptogram, slot=1, bank='BNI'):
    if bank == 'BNI':
        #Getting Previous samBalance
        samPrevBalance = _Global.BNI_SAM_1_WALLET if slot == 1 else _Global.BNI_SAM_2_WALLET
        # Converting Default Slot into Actual Slot
        alias_slot = BNI_SAM_SLOT[str(slot)]
        if len(card_info) == 0 or card_info is None:
            LOGGER.warning(('send_cryptogram', str(card_info), 'WRONG_VALUE'))
            return False
        if len(cyptogram) == 0 or cyptogram is None:
            LOGGER.warning(('send_cryptogram', str(cyptogram), 'WRONG_VALUE'))
            return False
        param = QPROX['SEND_CRYPTO'] + '|' + str(alias_slot) + '|' + str(card_info) + '|' + str(cyptogram)
        response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
        LOGGER.debug(("send_cryptogram", result))
        if response == 0 and len(result) > 10:
            result = result.replace('#', '')
            output = {
                'result': result,
                'bank_id': '2',
                'bank_name': bank,
            }
            sleep(1)
            ka_info_bni(slot=slot)
            # get_card_info(slot=slot)
            LOGGER.info(('send_cryptogram', str(slot), bank, str(output)))
            samCardNo = _Global.BNI_SAM_1_NO if slot == 1 else _Global.BNI_SAM_2_NO
            samLastBalance = _Global.BNI_SAM_1_WALLET if slot == 1 else _Global.BNI_SAM_2_WALLET
            param = {
                'trxid': 'REFILL_SAM',
                'samCardNo': samCardNo,
                'samCardSlot': slot,
                'samPrevBalance': samPrevBalance,
                'samLastBalance': samLastBalance,
                'topupCardNo': '',
                'topupPrevBalance': samPrevBalance,
                'topupLastBalance': samLastBalance,
                'status': 'REFILL_SUCCESS',
                'remarks': result,
            }
            _Global.store_upload_sam_audit(param)
            sleep(3)
            #Upload To Server
            _Global.upload_bni_wallet()
            _Global.TRIGGER_MANUAL_TOPUP = True
            return output
        else:
            _Global.NFC_ERROR = 'SEND_CRYPTO_BNI_ERROR_SLOT_'+str(slot)
            return False
    else:
        return False


# MO_REPORT
# 0001754699000002558375469900000255835A929C0E8DCEC98A95A574DE68D93CBB000000000100000088889999040000002D04C36E88889999040000002D04C36E0000000000000000000079EC3F7C7EED867EBC676CD434082D2F

def get_card_info(slot=1, bank='BNI'):
    global BNI_CARD_NO_SLOT_1, BNI_CARD_NO_SLOT_2
    if bank == 'BNI':
        # slot is index/sequence 0 and 1
        _slot = slot - 1
        param = QPROX['PURSE_DATA_BNI'] + '|' + str(_slot)
        response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
        LOGGER.debug(("init", result))
        if response == 0 and len(result) > 10:
            result = result.replace('#', '')
            output = {
                'card_info': result,
                'card_no': result[4:20],
                'bank_tid': _Global.TID_BNI,
                'bank_id': '2',
                'bank_name': bank,
            }
            # ka_info_bni(slot=slot)
            if slot == 1:
                BNI_CARD_NO_SLOT_1 = output['card_no']
                _Global.BNI_SAM_1_NO = BNI_CARD_NO_SLOT_1
            if slot == 2:
                BNI_CARD_NO_SLOT_2 = output['card_no']
                _Global.BNI_SAM_2_NO = BNI_CARD_NO_SLOT_2
            LOGGER.info(('final', str(slot), bank, str(output)))
            return output
        else:
            _Global.NFC_ERROR = 'CHECK_CARD_INFO_BNI_ERROR_SLOT_'+str(slot)
            return False
    else:
        return False


def open_qprox():
    global OPEN_STATUS
    if QPROX_PORT is None:
        LOGGER.debug(("open_qprox port : ", QPROX_PORT))
        _Global.NFC_ERROR = 'PORT_NOT_DEFINED'
        return False
    param = QPROX["OPEN"] + "|" + QPROX_PORT
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((param, result))
    OPEN_STATUS = True if response == 0 else False
    return OPEN_STATUS


def start_disconnect_qprox():
    _Tools.get_pool().apply_async(disconnect_qprox)


def disconnect_qprox():
    param = QPROX['STOP'] + '|'
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((response, result))


INIT_STATUS = False
INIT_TOPUP_MANDIRI = False
INIT_TOPUP_BNI = False
INIT_LIST = []


def start_init_qprox():
    _Tools.get_pool().apply_async(init_qprox)


def init_qprox():
    global INIT_STATUS, INIT_LIST, INIT_TOPUP_BNI, INIT_TOPUP_MANDIRI
    if OPEN_STATUS is not True:
        LOGGER.warning(('OPEN STATUS', str(OPEN_STATUS)))
        _Global.NFC_ERROR = 'PORT_NOT_OPENED'
        return
    try:
        for BANK in BANKS:
            if BANK['STATUS'] is True:
                if BANK['BANK'] == 'MANDIRI':
                    param = QPROX['INIT'] + '|' + QPROX_PORT + '|' + BANK['SAM'] + \
                            '|' + BANK['MID'] + '|' + BANK['TID']
                    response, result = _Command.send_request(param=param, output=None)
                    if response == 0:
                        LOGGER.info((BANK['BANK'], result))
                        INIT_LIST.append(BANK)
                        INIT_STATUS = True
                        INIT_TOPUP_MANDIRI = False
                    else:
                        LOGGER.warning((BANK['BANK'], result))

                if BANK['BANK'] == 'BNI':
                    param = QPROX['UPDATE_TID_BNI'] + '|' + TID_BNI
                    response, result = _Command.send_request(param=param, output=None)
                    if response == 0:
                        LOGGER.info((BANK['BANK'], result))
                        INIT_LIST.append(BANK)
                        INIT_STATUS = True
                        INIT_TOPUP_BNI = True
                        #Add Call KA Auth
                        # get_bni_wallet_status()
                    else:
                        LOGGER.warning((BANK['BANK'], result))
            sleep(1)
            continue
    except Exception as e:
        _Global.NFC_ERROR = 'FAILED_TO_INIT'
        LOGGER.warning(('init_qprox : ', e))


def start_debit_qprox(amount):
    _Tools.get_pool().apply_async(debit_qprox, (amount,))


def debit_qprox(amount):
    if len(INIT_LIST) == 0:
        LOGGER.warning(('debit_qprox', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + 'ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    param = QPROX['DEBIT'] + '|' + str(amount)
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug(("debit_qprox : ", result))
    # TODO check result
    if response == 0 and result is not None:
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + str(result))
    else:
        _Global.NFC_ERROR = 'DEBIT_ERROR'
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + 'ERROR')


def start_auth_ka():
    print('pyt: Waiting Login Card To Be Put Into Reader...')
    _Tools.get_pool().apply_async(auth_ka)


'''
Port, Slot, PIN SAM, Institution, Terminal, PIN KA, PIN KL,
COM1, 01, 0123456789abcdef, 00010002, 20010203, 20010203
'''


def auth_ka():
    global INIT_TOPUP_MANDIRI
    if len(INIT_LIST) == 0:
        LOGGER.warning(('auth_ka', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    _slot = str(_Global.MANDIRI_ACTIVE)
    _ka_pin = _Global.KA_PIN1
    if _slot == '2':
        _ka_pin = _Global.KA_PIN2
    param = QPROX['AUTH'] + '|' + QPROX_PORT + '|' + _slot + '|' + BANKS[0]['SAM'] + '|' + BANKS[0]['MID'] + '|' + \
            BANKS[0]['TID'] + '|' + _ka_pin + '|' + _Global.KL_PIN
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug(("auth_ka : ", _slot, result))
    # print('pyt: auth_ka mandiri : ', result)
    if response == 0:
        INIT_TOPUP_MANDIRI = True
        ka_info_mandiri(slot=_slot)
        QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|SUCCESS')
        # print('pyt: auth_ka NIK : ', result)
        # if KA_NIK in result:
        #     INIT_TOPUP_MANDIRI = True
        #     ka_info_mandiri()
        #     QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|SUCCESS')
        # else:
        #     QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|'+str(result))
    else:
        _Global.NFC_ERROR = 'AUTH_KA_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|'+str(result))


def start_check_balance():
    _Tools.get_pool().apply_async(check_balance)


'''
OUTPUT = Balance
'''
LAST_BALANCE_CHECK = None

FW_BANK = {
    '0': 'MANDIRI',
    '1': 'BRI JAVA',
    '2': 'BRI Desfire',
    '3': 'BNI',
    '4': 'DKI',
    '5': 'BCA'
}


def get_fw_bank(key):
    bank = ''
    try:
        bank = FW_BANK[key]
    except IndexError:
        bank = 'UNKNOWN'
    finally:
        return bank


def check_balance():
    global LAST_BALANCE_CHECK
    if TEST_MODE is True:
        output = {
            'balance': '99000',
            'card_no': '6032123443211234',
            'bank_type': '0',
            'bank_name': 'MANDIRI',
            'able_topup': '0000'
        }
        QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|' + json.dumps(output))
        return
    param = QPROX['BALANCE'] + '|'
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug(("check_balance : ", 'native', result))
    if response == 0 and len(result) > 4:
        output = {
            'balance': result.split('|')[0],
            'card_no': result.split('|')[1].replace('#', ''),
            'bank_type': result.split('|')[2].replace('#', ''),
            'bank_name': get_fw_bank(result.split('|')[2]),
            'able_topup': result.split('|')[3].replace('#', ''),
        }
        LAST_BALANCE_CHECK = output
        _Global.NFC_ERROR = ''
        QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|' + json.dumps(output))
    else:
        QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|ERROR')


def start_top_up_mandiri(amount, trxid):
    _Tools.get_pool().apply_async(top_up_mandiri, (amount, trxid,))

'''
OUTPUT = Balance, Report SAM, Report KA, Card Number
'''


def top_up_mandiri(amount, trxid='', slot=None):
    if len(INIT_LIST) == 0:
        LOGGER.warning(('top_up_mandiri', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP|ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    if slot is None:
        slot = str(_Global.MANDIRI_ACTIVE)
    param = QPROX['TOPUP'] + '|' + str(amount)
    _response, _result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    if _response == 0 and '|' in _result:
        __data = _result.split('|')
        __status = __data[0]
        __remarks = ''
        if __status == '0000':
            __remarks = __data[5]
        if __status in ERROR_TOPUP.keys():
            __remarks += '|'+ERROR_TOPUP[__status]
        # status='0000' -> success
        # samCardNo='7546130000013640'
        # samPrevBalance='100000'
        # samLastBalance='90000'
        # reportSAM='75461300000136407546130000013640010002EE0003520000647A0F127A0EAE2D944C9D04B5E8816DCE7F381E8480010701000009000009000007010002EE00000088889999E7C0A8568C598500AB3DFE1320FCBDE369D72A9D48B835AB00035204B5E8816D04B5E8816DCE7F380000090000090000754646000000159675464600000015965017CE0054DB8D88'
        # topupCardNo='7546460000001596'
        # topupPrevBalance='1000'
        # topupLastBalance='11000'
        # 0000| -> 0
        # 7546000001023442| -> 1
        # 556900| -> 2
        # 556899| -> 3
        # 1| -> 4
        # 75460000010567757546000001056775010C79B40C81840007D00F42400F3A702BA49F3600B6FFC692431D360F424001070100005A00002F000007010C79B40007D0888899996551465F2B1393685E20873C706ED28A2DB9825BF242CC3F0C818400B6FFC69200B6FFC692431D3600005A00002F000075460000000000480000000000000048E7AADAEBF223F5C4|
        # 7546000001056775| -> 6
        # 8912| -> 7
        # 8913 -> 8
        # topup_last_balance = str(int(__data[2].lstrip('0')) + int(amount))
        __samLastBalance = __data[3].lstrip('0')
        __report_sam = __data[5]
        # if __status == 'FFFE' and __data[2].lstrip('0') == __data[3].lstrip('0'):
        #     # __samLastBalance = str(int(__data[2].lstrip('0')) - int(amount))
        #     __report_sam = 'CARD_NOT_EXIST'
        output = {
            'last_balance': __data[8].lstrip('0'),
            'report_sam': __report_sam.split('#')[1],
            'card_no': __data[6],
            'report_ka': __report_sam.split('#')[0],
            'bank_id': '1',
            'bank_name': 'MANDIRI',
        }
        # Update Local Mandiri Wallet
        if slot == '1':
            _Global.MANDIRI_WALLET_1 = _Global.MANDIRI_WALLET_1 - int(amount)
            _Global.MANDIRI_ACTIVE_WALLET = _Global.MANDIRI_WALLET_1
        if slot == '2':
            _Global.MANDIRI_WALLET_2 = _Global.MANDIRI_WALLET_2 - int(amount)
            _Global.MANDIRI_ACTIVE_WALLET = _Global.MANDIRI_WALLET_2
        LOGGER.info(('top_up_mandiri', slot, str(output), _result))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP|' + json.dumps(output))
        param = {
            'trxid': trxid,
            'samCardNo': __data[1],
            'samCardSlot': slot,
            'samPrevBalance': __data[2].lstrip('0'),
            'samLastBalance': __samLastBalance,
            'topupCardNo': __data[6],
            'topupPrevBalance': __data[7].lstrip('0'),
            'topupLastBalance': __data[8].lstrip('0'),
            'status': __status,
            'remarks': __remarks,
        }
        _Global.store_upload_sam_audit(param)
        # Update to server
        _Global.upload_mandiri_wallet()
    else:
        LOGGER.warning(("top_up_mandiri", slot, _result))
        _Global.NFC_ERROR = 'TOPUP_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP|ERROR')


def start_top_up_bni(amount, trxid):
    # get_bni_wallet_status()
    _Tools.get_pool().apply_async(top_up_bni, (amount, trxid,))

'''
OUTPUT = Report SAM, Card Number
'''


def get_bni_wallet_status(upload=True):
    global BNI_TOPUP_AMOUNT
    try:
        # First Attempt For SLOT 1
        attempt = 0
        while True:
            attempt += 1
            get_card_info(slot=1)
            sleep(1)
            ka_info_bni(slot=1)
            if attempt == 3 or _Global.BNI_SAM_1_WALLET != 0:
                break
            sleep(1)
        # Second Attempt For SLOT 2
        _attempt = 0
        while True:
            _attempt += 1
            get_card_info(slot=2)
            sleep(1)
            ka_info_bni(slot=2)
            if _attempt == 3 or _Global.BNI_SAM_1_WALLET != 0:
                break
            sleep(1)
        if _Global.BNI_ACTIVE == 1:
            _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_1_WALLET
            # BNI_TOPUP_AMOUNT = _Global.BNI_SAM_1_WALLET
            LOGGER.info(('get_bni_wallet_status', str(_Global.BNI_ACTIVE), str(_Global.BNI_SAM_1_WALLET)))
        if _Global.BNI_ACTIVE == 2:
            _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_2_WALLET
            # BNI_TOPUP_AMOUNT = _Global.BNI_SAM_2_WALLET
            LOGGER.info(('get_bni_wallet_status', str(_Global.BNI_ACTIVE), str(_Global.BNI_SAM_2_WALLET)))
        if upload is True:
            # Do Upload To Server
            _Global.upload_bni_wallet()
    except Exception as e:
        LOGGER.warning(('get_bni_wallet_status', str(e)))


def update_bni_wallet(slot, amount, last_balance=None):
    if slot == 1:
        if last_balance is None:
            _Global.BNI_SAM_1_WALLET = _Global.BNI_SAM_1_WALLET - int(amount)
        else:
            _Global.BNI_SAM_1_WALLET = int(last_balance)
        _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_1_WALLET
    if slot == 2:
        if last_balance is None:
            _Global.BNI_SAM_2_WALLET = _Global.BNI_SAM_2_WALLET - int(amount)
        else:
            _Global.BNI_SAM_2_WALLET = int(last_balance)
        _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_2_WALLET
    # Do Upload To Server
    _Global.upload_bni_wallet()


ERROR_TOPUP = {
    '5106': 'ERROR_BNI_NOT_PRODUCTION',
    '5103': 'ERROR_BNI_PURSE_DISABLED',
    '1008': 'ERROR_INACTIVECARD',
    'FFFE': 'CARD_NOT_EXIST',
    '1004': 'PROCESS_TIMEOUT',
    'FFFD': 'PROCESS_NOT_FINISHED',
}


def top_up_bni(amount, trxid, slot=None):
    _slot = 0
    if slot is None:
        slot = _Global.BNI_ACTIVE
        _slot = _Global.BNI_ACTIVE - 1
    param = QPROX['INIT_BNI'] + '|' + str(_slot) + '|' + TID_BNI
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug(("init_bni", result))
    print('pyt: top_up_bni > init_bni : ', result)
    if response == 0 and '12292' not in result:
        # Update : Add slot after value
        _param = QPROX['TOPUP_BNI'] + '|' + str(amount) + '|' + str(_slot)
        _response, _result = _Command.send_request(param=_param, output=_Command.MO_REPORT, wait_for=2)
        print('pyt: top_up_bni > init_bni > update_bni : ', _result)
        __remarks = ''
        if _response == 0 and '|' in _result:
            _result = _result.replace('#', '')
            __data = _result.split('|')
            __status = __data[0]
            if __status == '0000':
                __remarks = __data[5]
            if __status in ERROR_TOPUP.keys():
                __remarks = ERROR_TOPUP[__status]
            # status='0000' -> success
            # samCardNo='7546130000013640'
            # samPrevBalance='100000'
            # samLastBalance='90000'
            # reportSAM='75461300000136407546130000013640010002EE0003520000647A0F127A0EAE2D944C9D04B5E8816DCE7F381E8480010701000009000009000007010002EE00000088889999E7C0A8568C598500AB3DFE1320FCBDE369D72A9D48B835AB00035204B5E8816D04B5E8816DCE7F380000090000090000754646000000159675464600000015965017CE0054DB8D88'
            # topupCardNo='7546460000001596'
            # topupPrevBalance='1000'
            # topupLastBalance='11000'
            # 0000| -> 0
            # 7546000001023442| -> 1
            # 556900| -> 2
            # 556899| -> 3
            # 1| -> 4
            # 75460000010567757546000001056775010C79B40C81840007D00F42400F3A702BA49F3600B6FFC692431D360F424001070100005A00002F000007010C79B40007D0888899996551465F2B1393685E20873C706ED28A2DB9825BF242CC3F0C818400B6FFC69200B6FFC692431D3600005A00002F000075460000000000480000000000000048E7AADAEBF223F5C4|
            # 7546000001056775| -> 6
            # 8912| -> 7
            # 8913 -> 8
            # topup_last_balance = str(int(__data[2].lstrip('0')) + int(amount))
            __samLastBalance = __data[3].lstrip('0')
            __report_sam = __data[5]
            if __status == 'FFFE' and __data[2].lstrip('0') == __data[3].lstrip('0'):
                # __samLastBalance = str(int(__data[2].lstrip('0')) - int(amount))
                __report_sam = 'CARD_NOT_EXIST'
            output = {
                'last_balance': __data[8].lstrip('0'),
                'report_sam': __report_sam,
                'card_no': __data[6],
                'report_ka': 'N/A',
                'bank_id': '2',
                'bank_name': 'BNI',
            }
            update_bni_wallet(slot, amount, __samLastBalance)
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit(__status+'|'+json.dumps(output))
            LOGGER.info(('top_up_bni', trxid, slot, str(output)))
            param = {
                'trxid': trxid,
                'samCardNo': __data[1],
                'samCardSlot': slot,
                'samPrevBalance': __data[2].lstrip('0'),
                'samLastBalance': __samLastBalance,
                'topupCardNo': __data[6],
                'topupPrevBalance': __data[7].lstrip('0'),
                'topupLastBalance': __data[8].lstrip('0'),
                'status': __status,
                'remarks': __remarks,
            }
            _Global.store_upload_sam_audit(param)
            _Global.TRIGGER_MANUAL_TOPUP = True
        else:
            # i = 0
            # while True:
            #     i += 1
            #     _response, _result = _Command.get_response_with_handle(out=_Command.MO_REPORT)
            #     LOGGER.debug(("check_balance : ", 'force', str(_result)))
            #     __remarks = ''
            #     if _response == 0 and '|' in _result:
            #         _result = _result.replace('#', '')
            #         __data = _result.split('|')
            #         __status = __data[0]
            #         if __status == '0000':
            #             __remarks = __data[5]
            #         if __status in ERROR_TOPUP.keys():
            #             __remarks = ERROR_TOPUP[__status]
            #         __samLastBalance = __data[3].lstrip('0')
            #         __report_sam = __data[5]
            #         if __status == 'FFFE' and __data[2].lstrip('0') == __data[3].lstrip('0'):
            #             # __samLastBalance = str(int(__data[2].lstrip('0')) - int(amount))
            #             __report_sam = 'CARD_NOT_EXIST'
            #         output = {
            #             'last_balance': __data[8].lstrip('0'),
            #             'report_sam': __report_sam,
            #             'card_no': __data[6],
            #             'report_ka': 'N/A',
            #             'bank_id': '2',
            #             'bank_name': 'BNI',
            #         }
            #         update_bni_wallet(slot, amount, __samLastBalance)
            #         QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit(__status + '|' + json.dumps(output))
            #         LOGGER.info(('top_up_bni', str(output)))
            #         param = {
            #             'trxid': trxid,
            #             'samCardNo': __data[1],
            #             'samCardSlot': slot,
            #             'samPrevBalance': __data[2].lstrip('0'),
            #             'samLastBalance': __samLastBalance,
            #             'topupCardNo': __data[6],
            #             'topupPrevBalance': __data[7].lstrip('0'),
            #             'topupLastBalance': __data[8].lstrip('0'),
            #             'status': __status,
            #             'remarks': __remarks,
            #         }
            #         _Global.store_upload_sam_audit(param)
            #         _Global.TRIGGER_MANUAL_TOPUP = True
            #         break
            #     if i == 10:
            #         # _Global.NFC_ERROR = 'CHECK_BALANCE_ERROR'
            #         QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ERROR')
            #         break
            #     sleep(1)
            # LOGGER.warning(('top_up_bni', 'UPDATE_BNI', _result))
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ERROR')
            # _Global.NFC_ERROR = 'INIT_TOPUP_BNI_ERROR'
    else:
        LOGGER.warning(('top_up_bni', 'INIT_BNI', result))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ERROR')
        _Global.NFC_ERROR = 'TOPUP_BNI_ERROR'


def start_ka_info():
    _Tools.get_pool().apply_async(ka_info_mandiri)

'''
OUTPUT = Limit TopUp, Main Counter, History Counter
'''
MANDIRI_TOPUP_AMOUNT = 0


def ka_info_mandiri(slot=None):
    global MANDIRI_TOPUP_AMOUNT
    if len(INIT_LIST) == 0:
        LOGGER.warning(('ka_info_mandiri', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    if slot is None:
        slot = str(_Global.MANDIRI_ACTIVE)
    param = QPROX['KA_INFO'] + '|'
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    LOGGER.debug(("ka_info_mandiri", slot, result))
    if response == 0 and result is not None:
        MANDIRI_TOPUP_AMOUNT = int(result.split('|')[0])
        _Global.MANDIRI_ACTIVE_WALLET = MANDIRI_TOPUP_AMOUNT
        if slot == '1':
            _Global.MANDIRI_WALLET_1 = MANDIRI_TOPUP_AMOUNT
            _Global.MANDIRI_ACTIVE = 1
        if slot == '2':
            _Global.MANDIRI_WALLET_2 = MANDIRI_TOPUP_AMOUNT
            _Global.MANDIRI_ACTIVE = 2
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|' + str(result))
    else:
        _Global.NFC_ERROR = 'KA_INFO_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')


BNI_TOPUP_AMOUNT = 0


def ka_info_bni(slot=1):
    global BNI_TOPUP_AMOUNT
    # if len(INIT_LIST) == 0 and init_check is True:
    #     LOGGER.warning(('ka_info_mandiri', 'INIT_LIST', str(INIT_LIST)))
    #     QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')
    #     _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
    #     return
    # Slot defined as sequence
    _slot = slot - 1
    param = QPROX['KA_INFO_BNI'] + '|' + str(_slot)
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug(("ka_info_bni", str(slot), result))
    if response == 0 and (result is not None and result != ''):
        # BNI_TOPUP_AMOUNT = int(result.split('|')[0])
        if slot == 1:
            _Global.BNI_SAM_1_WALLET = int(result.split('|')[0])
            _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_1_WALLET
        if slot == 2:
            _Global.BNI_SAM_2_WALLET = int(result.split('|')[0])
            _Global.BNI_ACTIVE_WALLET = _Global.BNI_SAM_2_WALLET
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|' + str(result))
    else:
        _Global.NFC_ERROR = 'KA_INFO_BNI_ERROR'
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')


# def start_master_activation_bni():
#     slot = 1
#     _Tools.get_pool().apply_async(refill_zero_bni, (slot,))
#
#
# def start_slave_activation_bni():
#     slot = 2
#     _Tools.get_pool().apply_async(refill_zero_bni, (slot,))
#
#
# def refill_zero_bni(slot=1):
#     _slot = slot - 1
#     param = QPROX['REFILL_ZERO'] + '|' + str(_slot) + '|' + TID_BNI
#     response, result = _Command.send_request(param=param, output=None)
#     if response == 0:
#         _Global.NFC_ERROR = ''
#         QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO|SUCCESS')
#     else:
#         if slot == 1:
#             _Global.NFC_ERROR = 'REFILL_ZERO_SLOT_1_BNI_ERROR'
#         if slot == 2:
#             _Global.NFC_ERROR = 'REFILL_ZERO_SLOT_2_BNI_ERROR'
#         QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO_ERROR')


def start_create_online_info():
    _Tools.get_pool().apply_async(create_online_info)

'''
OUTPUT = 0001000120010277010108201713140108201713142094.RQ1
'''

ONLINE_INFO_RESULT = None


def create_online_info():
    global ONLINE_INFO_RESULT
    if len(INIT_LIST) == 0:
        LOGGER.warning(('create_online_info', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    param = QPROX['CREATE_ONLINE_INFO'] + '|'
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    LOGGER.debug(("create_online_info : ", result))
    if response == 0 and result is not None:
        ONLINE_INFO_RESULT = str(result)
        QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|' + str(result))
    else:
        _Global.NFC_ERROR = 'CREATE_ONLINE_INFO_ERROR'
        QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|ERROR')


def start_init_online():
    _Tools.get_pool().apply_async(init_online)


def init_online():
    if len(INIT_LIST) == 0:
        LOGGER.warning(('init_online', 'INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|ERROR')
        _Global.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    param = QPROX['INIT_ONLINE'] + '|' + ONLINE_INFO_RESULT.replace('.RQ1', '.RSP')
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    LOGGER.debug(("init_online : ", result))
    # TODO check result
    if response == 0 and result is not None:
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|' + str(result))
    else:
        _Global.NFC_ERROR = 'INIT_ONLINE_ERROR'
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|ERROR')


def start_get_topup_readiness():
    global SIGNAL_TOPUP_READINESS
    SIGNAL_TOPUP_READINESS = True
    _Tools.get_pool().apply_async(get_topup_readiness)


SIGNAL_TOPUP_READINESS = True


def start_get_topup_status_instant():
    mode = 'get_instant'
    _Tools.get_pool().apply_async(get_topup_readiness, (mode,))


def get_topup_readiness(mode='full'):
    global SIGNAL_TOPUP_READINESS
    topup_readiness = dict()
    if TEST_MODE is True:
        mode = 'TEST_MODE'
        topup_readiness['mandiri'] = 'AVAILABLE'
        topup_readiness['bni'] = 'AVAILABLE'
        topup_readiness['balance_mandiri'] = str(10000000)
        topup_readiness['balance_bni'] = str(8000000)
    else:
        if mode == 'full' or mode == 'get_instant':
            topup_readiness['mandiri'] = 'AVAILABLE' if INIT_TOPUP_MANDIRI is True else 'N/A'
            topup_readiness['bni'] = 'AVAILABLE' if INIT_TOPUP_BNI is True else 'N/A'
            topup_readiness['balance_mandiri'] = str(_Global.MANDIRI_ACTIVE_WALLET)
            topup_readiness['balance_bni'] = str(_Global.BNI_ACTIVE_WALLET)
            topup_readiness['bni_wallet_1'] = str(_Global.BNI_SAM_1_WALLET)
            topup_readiness['bni_wallet_2'] = str(_Global.BNI_SAM_2_WALLET)
    if SIGNAL_TOPUP_READINESS is True:
        LOGGER.info((str(topup_readiness), str(mode)))
        QP_SIGNDLER.SIGNAL_GET_TOPUP_READINESS.emit(json.dumps(topup_readiness))
        SIGNAL_TOPUP_READINESS = False
