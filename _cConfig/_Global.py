__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
from _cConfig import _ConfigParser
from _tTools import _Tools
from _nNetwork import _NetworkAccess
from _dDAO import _DAO
from time import *
import os

LOGGER = logging.getLogger()
BACKEND_URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
QPROX_PORT = _ConfigParser.get_value('QPROX', 'port')
EDC_PORT = _ConfigParser.get_value('EDC', 'port')
MEI_PORT = _ConfigParser.get_value('MEI', 'port')
GRG_PORT = _ConfigParser.get_value('GRG', 'port')
CD_PORT1 = _ConfigParser.get_value('CD', 'port1')
CD_PORT2 = _ConfigParser.get_value('CD', 'port2')
CD_PORT3 = _ConfigParser.get_value('CD', 'port3')
PRINTER_PORT = _ConfigParser.get_value('PRINTER', 'port')
PRINTER_BAUDRATE = _ConfigParser.get_value('PRINTER', 'baudrate')
TEST_MODE = True if _ConfigParser.get_set_value('TERMINAL', 'test^usage', '0') == '1' else False
LIVE_MODE = True if _ConfigParser.get_set_value('TERMINAL', 'mode', 'live') == 'live' else False
RELOAD_SERVICE = True if _ConfigParser.get_set_value('TERMINAL', 'reload^service', '0') == '1' else False
TID = _ConfigParser.get_value('TERMINAL', 'tid')

# SERVICE_VERSION = open(os.path.join('C:\\', '_SOCKET_', 'SERVICE.VER'), 'r').readlines()[-1].replace('\n', '')
SERVICE_VERSION = 'N/A'


def get_service_version():
    global SERVICE_VERSION
    ___stat = -1
    ___resp = None
    try:
        # sleep(3)
        ___stat, ___resp = _NetworkAccess.get_local(SERVICE_URL + '999&param=0')
        if ___stat == 200:
            SERVICE_VERSION = ___resp['Response']
    except Exception as e:
        LOGGER.warning((___stat, ___resp, e))


BNI_TOPUP_AMOUNT = _ConfigParser.get_set_value('QPROX', 'amount^topup', '500000')
BNI_ACTIVE_WALLET = 0

CD_PORT_LIST = {
    '101': CD_PORT1,
    '102': CD_PORT2,
    '103': CD_PORT3,
}

BID = {
    'MANDIRI': '1',
    'BNI': '2',
    'BRI': '3',
    'BCA': '4'
}

# Harcoded Setting
ADJUST_AMOUNT_MINIMUM = 0
TRIGGER_MANUAL_TOPUP = True
ALLOW_DO_TOPUP = True

MID_MAN = _ConfigParser.get_value('QPROX', 'mid^man')
TID_MAN = _ConfigParser.get_value('QPROX', 'tid^man')
SAM_MAN = _ConfigParser.get_value('QPROX', 'sam^man')
MID_BNI = _ConfigParser.get_value('QPROX', 'mid^bni')
TID_BNI = _ConfigParser.get_value('QPROX', 'tid^bni')
MC_BNI = _ConfigParser.get_value('QPROX', 'mc^bni')
SAM1_BNI = _ConfigParser.get_value('QPROX', 'sam1^bni')
SAM2_BNI = _ConfigParser.get_value('QPROX', 'sam2^bni')
MID_BRI = _ConfigParser.get_value('QPROX', 'mid^bri')
TID_BRI = _ConfigParser.get_value('QPROX', 'tid^bri')
PROCODE_BRI = _ConfigParser.get_value('QPROX', 'procode^bri')
MID_BCA = _ConfigParser.get_value('QPROX', 'mid^bca')
TID_BCA = _ConfigParser.get_value('QPROX', 'tid^bca')

SERVICE_URL = 'http://localhost:9000/Service/GET?type=json&cmd='

MINIMUM_AMOUNT = int(_ConfigParser.get_set_value('QPROX', 'amount^minimum', '50000'))
TOPUP_AMOUNT = int(_ConfigParser.get_set_value('QPROX', 'amount^topup', '500000'))

LAST_AUTH = int(_ConfigParser.get_set_value('QPROX', 'last^auth', '0'))
LAST_UPDATE = int(_ConfigParser.get_set_value('QPROX', 'last^update', '0'))

BANKS = [{
    "BANK": "MANDIRI",
    "STATUS": True if ('---' not in MID_MAN and len(MID_MAN) > 3) else False,
    "MID": MID_MAN,
    "TID": TID_MAN,
    "SAM": SAM_MAN
}, {
    "BANK": "BNI",
    "STATUS": True if ('---' not in MID_BNI and len(MID_BNI) > 3) else False,
    "MID": MID_BNI,
    "TID": TID_BNI,
    "MC": MC_BNI,
    "SAM1": SAM1_BNI,
    "SAM2": SAM2_BNI,
    "MIN_AMOUNT": MINIMUM_AMOUNT,
    "DEFAULT_TOPUP": TOPUP_AMOUNT
}, {
    "BANK": "BRI",
    "STATUS": True if ('---' not in MID_BRI and len(MID_BRI) > 3) else False,
    "MID": MID_BRI,
    "TID": TID_BRI,
    "PROCODE": PROCODE_BRI
}, {
    "BANK": "BCA",
    "STATUS": True if ('---' not in MID_BCA and len(MID_BCA) > 3) else False,
    "MID": MID_BCA,
    "TID": TID_BCA,
}]

# [SFTP]
# host = 103.28.14.188
# user = tj-kiosk
# pass = tj-kiosk123
# port = 22222
#
# [FTP]
# host = ---
# user = ---
# pass = ---
# port = 21


SFTP_MANDIRI = {
    'status': True,
    'host': '103.28.14.188',
    'user': _ConfigParser.get_set_value('QPROX', 'sftp^mdr^user', 'tj-kiosk'),
    'pass': _ConfigParser.get_set_value('QPROX', 'sftp^mdr^pass', 'tj-kiosk123'),
    'port': '22222',
    'path': _ConfigParser.get_set_value('QPROX', 'sftp^mdr^path', '/home/mdd/TopUpOffline'),
}

FTP = {
    'status': False,
    'host': '---',
    'user': '---',
    'pass': '---',
    'port': '21'

}

KA_PIN1 = _ConfigParser.get_value('QPROX', 'ka^pin1')
KA_PIN2 = _ConfigParser.get_value('QPROX', 'ka^pin2')
KL_PIN = _ConfigParser.get_value('QPROX', 'kl^pin')
KA_NIK = _ConfigParser.get_set_value('QPROX', 'ka^nik', '2345')

# WALLET STATUS
# Assigned From QPROX Module
MANDIRI_WALLET_1 = 0
MANDIRI_WALLET_2 = 0
MANDIRI_ACTIVE_WALLET = 0
MANDIRI_ACTIVE = int(_ConfigParser.get_set_value('QPROX', 'mandiri^active^slot', '1'))
MANDIRI_NO_1 = _ConfigParser.get_set_value('QPROX', 'mandiri^sam^uid^1', '---')
MANDIRI_NO_2 = _ConfigParser.get_set_value('QPROX', 'mandiri^sam^uid^2', '---')
MANDIRI_REVERSE_SLOT_MODE = False
MANDIRI_SINGLE_SAM = int(_ConfigParser.get_set_value('QPROX', 'mandiri^single^sam', '1'))

BNI_SAM_1_WALLET = 0
BNI_SAM_2_WALLET = 0
BNI_ACTIVE = int(_ConfigParser.get_set_value('QPROX', 'bni^active^slot', '1'))
BRI_WALLET = 0
BCA_WALLET = 0
DKI_WALLET = 0

BNI_SAM_1_NO = ''
BNI_SAM_2_NO = ''

# DEVICE ERROR STATUS
# Assigned From Multiple Module
EDC_ERROR = ''
NFC_ERROR = ''
MEI_ERROR = ''
PRINTER_ERROR = ''
SCANNER_ERROR = ''
WEBCAM_ERROR = ''
CD1_ERROR = ''
CD2_ERROR = ''
CD3_ERROR = ''
ALLOWED_CONFIG_LOG = ['last^auth', 'last^update']


def log_to_config(section='last^auth'):
    global LAST_AUTH, LAST_UPDATE
    if section not in ALLOWED_CONFIG_LOG:
        LOGGER.warning(('NOT_ALLOWED', section, ALLOWED_CONFIG_LOG))
        return
    __timestamp = _Tools.now()
    if section == 'last^auth':
        LAST_AUTH = __timestamp
    if section == 'last^update':
        LAST_UPDATE = __timestamp
    _ConfigParser.set_value('QPROX', section, str(__timestamp))


def active_auth_session():
    if LAST_AUTH > 0:
        today = _Tools.today_time()
        current = (LAST_AUTH/1000)
        return True if (today+86400) > current else False
    else:
        return False


def mandiri_single_sam():
    return True if MANDIRI_SINGLE_SAM == 1 else False


def set_mandiri_uid(slot, uid):
    global MANDIRI_NO_1, MANDIRI_NO_2
    if slot == '1':
        MANDIRI_NO_1 = uid
        _ConfigParser.set_value('QPROX', 'mandiri^sam^uid^1', uid)
    if slot == '2':
        MANDIRI_NO_2 = uid
        _ConfigParser.set_value('QPROX', 'mandiri^sam^uid^2', uid)


def digit_in(s):
    return any(i.isdigit() for i in s)


QPROX = {
    "port": QPROX_PORT,
    "status": True if QPROX_PORT is not None and digit_in(QPROX_PORT) is True else False,
    # "bank_config": BANKS
}
EDC = {
    "port": EDC_PORT,
    "status": True if EDC_PORT is not None and digit_in(EDC_PORT) is True else False
}
MEI = {
    "port": MEI_PORT,
    "status": True if MEI_PORT is not None and digit_in(MEI_PORT) is True else False
}
GRG = {
    "port": GRG_PORT,
    "status": True if GRG_PORT is not None and digit_in(GRG_PORT) is True else False
}
CD = {
    "port1": CD_PORT1,
    "port2": CD_PORT2,
    "port3": CD_PORT3,
    "status": True if CD_PORT1 is not None and digit_in(CD_PORT1) is True else False,
    "list_port": CD_PORT_LIST
}

CD_READINESS = {
    "port1": 'N/A',
    "port2": 'N/A',
    "port3": 'N/A',
}

SMT_CONFIG = dict()


def start_get_devices():
    _Tools.get_pool().apply_async(get_devices)


def get_devices():
    # LOGGER.info(('[INFO] get_devices', DEVICES))
    return {"QPROX": QPROX, "EDC": EDC, "MEI": MEI, "CD": CD, "GRG": GRG}


def get_devices_status():
    return {
        "QPROX": "AVAILABLE" if QPROX["status"] is True else "NOT_AVAILABLE",
        "EDC": "AVAILABLE" if EDC["status"] is True else "NOT_AVAILABLE",
        "CD": "AVAILABLE" if CD["status"] is True else "NOT_AVAILABLE",
        "MEI": "AVAILABLE" if MEI["status"] is True else "NOT_AVAILABLE",
        "GRG": "AVAILABLE" if GRG["status"] is True else "NOT_AVAILABLE"
    }


def start_upload_device_state(device, status):
    _Tools.get_pool().apply_async(upload_device_state, (device, status, ))


def upload_device_state(device, status):
    if device not in ['nfc', 'mei', 'edc', 'printer', 'scanner', 'webcam', 'cd1', 'cd2', 'cd3']:
        LOGGER.warning(('device not in known_list', device, status))
        return
    try:
        param = {
            "device": device,
            "state": status
        }
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'change/device-state', param)
        LOGGER.info(("upload_device_state : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            return True
        return False
    except Exception as e:
        LOGGER.warning(("upload_device_state : ", e))
        return False


def start_upload_mandiri_wallet():
    _Tools.get_pool().apply_async(upload_mandiri_wallet)


def upload_mandiri_wallet():
    try:
        param = {
            'bank_name': 'MANDIRI',
            'active_wallet': MANDIRI_ACTIVE,
            'bank_tid': TID_MAN,
            'bank_mid': MID_MAN,
            'wallet_1': MANDIRI_WALLET_1,
            "wallet_2": MANDIRI_WALLET_2,
            "card_no_1": MANDIRI_NO_1,
            "card_no_2": MANDIRI_NO_2
        }
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'update/wallet-state', param)
        LOGGER.info(("upload_mandiri_wallet : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("upload_mandiri_wallet : ", e))
        return False


def start_upload_bni_wallet():
    _Tools.get_pool().apply_async(upload_bni_wallet)


def upload_bni_wallet():
    try:
        param = {
            'bank_name': 'BNI',
            'active_wallet': BNI_ACTIVE,
            'bank_tid': TID_BNI,
            'bank_mid': MID_BNI,
            'wallet_1': BNI_SAM_1_WALLET,
            "wallet_2": BNI_SAM_2_WALLET,
            "card_no_1": BNI_SAM_1_NO,
            "card_no_2": BNI_SAM_2_NO
        }
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'update/wallet-state', param)
        LOGGER.info(("upload_bni_wallet : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("upload_bni_wallet : ", e))
        return False


# def start_upload_failed_trx():
#     _Tools.get_pool().apply_async(store_upload_failed_trx)


def store_upload_failed_trx(trxid, pid='', amount=0, failure_type='', payment_method='', remarks=''):
    try:
        __param = {
            'trxid': trxid,
            'tid': TID,
            'mid': '',
            'pid': pid,
            'amount': amount,
            'cardNo': '',
            'failureType': failure_type,
            'paymentMethod': payment_method,
            'remarks': remarks,
        }
        check_trx = _DAO.check_trx_failure(trxid)
        if len(check_trx) == 0:
            _DAO.insert_transaction_failure(__param)
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'sync/transaction-failure', __param)
        LOGGER.info(("store_upload_failed_trx : ", response, str(__param)))
        if status == 200 and response['result'] == 'OK':
            __param['key'] = __param['trxid']
            _DAO.mark_sync(param=__param, _table='TransactionFailure', _key='trxid')
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("store_upload_failed_trx : ", e))
        return False


# def start_upload_admin_access(aid, username, cash_collection, edc_settlement, card_adjustment, remarks):
#     _Tools.get_pool().apply_async(upload_admin_access, (aid, username, cash_collection, edc_settlement,
#                                                         card_adjustment, remarks,))


def upload_admin_access(aid, username, cash_collection='', edc_settlement='', card_adjustment='', remarks=''):
    try:
        param = {
            'aid': aid,
            'username': username,
            'cash_collection': cash_collection,
            'edc_settlement': edc_settlement,
            'card_adjustment': card_adjustment,
            'remarks': remarks,
        }
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'sync/access-report', param)
        LOGGER.info(("upload_admin_access : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("upload_admin_access : ", e))
        return False


def start_upload_topup_error(__slot, __type):
    _Tools.get_pool().apply_async(upload_topup_error, (__slot, __type,))


def upload_topup_error(__slot, __type):
    try:
        param = {
            'slot': __slot,
            'type': __type
        }
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'update/topup-state', param)
        LOGGER.info(("upload_topup_error : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("upload_topup_error : ", e))
        return False


def store_upload_sam_audit(param):
    _table_ = 'SAMAudit'
    try:
        param = {
            'lid': _Tools.get_uuid(),
            'trxid': param['trxid'],
            'samCardNo': param['samCardNo'],
            'samCardSlot': param['samCardSlot'],
            'samPrevBalance': param['samPrevBalance'],
            'samLastBalance': param['samLastBalance'],
            'topupCardNo': param['topupCardNo'],
            'topupPrevBalance': param['topupPrevBalance'],
            'topupLastBalance': param['topupLastBalance'],
            'status': param['status'],
            'remarks': param['remarks'],
        }
        _DAO.insert_sam_audit(param)
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'sync/sam-audit', param)
        LOGGER.info(("store_upload_sam_audit : ", response, str(param)))
        if status == 200 and response['result'] == 'OK':
            param['key'] = param['lid']
            _DAO.mark_sync(param=param, _table=_table_, _key='lid')
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(("store_upload_sam_audit : ", e))
        return False


def sam_to_slot(no, bank='BNI'):
    global BNI_ACTIVE
    if bank == 'BNI':
        BNI_ACTIVE = int(no)
        save_sam_config()
        LOGGER.info(('[REMOTE]', 'sam_to_slot', str(no)))
        return 'SUCCESS_SWITCH_TO_SAM_'+no
    else:
        return 'UNKNOWN_BANK'


def save_sam_config(bank='BNI'):
    if bank == 'BNI':
        _ConfigParser.set_value('QPROX', 'bni^active^slot', str(BNI_ACTIVE))
    elif bank == 'MANDIRI':
        _ConfigParser.set_value('QPROX', 'mandiri^active^slot', str(MANDIRI_ACTIVE))


def get_active_sam(bank='MANDIRI', reverse=False):
    if bank == 'MANDIRI':
        if MANDIRI_REVERSE_SLOT_MODE is True or reverse is True:
            if MANDIRI_ACTIVE == 1:
                return '2'
            elif MANDIRI_ACTIVE == 2:
                return '1'
        else:
            return str(MANDIRI_ACTIVE)
    else:
        return
