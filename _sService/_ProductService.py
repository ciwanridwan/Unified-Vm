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
        _param = {
            'stock': stock,
            'stid': check_product[0]['stid'],
            'user': operator
        }
        LAST_UPDATED_STOCK.append(check_product[0])
        status, response = _NetworkAccess.post_to_url(url=BACKEND_URL + 'change/product-stock', param=_param)
        LOGGER.info(('change_product_stock', str(_param), str(status), str(response)))
        if status == 200 and response['result'] == 'OK':
            _DAO.custom_query(' UPDATE ProductStock SET stock=' + stock + ' WHERE stid="'+port+'" ')
            # To Bypass Refresh Product Stock Locally
            _KioskService.get_product_stock()
            PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|SUCCESS')
        else:
            PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')
    except Exception as e:
        LOGGER.warning(('change_product_stock', e))
        PR_SIGNDLER.SIGNAL_CHANGE_STOCK.emit('CHANGE_PRODUCT_STOCK|ERROR')