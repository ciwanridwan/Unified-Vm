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

CANCELLED_TRX = []


def serialize_payload(data, specification='MDD_CORE_API'):
    return _Global.serialize_payload(data, specification)


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


def start_get_qr_global(payload):
    payload = json.loads(payload)
    mode = 'N/A'
    if _Global.empty(mode):
        LOGGER.warning((str(payload), mode, 'MODE_NOT_FOUND'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|MODE_NOT_FOUND')
        return
    mode = payload['mode'].upper()
    payload = json.dumps(payload)
    _Helper.get_pool().apply_async(do_get_qr, (payload, mode,))


def do_get_qr(payload, mode, serialize=True):
    payload = json.loads(payload)
    # if mode in ['GOPAY', 'DANA', 'SHOPEEPAY']:
    #     LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
    #     QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|NOT_AVAILABLE')
    #     return
    if _Global.empty(payload['amount']) and mode in _Global.QR_NON_DIRECT_PAY:
        LOGGER.warning((str(payload), mode, 'MISSING_AMOUNT'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|MISSING_AMOUNT')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|MISSING_TRX_ID')
        return
    if  mode in ['DANA', 'SHOPEEPAY']:
        payload['reff_no'] = payload['trx_id']
    if serialize is True:
        param = serialize_payload(payload)
    # print('pyt: ' + str(_Helper.whoami()))
    # print('pyt: ' + str(payload))
    # print('pyt: ' + mode)
    try:
        url = _Global.QR_HOST+mode.lower()+'/get-qr'
        if not _Global.QR_PROD_STATE[mode]:
            url = 'http://apidev.mdd.co.id:28194/v1/'+mode.lower()+'/get-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=param)
        if s == 200 and r['response']['code'] == 200:
            if '10107' in url:
                r['data']['qr'] = r['data']['qr'].replace('https', 'http')
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|' + json.dumps(r['data']))
            if mode in ['LINKAJA', 'DANA', 'SHOPEEPAY']:
                param['refference'] = param['trx_id']
                param['trx_id'] = r['data']['trx_id']
            LOGGER.debug((str(param), str(r)))
            handle_check_process(json.dumps(param), mode)
        else:
            QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|ERROR')
            LOGGER.warning((str(param), str(r)))
    except Exception as e:
        LOGGER.warning((str(param), str(e)))
        QR_SIGNDLER.SIGNAL_GET_QR.emit('GET_QR|'+mode+'|ERROR')


def handle_check_process(param, mode):
    if mode in _Global.QR_NON_DIRECT_PAY:
        do_check_qr(param, mode, False)
    if mode in _Global.QR_DIRECT_PAY:
        sleep(5)
        do_pay_qr(param, mode)
    LOGGER.debug((str(param), mode))


def start_do_check_gopay_qr(payload):
    mode = 'GOPAY'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_dana_qr(payload):
    mode = 'DANA'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_shopee_qr(payload):
    mode = 'SHOPEEPAY'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def start_do_check_linkaja_qr(payload):
    mode = 'LINKAJA'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


CANCEL_PARAM = None


def do_check_qr(payload, mode, serialize=True):
    global CANCEL_PARAM
    payload = json.loads(payload)
    if mode in _Global.QR_DIRECT_PAY:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|MISSING_TRX_ID')
        return
    if serialize is True:
        payload = serialize_payload(payload)
    # _Helper.dump(payload)
    attempt = 0
    success = False
    while not success:
        try:
            # Handle QR Payment Cancellation Realtime Abort
            if payload['trx_id'] in CANCELLED_TRX:
                LOGGER.debug(('[BREAKING-LOOP]', 'QR CHECK STATUS', mode, payload['trx_id']))
                break
            attempt += 1
            _Helper.dump([success, attempt])
            url = _Global.QR_HOST+mode.lower()+'/status-payment'
            if not _Global.QR_PROD_STATE[mode]:
                url = 'http://apidev.mdd.co.id:28194/v1/'+mode.lower()+'/status-payment'
            CANCEL_PARAM = {
                'url'       : url.replace('status-payment', 'cancel-payment'),
                'payload'   : payload,
                'mode'      : mode
            }
            s, r = _NetworkAccess.post_to_url(url=url, param=payload)
            if s == 200 and r['response']['code'] == 200:
                success = check_payment_result(r['data'], mode)
                CANCEL_PARAM = None
                # QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|' + json.dumps(r['data']))
                # LOGGER.debug((str(payload), str(r)))
            # else:
            #     QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|ERROR')
            #     LOGGER.warning((str(payload), str(r)))
            #     break;
        except Exception as e:
            LOGGER.warning((str(payload), str(e)))
            # QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|ERROR')
            # break;
        if success is True:
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|SUCCESS|' + json.dumps(r['data']))
            break
        if attempt == 30:
            LOGGER.warning((str(payload), 'TIMEOUT', str(attempt*3)))
            QR_SIGNDLER.SIGNAL_CHECK_QR.emit('CHECK_QR|'+mode+'|TIMEOUT')
            break
        sleep(5)


def check_payment_result(result, mode):
    if _Global.empty(result):
        return False
    if mode in ['LINKAJA'] and result['status'] == 'PAID':
        return True
    if mode in ['GOPAY'] and result['status'] == 'SETTLEMENT':
        return True
    if mode in ['DANA', 'SHOPEEPAY'] and result['status'] == 'SUCCESS':
        return True
    return False


def start_do_pay_ovo_qr(payload):
    mode = 'OVO'
    sleep(5)
    _Helper.get_pool().apply_async(do_pay_qr, (payload, mode,))


def do_pay_qr(payload, mode, serialize=True):
    payload = json.loads(payload)
    if mode not in _Global.QR_DIRECT_PAY:
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
    if serialize is True:
        payload = serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/pay-qr'
        if not _Global.QR_PROD_STATE[mode]:
            url = 'http://apidev.mdd.co.id:28194/v1/'+mode.lower()+'/pay-qr'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|SUCCESS|' + json.dumps(r['data']))
            LOGGER.debug((str(payload), str(r)))
            handle_confirm_process(json.dumps(payload), mode)
        else:
            QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|ERROR')
            LOGGER.warning((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_PAY_QR.emit('PAY_QR|'+mode+'|ERROR')


def handle_confirm_process(payload, mode):
    if mode in _Global.QR_DIRECT_PAY:
        do_confirm_qr(payload, mode, False)
    LOGGER.debug((str(payload), mode))


def start_confirm_ovo_qr(payload):
    mode = 'OVO'
    _Helper.get_pool().apply_async(do_check_qr, (payload, mode,))


def do_confirm_qr(payload, mode, serialize=True):
    payload = json.loads(payload)
    if mode not in _Global.QR_DIRECT_PAY:
        LOGGER.warning((str(payload), mode, 'NOT_AVAILABLE'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|NOT_AVAILABLE')
        return
    if _Global.empty(payload['trx_id']):
        LOGGER.warning((str(payload), mode, 'MISSING_TRX_ID'))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|MISSING_TRX_ID')
        return
    if serialize is True:
        payload = serialize_payload(payload)
    try:
        url = _Global.QR_HOST+mode.lower()+'/trx-confirm'
        if not _Global.QR_PROD_STATE[mode]:
            url = 'http://apidev.mdd.co.id:28194/v1/'+mode.lower()+'/trx-confirm'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|SUCCESS|' + json.dumps(r['data']))
            LOGGER.debug((str(payload), str(r)))
        else:
            QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|ERROR')
            LOGGER.warning((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        QR_SIGNDLER.SIGNAL_CONFIRM_QR.emit('CONFIRM_QR|'+mode+'|ERROR')


def start_cancel_qr_global(trx_id):
    global CANCELLED_TRX
    trx_id = trx_id + '-' + _Global.TID
    if trx_id not in CANCELLED_TRX:
        CANCELLED_TRX.append(trx_id)
        LOGGER.info(('CANCELLING_QR_PAYMENT', trx_id))
    if CANCEL_PARAM is not None:
        _Helper.get_pool().apply_async(cancel_qr_global, )


def cancel_qr_global():
    global CANCEL_PARAM
    url = CANCEL_PARAM['url']
    payload = CANCEL_PARAM['payload']
    mode = CANCEL_PARAM['mode']
    if mode not in ['GOPAY', 'DANA', 'SHOPEEPAY']:
        LOGGER.debug((mode, 'NO AVAIL TO REQUEST QR CANCELLATION'))
        return
    try:
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['response']['code'] == 200:
            CANCEL_PARAM = None
        LOGGER.debug(mode, (str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((mode, str(e)))
        _Global.log_request(name=_Helper.whoami(), url=url, payload=payload)
