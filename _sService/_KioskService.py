__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
import os
import datetime
import time
import random
import sys
import shutil
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Common
from _dDAO import _DAO
from _tTools import _Helper
from _nNetwork import _NetworkAccess
from pprint import pprint
import win32print
import wmi
import pythoncom
from _sService import _UserService
from time import sleep
import subprocess
from operator import itemgetter
from _dDevice import _GRG


class KioskSignalHandler(QObject):
    __qualname__ = 'KioskSignalHandler'
    SIGNAL_GET_GUI_VERSION = pyqtSignal(str)
    SIGNAL_GET_KIOSK_NAME = pyqtSignal(str)
    SIGNAL_GET_FILE_LIST = pyqtSignal(str)
    SIGNAL_GET_PAYMENTS = pyqtSignal(str)
    SIGNAL_GET_REFUNDS = pyqtSignal(str)
    SIGNAL_GENERAL = pyqtSignal(str)
    SIGNAL_GET_KIOSK_STATUS = pyqtSignal(str)
    SIGNAL_PRICE_SETTING = pyqtSignal(str)
    SIGNAL_LIST_CASH = pyqtSignal(str)
    SIGNAL_COLLECT_CASH = pyqtSignal(str)
    SIGNAL_BOOKING_SEARCH = pyqtSignal(str)
    SIGNAL_RECREATE_PAYMENT = pyqtSignal(str)
    SIGNAL_ADMIN_KEY = pyqtSignal(str)
    SIGNAL_WALLET_CHECK = pyqtSignal(str)
    SIGNAL_GET_PRODUCT_STOCK = pyqtSignal(str)
    SIGNAL_STORE_TRANSACTION = pyqtSignal(str)
    SIGNAL_GET_TOPUP_AMOUNT = pyqtSignal(str)
    SIGNAL_STORE_TOPUP = pyqtSignal(str)
    SIGNAL_GET_MACHINE_SUMMARY = pyqtSignal(str)
    SIGNAL_GET_PAYMENT_SETTING = pyqtSignal(str)
    SIGNAL_SYNC_ADS_CONTENT = pyqtSignal(str)
    SIGNAL_ADMIN_GET_PRODUCT_STOCK = pyqtSignal(str)


K_SIGNDLER = KioskSignalHandler()
LOGGER = logging.getLogger()


def get_kiosk_status():
    _Helper.get_pool().apply_async(kiosk_status)


def kiosk_status():
    # if _Helper.is_online(source='kiosk_status') is False:
    #     _Common.KIOSK_SETTING = _DAO.init_kiosk()[0]
    #     _Common.KIOSK_ADMIN = _Common.KIOSK_SETTING['defaultAdmin']
    #     _Common.KIOSK_MARGIN = _Common.KIOSK_SETTING['defaultMargin']
    #     _Common.KIOSK_NAME = _Common.KIOSK_SETTING['name']
    #     _Common.KIOSK_REAL_STATUS = 'OFFLINE'
    K_SIGNDLER.SIGNAL_GET_KIOSK_STATUS.emit(json.dumps({
        'name': _Common.KIOSK_NAME,
        'version': _Common.VERSION,
        'status': _Common.KIOSK_STATUS,
        'real_status': _Common.KIOSK_STATUS,
        'tid': _Common.TID,
        # 'payment': _Common.PAYMENT_SETTING,
        'feature': _Common.FEATURE_SETTING,
        'last_money_inserted': _ConfigParser.get_value('GRG', 'last^money^inserted')
    }))


def load_from_temp_data(section, selected_mode):
    return _Common.load_from_temp_data(temp=section, mode=selected_mode)


def load_previous_kiosk_status():
    _Common.KIOSK_SETTING = _DAO.init_kiosk()[0]
    _Common.KIOSK_ADMIN = int(_Common.KIOSK_SETTING['defaultAdmin'])
    _Common.KIOSK_MARGIN = int(_Common.KIOSK_SETTING['defaultMargin'])
    _Common.KIOSK_NAME = _Common.KIOSK_SETTING['name']
    _Common.TOPUP_AMOUNT_SETTING = load_from_temp_data('topup-amount-setting', 'json')
    _Common.FEATURE_SETTING = load_from_temp_data('feature-setting', 'json')
    _Common.PAYMENT_SETTING = load_from_temp_data('payment-setting', 'json')
    _Common.REFUND_SETTING = load_from_temp_data('refund-setting', 'json')
    _Common.THEME_SETTING = load_from_temp_data('theme-setting', 'json')
    _Common.ADS_SETTING = load_from_temp_data('ads-setting', 'json')
    _Common.KIOSK_STATUS = 'OFFLINE'


def update_kiosk_status(s=400, r=None):
    try:
        if s == 200 and r['result'] == 'OK':
            if 'data' in r.keys() and not _Common.empty(r['data']):
                _Common.KIOSK_SETTING = r['data']['kiosk']
                _Common.KIOSK_NAME = _Common.KIOSK_SETTING['name']
                _Common.KIOSK_MARGIN = int(_Common.KIOSK_SETTING['defaultMargin'])
                _Common.KIOSK_ADMIN = int(_Common.KIOSK_SETTING['defaultAdmin'])
                _Common.PAYMENT_SETTING = r['data']['payment']
                define_device_port_setting(_Common.PAYMENT_SETTING)
                _Common.store_to_temp_data('payment-setting', json.dumps(r['data']['payment']))
                _Common.THEME_SETTING = r['data']['theme']
                define_theme(_Common.THEME_SETTING)
                _Common.FEATURE_SETTING = r['data']['feature']
                define_feature(_Common.FEATURE_SETTING)
                _Common.ADS_SETTING = r['data']['ads']
                _Common.store_to_temp_data('ads-setting', json.dumps(r['data']['ads']))
                # TODO: Check New Refund Data Setting
                if 'refund' in r['data'].keys():
                    _Common.REFUND_SETTING = r['data']['refund']
                    _Common.store_to_temp_data('refund-setting', json.dumps(r['data']['refund']))
                _Common.KIOSK_STATUS = 'ONLINE'
                _DAO.flush_table('Terminal')
                # _DAO.flush_table('Transactions', ' tid <> "' + KIOSK_SETTING['tid'] + '"')
                _DAO.update_kiosk_data(_Common.KIOSK_SETTING)
    except Exception as e:
        LOGGER.warning((e))
        load_previous_kiosk_status() 
    # finally:
    #     sleep(10)
    #     kiosk_status()
    #     pprint(_Common.KIOSK_SETTING)


def define_feature(d):
    _Common.store_to_temp_data('feature-setting', json.dumps(d))
    if 'multiple_card_shop' in d.keys():
        _ConfigParser.set_value('CD', 'multiple^eject', str(d['multiple_card_shop']))
    if 'search_trx' in d.keys():
        _Common.log_to_temp_config('search^trx', str(d['search_trx']))
    if 'whatsapp_voucher' in d.keys():
        _Common.log_to_temp_config('wa^voucher', str(d['whatsapp_voucher']))


def define_device_port_setting(data):
    '''
    [
        {"description": "CASH", "config": "COM2", "payment_method_id": 1, "status": "1", "name": "cash", "tid": "110322"}, 
        {"description": "CARD", "config": "COM3", "payment_method_id": 2, "status": "1", "name": "card", "tid": "110322"}, 
        {"description": "QR OVO", "config": "COM4", "payment_method_id": 4, "status": "1", "name": "ovo", "tid": "110322"}, 
        {"description": "QR LINKAJA", "config": "COM5", "payment_method_id": 7, "status": "1", "name": "linkaja", "tid": "110322"}
        ]
    ''' 
    if _Common.empty(data) is True:
        LOGGER.warning(('EMPTY_DATA_PAYMENT'))
        return
    for c in data: # QR No Need To Store in setting file
        if c['name'] == 'cash':
            _ConfigParser.set_value('GRG', 'port', c['config'])
        if c['name'] == 'card':
            _ConfigParser.set_value('EDC', 'port', c['config'])
        if c['name'] == 'prepaid':
            _ConfigParser.set_value('QPROX', 'port', c['config'])


def define_theme(d):
    _Common.store_to_temp_data('theme-setting', json.dumps(d))
    _Common.THEME_NAME = d['name']
    _Common.log_to_temp_config('theme^name', d['name'])
    config_js = sys.path[0] + '/_qQml/config.js'
    content_js = ''
    # Mandiri Update Schedule Time For Timer Trigger
    daily_settle_time = _ConfigParser.get_set_value('QPROX', 'mandiri^daily^settle^time', '02:00')
    content_js += 'var mandiri_update_schedule = "' + daily_settle_time + '";' + os.linesep
    edc_daily_settle_time = _ConfigParser.get_set_value('EDC', 'daily^settle^time', '23:00')
    content_js += 'var edc_settlement_schedule = "' + edc_daily_settle_time + '";' + os.linesep
    # Temp Config For Ubal Online
    content_js += 'var bank_ubal_online = ' + json.dumps(_Common.ALLOWED_BANK_UBAL_ONLINE) + ';' + os.linesep
    if type(d['master_logo']) != list:
        d['master_logo'] = [d['master_logo']]
    master_logo = []
    for m in d['master_logo']:
        download, image = _NetworkAccess.item_download(m, os.getcwd() + '/_qQml/source/logo')
        if download is True:
            master_logo.append(image)
        else:
            continue
    content_js += 'var master_logo = ' + json.dumps(master_logo) + ';' + os.linesep
    partner_logos = []
    for p in d['partner_logos']:
        download, image = _NetworkAccess.item_download(p, os.getcwd() + '/_qQml/source/logo')
        if download is True:
            partner_logos.append(image)
        else:
            continue
    content_js += 'var partner_logos = ' + json.dumps(partner_logos) + ';' + os.linesep
    backgrounds = []
    for b in d['backgrounds']:
        download, image = _NetworkAccess.item_download(b, os.getcwd() + '/_qQml/source/background')
        if download is True:
            backgrounds.append(image)
        else:
            continue
    content_js += 'var backgrounds = ' + json.dumps(backgrounds) + ';' + os.linesep
    # Running Text
    if not _Common.empty(d['running_text']):
        content_js += 'var running_text = "' + d['running_text'] + '";' + os.linesep
    # Running Text Color
    if not _Common.empty(d['running_text_color']):
        content_js += 'var running_text_color = "' + d['running_text_color'] + '";' + os.linesep
        content_js += 'var text_color = "' + _Common.COLOR_TEXT + '";' + os.linesep
        content_js += 'var frame_color = "' + d['frame_color'] + '";' + os.linesep
        content_js += 'var background_color = "' +  _Common.COLOR_BACK + '";' + os.linesep
    # Receipt tvc_waiting_time
    if not _Common.empty(d['tvc_waiting_time']):
        _Common.log_to_temp_config('tvc^waiting^time', str(d['tvc_waiting_time']))
        content_js += 'var tvc_waiting_time = ' +  str(d['tvc_waiting_time']) + ';' + os.linesep
    # Receipt Logo
    if not _Common.empty(d['receipt_custom_text']):
        _Common.CUSTOM_RECEIPT_TEXT = d['receipt_custom_text'].replace(os.linesep, '|')
        _Common.log_to_config('PRINTER', 'receipt^custom^text', d['receipt_custom_text'])
    store, receipt_logo = _NetworkAccess.item_download(d['receipt_logo'], os.getcwd() + '/_rReceipts')
    if store is True:
        _Common.RECEIPT_LOGO = receipt_logo
        _Common.log_to_config('PRINTER', 'receipt^logo', receipt_logo)
    with open(config_js, 'w+') as config_qml:
        config_qml.write(content_js)
        config_qml.close()
    LOGGER.info((config_js, content_js))


def start_define_ads(wait_for=5):
    sleep(wait_for)
    _Helper.get_pool().apply_async(define_ads, (_Common.ADS_SETTING, ))


def define_ads(a):
    if a is None or len(a) == 0:
        LOGGER.warning(("define_ads : ", 'Missing ADS_SETTING'))
        K_SIGNDLER.SIGNAL_SYNC_ADS_CONTENT.emit('SYNC_ADS|MISSING_ADS_SETTING')
        return False
    __metadata = a['metadata']
    __playlist = a['playlist']
    __tvc_path = sys.path[0] + '/_vVideo'
    __tvc_backup = sys.path[0] + '/_tTmp'
    if not os.path.exists(__tvc_path):
        os.makedirs(__tvc_path)
    __current_list = []
    __all_file = os.listdir(__tvc_path)
    for file in __all_file:
        extentions = ('.mp4', '.mov', '.avi', '.mpg', '.mpeg')
        if file.endswith(extentions):
            __current_list.append(file)
    __must_backup = list(set(__current_list) - set(__playlist))
    LOGGER.debug(("current list : ", str(__current_list)))
    LOGGER.debug(("new playlist : ", str(__playlist)))
    LOGGER.debug(("expired media(s) : ", str(__must_backup)))
    # __must_delete = __current_list
    # _Helper.dump(__must_delete)
    if len(__must_backup) > 0:
        for d in __must_backup:
            file_expired = os.path.join(__tvc_path, d)
            file_backup = os.path.join(__tvc_backup, d)
            if os.path.exists(file_expired):
                LOGGER.debug(("backup expired media : ", file_expired))
                K_SIGNDLER.SIGNAL_SYNC_ADS_CONTENT.emit('SYNC_ADS|BACKUP_EXPIRED_'+d.upper())
                shutil.copy(file_expired, file_backup)
                os.remove(file_backup)
    __must_download = list(set(__playlist) - set(__current_list))
    while len(__must_download) > 0:
        for l in __must_download:
            media_link = get_metadata_link(l, __metadata)
            LOGGER.debug(("add new media : ", media_link))
            K_SIGNDLER.SIGNAL_SYNC_ADS_CONTENT.emit('SYNC_ADS|ADD_NEW_'+l.upper())
            if media_link is not False:
                stream, media = _NetworkAccess.stream_large_download(media_link, l, _Common.TEMP_FOLDER, __tvc_path)
                if stream is True:
                    __must_download.remove(l)
    K_SIGNDLER.SIGNAL_SYNC_ADS_CONTENT.emit('SYNC_ADS|SUCCESS')
    return True


def get_metadata_link(media, data):
    if len(data) == 0 or media is None:
        return False
    for x in range(len(data)):
        if media == data[x]['name']:
            return data[x]['path']
    return False


def get_kiosk_price_setting():
    _Helper.get_pool().apply_async(kiosk_price_setting)


def kiosk_price_setting():
    K_SIGNDLER.SIGNAL_PRICE_SETTING.emit(json.dumps({
        'margin': _Common.KIOSK_MARGIN,
        'adminFee': _Common.KIOSK_ADMIN,
        'cancelAble': _Common.PAYMENT_CANCEL,
        'confirmAble': _Common.PAYMENT_CONFIRM
    }))


def development_status():
    return True if _ConfigParser.get_value('TERMINAL', 'server') == "dev" else False


IS_DEV = _Common.TEST_MODE


def rename_file(filename, list_, x):
    for char in list_:
        filename = filename.replace(char, x)
    return filename


def force_rename(file1, file2):
    from shutil import move
    try:
        move(file1, file2)
        return True
    except Exception as e:
        LOGGER.warning((file1, file2, str(e)))
        return False


def get_gui_version():
    _Helper.get_pool().apply_async(gui_version)


def gui_version():
    K_SIGNDLER.SIGNAL_GET_GUI_VERSION.emit(_Common.VERSION)


def get_kiosk_name():
    _Helper.get_pool().apply_async(kiosk_name)


def kiosk_name():
    K_SIGNDLER.SIGNAL_GET_KIOSK_NAME.emit(_Common.KIOSK_NAME)


def update_machine_stat(_url):
    _param = machine_summary()
    LOGGER.info(( _url, str(_param)))
    s, r = _NetworkAccess.post_to_url(url=_url, param=_param)
    return True if s == 200 and r['result'] == 'OK' else False


ERROR_PRINTER = {
    16: 'OUT_OF_PAPER'
}

COMP = None
LAST_SYNC = 'OFFLINE'


def kiosk_get_machine_summary():
    _Helper.get_pool().apply_async(get_machine_summary)

# SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE isCollected = 0

def get_machine_summary():
    try:
        result = machine_summary()
        result['total_trx'] = _DAO.get_total_count('Transactions')
        result['today_trx'] = _DAO.get_total_count('Transactions',
                                                   ' strftime("%Y-%m-%d", datetime(createdAt/1000, "unixepoch")) = '
                                                   'date("now") ')
        result['cash_trx'] = _DAO.get_total_count('Transactions', ' paymentType = "MEI" ')
        result['edc_trx'] = _DAO.get_total_count('Transactions', ' paymentType = "EDC" ')
        result['edc_not_settle'] = _DAO.custom_query(' SELECT IFNULL(SUM(amount), 0) AS __ FROM Settlement '
                                                     'WHERE status="EDC|OPEN" ')[0]['__']
        result['cash_available'] = _DAO.custom_query(' SELECT IFNULL(SUM(amount), 0) AS __  FROM Cash '
                                                     'WHERE collectedAt is null ')[0]['__']
        LOGGER.info(('SUCCESS', str(result)))
        K_SIGNDLER.SIGNAL_GET_MACHINE_SUMMARY.emit(json.dumps(result))
    except Exception as e:
        LOGGER.warning(('FAILED', str(e)))


def machine_summary():
    global COMP
    summary = {
        'c_space': '10000',
        'd_space': '10000',
        'ram_space': '2000',
        'cpu_temp': '33',
        'paper_printer': 'NORMAL',
        'gui_version': '1.0',
        'on_usage': 'IDLE',
        'edc_error': _Common.EDC_ERROR,
        'nfc_error': _Common.NFC_ERROR,
        'mei_error': _Common.BILL_ERROR,
        'printer_error': _Common.PRINTER_ERROR,
        'scanner_error': _Common.SCANNER_ERROR,
        'webcam_error': _Common.WEBCAM_ERROR,
        'cd1_error': _Common.CD1_ERROR,
        'cd2_error': _Common.CD2_ERROR,
        'cd3_error': _Common.CD3_ERROR,
        'mandiri_wallet': str(_Common.MANDIRI_ACTIVE_WALLET),
        'bni_wallet': str(_Common.BNI_ACTIVE_WALLET),
        'bri_wallet': str(_Common.BRI_WALLET),
        'bca_wallet': str(_Common.BCA_WALLET),
        'dki_wallet': str(_Common.DKI_WALLET),
        'last_sync': str(LAST_SYNC),
        'online_status': str(_Common.KIOSK_STATUS),
        'mandiri_active': str(_Common.MANDIRI_ACTIVE),
        'bni_active': str(_Common.BNI_ACTIVE),
        'service_ver': str(_Common.SERVICE_VERSION),
        'theme': str(_Common.THEME_NAME),
        'last_money_inserted': _ConfigParser.get_set_value('GRG', 'last^money^inserted', 'N/A')
        # 'bni_sam1_no': str(_Common.BNI_SAM_1_NO),
        # 'bni_sam2_no': str(_Common.BNI_SAM_2_NO),
    }
    try:
        pythoncom.CoInitialize()
        COMP = wmi.WMI()
        summary['gui_version'] = _Common.VERSION
        summary["c_space"] = get_disk_space("C:")
        summary["d_space"] = get_disk_space("D:")
        summary["ram_space"] = get_ram_space()
        summary['paper_printer'] = get_printer_status_v2()
    except Exception as e:
        LOGGER.warning(('FAILED', str(e)))
    finally:
        return summary


def get_ram_space():
    try:
        ram_space = []
        for e in COMP.Win32_OperatingSystem():
            ram_space.append(int(e.FreePhysicalMemory.strip()) / 1024)
            return "%.2f" % ram_space[0]
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))
        return "%.2f" % -1


def get_disk_space(caption):
    try:
        d_space = []
        for d in COMP.Win32_LogicalDisk(Caption=caption):
            if d.FreeSpace is not None:
                d_space.append(int(d.FreeSpace.strip()) / 1024 / 1024)
                return "%.2f" % d_space[0]
            else:
                return "%.2f" % -1
    except Exception as e:
        LOGGER.warning(("FAILED", caption, str(e)))
        return "%.2f" % -1


def get_printer_status():
    try:
        printer = win32print.OpenPrinter(win32print.GetDefaultPrinter())
        printer_status = win32print.GetPrinter(printer)
        status = int(printer_status[18])
        # status = 16
        win32print.ClosePrinter(printer)
        if status == 0:
            return 'NORMAL'
        elif status == 16:
            return ERROR_PRINTER[status]
        else:
            return 'UNKNOWN_ERROR'
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))
        return 'NOT_DETECTED'


PRINTER_STATUS_CMD = os.path.join(sys.path[0], '_lLib', 'printer', 'printer.exe')


def get_printer_status_v2():
    try:
        command = PRINTER_STATUS_CMD + " status"
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
        output = output[0].split(";")
        response = json.loads(output[0])
        if response['Status'] == 0:
            if response['Online'] == 1:
                return 'NORMAL'
            else:
                return 'OFFLINE'
        else:
            return 'UNKNOWN_ERROR'
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))
        return 'UNKNOWN_ERROR'


def get_cpu_temp():
    variance = random.uniform(0.09, 1.09)
    common = 30
    try:
        pythoncom.CoInitialize()
        comp = wmi.WMI(namespace="root\wmi")
        cpu_temp = []
        for g in comp.MSAcpi_ThermalZoneTemperature():
            cpu_temp.append((int(g.CurrentTemperature) / 10) - 273.15 + variance)
            return "%.2f" % cpu_temp[0]
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))
        return "%.2f" % (common - variance)
    # return "%.2f" % (common - variance)


def execute_command(command):
    _Helper.execute_console(command)


def post_gui_version():
    _Helper.get_pool().apply_async(gui_info)


def gui_info():
    try:
        # NO-NEED Budled with Kiosk Status
        status, response = _NetworkAccess.post_to_url('box/guiInfo', {"gui_version": str(_Common.VERSION)})
        LOGGER.info(('SUCCESS', str(status), str(response)))
    except Exception as e:
        LOGGER.warning(('FAILED', str(e)))


def get_file_list(dir_):
    _Helper.get_pool().apply_async(file_list, (dir_,))


def file_list(dir_):
    if _Common.empty(dir_):
        LOGGER.warning((dir_, 'MISSING_DIRECTORY'))
        return
    ext_files = '.*'
    if "Video" in str(dir_):
        ext_files = ('.mp4', '.mov', '.avi', '.mpg', '.mpeg')
    elif "Image" in str(dir_):
        ext_files = ('.png', '.jpeg', '.jpg')
    elif "Music" in str(dir_):
        ext_files = ('.mp3', '.ogg', '.wav')
    _dir_ = dir_.replace(".", "")
    try:
        files = {
            "result": [x for x in os.listdir(sys.path[0] + _dir_) if x.endswith(ext_files)],
            "dir": dir_
        }
        if "Video" in str(dir_):
            # files["old_result"] = files["result"]
            files["playlist"] = _Common.ADS_SETTING['playlist']
            files["count"] = len(files["result"])
        LOGGER.info((_dir_, str(files)))
        K_SIGNDLER.SIGNAL_GET_FILE_LIST.emit(json.dumps(files))
    except Exception as e:
        K_SIGNDLER.SIGNAL_GET_FILE_LIST.emit("ERROR")
        LOGGER.warning((_dir_, str(e)))


def post_tvc_list(list_):
    if list_ is None or list_ == "":
        return
    try:
        #NOTES: NO NEED, PLAYLIST FROM SERVER ALREADY
        status, response = _NetworkAccess.post_to_url('box/tvcList', {"tvclist": list_})
        LOGGER.info(('SUCCESS', response))
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))


def post_tvc_log(media):
    _Helper.get_pool().apply_async(update_tvc_log, (media,))


def update_tvc_log(media):
    # Function to update the media count locally and keep it for on hour
    if media not in _Common.ADS_SETTING['playlist']:
        LOGGER.debug((media, str(_Common.ADS_SETTING['playlist']), 'MEDIA_NOT_FOUND_IN_PLAYLIST'))
        return
    media_code = '___'+media.replace(' ', '^')
    # _Helper.dump(media_code)
    media_today_path = sys.path[0]+'/_tTmp/'+media_code+'/'+time.strftime("%Y-%m-%d")+'.count'
    # _Helper.dump(media_today_path)
    if not os.path.isdir(sys.path[0]+'/_tTmp/'+media_code):
        os.mkdir(sys.path[0]+'/_tTmp/'+media_code, 777)
    if not os.path.exists(media_today_path):
        count = 1
        with open(media_today_path, 'w+') as c:
            c.write(str(count))
            c.close()
    else:
        last_count = int(open(media_today_path, 'r').read().strip())
        count = last_count + 1
        with open(media_today_path, 'w') as c:
            c.write(str(count))
            c.close()
    last_update_media = int(_ConfigParser.get_set_value('TEMPORARY', media_code, '0'))
    if (last_update_media + (60 * 60 * 1000)) > _Helper.now():
        LOGGER.debug((media, str(count), str(last_update_media), 'SKIP_NEXT_LOOP'))
        return
    else:
        send_tvc_log(media, count, media_code)


def send_tvc_log(media, count, media_code=None):
    if _Common.empty(media):
        LOGGER.warning((media, str(count), 'MISSING_MEDIA_NAME'))
        return
    if _Common.empty(count):
        LOGGER.warning((media, str(count), 'MISSING_MEDIA_COUNT'))
        return
    if media_code is None or media_code[:3] != '___':
        # media_code = media.replace(' ', '^')
        media_code = '___'+media.replace(' ', '^')
    param = {
        "media": media,
        "count": str(count),
        "date": time.strftime("%Y-%m-%d")
    }
    try:
        status, response = _NetworkAccess.post_to_url(_Common.BACKEND_URL+'count/ads', param)
        _Common.log_to_temp_config(media_code, str(_Helper.now()))
        # Not Handling Response Result
        LOGGER.info((media, str(count), status, response))
    except Exception as e:
        LOGGER.warning((media, str(count), str(e)))


def start_get_payments():
    _Helper.get_pool().apply_async(get_payments)


def get_payments():
    K_SIGNDLER.SIGNAL_GET_PAYMENTS.emit(json.dumps(_Common.get_payments()))


def start_get_refunds():
    _Helper.get_pool().apply_async(get_refunds)


def get_refunds():
    K_SIGNDLER.SIGNAL_GET_REFUNDS.emit(json.dumps(_Common.get_refunds()))


FIRST_RUN_FLAG = True


def start_restart_mdd_service():
    global FIRST_RUN_FLAG
    if FIRST_RUN_FLAG is True:
        _Helper.get_pool().apply_async(restart_mdd_service)
        FIRST_RUN_FLAG = False


def restart_mdd_service():
    os.system('powershell restart-service MDDTopUpService -force')
    # process = subprocess.run('powershell restart-service MDDTopUpService -force', shell=True, stdout=subprocess.PIPE)
    # output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
    # # LOGGER.info(('[INFO] restart_mdd_service result : ', str(output)))
    # print("pyt : ", output)


def start_get_cash_data():
    _Helper.get_pool().apply_async(list_uncollected_cash)


def list_uncollected_cash():
    list_cash = _DAO.list_uncollected_cash()
    if len(list_cash) == 0:
        K_SIGNDLER.SIGNAL_LIST_CASH.emit('ZERO')
        return
    response = {
        'total': len(list_cash),
        'data': list_cash
    }
    K_SIGNDLER.SIGNAL_LIST_CASH.emit(json.dumps(response))
    LOGGER.info(('SUCCESS', json.dumps(response)))


def start_begin_collect_cash():
    _Helper.get_pool().apply_async(begin_collect_cash)


def begin_collect_cash():
    # Add GRG Device Reset Function
    # if _Common.GRG['status'] is True:
    #     LOGGER.info(('begin_collect_cash', 'call init_grg'))
    #     _GRG.init_grg()
    list_cash = _DAO.list_uncollected_cash()
    if len(list_cash) == 0:
        K_SIGNDLER.SIGNAL_COLLECT_CASH.emit('COLLECT_CASH|NOT_FOUND')
        return
    operator = 'OPERATOR'
    if _UserService.USER is not None:
        operator = _UserService.USER['first_name']
    list_collect = []
    for cash in list_cash:
        param = {
            'csid': cash['csid'],
            'collectedAt': 19900901,
            'collectedUser': operator
        }
        _DAO.collect_cash(param)
        list_collect.append(cash['csid'])
    post_cash_collection(list_collect, _Helper.now())
    K_SIGNDLER.SIGNAL_COLLECT_CASH.emit('COLLECT_CASH|DONE')


def post_cash_collection(l, t):
    try:
        operator = 'OPERATOR'
        if _UserService.USER is not None:
            operator = _UserService.USER['first_name']
        param = {
            "csid": '|'.join(l),
            "user": operator,
            "updatedAt": t
        }
        status, response = _NetworkAccess.post_to_url(_Common.BACKEND_URL + 'collect/cash', param)
        if status == 200:
            LOGGER.info(("SUCCESS", response))
        else:
            # LOG REQUEST
            _Common.store_request_to_job(name=_Helper.whoami(), url=_Common.BACKEND_URL + 'collect/cash', payload=param)
    except Exception as e:
        LOGGER.warning(("FAILED", str(e)))


def start_adjust_table(p):
    _Helper.get_pool().apply_async(adjust_table, (p,))


def adjust_table(p, t='Receipts'):
    try:
        try:
            count_table = _DAO.check_table({'table': t})
            LOGGER.info(('Count Table ', t, str(count_table)))
        except Exception as e:
            LOGGER.info(('Table Not Found, ', e, 'Adjusting : ', p))
            _DAO.adjust_table(p)
    except Exception as e:
        LOGGER.warning(('FAILED', str(e), t))


def start_alter_table(a):
    _Helper.get_pool().apply_async(alter_table, (a,))


def alter_table(a):
    try:
        _DAO.adjust_table(a)
    except Exception as e:
        LOGGER.debug(('FAILED', str(e)))


def start_direct_alter_table(s):
    _Helper.get_pool().apply_async(direct_alter_table, (s,))


def direct_alter_table(scripts):
    result = []
    if _Common.empty(scripts):
        LOGGER.warning(('EMPTY ADJUSTMENT SCRIPT'))
        return
    if type(scripts) == list and len(scripts) > 0:
        for script in scripts:
            result.append({'script': script, 'result': _DAO.direct_adjust_table(script=script)})
    else:
        result.append({'script': scripts, 'result': _DAO.direct_adjust_table(script=scripts)})
    LOGGER.info(('RESULT', str(result)))
    return result


TID = _Common.TID


def start_get_admin_key():
    _Helper.get_pool().apply_async(get_admin_key)


def get_admin_key():
    salt = datetime.datetime.now().strftime("%Y%m%d")
    K_SIGNDLER.SIGNAL_ADMIN_KEY.emit(_Common.TID+salt)


def start_check_wallet(amount):
    _Helper.get_pool().apply_async(check_wallet, (amount,))


def check_wallet(amount):
    try:
        param = {"amount": int(amount)}
        status, response = _NetworkAccess.post_to_url(_Common.BACKEND_URL + 'task/check-wallet', param)
        LOGGER.info((response))
        if status == 200 and response is not None:
            K_SIGNDLER.SIGNAL_WALLET_CHECK.emit(json.dumps(response))
        else:
            K_SIGNDLER.SIGNAL_WALLET_CHECK.emit('ERROR')
    except Exception as e:
        LOGGER.warning((e))
        K_SIGNDLER.SIGNAL_WALLET_CHECK.emit('ERROR')


def kiosk_get_product_stock():
    _Helper.get_pool().apply_async(get_product_stock, )


def get_product_stock():
    stock = []
    try:
        check_stock = _DAO.get_product_stock()
        check_stock = sorted(check_stock, key=itemgetter('status'))
        if len(check_stock) > 0:
            stock = check_stock
            for s in stock:
                s['image'] = ''
                if '|' in s['remarks']:
                    s['image'] = s['remarks'].split('|')[1]
                    if 'source/card/' not in s['remarks'].split('|')[1]:
                        s['image'] = 'source/card/' + s['remarks'].split('|')[1]
                    s['remarks'] = s['remarks'].split('|')[0]
        LOGGER.debug((str(stock)))
        K_SIGNDLER.SIGNAL_GET_PRODUCT_STOCK.emit(json.dumps(stock))
        return True
    except Exception as e:
        LOGGER.warning((e))
        K_SIGNDLER.SIGNAL_GET_PRODUCT_STOCK.emit(json.dumps(stock))
        return False


def start_store_transaction_global(param):
    _Helper.get_pool().apply_async(store_transaction_global, (param,))


GLOBAL_TRANSACTION_DATA = None

# '{"date":"Thursday, March 07, 2019","epoch":1551970698740,"payment":"cash","shop_type":"shop","time":"9:58:18 PM",
# "qty":4,"value":"3000","provider":"Kartu Prabayar","raw":{"init_price":500,"syncFlag":1,"createdAt":1551856851000,
# "stock":99,"pid":"testprod001","name":"Test Product","status":1,"sell_price":750,"stid":"stid001",
# "remarks":"TEST STOCK PRODUCT"},"notes":"DEBUG_TEST - 1551970698879"}'
# '{"date":"Thursday, March 07, 2019","epoch":1551970911009,"payment":"debit","shop_type":"topup","time":"10:01:51 PM",
# "qty":1,"value":"50000","provider":"e-Money Mandiri","raw":{"provider":"e-Money Mandiri","value":"50000"},
# "notes":"DEBUG_TEST - 1551970911187"}')


def get_tpid(string):
    param = {'string': string}
    t = _DAO.get_tpid(param)
    _tpid = t[0]['tpid']
    print('pyt: get transactionType code : ', _tpid)
    return _tpid


def get_payment(string):
    if string == 'debit' or string == 'credit':
        return 'EDC'
    elif string == 'cash':
        return 'MEI'


MEI_HISTORY = ''
CARD_NO = ''
TRX_ID_SALE = ''
PID_SALE = ''
PID_STOCK_SALE = ''


def retry_store_transaction_global():
    _param = json.dumps(GLOBAL_TRANSACTION_DATA)
    _retry = True
    _Helper.get_pool().apply_async(store_transaction_global, (_param, _retry,))


def start_direct_store_transaction_data(payload):
    _Helper.get_pool().apply_async(direct_store_transaction_data, (payload,))


def direct_store_transaction_data(payload):
    global GLOBAL_TRANSACTION_DATA
    GLOBAL_TRANSACTION_DATA = json.loads(payload)


def store_transaction_global(param, retry=False):
    global GLOBAL_TRANSACTION_DATA, TRX_ID_SALE, PID_SALE, CARD_NO, PID_STOCK_SALE
    g = GLOBAL_TRANSACTION_DATA = json.loads(param)
    LOGGER.info(('GLOBAL_TRANSACTION_DATA', param))
    try:
        __pid = PID_SALE = g['shop_type'] + str(g['epoch'])
        # _______________________________________________________________________________________________________
        if retry is False:
            _trxid = TRX_ID_SALE = _Helper.get_uuid()
            # If TRX Failure/Payment Error Detected
            if 'payment_error' in g.keys():
                if g['shop_type'] == 'shop':
                    PID_SALE = g['raw']['pid']
                g['pid'] = __pid
                g['trxid'] = _trxid
                if g['payment'] == 'cash':
                    # Saving The CASH
                    _GRG.log_book_cash(PID_SALE, g['payment_received'], 'cancel')
                    # save_cash_local(g['payment_received'], 'cancel')
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('PAYMENT_FAILED_CANCEL_TRIGGERED')
                # Must Stop The Logic Here
                return
            _total_price = int(g['value']) * int(g['qty'])
            _param = {
                'pid': __pid,
                'name': g['provider'],
                'price': _total_price,
                'details': param,
                'status': 1
            }
            check_prod = _DAO.check_product(__pid)
            if len(check_prod) == 0:
                _DAO.insert_product(_param)
            status, response = _NetworkAccess.post_to_url(url=_Common.BACKEND_URL + 'sync/product', param=_param)
            if status == 200 and response['id'] == _param['pid']:
                _param['key'] = _param['pid']
                _DAO.mark_sync(param=_param, _table='Product', _key='pid')
            K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|STORE_PRODUCT-'+_param['pid'])
            if g['payment'] == 'cash':
                # Saving The CASH
                # save_cash_local(g['payment_received'])
                _GRG.log_book_cash(PID_SALE, g['payment_received'], 'cancel')

        # _______________________________________________________________________________________________________
        _param_stock = dict()
        _trxid = TRX_ID_SALE
        _param = {
            'pid': __pid,
            'name': g['provider'],
            'price': int(g['value']),
            'details': param,
            'status': 1
        }
        if g['shop_type'] == 'shop':
            PID_STOCK_SALE = g['raw']['pid']
            _param_stock = {
                'pid': PID_STOCK_SALE,
                'stock': int(g['raw']['stock']) - int(g['qty'])
            }
            _DAO.update_product_stock(_param_stock)
            K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|UPDATE_PRODUCT_STOCK-' + _param_stock['pid'])
            __pid = str(__pid) + '|' + str(_param_stock['pid']) + '|' + str(_param_stock['stock'])
        __notes = json.dumps(g['payment_details'])
        __total_price = int(g['value']) * int(g['qty'])
        __param = {
            'trxid': _trxid,
            'tid': TID,
            'mid': '',
            'pid': __pid,
            'tpid': '',
            'sale': __total_price,
            'amount': __total_price,
            'cardNo': g['payment_details'].get('card_no', ''),
            'paymentType': get_payment(g['payment']),
            'paymentNotes': __notes,
            'isCollected': 0,
            'pidStock': PID_STOCK_SALE if g['shop_type'] == 'shop' else ''
        }
        g['pid'] = PID_SALE
        g['trxid'] = _trxid
        check_trx = _DAO.check_trx(_trxid)
        if len(check_trx) == 0:
            _DAO.insert_transaction(__param)
            K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|STORE_TRX-' + _trxid)
            __param['createdAt'] = _Helper.now()
            status, response = _NetworkAccess.post_to_url(url=_Common.BACKEND_URL + 'sync/transaction-topup', param=__param)
            if status == 200 and response['id'] == __param['trxid']:
                __param['key'] = __param['trxid']
                _DAO.mark_sync(param=__param, _table='Transactions', _key='trxid')
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|UPLOAD_TRX-' + _trxid)
            else:
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('PENDING|UPLOAD_TRX-' + _trxid)
    except Exception as e:
        LOGGER.warning((str(retry), str(e)))
        K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('ERROR')
    # finally:
    #     MEI_HISTORY = ''
    #     CARD_NO = ''


def start_kiosk_get_topup_amount():
    _Helper.get_pool().apply_async(kiosk_get_topup_amount)


def kiosk_get_topup_amount():
    LOGGER.info((str(_Common.TOPUP_AMOUNT_SETTING)))
    K_SIGNDLER.SIGNAL_GET_TOPUP_AMOUNT.emit(json.dumps(_Common.TOPUP_AMOUNT_SETTING))


def start_kiosk_get_payment_setting():
    _Helper.get_pool().apply_async(kiosk_get_payment_setting)


def kiosk_get_payment_setting():
    # LOGGER.info((str(_Common.PAYMENT_SETTING)))
    K_SIGNDLER.SIGNAL_GET_PAYMENT_SETTING.emit(json.dumps(_Common.PAYMENT_SETTING))


def start_store_topup_transaction(param):
    _Helper.get_pool().apply_async(store_topup_transaction, (param,))

# '{"date":"Thursday, March 07, 2019","epoch":1551970911009,"payment":"debit","shop_type":"topup","time":"10:01:51 PM",
# "qty":1,"value":"50000","provider":"e-Money Mandiri","raw":{"provider":"e-Money Mandiri","value":"50000"},
# "topup_details": { 'last_balance': _result.split('|')[0], 'report_sam': _result.split('|')[1], 'report_ka': _result.split('|')[2],
# 'card_no': _result.split('|')[3], 'bank_id': '1', 'bank_name': 'MANDIRI', }')


def store_topup_transaction(param):
    global GLOBAL_TRANSACTION_DATA
    try:
        p = json.loads(param)
        GLOBAL_TRANSACTION_DATA['topup_details'] = p['topup_details']
        _param = {
            'rid': _Helper.get_uuid(),
            'trxid': TRX_ID_SALE,
            'cardNo': p['topup_details']['card_no'],
            'balance': p['topup_details']['last_balance'],
            'reportSAM': p['topup_details']['report_sam'],
            'reportKA': p['topup_details']['report_ka'],
            'status': 1,
            'remarks': param
        }
        _DAO.insert_topup_record(_param)
        _param['createdAt'] = _Helper.now()
        status, response = _NetworkAccess.post_to_url(url=_Common.BACKEND_URL + 'sync/topup-records', param=_param)
        LOGGER.info(('sync store_topup_transaction', str(_param), str(status), str(response)))
        if status == 200 and response['id'] == _param['rid']:
            _param['key'] = _param['rid']
            _DAO.mark_sync(param=_param, _table='TopUpRecords', _key='rid')
            K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|SUCCESS')
        else:
            K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|SUCCESS-SYNC-FAILED')
    except Exception as e:
        LOGGER.warning((e))
        K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|ERROR')


def reset_db_record():
    LOGGER.info(('START_RESET_DB_RECORDS', _Helper.time_string()))
    try:
        # _DAO.flush_table('TopUpRecords', ' tid <> "'+_Common.TID+'" ')
        # time.sleep(1)
        _DAO.flush_table('Receipts', ' tid <> "'+_Common.TID+'" ')
        time.sleep(1)
        _DAO.flush_table('Settlement', ' tid <> "'+_Common.TID+'" AND status NOT LIKE "%EDC%" ')
        time.sleep(1)
        _DAO.custom_update('UPDATE Settlement SET status = "EDC|VOID" WHERE status LIKE "%EDC%" AND tid <> "'+_Common.TID+'" ')
        time.sleep(1)
        _DAO.flush_table('Cash', ' tid <> "'+_Common.TID+'" ')
        # time.sleep(1)
        # _DAO.flush_table('Product')
        time.sleep(1)
        _DAO.flush_table('Transactions', ' tid <> "'+_Common.TID+'" ')
        time.sleep(1)
        _DAO.flush_table('TransactionFailure', ' tid <> "'+_Common.TID+'" ')
        # Add Data HouseKeeping Which Older Than n Months
        # house_keeping(age_month=3)
        LOGGER.info(('FINISH_RESET_DB_RECORDS', _Helper.time_string()))
        return 'FIRST_INIT_CLEANUP_SUCCESS'
    except Exception as e:
        LOGGER.warning((str(e)))
        return 'FIRST_INIT_CLEANUP_FAILED'


def user_action_log(log):
    LOGGER.info(('[USER_ACTION]', str(log)))


def python_dump(log):
    _Helper.dump(log)


def house_keeping(age_month=1, mode='DATA_FILES'):
    if mode == 'DATA_FILES':
        LOGGER.info(('START DATA HOUSE_KEEPING', age_month, mode, _Helper.time_string()))
        print('pyt: START DATA HOUSE_KEEPING ' + mode + ' ' +_Helper.time_string())
        _DAO.clean_old_data(tables=['Cash', 'Receipts', 'Settlement', 'Product', 'SAMAudit', 'SAMRecords',
                                    'TopupRecords', 'TransactionFailure', 'Transactions'],
                            key='createdAt',
                            age_month=age_month)
    expired = time.time() - (age_month * 30 * 24 * 60 * 60)
    paths = ['_pPDF', '_lLog', '_qQr']
    LOGGER.info(('START FILES HOUSE_KEEPING', age_month, paths, expired, mode, _Helper.time_string()))
    print('pyt: START FILES HOUSE_KEEPING ' + str(paths) + ' ' + str(expired) + ' ' + mode + ' ' + _Helper.time_string())
    for path in paths:
        work_dir = os.path.join(sys.path[0], path)
        for f in os.listdir(work_dir):
            file = os.path.join(work_dir, f)
            if os.path.isfile(file):
                stat = os.stat(file)
                if stat.st_ctime < expired:
                    os.remove(file)
    LOGGER.info(('FINISH DATA/FILES HOUSE_KEEPING', age_month, mode, _Helper.time_string()))
    print('pyt: FINISH DATA/FILES HOUSE_KEEPING ' + mode + ' ' +_Helper.time_string())
    return 'HOUSE_KEEPING_' + str(age_month) + 'SUCCESS'
