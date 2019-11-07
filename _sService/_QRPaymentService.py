__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
from _nNetwork import _NetworkAccess


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
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|NOT_AVAILABLE')
        return
    if _Global.empty(payload['amount']) and mode in ['LINKAJA', 'GOJEK']:
        LOGGER.warning((str(payload), mode, 'MISSING_AMOUNT'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|MISSING_AMOUNT')
        return
    if _Global.empty(payload['trx_id']) and mode == 'GOJEK':
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/get-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('TRX_CHECK|ERROR')


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
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/status-payment'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|ERROR')


def start_do_pay_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_pay_qr, (payload, mode,))


def do_pay_qr(payload, mode):
    if mode in ['GOPAY', 'DANA', 'LINKAJA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|MISSING_TRX_ID')
        return
    if _Global.empty(payload['amount']):
        LOGGER.warning((str(payload), mode, 'MISSING_AMOUNT'))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|MISSING_AMOUNT')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/pay-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|ERROR')


def start_confirm_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def do_confirm_qr(payload, mode):
    if mode in ['GOPAY', 'DANA', 'LINKAJA']:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|MISSING_TRX_ID')
        return
    payload = _Global.serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/trx-confirm'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|' + json.dumps(r['data']))
        else:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|ERROR')
