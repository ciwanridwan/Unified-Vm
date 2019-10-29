__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
from _nNetwork import _NetworkAccess
import sys
import os


class PPOBSignalHandler(QObject):
    __qualname__ = 'PPOBSignalHandler'
    SIGNAL_GET_PRODUCTS = pyqtSignal(str)
    SIGNAL_CHECK_PPOB = pyqtSignal(str)
    SIGNAL_TRX_PPOB = pyqtSignal(str)


PPOB_SIGNDLER = PPOBSignalHandler()
LOGGER = logging.getLogger()


def start_get_ppob_product():
    _Helper.get_pool().apply_async(get_ppob_product)


def get_ppob_product():
    if (_Global.LAST_GET_PPOB + (60 * 60 * 1000)) > _Helper.now():
        products = _Global.load_from_temp_data(temp='ppob-product', mode='json')
    else:
        s, r = _NetworkAccess.get_from_url(url=_Global.BACKEND_URL+'get/product')
        if s == 200 and r['result'] == 'OK':
            products = r['data']
            _Global.LAST_GET_PPOB = _Helper.now()
            _Global.log_to_temp_config('last^get^ppob', _Global.LAST_GET_PPOB)
            _Global.store_to_temp_data(temp='ppob-product', content=json.dumps(products))
        else:
            products = _Global.load_from_temp_data(temp='ppob-product', mode='json')
    # products = store_image_item(products)
    PPOB_SIGNDLER.SIGNAL_GET_PRODUCTS.emit(json.dumps(products))


def store_image_item(products):
    for p in range(len(products)):
        old_path_category = products[p]['category_url']
        new_path_category = sys.path[0]+'/_qQML/source/ppob_category'
        store_category, category = _NetworkAccess.item_download(old_path_category, new_path_category)
        if store_category is True:
            products[p]['category_url'] = 'source/ppob_category/'+category
        operator = products[p]['operator']
        old_path_icon = 'https://api.trendpos.id/mcash/icon?operator='+operator.lower()
        new_path_icon = sys.path[0]+'/_qQML/source/ppob_icon'
        store_icon, icon = _NetworkAccess.item_download(old_path_icon, new_path_icon, name=operator+'.png')
        if store_icon is True:
            products[p]['icon_url'] = 'source/ppob_icon/'+icon
    return products


def start_check_ppob_product(msisdn, product_id):
    _Helper.get_pool().apply_async(check_ppob_product, (msisdn, product_id,))


def check_ppob_product(msisdn='', product_id=''):
    if _Global.empty(msisdn):
        LOGGER.warning((msisdn, product_id, 'MISSING_MSISDN'))
        PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|MISSING_MSISDN')
        return
    if _Global.empty(product_id):
        LOGGER.warning((msisdn, product_id, 'MISSING_PRODUCT_ID'))
        PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|MISSING_PRODUCT_ID')
        return
    try:
        param = {
            'msisdn': msisdn,
            'product_id': product_id
        }
        s, r = _NetworkAccess.post_to_url(url=_Global.BACKEND_URL+'ppob/check', param=param)
        if s == 200 and r['result'] == 'OK':
            PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|' + json.dumps(r['data']))
        else:
            PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|ERROR')
        LOGGER.debug((msisdn, product_id, str(r)))
    except Exception as e:
        LOGGER.warning((msisdn, product_id, str(e)))
        PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|ERROR')


def start_do_pay_ppob(payload):
    mode = 'PAY'
    _Helper.get_pool().apply_async(do_trx_ppob, (payload, mode,))


def start_do_topup_ppob(payload):
    mode = 'TOPUP'
    _Helper.get_pool().apply_async(do_trx_ppob, (payload, mode,))


def do_trx_ppob(payload, mode='PAY'):
    # product_id,msisdn,amount,reff_no,payment_type,product_category,operator
    payload = json.loads(payload)
    if _Global.empty(payload['msisdn']):
        LOGGER.warning((str(payload), 'MISSING_MSISDN'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_MSISDN')
        return
    if _Global.empty(payload['product_id']):
        LOGGER.warning((str(payload), 'MISSING_PRODUCT_ID'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_PRODUCT_ID')
        return
    if _Global.empty(payload['amount']):
        LOGGER.warning((str(payload), 'MISSING_AMOUNT'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_AMOUNT')
        return
    if _Global.empty(payload['reff_no']):
        LOGGER.warning((str(payload), 'MISSING_REFF_NO'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_REFF_NO')
        return
    if _Global.empty(payload['product_category']):
        LOGGER.warning((str(payload), 'MISSING_PRODUCT_CATEGORY'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_PRODUCT_CATEGORY')
        return
    if _Global.empty(payload['payment_type']):
        LOGGER.warning((str(payload), 'MISSING_PAYMENT_TYPE'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_PAYMENT_TYPE')
        return
    if _Global.empty(payload['operator']):
        LOGGER.warning((str(payload), 'MISSING_OPERATOR'))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|MISSING_OPERATOR')
        return
    try:
        url = _Global.BACKEND_URL+'ppob/pay'
        if mode == 'TOPUP':
            url = _Global.BACKEND_URL+'ppob/topup'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|' + json.dumps(r['data']))
        else:
            PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|ERROR')
        LOGGER.debug((str(payload), mode, str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), mode, str(e)))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|ERROR')
