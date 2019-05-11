__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser
from _dDAO import _DAO
from _tTools import _Tools
from _nNetwork import _NetworkAccess
from _sService import _UserService
from _sService import _KioskService


class ProductSignalHandler(QObject):
    __qualname__ = 'ProductSignalHandler'
    SIGNAL_CHANGE_STOCK = pyqtSignal(str)


PR_SIGNDLER = ProductSignalHandler()
LOGGER = logging.getLogger()
BACKEND_URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
LAST_UPDATED_STOCK = []


def start_change_product_stock(port, stock):
    _Tools.get_pool().apply_async(change_product_stock, (port, stock,))


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
            PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')
    except Exception as e:
        LOGGER.warning(('change_product_stock', e))
        PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')


def kiosk_get_product_stock():
    _url = BACKEND_URL + 'get/product-stock'
    if _Tools.is_online(source='start_get_product_stock') is True:
        s, r = _NetworkAccess.get_from_url(url=_url)
        if s == 200 and r['result'] == 'OK':
            products = r['data']
            _DAO.flush_table('ProductStock')
            for product in products:
                _DAO.insert_product_stock(product)
            _KioskService.get_product_stock()
