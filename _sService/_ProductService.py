__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Global
from _dDAO import _DAO
from _tTools import _Helper
from _nNetwork import _NetworkAccess
from _sService import _UserService
from _sService import _KioskService
import json
from operator import itemgetter



class ProductSignalHandler(QObject):
    __qualname__ = 'ProductSignalHandler'
    SIGNAL_CHANGE_STOCK = pyqtSignal(str)
    SIGNAL_CHECK_VOUCHER = pyqtSignal(str)
    SIGNAL_USE_VOUCHER = pyqtSignal(str)


PR_SIGNDLER = ProductSignalHandler()
LOGGER = logging.getLogger()
BACKEND_URL = _Global.BACKEND_URL
LAST_UPDATED_STOCK = []


def start_change_product_stock(port, stock):
    _Helper.get_pool().apply_async(change_product_stock, (port, stock,))


def change_product_stock(port, stock):
    global LAST_UPDATED_STOCK
    check_product = _DAO.custom_query(' SELECT * FROM ProductStock WHERE status='+port+' ')
    if len(check_product) == 0:
        PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT|STID_NOT_FOUND')
        return
    try:
        operator = 'OPERATOR'
        if _UserService.USER is not None:
            operator = _UserService.USER['first_name']
        _stid = check_product[0]['stid']
        _param = {
            'stock': stock,
            'stid': _stid,
            'user': operator
        }
        # Record Local Change
        LAST_UPDATED_STOCK.append(check_product[0])
        # Log Change To Local And Send Signal Into View
        _DAO.custom_update(' UPDATE ProductStock SET stock=' + stock + ' WHERE stid="'+_stid+'" ')
        _KioskService.kiosk_get_product_stock()
        status, response = _NetworkAccess.post_to_url(url=BACKEND_URL + 'change/product-stock', param=_param)
        LOGGER.info(('change_product_stock', str(_param), str(status), str(response)))
        if status == 200 and response['result'] == 'OK':
            # _KioskService.kiosk_get_product_stock()
            PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|SUCCESS')
        else:
            # LOG REQUEST
            _Global.log_request(name=_Helper.whoami, url=BACKEND_URL + 'change/product-stock', payload=_param)
            PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')
    except Exception as e:
        LOGGER.warning(('change_product_stock', e))
        PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')


def kiosk_get_product_stock():
    _url = BACKEND_URL + 'get/product-stock'
    if _Helper.is_online(source='start_get_product_stock') is True:
        s, r = _NetworkAccess.get_from_url(url=_url)
        if s == 200 and r['result'] == 'OK':
            products = r['data']
            products = sorted(products, key=itemgetter('status'))
            _DAO.flush_table('ProductStock')
            for product in products:
                _DAO.insert_product_stock(product)
            _KioskService.get_product_stock()


def start_check_voucher(voucher):
    _Helper.get_pool().apply_async(check_voucher, (voucher,))


def check_voucher(voucher):
    if _Global.empty(voucher):
        LOGGER.warning((str(voucher), 'MISSING_VOUCHER_NUMBER'))
        PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.emit('CHECK_VOUCHER|MISSING_VOUCHER_NUMBER')
        return
    payload = {
        'vcode': voucher
    }
    try:
        url = _Global.BACKEND_URL+'ppob/voucher/check'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data']['Response'] == '0':
            product_id = r['data']['product']
            check_product = _DAO.check_product_status_by_pid({'pid': product_id})
            if len(check_product) > 0:
                output = {
                    'mode': 'card_collection',
                    'product': product_id,
                    'qty': r['data']['qty_available'],
                    'voucher_details': r['data'],
                    'card': check_product[0],
                    'slot': check_product[0]['status']
                }
                PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.emit('CHECK_VOUCHER|' + json.dumps(output))
            else:
                PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.emit('CHECK_VOUCHER|EMPTY')
        else:
            PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.emit('CHECK_VOUCHER|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.emit('CHECK_VOUCHER|ERROR')


def start_use_voucher(voucher, reff_no):
    _Helper.get_pool().apply_async(use_voucher, (voucher, reff_no,))


def use_voucher(voucher, reff_no):
    if _Global.empty(voucher):
        LOGGER.warning((str(voucher), 'MISSING_VOUCHER_NUMBER'))
        PR_SIGNDLER.SIGNAL_USE_VOUCHER.emit('USE_VOUCHER|MISSING_VOUCHER_NUMBER')
        return
    if _Global.empty(reff_no):
        LOGGER.warning((str(reff_no), 'MISSING_REFF_NO'))
        PR_SIGNDLER.SIGNAL_USE_VOUCHER.emit('USE_VOUCHER|MISSING_REFF_NO')
        return
    product_id = reff_no.split('-')[1]
    check_product = _DAO.check_product_status_by_pid({'pid': product_id})
    if len(check_product) > 0:
        _DAO.update_product_stock({
                'pid': product_id,
                'stock': check_product[0]['stock'] - 1,
            })
    payload = {
        'vcode': voucher,
        'note_ref': reff_no + '-' + _Global.TID
    }
    try:
        url = _Global.BACKEND_URL+'ppob/voucher/use'
        s, r = _NetworkAccess.post_to_url(url=url, param=payload)
        if s == 200 and r['result'] == 'OK' and r['data'] is not None:
            PR_SIGNDLER.SIGNAL_USE_VOUCHER.emit('USE_VOUCHER|' + json.dumps(r['data']))
        else:
            PR_SIGNDLER.SIGNAL_USE_VOUCHER.emit('USE_VOUCHER|ERROR')
        LOGGER.debug((str(payload), str(r)))
    except Exception as e:
        LOGGER.warning((str(payload), str(e)))
        PR_SIGNDLER.SIGNAL_USE_VOUCHER.emit('USE_VOUCHER|ERROR')
