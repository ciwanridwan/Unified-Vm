__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
from datetime import datetime
import os
import sys
import logging
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Common
from _dDAO import _DAO
from _tTools import _Helper
from _nNetwork import _NetworkAccess
from _nNetwork import _SFTPAccess
from _dDevice import _QPROX, _EDC
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
_Common.SMT_CONFIG['url'] = SMT_URL
_Common.SMT_CONFIG['mid'] = SMT_MID
_Common.SMT_CONFIG['token'] = SMT_TOKEN
_Common.SMT_CONFIG['full_url'] = SMT_URL + 'settlement/submit'

HEADER = {
    'Content-Type': 'application/json',
}
FILE_PATH = os.path.join(sys.path[0], '_rRemoteFiles')

BID = _Common.BID
GLOBAL_SETTLEMENT = []


def store_local_settlement(__param):
    try:
        param = {
            "sid": _Helper.get_uuid(),
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
        __param['tid'] = 'MDD-VM'+TID
        status, response = _NetworkAccess.post_to_url(url=__url, param=__param)
        # LOGGER.debug(('push_settlement_data :', str(status), str(response)))
        if status == 200 and response['response']['code'] == 200:
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


MANDIRI_LAST_TIMESTAMP = ''
MANDIRI_LAST_FILENAME = ''


def create_settlement_file(bank='BNI', mode='TOPUP', output_path=None, force=False):
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
            _filename = 'TOPMDD_'+_Common.MID_BNI + _Common.TID_BNI + datetime.now().strftime('%Y%m%d%H%M%S')+'.TXT'
            LOGGER.info(('Settlement Filename', bank, mode, _filename))
            _filecontent = ''
            _filecontent2 = ''
            _all_amount = 0
            _header = 'H01' + _Common.MID_BNI + _Common.TID_BNI + '|'
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
            _crc = _Helper.file2crc32(_file_created)
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
                'smid': _Helper.get_uuid(),
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
            if len(settlements) == 0 and force is False:
                LOGGER.warning(('No Data For Settlement', bank, mode, str(settlements)))
                return False
            __shift = '0002'
            __seq = '02'
            __timestamp = datetime.now().strftime('%d%m%Y%H%M')
            MANDIRI_LAST_TIMESTAMP = __timestamp
            __raw = _Common.MID_MAN + __shift + _Common.TID_MAN + __seq + (__timestamp * 2) + 'XXXX' + '.txt'
            __ds = _Helper.get_ds(__raw, 4, True)
            _filename = _Common.MID_MAN + __shift + _Common.TID_MAN + __seq + (__timestamp * 2) + __ds + '.txt'
            MANDIRI_LAST_FILENAME = _filename
            LOGGER.info(('Create Settlement Filename', bank, mode, _filename))
            _filecontent = ''
            _all_amount = 0
            x = 0
            for settle in settlements:
                x += 1
                remarks = json.loads(settle['remarks'])
                _all_amount += (int(remarks['value'])-int(remarks['admin_fee']))
                _filecontent += _Helper.reverse_hexdec(settle['reportSAM']) + __shift + str(x).zfill(6) + chr(3) + '|'
            _header = 'PREPAID' + str(len(settlements) + 2).zfill(8) + str(_all_amount).zfill(12) + __shift + \
                      _Common.MID_MAN + datetime.now().strftime('%d%m%Y') + chr(3) + '|'
            _filecontent = _header + _filecontent
            _trailer = _Common.MID_MAN + str(len(settlements)).zfill(8)
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
                'smid': _Helper.get_uuid(),
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
            if len(settlements) == 0 and force is False:
                LOGGER.warning(('No Data For Settlement', bank, mode, str(settlements)))
                return False
            __shift = '0002'
            # __seq = '02'
            # __timestamp = MANDIRI_LAST_TIMESTAMP
            # __ds = __timestamp[-4:]
            # _filename = 'KA' + _Common.MID_MAN + __shift + _Common.TID_MAN + __seq + (__timestamp * 2) + __ds + '.TXT'
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
                      _Common.MID_MAN + datetime.now().strftime('%d%m%Y') + chr(3) + '|'
            _filecontent = _header + _filecontent
            _trailer = _Common.MID_MAN + str(len(settlements)).zfill(8)
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
                'smid': _Helper.get_uuid(),
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
    _Helper.get_pool().apply_async(do_settlement_for, (bank,))


def start_do_mandiri_topup_settlement():
    if int(_Common.MANDIRI_ACTIVE_WALLET) <= int(_Common.MINIMUM_AMOUNT):
        bank = 'MANDIRI'
        _Common.MANDIRI_ACTIVE_WALLET = 0
        _Helper.get_pool().apply_async(do_settlement_for, (bank,))
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')
    else:
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|NO_REQUIRED')


def start_reset_mandiri_settlement():
    bank = 'MANDIRI'
    _Common.MANDIRI_ACTIVE_WALLET = 0
    force = True
    _Helper.get_pool().apply_async(do_settlement_for, (bank, force,))
    ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')


def start_dummy_mandiri_topup_settlement():
    bank = 'MANDIRI'
    force = True
    _Helper.get_pool().apply_async(do_settlement_for, (bank, force,))
    ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')


def do_settlement_for(bank='BNI', force=False):
    if bank == 'BNI':
        _SFTPAccess.HOST_BID = 2
        if _Helper.is_online(source='bni_settlement') is False:
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
        _SFTPAccess.HOST_BID = 1
        if _Helper.is_online(source='mandiri_settlement') is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_NO_INTERNET_CONNECTION')
            return
        # _QPROX.auth_ka(_slot=_Common.get_active_sam(bank='MANDIRI', reverse=False), initial=False)
        # if _SFTPAccess.SFTP is not None:
        #     _SFTPAccess.close_sftp()
        # _SFTPAccess.init_sftp()
        # if _SFTPAccess.SFTP is None:
        #     LOGGER.warning(('do_settlement_for', bank, 'failed cannot init SFTP'))
        #     return
        _param_sett = create_settlement_file(bank=bank, mode='TOPUP', force=force)
        if _param_sett is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_CREATE_FILE_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|CREATE_FILE_SETTLEMENT')
        _file_ok = _param_sett['filename'].replace('.TXT', '.OK')
        _push_file_sett = upload_settlement_file(filename=[_param_sett['filename'], _file_ok],
                                                 local_path=_param_sett['path_file'],
                                                 remote_path=_Common.SFTP_MANDIRI['path']+'/Sett_Macin_DEV')
        if _push_file_sett is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_UPLOAD_FILE_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|UPLOAD_FILE_SETTLEMENT')
        _param_ka = create_settlement_file(bank=bank, mode='KA', force=force)
        if _param_ka is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_CREATE_FILE_KA_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|CREATE_FILE_KA_SETTLEMENT')
        _param_ka_ok = _param_ka['filename'].replace('.TXT', '.OK')
        _push_file_kalog = upload_settlement_file(filename=[_param_ka['filename'], _param_ka_ok],
                                                  local_path=_param_ka['path_file'],
                                                  remote_path=_Common.SFTP_MANDIRI['path']+'/Kalog_Macin_DEV')
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
                                           remote_path=_Common.SFTP_MANDIRI['path']+'/UpdateRequestIn_DEV')
        if _push_rq1 is False:
            ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|FAILED_UPLOAD_FILE_RQ1_SETTLEMENT')
            return
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|UPLOAD_FILE_RQ1_SETTLEMENT')
        sleep(1)
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|WAITING_RSP_UPDATE')
        _QPROX.do_update_limit_mandiri(_file_rq1['rsp'])
        # _QPROX.auth_ka(_slot=_Common.get_active_sam(bank='MANDIRI', reverse=False), initial=False)
        # Move To QPROX Module
    else:
        return


def mandiri_create_rq1(content):
    try:
        _filename = MANDIRI_LAST_FILENAME.replace('.txt', '.RQ1')
        _file_rq1 = os.path.join(FILE_PATH, _filename)
        with open(_file_rq1, 'w+') as f:
            f.write(content)
            f.close()
        output = {
            'rq1': content,
            'filename': _filename,
            'path_file': _file_rq1,
            'rsp': MANDIRI_LAST_FILENAME.replace('.txt', '.RSP')
        }
        LOGGER.debug(str(output))
        return output
    except Exception as e:
        LOGGER.warning(str(e))
        return False


def start_validate_update_balance():
    _Helper.get_pool().apply_async(validate_update_balance)


def validate_update_balance():
    while True:
        daily_settle_time = _ConfigParser.get_set_value('QPROX', 'mandiri^daily^settle^time', '02:00')
        sync_time = int(_ConfigParser.get_set_value('QPROX', 'mandiri^daily^sync^time', '3600'))
        current_time = _Helper.now() / 1000
        LOGGER.debug(('MANDIRI_SAM_UPDATE_BALANCE', 'SYNC_TIME', sync_time, 'DAILY_SETTLEMENT', daily_settle_time))
        if _Common.LAST_UPDATE > 0:
            last_update_with_tolerance = (_Common.LAST_UPDATE/1000) + 84600
            if current_time >= last_update_with_tolerance:
                LOGGER.info(('DETECTED_EXPIRED_LIMIT_UPDATE', last_update_with_tolerance, current_time))
                _Common.MANDIRI_ACTIVE_WALLET = 0
                do_settlement_for(bank='MANDIRI', force=True)
                ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')
        if _Helper.whoami() not in _Common.ALLOWED_SYNC_TASK:
            LOGGER.debug(('[BREAKING-LOOP] ', _Helper.whoami()))
            break
        next_run_time = current_time + sync_time
        LOGGER.debug(('MANDIRI_SAM_UPDATE_BALANCE NEXT RUN', _Helper.convert_epoch(t=next_run_time)))
        sleep(sync_time)


MANDIRI_UPDATE_SCHEDULE_RUNNING = False


def start_trigger_mandiri_sam_update():
    if not _QPROX.INIT_MANDIRI:
        LOGGER.warning(('FAILED MANDIRI_SAM_UPDATE_BALANCE', 'INIT_MANDIRI', _QPROX.INIT_MANDIRI))
        print("pyt: Failed MANDIRI_SAM_UPDATE_BALANCE, Mandiri SAM Not Init Yet")
        return
    sleep(_Helper.get_random_num(.7, 2.9))
    if not MANDIRI_UPDATE_SCHEDULE_RUNNING:
        _Helper.get_pool().apply_async(trigger_mandiri_sam_update)
    else:
        print("pyt: Failed MANDIRI_SAM_UPDATE_BALANCE, Already Triggered Previously")


def trigger_mandiri_sam_update():
    global MANDIRI_UPDATE_SCHEDULE_RUNNING

    # When This Function is Triggered, It will be forced update the SAM Balance And Ignore
    # Last Update Timestamp on TEMPORARY 
    daily_settle_time = _ConfigParser.get_set_value('QPROX', 'mandiri^daily^settle^time', '02:00')
    current_time = _Helper.now() / 1000
    last_update = 0
    if _Common.LAST_UPDATE > 0:
        last_update = _Common.LAST_UPDATE/1000
    last_update_with_tolerance = (last_update + 84600000)/1000
    current_limit = 5000000
    if _Common.MANDIRI_ACTIVE_WALLET > current_limit:
        current_limit = 10000000
    if _Common.MANDIRI_ACTIVE_WALLET < current_limit or current_time >= last_update_with_tolerance:
        MANDIRI_UPDATE_SCHEDULE_RUNNING = True
        LOGGER.info(('TRIGGERED_BY_TIME_SETUP', _Helper.time_string('%H:%M'), daily_settle_time))
        _Common.MANDIRI_ACTIVE_WALLET = 0
        do_settlement_for(bank='MANDIRI', force=True)
        ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.emit('MANDIRI_SETTLEMENT|TRIGGERED')
        MANDIRI_UPDATE_SCHEDULE_RUNNING = False
    else:
        LOGGER.warning(('FAILED_START_TIME_TRIGGER', _Helper.time_string('%H:%M'), daily_settle_time))
        LOGGER.warning(('LAST_UPDATE_BALANCE', _Helper.convert_epoch(last_update)))
        LOGGER.warning(('CURRENT_SAM_BALANCE', _Common.MANDIRI_ACTIVE_WALLET), current_limit)


def start_trigger_edc_settlement():
    sleep(_Helper.get_random_num(.7, 2.9))
    if not _Common.EDC_SETTLEMENT_RUNNING:
        _Common.EDC_SETTLEMENT_RUNNING = True
        _Helper.get_pool().apply_async(trigger_edc_settlement)
    else:
        print("pyt: Failed EDC_SETTLEMENT_SCHEDULE, Already Triggered Previously")


def trigger_edc_settlement():
    daily_settle_time = _ConfigParser.get_set_value('EDC', 'daily^settle^time', '23:00')
    LOGGER.info(('TRIGGERED_BY_TIME_SETUP', 'EDC_SETTLEMENT_SCHEDULE', _Helper.time_string('%H:%M'), daily_settle_time))
    _EDC.define_edc_settlement()
    _Common.EDC_SETTLEMENT_RUNNING = False


