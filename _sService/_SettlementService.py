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
from _dDevice import _QPROX
from time import sleep


class SettlementSignalHandler(QObject):
    __qualname__ = 'SettlementSignalHandler'
    SIGNAL_MANDIRI_SETTLEMENT = pyqtSignal(str)


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


def upload_settlement_file(filename, local_path, remote_path=None):
    return _SFTPAccess.send_file(filename, local_path=local_path, remote_path=remote_path)


def get_response_settlement(filename, remote_path):
    return _SFTPAccess.get_file(filename, remote_path=remote_path)


GLOBAL_SETTLEMENT = []
MANDIRI_LAST_TIMESTAMP = ''
MANDIRI_LAST_FILENAME = ''


def create_settlement_file(bank='BNI', mode='TOPUP', output_path=None, dummy=False):
    global GLOBAL_SETTLEMENT, MANDIRI_LAST_TIMESTAMP, MANDIRI_LAST_FILENAME
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
            LOGGER.info(('Settlement Filename', bank, mode, _filename))
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
            # LOGGER.info(('Create Settlement File', bank, mode))
            if output_path is None:
                output_path = FILE_PATH
            settlements = _DAO.get_query_from('TopUpRecords', ' syncFlag=1 AND reportKA <> "N/A" ')
            GLOBAL_SETTLEMENT = settlements
            if len(settlements) == 0 and dummy is False:
                LOGGER.warning(('No Data For Settlement', bank, mode, str(settlements)))
                return False
            __shift = '0002'
            __seq = '02'
            __timestamp = datetime.now().strftime('%d%m%Y%H%M')
            MANDIRI_LAST_TIMESTAMP = __timestamp
            __raw = _Global.MID_MAN + __shift + _Global.TID_MAN + __seq + (__timestamp * 2) + 'XXXX' + '.txt'
            __ds = str(_Tools.get_ds(__raw, 4, True))
            _filename = _Global.MID_MAN + __shift + _Global.TID_MAN + __seq + (__timestamp * 2) + __ds + '.txt'
            MANDIRI_LAST_FILENAME = _filename
            LOGGER.info(('Create Settlement Filename', bank, mode, _filename))
            _filecontent = ''
            _all_amount = 0
            x = 0
            for settle in settlements:
                x += 1
                remarks = json.loads(settle['remarks'])
                _all_amount += int(remarks['value'])
                _filecontent += settle['reportSAM'] + __shift + str(x).zfill(6) + chr(3) + '|'
            _header = 'PREPAID' + str(len(settlements) + 2).zfill(8) + str(_all_amount).zfill(12) + __shift + \
                      _Global.MID_MAN + datetime.now().strftime('%d%m%Y') + chr(3) + '|'
            _filecontent = _header + _filecontent
            _trailer = _Global.MID_MAN + str(len(settlements)).zfill(8)
            _filecontent += _trailer
            _file_created = os.path.join(output_path, _filename)
            with open(_file_created, 'w+') as f:
                __all_lines = _filecontent.split('|')
                for line in __all_lines:
                    if line != __all_lines[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _file_created_ok = os.path.join(output_path, _filename.replace('.txt', '.ok'))
            with open(_file_created_ok, 'w+') as f_ok:
                f_ok.write('')
                f_ok.close()
            _result = {
                'path_file': _file_created,
                'filename': _filename,
                'row': len(settlements),
                'amount': str(_all_amount),
                'bank': bank,
                'bid': BID[bank],
                'settlement_created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            _DAO.insert_sam_record({
                'smid': _Tools.get_uuid(),
                'fileName': _filename,
                'fileContent': _filecontent,
                'status': 1,
                'remarks': json.dumps(_result)
            })
            for settle in GLOBAL_SETTLEMENT:
                settle['key'] = settle['rid']
                _DAO.mark_sync(param=settle, _table='TopUpRecords', _key='rid', _syncFlag=3)
            return _result
        except Exception as e:
            LOGGER.warning((bank, mode, str(e)))
            return False
    elif bank == 'MANDIRI' and mode == 'KA':
        try:
            # LOGGER.info(('Create Settlement File', bank, mode))
            if output_path is None:
                output_path = FILE_PATH
            settlements = _DAO.get_query_from('TopUpRecords', ' syncFlag=3 AND reportKA <> "N/A" ')
            # GLOBAL_SETTLEMENT = settlements
            if len(settlements) == 0 and dummy is False:
                LOGGER.warning(('No Data For Settlement', bank, mode, str(settlements)))
                return False
            __shift = '0002'
            # __seq = '02'
            # __timestamp = MANDIRI_LAST_TIMESTAMP
            # __ds = __timestamp[-4:]
            # _filename = 'KA' + _Global.MID_MAN + __shift + _Global.TID_MAN + __seq + (__timestamp * 2) + __ds + '.TXT'
            _filename = 'KA' + MANDIRI_LAST_FILENAME
            LOGGER.info(('Create Settlement Filename', bank, mode, _filename))
            _filecontent = ''
            _all_amount = 0
            x = 0
            for settle in settlements:
                x += 1
                remarks = json.loads(settle['remarks'])
                _all_amount += int(remarks['value'])
                _filecontent += settle['reportKA'] + __shift + str(x).zfill(6) + chr(3) + '|'
            _header = 'ADMINCARD' + str(len(settlements) + 2).zfill(8) + str(_all_amount).zfill(12) + __shift + \
                      _Global.MID_MAN + datetime.now().strftime('%d%m%Y') + chr(3) + '|'
            _filecontent = _header + _filecontent
            _trailer = _Global.MID_MAN + str(len(settlements)).zfill(8)
            _filecontent += _trailer
            _file_created = os.path.join(output_path, _filename)
            with open(_file_created, 'w+') as f:
                __all_lines = _filecontent.split('|')
                for line in __all_lines:
                    if line != __all_lines[-1]:
                        f.write(line+'\n')
                    else:
                        f.write(line)
                f.close()
            _file_created_ok = os.path.join(output_path, _filename.replace('.txt', '.ok'))
            with open(_file_created_ok, 'w+') as f_ok:
                f_ok.write('')
                f_ok.close()
            _result = {
                'path_file': _file_created,
                'filename': _filename,
                'row': len(settlements),
                'amount': str(_all_amount),
                'bank': bank,
                'bid': BID[bank],
                'settlement_created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            _DAO.insert_sam_record({
                'smid': _Tools.get_uuid(),
                'fileName': _filename,
                'fileContent': _filecontent,
                'status': 1,
                'remarks': json.dumps(_result)
            })
            for settle in settlements:
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
    bank = 'BNI'
    _Tools.get_pool().apply_async(do_settlement_for, (bank, ))


def start_do_mandiri_topup_settlement():
    bank = 'MANDIRI'
    _Tools.get_pool().apply_async(do_settlement_for, (bank, ))
    ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')


def start_dummy_mandiri_topup_settlement():
    bank = 'MANDIRI'
    dummy = True
    _Tools.get_pool().apply_async(do_settlement_for, (bank, dummy, ))
    ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')


def do_settlement_for(bank='BNI', dummy=False):
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
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_NO_INTENET_CONNECTION')
            return
        _QPROX.auth_ka(_Global.get_active_sam(bank='MANDIRI'))
        # if _SFTPAccess.SFTP is not None:
        #     _SFTPAccess.close_sftp()
        # _SFTPAccess.init_sftp()
        # if _SFTPAccess.SFTP is None:
        #     LOGGER.warning(('do_settlement_for', bank, 'failed cannot init SFTP'))
        #     return
        _param_sett = create_settlement_file(bank=bank, mode='TOPUP', dummy=dummy)
        if _param_sett is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_CREATE_FILE_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|CREATE_FILE_SETTLEMENT')
        _file_ok = _param_sett['filename'].replace('.TXT', '.OK')
        _push_file_sett = upload_settlement_file(filename=[_param_sett['filename'], _file_ok],
                                                 local_path=_param_sett['path_file'],
                                                 remote_path='/home/ftpuser/TopUpOffline/Sett_Macin_DEV')
        if _push_file_sett is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_UPLOAD_FILE_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|UPLOAD_FILE_SETTLEMENT')
        _param_ka = create_settlement_file(bank=bank, mode='KA', dummy=dummy)
        if _param_ka is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_CREATE_FILE_KA_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|CREATE_FILE_KA_SETTLEMENT')
        _param_ka_ok = _param_ka['filename'].replace('.TXT', '.OK')
        _push_file_kalog = upload_settlement_file(filename=[_param_ka['filename'], _param_ka_ok],
                                                  local_path=_param_ka['path_file'],
                                                  remote_path='/home/ftpuser/TopUpOffline/Kalog_Macin_DEV')
        if _push_file_kalog is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_UPLOAD_FILE_KA_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|UPLOAD_FILE_KA_SETTLEMENT')
        _rq1 = _QPROX.create_online_info()
        if _rq1 is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_GENERATE_RQ1_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|GENERATE_RQ1_SETTLEMENT')
        _file_rq1 = mandiri_create_rq1(content=_rq1)
        if _file_rq1 is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_CREATE_FILE_RQ1_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|CREATE_FILE_RQ1_SETTLEMENT')
        _push_rq1 = upload_settlement_file(filename=_file_rq1['filename'],
                                           local_path=_file_rq1['path_file'],
                                           remote_path='/home/ftpuser/TopUpOffline/UpdateRequestIn_DEV')
        if _push_rq1 is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_UPLOAD_FILE_RQ1_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|UPLOAD_FILE_RQ1_SETTLEMENT')
        sleep(1)
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|WAITING_RSP_UPDATE')
        _QPROX.do_update_limit_mandiri(_push_rq1['rsp'])
    else:
        return


def mandiri_create_rq1(content):
    try:
        _filename = MANDIRI_LAST_FILENAME.replace('.TXT', '.RQ1')
        _file_rq1 = os.path.join(FILE_PATH, _filename)
        with open(_file_rq1, 'w+') as f:
            f.write(content)
            f.close()
        output = {
            'rq1': content,
            'filename': _filename,
            'path_file': _file_rq1,
            'rsp': MANDIRI_LAST_FILENAME.replace('.TXT', '.RSP')
        }
        LOGGER.debug(str(output))
        return output
    except Exception as e:
        LOGGER.warning(str(e))
        return False
