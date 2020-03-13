__author__ = 'fitrah.wahyudi.imam@gmail.com'


from _cConfig import _ConfigParser, _Common
from _cCommand import _Command
from PyQt5.QtCore import QObject, pyqtSignal
import logging
from _tTools import _Helper
from time import sleep
import json
from _nNetwork import _NetworkAccess

LOGGER = logging.getLogger()
QPROX_PORT = _Common.QPROX_PORT
MID_MAN = _Common.MID_MAN
TID_MAN = _Common.TID_MAN
SAM_MAN = _Common.SAM_MAN
MID_BNI = _Common.MID_BNI
TID_BNI = _Common.TID_BNI
MC_BNI = _Common.MC_BNI
SAM1_BNI = _Common.SAM1_BNI
SAM2_BNI = _Common.SAM2_BNI
MID_BRI = _Common.MID_BRI
TID_BRI = _Common.TID_BRI
PROCODE_BRI = _Common.PROCODE_BRI
MID_BCA = _Common.MID_BCA
TID_BCA = _Common.TID_BCA

BANKS = _Common.BANKS
# print(BANKS)

BNI_SAM_SLOT = {
    '1': SAM1_BNI,
    '2': SAM2_BNI
}


QPROX = {
    "OPEN": "000",
    "INIT": "001",
    "AUTH": "002",
    "BALANCE": "003", #With Detail Card Attribute
    "TOPUP": "004", #Transfer Balance Offline MANDIRI
    "KA_INFO": "005",
    "CREATE_ONLINE_INFO": "006",
    "INIT_ONLINE": "007",
    "DEBIT": "008",
    "GENERAL_BALANCE": "009",
    "STOP": "010",
    "UPDATE_TID_BNI": "011",
    "INIT_BNI": "012",
    "TOPUP_BNI": "013", #Transfer Balance Offline BNI
    "KA_INFO_BNI": "014",
    "PURSE_DATA_BNI": "015", #Get Card Info For Topup Modal
    "SEND_CRYPTO": "016", #Send Cryptogram For Topup Modal
    "REFILL_ZERO": "018", #Refill Zero To Fix Error Update Balance Failure
    "UPDATE_BALANCE_ONLINE": "019", #Update Balance Online Mandiri
    "PURSE_DATA_BNI_CONTACTLESS": "020", #Get Card Info BNI Tapcash contactless,
    "SEND_CRYPTO_CONTACTLESS": "021", #Send Cryptogram For BNI Tapcash contactless,
}

# 020 GetPurseData (ambil pursedata dari kartu), tidak ada parameter
# 021 UpdateCardCryptogram (update cryptogram ke kartu), parameter pursedata & cryptogram


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
    SIGNAL_UPDATE_BALANCE_ONLINE = pyqtSignal(str)


QP_SIGNDLER = QSignalHandler()
OPEN_STATUS = False
TEST_MODE = _Common.TEST_MODE

# BNI ERROR CARD
ERROR_TOPUP = {
    '5106': 'ERROR_BNI_NOT_PRODUCTION',
    '5103': 'ERROR_BNI_PURSE_DISABLED',
    '1008': 'ERROR_INACTIVECARD',
    'FFFE': 'CARD_NOT_EXIST',
    '1004': 'PROCESS_TIMEOUT',
    'FFFD': 'PROCESS_NOT_FINISHED',
    '6969': 'CARD_NOT_MATCH'
}

def send_cryptogram(card_info, cyptogram, slot=1, bank='BNI'):
    if bank == 'BNI':
        #Getting Previous samBalance
        samPrevBalance = _Common.BNI_SAM_1_WALLET if slot == 1 else _Common.BNI_SAM_2_WALLET
        # Converting Default Slot into Actual Slot
        alias_slot = BNI_SAM_SLOT[str(slot)]
        if len(card_info) == 0 or card_info is None:
            LOGGER.warning((str(card_info), 'WRONG_VALUE'))
            return False
        if len(cyptogram) == 0 or cyptogram is None:
            LOGGER.warning((str(cyptogram), 'WRONG_VALUE'))
            return False
        param = QPROX['SEND_CRYPTO'] + '|' + str(alias_slot) + '|' + str(card_info) + '|' + str(cyptogram)
        response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
        LOGGER.debug((result))
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
            LOGGER.info((str(slot), bank, str(output)))
            samCardNo = _Common.BNI_SAM_1_NO if slot == 1 else _Common.BNI_SAM_2_NO
            samLastBalance = _Common.BNI_SAM_1_WALLET if slot == 1 else _Common.BNI_SAM_2_WALLET
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
            _Common.store_upload_sam_audit(param)
            sleep(3)
            #Upload To Server
            _Common.upload_bni_wallet()
            _Common.TRIGGER_MANUAL_TOPUP = True
            return output
        else:
            _Common.NFC_ERROR = 'SEND_CRYPTO_BNI_ERROR_SLOT_'+str(slot)
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
        LOGGER.debug((result))
        if response == 0 and len(result) > 10:
            result = result.replace('#', '')
            output = {
                'card_info': result,
                'card_no': result[4:20],
                'bank_tid': _Common.TID_BNI,
                'bank_id': '2',
                'bank_name': bank,
            }
            # ka_info_bni(slot=slot)
            if slot == 1:
                _Common.BNI_SAM_1_NO = BNI_CARD_NO_SLOT_1 = output['card_no'] 
            if slot == 2:
                _Common.BNI_SAM_2_NO = BNI_CARD_NO_SLOT_2 = output['card_no']
            LOGGER.debug(('set_bni_sam_no', str(slot), output['card_no']))
            _Common.set_bni_sam_no(str(slot), output['card_no'])
            LOGGER.info((str(slot), bank, str(output)))
            return output
        else:
            _Common.NFC_ERROR = 'CHECK_CARD_INFO_BNI_ERROR_SLOT_'+str(slot)
            return False
    else:
        return False


def open_qprox():
    global OPEN_STATUS
    if QPROX_PORT is None:
        LOGGER.debug(("port : ", QPROX_PORT))
        _Common.NFC_ERROR = 'PORT_NOT_DEFINED'
        return False
    param = QPROX["OPEN"] + "|" + QPROX_PORT
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((param, result))
    OPEN_STATUS = True if response == 0 else False
    return OPEN_STATUS


def start_disconnect_qprox():
    _Helper.get_pool().apply_async(disconnect_qprox)


def disconnect_qprox():
    param = QPROX['STOP'] + '|'
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((response, result))


INIT_STATUS = False
INIT_MANDIRI = False
INIT_BNI = False
INIT_LIST = []


def start_init_qprox():
    _Helper.get_pool().apply_async(init_qprox)


def init_qprox():
    global INIT_STATUS, INIT_LIST, INIT_BNI, INIT_MANDIRI
    if OPEN_STATUS is not True:
        LOGGER.warning(('OPEN STATUS', str(OPEN_STATUS)))
        _Common.NFC_ERROR = 'PORT_NOT_OPENED'
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
                        INIT_MANDIRI = False
                        if _Common.active_auth_session():
                            INIT_MANDIRI = True
                        # Positive Assumption Last Update Bringing KA LOGIN Session
                        if _Common.last_update_attempt():
                            INIT_MANDIRI = True
                            _Common.log_to_temp_config('last^auth')
                        if _Common.MANDIRI_SINGLE_SAM:
                            # _Common.MANDIRI_ACTIVE = 1
                            # _Common.save_sam_config(bank='MANDIRI')
                            ka_info_mandiri(str(_Common.MANDIRI_ACTIVE), caller='FIRST_INIT_SINGLE_SAM')
                        else:
                            ka_info_mandiri(str(_Common.get_active_sam(bank='MANDIRI', reverse=True)), caller='FIRST_INIT')
                    else:
                        LOGGER.warning((BANK['BANK'], result))
                if BANK['BANK'] == 'BNI':
                    param = QPROX['UPDATE_TID_BNI'] + '|' + TID_BNI
                    response, result = _Command.send_request(param=param, output=None)
                    if response == 0:
                        LOGGER.info((BANK['BANK'], result))
                        INIT_LIST.append(BANK)
                        INIT_STATUS = True
                        INIT_BNI = True
                        ka_info_bni(slot=_Common.BNI_ACTIVE)
                        sleep(1.5)
                        get_card_info(slot=_Common.BNI_ACTIVE, bank='BNI')    
                        # get_bni_wallet_status()
                    else:
                        LOGGER.warning((BANK['BANK'], result))
            sleep(1)
            continue
    except Exception as e:
        _Common.NFC_ERROR = 'FAILED_TO_INIT'
        LOGGER.warning((e))


def start_debit_qprox(amount):
    _Helper.get_pool().apply_async(debit_qprox, (amount,))


def debit_qprox(amount):
    if len(INIT_LIST) == 0:
        LOGGER.warning(('INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + 'ERROR')
        _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    param = QPROX['DEBIT'] + '|' + str(amount)
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug((result))
    # TODO check result
    if response == 0 and result is not None:
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + str(result))
    else:
        _Common.NFC_ERROR = 'DEBIT_ERROR'
        QP_SIGNDLER.SIGNAL_DEBIT_QPROX.emit('DEBIT|' + 'ERROR')


def start_auth_ka():
    print('pyt: Waiting Login Card To Be Put Into Reader...')
    _Helper.get_pool().apply_async(auth_ka)


'''
Port, Slot, PIN SAM, Institution, Terminal, PIN KA, PIN KL,
COM1, 01, 0123456789abcdef, 00010002, 20010203, 20010203
'''


def auth_ka(_slot=None, initial=True):
    global INIT_MANDIRI
    if len(INIT_LIST) == 0:
        LOGGER.warning(('INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|ERROR')
        _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    __single_sam = _Common.mandiri_single_sam()
    if __single_sam is True:
        _Common.MANDIRI_ACTIVE = 1
        _Common.save_sam_config(bank='MANDIRI')
    if _slot is None:
        if __single_sam:
            _slot = str(_Common.MANDIRI_ACTIVE)
        else:
            _slot = str(_Common.get_active_sam(bank='MANDIRI', reverse=True))
    _ka_pin = _Common.KA_PIN1
    if _slot == '2':
        _ka_pin = _Common.KA_PIN2
    param = QPROX['AUTH'] + '|' + QPROX_PORT + '|' + _slot + '|' + BANKS[0]['SAM'] + '|' + BANKS[0]['MID'] + '|' + \
            BANKS[0]['TID'] + '|' + _ka_pin + '|' + _Common.KL_PIN
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((_slot, result))
    if response == 0 and _Common.KA_NIK == result:
        # Log Auth Time
        _Common.log_to_temp_config()
        INIT_MANDIRI = True
        ka_info_mandiri(slot=_slot, caller='KA_AUTH')
        if initial is False or __single_sam is True:
            QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|SUCCESS')
        else:
            __slot = str(_Common.get_active_sam(bank='MANDIRI', reverse=True))
            __ka_pin = _Common.KA_PIN1
            if __slot == '2':
                __ka_pin = _Common.KA_PIN2
            __ka_pin = _Common.KA_PIN2
            __param = QPROX['AUTH'] + '|' + QPROX_PORT + '|' + __slot + '|' + BANKS[0]['SAM'] + '|' + BANKS[0]['MID'] \
                      + '|' + BANKS[0]['TID'] + '|' + __ka_pin + '|' + _Common.KL_PIN
            __response, __result = _Command.send_request(param=__param, output=None)
            LOGGER.debug((__slot, __result))
            if __response == 0:
                ka_info_mandiri(slot=__slot, caller='KA_AUTH_#2')
                QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|SUCCESS')
            else:
                _Common.NFC_ERROR = 'AUTH_KA_MANDIRI_ERROR'
                QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|'+str(__result))
    else:
        _Common.NFC_ERROR = 'AUTH_KA_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_AUTH_QPROX.emit('AUTH_KA|'+str(result))


def start_check_balance():
    _Helper.get_pool().apply_async(check_balance)


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
    param = QPROX['BALANCE'] + '|'
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug((param, result))
    if response == 0:
        bank_name = get_fw_bank(result.split('|')[2])
        card_no = result.split('|')[1].replace('#', '')
        balance = result.split('|')[0]
        output = {
            'balance': balance,
            'card_no': card_no,
            'bank_type': result.split('|')[2].replace('#', ''),
            'bank_name': bank_name,
            # 'able_topup': result.split('|')[3].replace('#', ''),
            'able_topup': '0000', #Force Allowed Topup For All Non BNI
        }
        # Special Handling For BNI Tapcash
        if bank_name == 'BNI':
            output['able_topup'] = result.split('|')[3].replace('#', '')
            # Drop Balance Check If Not Available For Topup
            if output['able_topup'] in ERROR_TOPUP.keys():
                QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|ERROR')
                return
        elif bank_name == 'DKI':
            prev_last_balance = _ConfigParser.get_value('TEMPORARY', card_no)
            if not _Common.empty(prev_last_balance):
                output['balance'] = prev_last_balance
            else:
                _Common.log_to_temp_config(card_no, balance)
        LAST_BALANCE_CHECK = output
        _Common.NFC_ERROR = ''
        QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|' + json.dumps(output))
    else:
        QP_SIGNDLER.SIGNAL_BALANCE_QPROX.emit('BALANCE|ERROR')


def start_top_up_mandiri(amount, trxid):
    _Helper.get_pool().apply_async(top_up_mandiri, (amount, trxid,))

'''
OUTPUT = Balance, Report SAM, Report KA, Card Number
'''


def top_up_mandiri(amount, trxid='', slot=None):
    global INIT_MANDIRI
    if len(INIT_LIST) == 0:
        LOGGER.warning(('INIT_LIST', str(INIT_LIST)))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP|ERROR')
        _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
        return
    if slot is None:
        slot = str(_Common.MANDIRI_ACTIVE)
    param = QPROX['TOPUP'] + '|' + str(amount)
    _response, _result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    if _response == 0 and '|' in _result:
        __data = _result.split('|')
        __status = __data[0]
        __remarks = ''
        if __status == '0000':
            __remarks = __data[5]
        if __status == '6969':
            LOGGER.warning(('TOPUP_FAILED_CARD_NOT_MATCH', LAST_BALANCE_CHECK))
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_FAILED_CARD_NOT_MATCH')
            return
        if __status == '6984':
            LOGGER.warning(('MANDIRI_SAM_BALANCE_EXPIRED', _result))
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('MANDIRI_SAM_BALANCE_EXPIRED')
            # INIT_MANDIRI = False
            _Common.MANDIRI_ACTIVE_WALLET = 0
            return
        if __status in ['6982', '1001']:
            LOGGER.warning(('TOPUP_FAILED_KA_NOT_LOGIN', _result))
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_FAILED_KA_NOT_LOGIN')
            INIT_MANDIRI = False
            _Common.MANDIRI_ACTIVE_WALLET = 0
            return
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
            'report_sam': __report_sam.split('#')[0],
            'card_no': __data[6],
            'report_ka': __report_sam.split('#')[1],
            'bank_id': '1',
            'bank_name': 'MANDIRI',
        }
        # Update Local Mandiri Wallet
        if slot == '1':
            _Common.MANDIRI_WALLET_1 = _Common.MANDIRI_WALLET_1 - int(amount)
            _Common.MANDIRI_ACTIVE_WALLET = _Common.MANDIRI_WALLET_1
        if slot == '2':
            _Common.MANDIRI_WALLET_2 = _Common.MANDIRI_WALLET_2 - int(amount)
            _Common.MANDIRI_ACTIVE_WALLET = _Common.MANDIRI_WALLET_2
        LOGGER.info((slot, __status, str(output), _result))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit(__status+'|'+json.dumps(output))
        __card_uid = __report_sam.split('#')[0][:14]
        param = {
            'trxid': trxid,
            'samCardNo': __card_uid,
            'samCardSlot': slot,
            'samPrevBalance': __data[2].lstrip('0'),
            'samLastBalance': __samLastBalance,
            'topupCardNo': __data[6],
            'topupPrevBalance': __data[7].lstrip('0'),
            'topupLastBalance': __data[8].lstrip('0'),
            'status': __status,
            'remarks': __remarks,
        }
        _Common.set_mandiri_uid(slot, __card_uid)
        _Common.store_upload_sam_audit(param)
        # Update to server
        _Common.upload_mandiri_wallet()
    else:
        LOGGER.warning((slot, _result))
        _Common.NFC_ERROR = 'TOPUP_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP|ERROR')


def start_top_up_bni(amount, trxid):
    # get_bni_wallet_status()
    _Helper.get_pool().apply_async(top_up_bni, (amount, trxid,))

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
            if attempt == 3 or _Common.BNI_SAM_1_WALLET != 0:
                break
            sleep(1)
        # Second Attempt For SLOT 2
        _attempt = 0
        while True:
            _attempt += 1
            get_card_info(slot=2)
            sleep(1)
            ka_info_bni(slot=2)
            if _attempt == 3 or _Common.BNI_SAM_1_WALLET != 0:
                break
            sleep(1)
        if _Common.BNI_ACTIVE == 1:
            _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_1_WALLET
            # BNI_TOPUP_AMOUNT = _Common.BNI_SAM_1_WALLET
            LOGGER.info((str(_Common.BNI_ACTIVE), str(_Common.BNI_SAM_1_WALLET)))
        if _Common.BNI_ACTIVE == 2:
            _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_2_WALLET
            # BNI_TOPUP_AMOUNT = _Common.BNI_SAM_2_WALLET
            LOGGER.info((str(_Common.BNI_ACTIVE), str(_Common.BNI_SAM_2_WALLET)))
        if upload is True:
            # Do Upload To Server
            _Common.upload_bni_wallet()
    except Exception as e:
        LOGGER.warning((str(e)))


def update_bni_wallet(slot, amount, last_balance=None):
    if slot == 1:
        if last_balance is None:
            _Common.BNI_SAM_1_WALLET = _Common.BNI_SAM_1_WALLET - int(amount)
        else:
            _Common.BNI_SAM_1_WALLET = int(last_balance)
        _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_1_WALLET
    if slot == 2:
        if last_balance is None:
            _Common.BNI_SAM_2_WALLET = _Common.BNI_SAM_2_WALLET - int(amount)
        else:
            _Common.BNI_SAM_2_WALLET = int(last_balance)
        _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_2_WALLET
    _Common.upload_bni_wallet()


def start_fake_update_dki(card_no, amount):
    bank = 'DKI'
    _Helper.get_pool().apply_async(fake_update_balance, (bank, card_no, amount,))


def fake_update_balance(bank, card_no, amount):
    if bank == 'DKI':
        sleep(2)
        prev_balance = _ConfigParser.get_value('TEMPORARY', card_no)
        last_balance = int(prev_balance) + int(amount)
        output = {
            'last_balance': str(last_balance),
            'report_sam': 'DUMMY-'+card_no+'-'+amount+'-'+str(_Helper.now()),
            'card_no': card_no,
            'report_ka': 'N/A',
            'bank_id': '4',
            'bank_name': 'DKI',
            }
        _Common.log_to_temp_config(card_no, last_balance)
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('0000|'+json.dumps(output))
    else:
        return


def start_topup_up_bni_with_attempt(amount, trxid, attempt):
    slot = None
    _Helper.get_pool().apply_async(top_up_bni, (amount, trxid, slot, attempt,))


def top_up_bni(amount, trxid, slot=None, attempt=None):
    _slot = 1
    if slot is None:
        slot = _Common.BNI_ACTIVE
        _slot = _Common.BNI_ACTIVE - 1
    if attempt == '5':
        LOGGER.debug(('TOPUP_ATTEMPT_REACHED', str(int(attempt) - 1)))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ATTEMPT_REACHED')
        return
    param = QPROX['INIT_BNI'] + '|' + str(_slot) + '|' + TID_BNI
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug((attempt, amount, trxid, slot, result))
    # print('pyt: top_up_bni > init_bni : ', result)
    if response == 0 and '12292' not in result:
        # Update : Add slot after value
        _param = QPROX['TOPUP_BNI'] + '|' + str(amount) + '|' + str(_slot)
        _response, _result = _Command.send_request(param=_param, output=_Command.MO_REPORT, wait_for=2)
        LOGGER.debug((attempt, amount, trxid, slot, _result))
        # print('pyt: top_up_bni > init_bni > update_bni : ', _result)
        __remarks = ''
        if _response == 0 and '|' in _result:
            _result = _result.replace('#', '')
            __data = _result.split('|')
            __status = __data[0]
            if __status == '0000':
                __remarks = __data[5]
            if __status == '6984':
                LOGGER.warning(('BNI_SAM_BALANCE_NOT_SUFFICIENT', slot, _result))
                QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('BNI_SAM_BALANCE_NOT_SUFFICIENT|'+str(slot))
                return
            if __status == '6969':
                LOGGER.warning(('TOPUP_FAILED_CARD_NOT_MATCH', LAST_BALANCE_CHECK))
                QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_FAILED_CARD_NOT_MATCH')
                return
            if __status in ERROR_TOPUP.keys():
                __remarks = ERROR_TOPUP[__status]
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
            # Add Timeout Response
            if __status == '1004' or __status == '5103' or __status == 'FFFE':
                LOGGER.debug(('TOPUP_TIMEOUT', attempt, __status, _result))
                QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_TIMEOUT')
            else:
                LOGGER.info((str(output)))
                QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit(__status+'|'+json.dumps(output))
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
            _Common.store_upload_sam_audit(param)
        else:
            QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ERROR')
    else:
        LOGGER.warning(('INIT_BNI', result))
        QP_SIGNDLER.SIGNAL_TOPUP_QPROX.emit('TOPUP_ERROR')
        _Common.NFC_ERROR = 'TOPUP_BNI_ERROR'


def start_ka_info():
    _Helper.get_pool().apply_async(ka_info_mandiri)

'''
OUTPUT = Limit TopUp, Main Counter, History Counter
'''
MANDIRI_TOPUP_AMOUNT = 0


def ka_info_mandiri(slot=None, caller=''):
    global MANDIRI_TOPUP_AMOUNT
    # if len(INIT_LIST) == 0:
    #     LOGGER.warning(('ka_info_mandiri', 'INIT_LIST', str(INIT_LIST)))
    #     QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')
    #     _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
    #     return
    if slot is None:
        slot = str(_Common.MANDIRI_ACTIVE)
    param = QPROX['KA_INFO'] + '|' + slot + '|'
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
    LOGGER.debug((caller, slot, result))
    if response == 0 and result is not None:
        MANDIRI_TOPUP_AMOUNT = int(result.split('|')[0])
        _Common.MANDIRI_ACTIVE_WALLET = MANDIRI_TOPUP_AMOUNT
        if slot == '1':
            _Common.MANDIRI_WALLET_1 = MANDIRI_TOPUP_AMOUNT
            _Common.MANDIRI_ACTIVE = 1
        elif slot == '2':
            _Common.MANDIRI_WALLET_2 = MANDIRI_TOPUP_AMOUNT
            _Common.MANDIRI_ACTIVE = 2
        _Common.save_sam_config(bank='MANDIRI')
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|' + str(result))
    else:
        _Common.NFC_ERROR = 'KA_INFO_MANDIRI_ERROR'
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')


BNI_TOPUP_AMOUNT = 0


def ka_info_bni(slot=1):
    global BNI_TOPUP_AMOUNT
    # if len(INIT_LIST) == 0 and init_check is True:
    #     LOGGER.warning(('ka_info_mandiri', 'INIT_LIST', str(INIT_LIST)))
    #     QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|ERROR')
    #     _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
    #     return
    # Slot defined as sequence
    _slot = slot - 1
    param = QPROX['KA_INFO_BNI'] + '|' + str(_slot)
    response, result = _Command.send_request(param=param, output=_Command.MO_REPORT, wait_for=1.5)
    LOGGER.debug((str(slot), result))
    if response == 0 and (result is not None and result != ''):
        # BNI_TOPUP_AMOUNT = int(result.split('|')[0])
        if slot == 1:
            _Common.BNI_SAM_1_WALLET = int(result.split('|')[0])
            _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_1_WALLET
        if slot == 2:
            _Common.BNI_SAM_2_WALLET = int(result.split('|')[0])
            _Common.BNI_ACTIVE_WALLET = _Common.BNI_SAM_2_WALLET
        QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.emit('KA_INFO|' + str(result))
    else:
        _Common.NFC_ERROR = 'KA_INFO_BNI_ERROR'
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
#         _Common.NFC_ERROR = ''
#         QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO|SUCCESS')
#     else:
#         if slot == 1:
#             _Common.NFC_ERROR = 'REFILL_ZERO_SLOT_1_BNI_ERROR'
#         if slot == 2:
#             _Common.NFC_ERROR = 'REFILL_ZERO_SLOT_2_BNI_ERROR'
#         QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO_ERROR')


def start_create_online_info():
    _Helper.get_pool().apply_async(create_online_info)

'''
OUTPUT = 0001000120010277010108201713140108201713142094.RQ1
'''

PREV_RQ1_DATA = None
PREV_RQ1_SLOT = None


def create_online_info(slot=None):
    global PREV_RQ1_DATA, PREV_RQ1_SLOT
    # if len(INIT_LIST) == 0:
    #     LOGGER.warning(('create_online_info', 'INIT_LIST', str(INIT_LIST)))
    #     QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|ERROR')
    #     _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
    #     return
    if slot is None:
        slot = str(_Common.MANDIRI_ACTIVE)
    param = QPROX['CREATE_ONLINE_INFO'] + '|' + slot + '|'
    if _Common.MANDIRI_ACTIVE_WALLET > 0:
        _Common.MANDIRI_ACTIVE_WALLET = 0  
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((slot, result))
    if response == 0 and len(result) > 3:
        PREV_RQ1_DATA = str(result)
        PREV_RQ1_SLOT = str(_Common.MANDIRI_ACTIVE)
        # Also Re-write last^auth (MANDIRI_KA_LOGIN state in temp config)
        _Common.log_to_temp_config(section='last^auth')
        # QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|' + str(result))
        return PREV_RQ1_DATA
    else:
        _Common.NFC_ERROR = 'CREATE_ONLINE_INFO_ERROR'
        # QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.emit('CREATE_ONLINE_INFO|ERROR')
        return False


def start_init_online():
    _Helper.get_pool().apply_async(init_online)


def init_online(rsp=None, slot=None):
    # if len(INIT_LIST) == 0:
    #     LOGGER.warning(('init_online', 'INIT_LIST', str(INIT_LIST)))
    #     QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|ERROR')
    #     _Common.NFC_ERROR = 'EMPTY_INIT_LIST'
    #     return
    if rsp is None:
        LOGGER.warning(("[FAILED]", rsp, slot))
        return
    param = QPROX['INIT_ONLINE'] + '|' + slot + '|' + rsp + '|'
    response, result = _Command.send_request(param=param, output=None)
    LOGGER.debug((rsp, slot, result, response))
    if response == 0 and result is not None:
        ka_info_mandiri(slot=slot, caller='UPDATE_SALDO_KA')
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|SUCCESS')
        _Common.log_to_temp_config(section='last^update')
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('MANDIRI_SETTLEMENT|SUCCESS')
        return True
    else:
        _Common.NFC_ERROR = 'INIT_ONLINE_ERROR'
        QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.emit('INIT_ONLINE|ERROR')
        return False


def do_update_limit_mandiri(rsp):
    attempt = 0
    _url = 'http://'+_Common.SFTP_MANDIRI['host']+'/bridge-service/filecheck.php?content=1&no_correction=1'
    _param = {
        'ext': '.RSP',
        'file_path': _Common.SFTP_MANDIRI['path']+'/UpdateRequestDownload_DEV/'+rsp
    }
    if '_DEV' in _param['file_path']:
        if _Common.LIVE_MODE is True or _Common.TEST_MODE is True:
            _param['file_path'] = _param['file_path'].replace('_DEV', '')
    while True:
        attempt += 1
        _stat, _res = _NetworkAccess.post_to_url(_url, _param)
        LOGGER.debug((attempt, rsp, _stat, _res))
        if _stat == 200 and _res['status'] == 0 and _res['file'] is True:
            __content_rq1 = _res['content'].split('#')[0]
            if PREV_RQ1_DATA == __content_rq1:
                __content_rsp = _res['content'].split('#')[1]
                init_online(__content_rsp, PREV_RQ1_SLOT)
                LOGGER.info(('RQ1 MATCH', PREV_RQ1_SLOT, PREV_RQ1_DATA, __content_rq1, __content_rsp))
                break
            else:
                LOGGER.warning(('[DETECTED] RQ1 NOT MATCH', PREV_RQ1_DATA, __content_rq1))
            if not _Common.mandiri_single_sam():
                # Switch To The Other Slot
                auth_ka(_slot=_Common.get_active_sam(bank='MANDIRI', reverse=True), initial=False)
            break
        sleep(15)


def start_get_topup_readiness():
    _Helper.get_pool().apply_async(get_topup_readiness)


def start_get_topup_status_instant():
    mode = 'get_instant'
    _Helper.get_pool().apply_async(get_topup_readiness, (mode,))


def get_topup_readiness(mode='full'):
    ___ = dict()
    ___['balance_mandiri'] = str(_Common.MANDIRI_ACTIVE_WALLET)
    ___['balance_bni'] = str(_Common.BNI_ACTIVE_WALLET)
    ___['bni_wallet_1'] = str(_Common.BNI_SAM_1_WALLET)
    ___['bni_wallet_2'] = str(_Common.BNI_SAM_2_WALLET)
    ___['mandiri'] = 'AVAILABLE' if (INIT_MANDIRI is True and _Common.MANDIRI_ACTIVE_WALLET > 0) is True else 'N/A'
    ___['bni'] = 'AVAILABLE' if (INIT_BNI is True and _Common.BNI_ACTIVE_WALLET > 0) is True else 'N/A'
    ___['bri'] = 'AVAILABLE' if _ConfigParser.get_set_value('QPROX', 'topup^online^bri', '0') == '1' else 'N/A'
    ___['bca'] = 'AVAILABLE' if _ConfigParser.get_set_value('QPROX', 'topup^online^bca', '0') == '1' else 'N/A'
    ___['dki'] = 'AVAILABLE' if _ConfigParser.get_set_value('QPROX', 'topup^online^dki', '0') == '1' else 'N/A'
    ___['emoney'] = _Common.TOPUP_AMOUNT_SETTING['emoney']
    ___['tapcash'] = _Common.TOPUP_AMOUNT_SETTING['tapcash']
    ___['brizzi'] = _Common.TOPUP_AMOUNT_SETTING['brizzi']
    ___['flazz'] = _Common.TOPUP_AMOUNT_SETTING['flazz']
    ___['jakcard'] = _Common.TOPUP_AMOUNT_SETTING['jakcard']
    LOGGER.info((str(___), str(mode)))
    QP_SIGNDLER.SIGNAL_GET_TOPUP_READINESS.emit(json.dumps(___))


def start_update_balance_online(bank):
    _Helper.get_pool().apply_async(update_balance_online, (bank,))


MANDIRI_GENERAL_ERROR = '51000'
MANDIRI_NO_PENDING = '51003'


def update_balance_online(bank):
    if bank is None or bank not in FW_BANK.values():
         QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|UNKNOWN_BANK')
         return
    if bank == 'MANDIRI':
        try:            
            param = QPROX['UPDATE_BALANCE_ONLINE'] + '|' + _Common.TID + '|' + _Common.QR_MID + '|' + _Common.QR_TOKEN
            response, result = _Command.send_request(param=param, output=None)
            # if _Common.TEST_MODE is True and _Common.empty(result):
            #   result = '6032111122223333|20000|198000'
            if response == 0 and result is not None:
                output = {
                    'bank': bank,
                    'card_no': result.split('|')[0],
                    'topup_amount': result.split('|')[1],
                    'last_balance': result.split('|')[2],
                }
                QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|SUCCESS|'+json.dumps(output))
            else:
                if MANDIRI_GENERAL_ERROR in result:
                    QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|GENERAL_ERROR')
                elif MANDIRI_NO_PENDING in result:
                    QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|NO_PENDING_BALANCE')
                else:
                    QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|ERROR')
            LOGGER.debug((result, response))
        except Exception as e:
            LOGGER.warning(str(e))
            QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|ERROR')
    if bank == 'BNI':
        try:
            if LAST_BALANCE_CHECK['able_topup'] in ERROR_TOPUP.keys():
                QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|INVALID_CARD')
                return
            # Do Action List :
            # - Get Purse Data Tapcash
            card_info = get_card_info_tapcash()
            if card_info is False:
                QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|ERROR')
                return
            # - Request Update Balance BNI
            crypto_data = request_update_balance_bni(card_info)
            if crypto_data is False:
                QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|GENERAL_ERROR')
                return
            if crypto_data == 'NO_PENDING_BALANCE':
                QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|NO_PENDING_BALANCE')
                return
            attempt = 0
            while True:
                attempt+=1
                send_crypto_tapcash = send_cryptogram_tapcash(crypto_data['dataToCard'], card_info)
                _Helper.dump(send_crypto_tapcash)
                if send_crypto_tapcash is True:
                # - Send Output as Mandiri Specification            
                    output = {
                        'bank': bank,
                        'card_no': card_info[4:20],
                        'topup_amount': str(crypto_data['amount']),
                        'last_balance': '0', #TODO: replace "last_balance"
                    }
                    QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|SUCCESS|'+json.dumps(output))
                    break
                if attempt >= 3:
                    QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|ERROR')
                    break
                sleep(1)
        except Exception as e:
            LOGGER.warning(str(e))
            QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.emit('UPDATE_BALANCE_ONLINE|ERROR')


def get_card_info_tapcash():
    # PURSE_DATA_BNI_CONTACTLESS
    # {"Result":"0","Command":"020","Parameter":"0","Response":"000175461700003074850000000001232195AEEADE4A080F4B00285DDCD9B4BA924B00000000010013B288889999040000962F210F4088889999040000962F210F4000000000000000000000ACD44750B49BC46B63D15DC8579D3280","ErrorDesc":"Sukses"}
    param = QPROX['PURSE_DATA_BNI_CONTACTLESS'] + '|'
    try:
        response, result = _Command.send_request(param=param, output=None)
        if response == 0 and result is not None:
            return result
        else:
            return False
    except Exception as e:
        LOGGER.warning(str(e))
        return False


def request_update_balance_bni(card_info):
    if card_info is None:
        return False
    try:
        param = {
            'token': _Common.TOPUP_TOKEN,
            'mid': _Common.TOPUP_MID,
            'tid': _Common.TID,
            'reff_no': _Helper.time_string(f='%Y%m%d%H%M%S'),
            'card_info': card_info,
            'card_no': card_info[4:20]
        }
        status, response = _NetworkAccess.post_to_url(url=_Common.TOPUP_URL + 'v1/topup-bni/update', param=param)
        LOGGER.debug((str(param), str(status), str(response)))
        if status == 200 and response['response']['code'] == 200:
            # {
                # "response":{
                #   "code":200,
                #   "message":"Update Balance Success",
                #   "latency":1.4313230514526
                # },
                # "data":{
                #   "amount":"30000",
                #   "auth_id":"164094",
                #   "dataToCard":"06015F902D04C57100000000000000001C54522709845B42F240343E96F11041"
                # }
            # }
            return response['data']
        elif response['response']['code'] == 400 and 'No Pending Balance' in response['response']['message']:
            return 'NO_PENDING_BALANCE'
        else:
            return False
    except Exception as e:
        LOGGER.warning(str(e))
        return False


def send_cryptogram_tapcash(cyptogram, card_info):
    if cyptogram is None or card_info is None:
        return False
    try:
        param = QPROX['SEND_CRYPTO_CONTACTLESS'] + '|' + str(card_info) + '|' + str(cyptogram)
        response, result = _Command.send_request(param=param, output=_Command.MO_REPORT)
        LOGGER.debug((str(response), str(result)))
        return True if response == 0 else False
    except Exception as e:
        LOGGER.warning(str(e))
        return False


