__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser
from _tTools import _Tools
from _nNetwork import _NetworkAccess
import hashlib
import os
import sys


class PPOBSignalHandler(QObject):
    __qualname__ = 'PPOBSignalHandler'


PPOB_SIGNDLER = PPOBSignalHandler()
LOGGER = logging.getLogger()
