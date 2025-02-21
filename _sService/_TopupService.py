__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _nNetwork import _NetworkAccess
from _dDevice import _QPROX
from _cConfig import _Common
from _tTools import _Helper
from time import sleep
from _cCommand import _Command


class TopupSignalHandler(QObject):
    __qualname__ = 'TopupSignalHandler'
    SIGNAL_DO_TOPUP_BNI = pyqtSignal(str)


TP_SIGNDLER = TopupSignalHandler()
LOGGER = logging.getLogger()

TOPUP_URL = _Common.TOPUP_URL
TOPUP_TOKEN = _Common.TOPUP_TOKEN
TOPUP_MID = _Common.TOPUP_MID
# TOPUP_TID = '0123456789abcdefghijkl' -> Change Using Terminal ID
TOPUP_TID = _Common.TID
# ==========================================================


def start_define_topup_slot_bni():
    _Helper.get_pool().apply_async(define_topup_slot_bni)


BNI_UPDATE_BALANCE_PROCESS = False


def define_topup_slot_bni():
    while True:
        if not BNI_UPDATE_BALANCE_PROCESS:
            if _Common.BNI_SAM_1_WALLET <= _Common.MINIMUM_AMOUNT:
                LOGGER.debug(('START_BNI_SAM_AUTO_UPDATE_SLOT_1', str(_Common.MINIMUM_AMOUNT), str(_Common.BNI_SAM_1_WALLET)))
                TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_1')
                do_topup_bni(slot=1, force=True)
            if _Common.BNI_SINGLE_SAM is False and _Common.BNI_SAM_2_WALLET <= _Common.MINIMUM_AMOUNT:
                LOGGER.debug(('START_BNI_SAM_AUTO_UPDATE_SLOT_2', str(_Common.MINIMUM_AMOUNT), str(_Common.BNI_SAM_2_WALLET)))
                TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_2')
                do_topup_bni(slot=2, force=True)
        sleep(5)


def start_do_topup_bni(slot):
    _Helper.get_pool().apply_async(do_topup_bni, (int(slot),))


def start_do_force_topup_bni():
    slot = _Common.BNI_ACTIVE
    force = True
    _Helper.get_pool().apply_async(do_topup_bni, (int(slot), force, ))


def do_topup_bni(slot=1, force=False):
    global BNI_UPDATE_BALANCE_PROCESS
    try:
        if force is False and _Common.ALLOW_DO_TOPUP is False:
            LOGGER.warning(('do_topup_bni', slot, _Common.ALLOW_DO_TOPUP))
            return 'TOPUP_NOT_ALLOWED'
        _get_card_data = _QPROX.get_card_info(slot=slot)
        if _get_card_data is False:
            TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('FAILED_GET_CARD_INFO_BNI')
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_GET_CARD_INFO_BNI'
        BNI_UPDATE_BALANCE_PROCESS = True
        _Common.BNI_ACTIVE_WALLET = 0
        _result_pending = pending_balance({
            'card_no': _get_card_data['card_no'],
            'amount': _Common.BNI_TOPUP_AMOUNT,
            'card_tid': _Common.TID_BNI
        })
        if _result_pending is False:
            TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('FAILED_PENDING_BALANCE_BNI')
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_PENDING_BALANCE_BNI'
        _result_ubal = update_balance({
            'card_no': _get_card_data['card_no'],
            'card_info': _get_card_data['card_info'],
            'reff_no': _result_pending['reff_no']
        })
        if _result_ubal is False:
            TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('FAILED_UPDATE_BALANCE_BNI')
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_UPDATE_BALANCE_BNI'
        _send_crypto = _QPROX.send_cryptogram(_get_card_data['card_info'], _result_ubal['dataToCard'], slot=slot)
        if _send_crypto is False:
            TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('FAILED_SEND_CRYPTOGRAM_BNI')
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_SEND_CRYPTOGRAM_BNI'
        else:
            BNI_UPDATE_BALANCE_PROCESS = False
            TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('SUCCESS_TOPUP_BNI')
            _Common.upload_topup_error(slot, 'RESET')
            return 'SUCCESS_TOPUP_BNI'
    except Exception as e:
        LOGGER.warning(('do_topup_bni', str(slot), str(e)))
        TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('FAILED_TOPUP_BNI')


def do_reset_pending_master():
    slot = 1
    _Helper.get_pool().apply_async(reset_pending_balance, (slot,))


def do_reset_pending_slave():
    slot = 2
    _Helper.get_pool().apply_async(reset_pending_balance, (slot,))


def reset_pending_balance(slot=1):
    try:
        _get_card_data = _QPROX.get_card_info(slot=slot)
        if _get_card_data is False:
            return 'FAILED_GET_CARD_INFO_BNI'
        _result_pending = pending_balance({
            'card_no': _get_card_data['card_no'],
            'amount': '10',
            'card_tid': _Common.TID_BNI,
            'activation': '1'
        })
        if _result_pending is False:
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_PENDING_BALANCE_BNI'
        _result_ubal = update_balance({
            'card_no': _get_card_data['card_no'],
            'card_info': _get_card_data['card_info'],
            'reff_no': _result_pending['reff_no']
        })
        if _result_ubal is False:
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_UPDATE_BALANCE_BNI'
        _send_crypto = _QPROX.send_cryptogram(_get_card_data['card_info'], _result_ubal['dataToCard'], slot=slot)
        if _send_crypto is False:
            _Common.upload_topup_error(slot, 'ADD')
            return 'FAILED_SEND_CRYPTOGRAM_BNI'
        else:
            _Common.upload_topup_error(slot, 'RESET')
            _Common.ALLOW_DO_TOPUP = True
            return 'SUCCESS_RESET_PENDING_BNI'
    except Exception as e:
        LOGGER.warning(('reset_pending_balance', str(slot), str(e)))
        return False


def pending_balance(_param, bank='BNI', mode='TOPUP'):
    if bank == 'BNI' and mode == 'TOPUP':
        try:
            # param must be
            # "token":"<<YOUR API-TOKEN>>",
            # "mid":"<<YOUR MERCHANT_ID>>",
            # "tid":"<<YOUR TERMINAL/DEVICE_ID>>",
            # "amount":"30000",
            # "card_no":"7546990000025583"
            # ---> Need Card Number And Amount
            _param['token'] = TOPUP_TOKEN
            _param['mid'] = TOPUP_MID
            _param['tid'] = TOPUP_TID
            status, response = _NetworkAccess.post_to_url(url=TOPUP_URL + 'v1/topup-bni/pending', param=_param)
            LOGGER.debug(('pending_balance', str(_param), str(status), str(response)))
            if status == 200 and response['response']['code'] == 200:
                # {
                # "response":{
                #   "code":200,
                #   "message":"Pending Balance Success",
                #   "latency":2.2753360271454
                # },
                # "data":{
                #   "amount":"30000",
                #   "card_no":"7546990000025583",
                #   "reff_no":"20181207180324000511",
                #   "provider_id":"BNI_TAPCASH",
                #   "trx_pin":"12345"
                #   }
                # }
                return response['data']
            else:
                return False
        except Exception as e:
            LOGGER.warning((bank, mode, e))
            return False
    else:
        LOGGER.warning(('Unknown', bank, mode))
        return False


def update_balance(_param, bank='BNI', mode='TOPUP'):
    if bank == 'BNI' and mode == 'TOPUP':
        try:
            # param must be
            # "token":"<<YOUR API-TOKEN>>",
            # "mid":"<<YOUR MERCHANT_ID>>",
            # "tid":"<<YOUR TERMINAL/DEVICE_ID>>",
            # "reff_no":"20181207180324000511",
            # "card_info":"0001754699000002558375469900000255835A929C0E8DCEC98A95A574DE68D93CBB0
            # 00000000100000088889999040000002D04C36E88889999040000002D04C36E000000000000000000
            # 0079EC3F7C7EED867EBC676CD434082D2F",
            # "card_no":"7546990000025583"
            # ---> Need Card Number, Card Info, Reff_No
            _param['token'] = TOPUP_TOKEN
            _param['mid'] = TOPUP_MID
            _param['tid'] = TOPUP_TID
            status, response = _NetworkAccess.post_to_url(url=TOPUP_URL + 'v1/topup-bni/update', param=_param)
            LOGGER.debug(('update_balance', str(_param), str(status), str(response)))
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
                # _Common.ALLOW_DO_TOPUP = True
                return response['data']
            else:
                _Common.ALLOW_DO_TOPUP = False
                return False
        except Exception as e:
            LOGGER.warning((bank, mode, e))
            return False
    else:
        LOGGER.warning(('Unknown', bank, mode))
        return False


def reversal_balance(_param, bank='BNI', mode='TOPUP'):
    if bank == 'BNI' and mode == 'TOPUP':
        try:
            # param must be
            # "token":"<<YOUR API-TOKEN>>",
            # "mid":"<<YOUR MERCHANT_ID>>",
            # "tid":"<<YOUR TERMINAL/DEVICE_ID>>",
            # "card_no":"7546990000025583",
            # "amount":"30000",
            # "auth_id":"164094",
            # "card_data":"06015F902D04C57100000000000000001C54522709845B42F240343E96F11041"
            # ---> Need Card Number, Card Data, Amount, Auth ID
            _param['token'] = TOPUP_TOKEN
            _param['mid'] = TOPUP_MID
            _param['tid'] = TOPUP_TID
            status, response = _NetworkAccess.post_to_url(url=TOPUP_URL + 'v1/topup-bni/reversal', param=_param)
            LOGGER.debug(('reversal_balance', str(_param), str(status), str(response)))
            if status == 200 and response['response']['code'] == 200:
                # {
                # "response":{
                #   "code":200,
                #   "message":"Reversal Balance Success",
                #   "latency":2.8180389404297
                # },
                # "data":{
                #   "card_no":"7546990000025583",
                #   "amount":"30000"
                #   }
                # }
                return response['data']
            else:
                return False
        except Exception as e:
            LOGGER.warning((bank, mode, e))
            return False
    else:
        LOGGER.warning(('Unknown', bank, mode))
        return False


def start_master_activation_bni():
    slot = 1
    _Helper.get_pool().apply_async(refill_zero_bni, (slot,))


def start_slave_activation_bni():
    slot = 2
    _Helper.get_pool().apply_async(refill_zero_bni, (slot,))


def refill_zero_bni(slot=1):
    _slot = slot - 1
    param = _QPROX.QPROX['REFILL_ZERO'] + '|' + str(_slot) + '|' + _QPROX.TID_BNI
    response, result = _Command.send_request(param=param, output=None)
    if response == 0:
        _Common.NFC_ERROR = ''
        _QPROX.QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO|SUCCESS')
        sleep(2)
        reset_pending_balance(slot=slot)
    else:
        if slot == 1:
            _Common.NFC_ERROR = 'REFILL_ZERO_SLOT_1_BNI_ERROR'
        if slot == 2:
            _Common.NFC_ERROR = 'REFILL_ZERO_SLOT_2_BNI_ERROR'
        _QPROX.QP_SIGNDLER.SIGNAL_REFILL_ZERO.emit('REFILL_ZERO_ERROR')


