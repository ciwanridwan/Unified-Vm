__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _Global
from _tTools import _Helper
from _nNetwork import _NetworkAccess


class PPOBSignalHandler(QObject):
    __qualname__ = 'PPOBSignalHandler'
    SIGNAL_GET_PRODUCTS = pyqtSignal(str)


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
    PPOB_SIGNDLER.SIGNAL_GET_PRODUCTS.emit(json.dumps(products))
