__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
from _nNetwork import _NetworkAccess
import sys
# import os


class PPOBSignalHandler(QObject):
    __qualname__ = 'PPOBSignalHandler'
    SIGNAL_GET_PRODUCTS = pyqtSignal(str)
    SIGNAL_CHECK_PPOB = pyqtSignal(str)
    SIGNAL_TRX_PPOB = pyqtSignal(str)
    SIGNAL_TRX_CHECK = pyqtSignal(str)
    SIGNAL_CHECK_BALANCE = pyqtSignal(str)
    SIGNAL_TRANSFER_BALANCE = pyqtSignal(str)


PPOB_SIGNDLER = PPOBSignalHandler()
LOGGER = logging.getLogger()


def start_get_ppob_product():
    _Helper.get_pool().apply_async(get_ppob_product)


def get_ppob_product():
    _check_prev_ppob = _Global.load_from_temp_data(temp='ppob-product', mode='json')
    if (_Global.get_config_value('last^get^ppob') + (60 * 60 * 1000)) > _Helper.now() and not _Global.empty(_check_prev_ppob):
        products = _check_prev_ppob
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
        # mcash/cek/TELKOM/161101001530
        # mcash/cek/BPJS/0001264047118
        # mcash/cek/PLN/173000000485
        # mcash/cek/MATRIX/08164300888
        # mcash/cek/PALYJA/000603544
        param = {
            'msisdn': msisdn,
            'product_id': product_id
        }
        s, r = _NetworkAccess.post_to_url(url=_Global.BACKEND_URL+'ppob/check', param=param)
        if s == 200 and r['result'] == 'OK':
            output = r['data']
            customer_name = ''
            total_pay = 0
            payable = 0
            if 'BERHASIL' in output['msg']:
                customer_name = extract_customer_name(msisdn, output['msg'])
                total_pay = int(output['ori_amount']) + int(output['admin_fee'])
                payable = 1
            output['customer'] = customer_name
            output['total'] = total_pay
            output['payable'] = payable
            output['msisdn'] = msisdn
            output['category'] = product_id
            _Helper.dump(output)
            PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|' + json.dumps(output))
        else:
            PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|ERROR')
        LOGGER.debug((msisdn, product_id, str(r)))
    except Exception as e:
        LOGGER.warning((msisdn, product_id, str(e)))
        PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.emit('PPOB_CHECK|ERROR')


def extract_customer_name(key, message):
    customer = ''
    if 'GAGAL' in message:
        return customer
    key = key[:-2]
    idx = message.find(key)
    if idx < 0:
        return customer
    clean_message = message[idx:].split(' adalah')[0]
    messages = clean_message.split(' ')
    c = []
    for m in messages:
        if m not in [' -a-n', 'adalah'] and not m.isdigit() and messages[0] != m and len(m) > 1:
            c.append(m)
    customer = ' '.join(c)
    return customer


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
    _Helper.dump(payload)
    try:
        url = _Global.BACKEND_URL+'ppob/pay'
        if mode == 'TOPUP':
            url = _Global.BACKEND_URL+'ppob/topup'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|' + json.dumps(r['data']))
            LOGGER.debug((str(payload), mode, str(r)))
        else:
            PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|ERROR')
            LOGGER.warning((str(payload), mode, str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), mode, str(e)))
        PPOB_SIGNDLER.SIGNAL_TRX_PPOB.emit('PPOB_TRX|ERROR')


def start_check_trx_online(reff_no):
    _Helper.get_pool().apply_async(do_check_trx, (reff_no,))


def do_check_trx(reff_no):
    if _Global.empty(reff_no):
        LOGGER.warning((str(reff_no), 'MISSING_REFF_NO'))
        PPOB_SIGNDLER.SIGNAL_TRX_CHECK.emit('TRX_CHECK|MISSING_REFF_NO')
        return
    payload = {
        'reff_no': reff_no
    }
    try:
        url = _Global.BACKEND_URL+'ppob/trx/detail'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PPOB_SIGNDLER.SIGNAL_TRX_CHECK.emit('TRX_CHECK|' + json.dumps(r['data']))
        else:
            PPOB_SIGNDLER.SIGNAL_TRX_CHECK.emit('TRX_CHECK|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        PPOB_SIGNDLER.SIGNAL_TRX_CHECK.emit('TRX_CHECK|ERROR')


def start_check_diva_balance(username):
    _Helper.get_pool().apply_async(check_diva_balance, (username,))


def check_diva_balance(username):
    if _Global.empty(username):
        LOGGER.warning((str(username), 'MISSING_USERNAME'))
        PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|MISSING_USERNAME')
        return
    payload = {
        'customer_login': username
    }
    try:
        url = _Global.BACKEND_URL+'diva/inquiry'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|' + json.dumps(r['data']))
        else:
            PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|ERROR')


def start_transfer_balance(payload):
    _Helper.get_pool().apply_async(diva_transfer_balance, (payload,))


def diva_transfer_balance(payload):
    payload = json.loads(payload)
    if _Global.empty(payload['reff_no']):
        LOGGER.warning((str(payload), 'MISSING_REFF_NO'))
        PPOB_SIGNDLER.SIGNAL_TRANSFER_BALANCE.emit('TRANSFER_BALANCE|MISSING_REFF_NO')
        return
    if _Global.empty(payload['customer']):
        LOGGER.warning((str(payload), 'MISSING_CUSTOMER'))
        PPOB_SIGNDLER.SIGNAL_TRANSFER_BALANCE.emit('TRANSFER_BALANCE|MISSING_CUSTOMER')
        return
    if _Global.empty(payload['amount']):
        LOGGER.warning((str(payload), 'MISSING_AMOUNT'))
        PPOB_SIGNDLER.SIGNAL_TRANSFER_BALANCE.emit('TRANSFER_BALANCE|MISSING_AMOUNT')
        return
    payload['customer_login'] = payload['customer']
    try:
        url = _Global.BACKEND_URL+'diva/transfer'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|' + json.dumps(r['data']))
        else:
            PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.emit('BALANCE_CHECK|ERROR')
