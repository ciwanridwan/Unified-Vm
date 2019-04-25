__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
from datetime import datetime
import os
import sys
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Global
from _dDAO import _DAO
from _tTools import _Tools
from _nNetwork import _NetworkAccess
from _nNetwork import _SFTPAccess


class SettlementSignalHandler(QObject):
    __qualname__ = 'SettlementSignalHandler'


ST_SIGNDLER = SettlementSignalHandler()
LOGGER = logging.getLogger()
BACKEND_URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
TID = _ConfigParser.get_value('TERMINAL', 'tid')
SALT = '|KIOSK'
# Hardcoded Setting for SMT -----------------------
SMT_URL = 'https://smt.mdd.co.id:10000/c2c-api/'
SMT_MID = 'eb03307c9f8e26c02595be6bbf682c0c'
SMT_TOKEN = 'a34837228839a9af1d5d5d968ad1b885'
# -------------------------------------------------
_Global.SMT_CONFIG['url'] = SMT_URL
_Global.SMT_CONFIG['mid'] = SMT_MID
_Global.SMT_CONFIG['token'] = SMT_TOKEN
_Global.SMT_CONFIG['full_url'] = SMT_URL + 'settlement/submit'

HEADER = {
    'Content-Type': 'application/json',
}
FILE_PATH = os.path.join(sys.path[0], '_rRemoteFiles')

BID = _Global.BID


def store_local_settlement(__param):
    try:
        param = {
            "sid": _Tools.get_uuid(),
            "tid": TID,
            "bid": BID[__param['bank']],
            "filename": __param['filename'],
            "status": 'TOPUP_PREPAID|OPEN',
            "amount": __param['amount'],
            "row": __param['row']
        }
        _DAO.insert_settlement(param=param)
        return param['sid']
    except Exception as e:
        LOGGER.warning(str(e))
        return None


def push_settlement_data(__param):
    global GLOBAL_SETTLEMENT
    """
    "bid": "1",
    "amount": 999000,
    "row": 99,
    "filename": "FILETEST123456789098765432100000006.txt",
    "settlement_created_at": "2018-11-26 11:00:00"
    """
    __url = SMT_URL + 'settlement/submit'
    if __param is None:
        LOGGER.warning(('push_settlement_data :', 'Missing __param'))
        return False
    __sid = store_local_settlement(__param)
    if __sid is None:
        LOGGER.warning(('push_settlement_data :', '__sid is None'))
        return False
    try:
        __param['mid'] = SMT_MID
        __param['token'] = SMT_TOKEN
        __param['tid'] = 'TJ-TOPUP-VM'+TID
        status, response = _NetworkAccess.post_to_url(url=__url, param=__param)
        # LOGGER.debug(('push_settlement_data :', str(status), str(response)))
        if status == 200:
            _DAO.update_settlement({'sid': __sid, 'status': 'TOPUP_PREPAID|CLOSED'})
            for settle in GLOBAL_SETTLEMENT:
                settle['key'] = settle['rid']
                _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=9)
            GLOBAL_SETTLEMENT = []
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(('push_settlement_data :', e))
        return False


def upload_settlement_file(filename, local_path):
    return _SFTPAccess.send_file(filename, local_path=local_path)


def get_response_settlement(filename, remote_path):
    return _SFTPAccess.get_file(filename, remote_path=remote_path)


GLOBAL_SETTLEMENT = []


def create_settlement_file(bank='BNI', mode='TOPUP', output_path=None):
    global GLOBAL_SETTLEMENT
    if bank == 'BNI' and mode == 'TOPUP':
        try:
            LOGGER.info(('Create Settlement File', bank, mode))
            if output_path is None:
                output_path = FILE_PATH
            settlements = _DAO.get_query_from('TopUpRecords', ' syncFlag=1 AND reportKA="N/A" ')
            GLOBAL_SETTLEMENT = settlements
            if len(settlements) == 0:
                LOGGER.warning(('No Data For Settlement', str(settlements)))
                return False
            _filename = 'TOPMDD_'+_Global.MID_BNI + _Global.TID_BNI + datetime.now().strftime('%Y%m%d%H%M%S')+'.TXT'
            LOGGER.info(('Settlement Filename', _filename))
            _filecontent = ''
            _filecontent2 = ''
            _all_amount = 0
            _header = 'H01' + _Global.MID_BNI + _Global.TID_BNI + '|'
            _filecontent += _header
            _trailer = 'T' + str(len(settlements)).zfill(6) + '00000000'
            for settle in settlements:
                remarks = json.loads(settle['remarks'])
                _all_amount += int(remarks['value']) #Must Be Denom
                _filecontent += ('D' + settle['reportSAM']) + '|'
                # settle['key'] = settle['rid']
                # _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=9)
            # Copy File Content Here to Update with the new CRC32
            _filecontent2 = _filecontent
            _filecontent += _trailer
            _file_created = os.path.join(output_path, _filename)
            with open(_file_created, 'w+') as f:
                __all_lines1 = _filecontent.split('|')
                for line in __all_lines1:
                    if line != __all_lines1[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _crc = _Tools.file2crc32(_file_created)
            if _crc is False:
                LOGGER.warning(('Settlement Filename Failed in CRC', _filename))
                return False
            _filecontent2 += ('T' + str(len(settlements)).zfill(6) + _crc)
            with open(_file_created, 'w+') as f:
                __all_lines2 = _filecontent2.split('|')
                for line in __all_lines2:
                    if line != __all_lines2[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _result = {
                'path_file': _file_created,
                'filename': _filename,
                'row': len(settlements),
                'amount': str(_all_amount),
                'bank': bank,
                'bid': BID[bank],
                'settlement_created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            # Insert Into DB
            #       smid            VARCHAR(100) PRIMARY KEY NOT NULL,
            #       fileName        TEXT,
            #       fileContent     TEXT,
            #       status          INT,
            #       remarks         TEXT,
            _DAO.insert_sam_record({
                'smid': _Tools.get_uuid(),
                'fileName': _filename,
                'fileContent': _filecontent2,
                'status': 1,
                'remarks': json.dumps(_result)
            })
            # To Prevent Re-Create The Same File When Failed Push To SMT
            for settle in GLOBAL_SETTLEMENT:
                settle['key'] = settle['rid']
                _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=9)
            return _result
        except Exception as e:
            LOGGER.warning((bank, mode, str(e)))
            return False
    elif bank == 'MANDIRI' and mode == 'TOPUP':
        try:
            # TODO Check Mandiri Settlement Function
            LOGGER.info(('Create Settlement File', bank, mode))
            if output_path is None:
                output_path = FILE_PATH
            settlements = _DAO.get_query_from('TopUpRecords', ' syncFlag=1 AND reportKA="N/A" ')
            GLOBAL_SETTLEMENT = settlements
            if len(settlements) == 0:
                LOGGER.warning(('No Data For Settlement', str(settlements)))
                return False
            _filename = 'TOPMDD_'+_Global.MID_BNI + _Global.TID_BNI + datetime.now().strftime('%Y%m%d%H%M%S')+'.TXT'
            LOGGER.info(('Settlement Filename', _filename))
            _filecontent = ''
            _filecontent2 = ''
            _all_amount = 0
            _header = 'H01' + _Global.MID_BNI + _Global.TID_BNI + '|'
            _filecontent += _header
            _trailer = 'T' + str(len(settlements)).zfill(6) + '00000000'
            for settle in settlements:
                remarks = json.loads(settle['remarks'])
                _all_amount += int(remarks['value']) #Must Be Denom
                _filecontent += ('D' + settle['reportSAM']) + '|'
                # settle['key'] = settle['rid']
                # _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=9)
            # Copy File Content Here to Update with the new CRC32
            _filecontent2 = _filecontent
            _filecontent += _trailer
            _file_created = os.path.join(output_path, _filename)
            with open(_file_created, 'w+') as f:
                __all_lines1 = _filecontent.split('|')
                for line in __all_lines1:
                    if line != __all_lines1[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _crc = _Tools.file2crc32(_file_created)
            if _crc is False:
                LOGGER.warning(('Settlement Filename Failed in CRC', _filename))
                return False
            _filecontent2 += ('T' + str(len(settlements)).zfill(6) + _crc)
            with open(_file_created, 'w+') as f:
                __all_lines2 = _filecontent2.split('|')
                for line in __all_lines2:
                    if line != __all_lines2[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _result = {
                'path_file': _file_created,
                'filename': _filename,
                'row': len(settlements),
                'amount': str(_all_amount),
                'bank': bank,
                'bid': BID[bank],
                'settlement_created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            # Insert Into DB
            #       smid            VARCHAR(100) PRIMARY KEY NOT NULL,
            #       fileName        TEXT,
            #       fileContent     TEXT,
            #       status          INT,
            #       remarks         TEXT,
            _DAO.insert_sam_record({
                'smid': _Tools.get_uuid(),
                'fileName': _filename,
                'fileContent': _filecontent2,
                'status': 1,
                'remarks': json.dumps(_result)
            })
            # To Prevent Re-Create The Same File When Failed Push To SMT
            for settle in GLOBAL_SETTLEMENT:
                settle['key'] = settle['rid']
                _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=9)
            return _result
        except Exception as e:
            LOGGER.warning((bank, mode, str(e)))
            return False
    else:
        LOGGER.warning(('Unknown bank/mode', bank, mode))
        return False

# {
#      'path_file': _file_created,
#      'filename': _filename,
#      'row': len(settlements),
#      'amount': str(_all_amount),
#      'bank': bank,
#      'bid': BID[bank],
#      'settlement_created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
# }


def start_do_bni_topup_settlement():
    _Tools.get_pool().apply_async(do_settlement_for, ('BNI', ))


def do_settlement_for(bank='BNI'):
    if bank == 'BNI':
        if _Tools.is_online(source='bni_settlement') is False:
            return
        # if _SFTPAccess.SFTP is not None:
        #     _SFTPAccess.close_sftp()
        # _SFTPAccess.init_sftp()
        # if _SFTPAccess.SFTP is None:
        #     LOGGER.warning(('do_settlement_for', bank, 'failed cannot init SFTP'))
        #     return
        _param = create_settlement_file(bank=bank)
        if _param is False:
            return
        _push = upload_settlement_file(_param['filename'], _param['path_file'])
        if _push is False:
            return
        return push_settlement_data(_param)
    elif bank == 'MANDIRI':
        if _Tools.is_online(source='mandiri_settlement') is False:
            return
        # if _SFTPAccess.SFTP is not None:
        #     _SFTPAccess.close_sftp()
        # _SFTPAccess.init_sftp()
        # if _SFTPAccess.SFTP is None:
        #     LOGGER.warning(('do_settlement_for', bank, 'failed cannot init SFTP'))
        #     return
        _param = create_settlement_file(bank=bank)
        if _param is False:
            return
        _push = upload_settlement_file(_param['filename'], _param['path_file'])
        if _push is False:
            return
        return push_settlement_data(_param)
    else:
        return
