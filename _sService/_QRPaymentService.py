__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
from _nNetwork import _NetworkAccess
from time import sleep


class QRSignalHandler(QObject):
    __qualname__ = 'QRSignalHandler'
    SIGNAL_GET_QR = pyqtSignal(str)
    SIGNAL_CHECK_QR = pyqtSignal(str)
    SIGNAL_PAY_QR = pyqtSignal(str)
    SIGNAL_CONFIRM_QR = pyqtSignal(str)
    SIGNAL_CANCEL_QR = pyqtSignal(str)


QR_SIGNDLER = QRSignalHandler()
LOGGER = logging.getLogger()


def start_get_qr_gopay(payload):
    mode = 'GOPAY'
    _Helper.get_pool().apply_async(do_get_qr, (payload, mode,))


def start_get_qr_ovo(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_get_qr, (payload, mode,))


def start_get_qr_dana(payload):
    mode = 'DANA'
    _Helper.get_pool().apply_async(do_get_qr, (payload, mode,))


def start_get_qr_linkaja(payload):
    mode = 'LINKAJA'
    _Helper.get_pool().apply_async(do_get_qr, (payload, mode,))


def do_get_qr(payload, mode):
    if mode in ['GOPAY', 'OVO', 'DANA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['amount']) and mode in ['LINKAJA', 'GOJEK']:
        LOGGER.warning((str(payload), mode, 'MISSING_AMOUNT'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|MISSING_AMOUNT')
        return
    if _Global.empty(payload['trx_id']) and mode == 'GOJEK':
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/get-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|' + mode + '|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('TRX_CHECK|'+mode+'|ERROR')


def start_do_check_gopay_qr(payload):
    mode = 'GOPAY'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_dana_qr(payload):
    mode = 'DANA'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_linkaja_qr(payload):
    mode = 'LINKAJA'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def do_check_qr(payload, mode):
    if mode in ['GOPAY', 'OVO', 'DANA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    attempt = 0
    success = False
    while not success:
        try:
            attempt += 1
            url = _Global.QR_HOST+mode.lower()+'/status-payment'
            s, r = _NetworkAccess.post_to_url(url=url, param=payload)
            if s == 200 and r['response']['code'] == 200:
                success = check_payment_result(r['data'], mode)
                QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|' + json.dumps(r['data']))
            else:
                QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|ERROR')
                break;
            LOGGER.debug((str(payload), str(r)))
        except Exception as e:
            LOGGER.warning((str(payload), str(e)))
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|ERROR')
            break;
        if success is True:
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|SUCCESS|' + json.dumps(r['data']))
            break
        if attempt == 20:
            LOGGER.warning((str(payload), 'TIMEOUT', str(attempt*3)))
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|TIMEOUT')
            break
        sleep(3)


def check_payment_result(result, mode):
    if _Global.empty(result):
        return False
    if mode == 'linkaja':
        if result['data']['status'] == 'PAID':
            return True
    if mode == 'gopay':
        if result['data']['status'] == 'SETTLEMENT':
            return True
    return False



def start_do_pay_ovo_qr(payload):
    mode = 'OVO'
    sleep(5)
    _Helper.get_pool().apply_async(do_pay_qr, (payload, mode,))


def do_pay_qr(payload, mode):
    if mode in ['GOPAY', 'DANA', 'LINKAJA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|MISSING_TRX_ID')
        return
    if _Global.empty(payload['amount']):
        LOGGER.warning((str(payload), mode, 'MISSING_AMOUNT'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|MISSING_AMOUNT')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/pay-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|ERROR')


def start_confirm_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def do_confirm_qr(payload, mode):
    if mode in ['GOPAY', 'DANA', 'LINKAJA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/trx-confirm'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|ERROR')
