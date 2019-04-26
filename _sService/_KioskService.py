__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
import os
import datetime
import time
import random
import sys
from PyQt5.QtCore import QObject, pyqtSignal
from _cConfig import _ConfigParser, _Global
from _dDAO import _DAO
from _tTools import _Tools
from _nNetwork import _NetworkAccess
from pprint import pprint
import win32print
import wmi
import pythoncom
from _sService import _UserService
from time import sleep
import subprocess
# from _dDevice import _GRG


class KioskSignalHandler(QObject):
    __qualname__ = 'KioskSignalHandler'
    SIGNAL_GET_GUI_VERSION = pyqtSignal(str)
    SIGNAL_GET_KIOSK_NAME = pyqtSignal(str)
    SIGNAL_GET_FILE_LIST = pyqtSignal(str)
    SIGNAL_GET_DEVICE_STAT = pyqtSignal(str)
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


K_SIGNDLER = KioskSignalHandler()
LOGGER = logging.getLogger()
VERSION = open(os.path.join(os.getcwd(), 'kiosk.ver'), 'r').read().strip()
KIOSK_NAME = "---"
KIOSK_STATUS = 'ONLINE'
KIOSK_SETTING = []
KIOSK_MARGIN = 3
KIOSK_ADMIN = 1500
PRINTER_STATUS = "NORMAL"
BACKEND_URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
PAYMENTCANCEL = _ConfigParser.get_set_value('TERMINAL', 'payment^cancel', '1')
PAYMENTCONFIRM = _ConfigParser.get_set_value('TERMINAL', 'payment^confirm', '0')
IS_PIR = True if _ConfigParser.get_set_value('TERMINAL', 'pir^usage', '0') == '1' else False


KIOSK_REAL_STATUS = 'ONLINE'


def get_kiosk_status():
    _Tools.get_pool().apply_async(kiosk_status)


def kiosk_status():
    global KIOSK_REAL_STATUS, KIOSK_NAME, KIOSK_ADMIN, KIOSK_SETTING, KIOSK_MARGIN
    if _Tools.is_online(source='kiosk_status') is False:
        KIOSK_SETTING = _DAO.init_kiosk()[0]
        KIOSK_ADMIN = KIOSK_SETTING['defaultAdmin']
        KIOSK_MARGIN = KIOSK_SETTING['defaultMargin']
        KIOSK_NAME = KIOSK_SETTING['name']
        KIOSK_REAL_STATUS = 'OFFLINE'
    K_SIGNDLER.SIGNAL_GET_KIOSK_STATUS.emit(json.dumps({
        'name': KIOSK_NAME,
        'version': VERSION,
        'status': KIOSK_STATUS,
        'real_status': KIOSK_REAL_STATUS,
        'tid': TID
    }))


def update_kiosk_status(r):
    global KIOSK_STATUS, KIOSK_SETTING, KIOSK_NAME, KIOSK_ADMIN, KIOSK_MARGIN, PRINTER_STATUS
    KIOSK_STATUS = 'UNAUTHORIZED'
    try:
        PRINTER_STATUS = get_printer_status_v2()
        LOGGER.info(("get_printer_status : ", PRINTER_STATUS))
        if len(r['data']) == 0:
            KIOSK_SETTING = _DAO.init_kiosk()[0]
            KIOSK_ADMIN = KIOSK_SETTING['defaultAdmin']
            KIOSK_MARGIN = KIOSK_SETTING['defaultMargin']
            KIOSK_NAME = KIOSK_SETTING['name']
            if PRINTER_STATUS == "NORMAL":
                KIOSK_STATUS = 'ONLINE'
        else:
            KIOSK_SETTING = r['data'][0]
            KIOSK_NAME = KIOSK_SETTING['name']
            KIOSK_MARGIN = int(KIOSK_SETTING['defaultMargin'])
            KIOSK_ADMIN = int(KIOSK_SETTING['defaultAdmin'])
            if r['result'] == 'OK' and PRINTER_STATUS == "NORMAL":
                KIOSK_STATUS = 'ONLINE'
            _DAO.flush_table('Terminal')
            _DAO.flush_table('Transactions', ' tid <> "' + KIOSK_SETTING['tid'] + '"')
            _DAO.update_kiosk_data(KIOSK_SETTING)
    except Exception as e:
        LOGGER.warning(("update_kiosk_status : ", str(e)))
    finally:
        kiosk_status()
        pprint(KIOSK_SETTING)


def get_kiosk_price_setting():
    _Tools.get_pool().apply_async(kiosk_price_setting)


def kiosk_price_setting():
    price_setting = {
        'margin': KIOSK_MARGIN,
        'adminFee': KIOSK_ADMIN,
        'cancelAble': PAYMENTCANCEL,
        'confirmAble': PAYMENTCONFIRM
    }
    K_SIGNDLER.SIGNAL_PRICE_SETTING.emit(json.dumps(price_setting))


def development_status():
    if _ConfigParser.get_value('TERMINAL', 'server') == "dev":
        return True
    else:
        LOGGER.info('Public live GUI is Running')
        return False


IS_DEV = development_status()


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
        LOGGER.warning(("force_rename : ", file1, file2, str(e)))
        return False


def get_gui_version():
    _Tools.get_pool().apply_async(gui_version)


def gui_version():
    K_SIGNDLER.SIGNAL_GET_GUI_VERSION.emit(VERSION)


def get_kiosk_name():
    _Tools.get_pool().apply_async(kiosk_name)


def kiosk_name():
    K_SIGNDLER.SIGNAL_GET_KIOSK_NAME.emit(KIOSK_NAME)


def update_machine_stat(_url):
    _param = machine_summary()
    LOGGER.info(('update_machine_stat:', _url, str(_param)))
    s, r = _NetworkAccess.post_to_url(url=_url, param=_param)
    if s == 200 and r['result'] == 'OK':
        return True
    else:
        return False


ERROR_PRINTER = {
    16: 'OUT_OF_PAPER'
}

COMP = None
LAST_SYNC = 'OFFLINE'


def kiosk_get_machine_summary():
    _Tools.get_pool().apply_async(get_machine_summary)


def get_machine_summary():
    try:
        result = machine_summary()
        result['total_trx'] = _DAO.get_total_count('Transactions')
        result['today_trx'] = _DAO.get_total_count('Transactions',
                                                   ' strftime("%Y-%m-%d", datetime(createdAt/1000, "unixepoch")) = '
                                                   'date("now") ')
        result['cash_trx'] = _DAO.get_total_count('Transactions', ' paymentType = "MEI" ')
        result['edc_trx'] = _DAO.get_total_count('Transactions', ' paymentType = "EDC" ')
        result['edc_not_settle'] = _DAO.custom_query(' SELECT sum(amount) as total FROM Settlement WHERE status="EDC|OPEN" ')
        result['cash_available'] = _DAO.custom_query(' SELECT sum(amount) as total FROM Cash WHERE collectedAt is null ')
        LOGGER.info(('get_machine_summary', str(result)))
        K_SIGNDLER.SIGNAL_GET_MACHINE_SUMMARY.emit(json.dumps(result))
    except Exception as e:
        LOGGER.warning(('get_machine_summary', str(e)))


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
        'edc_error': _Global.EDC_ERROR,
        'nfc_error': _Global.NFC_ERROR,
        'mei_error': _Global.MEI_ERROR,
        'printer_error': _Global.PRINTER_ERROR,
        'scanner_error': _Global.SCANNER_ERROR,
        'webcam_error': _Global.WEBCAM_ERROR,
        'cd1_error': _Global.CD1_ERROR,
        'cd2_error': _Global.CD2_ERROR,
        'cd3_error': _Global.CD3_ERROR,
        'mandiri_wallet': str(_Global.MANDIRI_WALLET),
        'bni_wallet': str(_Global.BNI_ACTIVE_WALLET_AMOUNT),
        'bri_wallet': str(_Global.BRI_WALLET),
        'bca_wallet': str(_Global.BCA_WALLET),
        'dki_wallet': str(_Global.DKI_WALLET),
        'last_sync': str(LAST_SYNC),
        'online_status': str(KIOSK_STATUS),
        'mandiri_active': str(_Global.MANDIRI_ACTIVE),
        'bni_active': str(_Global.BNI_ACTIVE),
        'service_ver': str(_Global.SERVICE_VERSION),
        # 'bni_sam1_no': str(_Global.BNI_SAM_1_NO),
        # 'bni_sam2_no': str(_Global.BNI_SAM_2_NO),
    }
    try:
        pythoncom.CoInitialize()
        COMP = wmi.WMI()
        summary['gui_version'] = VERSION
        summary["c_space"] = get_disk_space("C:")
        summary["d_space"] = get_disk_space("D:")
        summary["ram_space"] = get_ram_space()
        summary['paper_printer'] = get_printer_status_v2()
    except Exception as e:
        LOGGER.warning(('machine_summary : ', str(e)))
    finally:
        return summary


def get_ram_space():
    try:
        ram_space = []
        for e in COMP.Win32_OperatingSystem():
            ram_space.append(int(e.FreePhysicalMemory.strip()) / 1024)
            return "%.2f" % ram_space[0]
    except Exception as e:
        LOGGER.warning(("get_ram_space : ", str(e)))
        return "%.2f" % -1


def get_disk_space(caption):
    try:
        d_space = []
        for d in COMP.Win32_LogicalDisk(Caption=caption):
            d_space.append(int(d.FreeSpace.strip()) / 1024 / 1024)
            return "%.2f" % d_space[0]
    except Exception as e:
        LOGGER.warning(("get_disk_space " + caption + " ", str(e)))
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
        LOGGER.warning(("get_printer_status : ", str(e)))
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
        LOGGER.warning(("get_printer_status_v2 : ", str(e)))
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
        LOGGER.warning(("get_cpu_temp : ", str(e)))
        return "%.2f" % (common - variance)
    # return "%.2f" % (common - variance)


def execute_command(command):
    try:
        os.system(command)
        LOGGER.info(('execute_command:', command))
    except Exception as e:
        LOGGER.warning(('execute_command:', str(e)))


def post_gui_version():
    _Tools.get_pool().apply_async(gui_info)


def gui_info():
    global VERSION
    try:
        # NO-NEED Budled with Kiosk Status
        status, response = _NetworkAccess.post_to_url('box/guiInfo', {"gui_version": str(VERSION)})
        LOGGER.info(('gui_info: ', str(status), str(response)))
    except Exception as e:
        LOGGER.warning(('gui_info: ', e))


def get_file_list(dir_):
    _Tools.get_pool().apply_async(file_list, (dir_,))


def file_list(dir_):
    if dir_ == "" or dir_ is None:
        return
    ext_files = '.*'
    if "Video" in str(dir_):
        ext_files = ('.mp4', '.mov', '.avi', '.mpg', '.mpeg')
    elif "Image" in str(dir_):
        ext_files = ('.png', '.jpeg', '.jpg')
    elif "Music" in str(dir_):
        ext_files = ('.mp3', '.ogg', '.wav')
    try:
        _dir_ = dir_.replace(".", "")
        _tvclist = [xyz for xyz in os.listdir(sys.path[0] + _dir_) if xyz.endswith(ext_files)]
        # post_tvc_list(json.dumps(_tvclist))
        files = {
            "result": _tvclist,
            "dir": dir_
        }
        # print(files)
        LOGGER.info(("getting files from : ", _dir_, str(files)))
        K_SIGNDLER.SIGNAL_GET_FILE_LIST.emit(json.dumps(files))
    except Exception as e:
        K_SIGNDLER.SIGNAL_GET_FILE_LIST.emit("ERROR")
        LOGGER.warning(("file_list: ", e))


def post_tvc_list(list_):
    if list_ is None or list_ == "":
        return
    try:
        #TODO Create Backend URL
        status, response = _NetworkAccess.post_to_url('box/tvcList', {"tvclist": list_})
        LOGGER.info(('post_tvc_list: ', response))
    except Exception as e:
        LOGGER.warning(("post_tvc_list: ", e))


def post_tvc_log(media):
    _Tools.get_pool().apply_async(tvc_log, (media,))


def tvc_log(media):
    if media is None or media == "":
        return
    param = {
        "filename": media,
        "country": "ID",
        "playtime": time.strftime("%Y-%m-%d %H")
    }
    try:
        #TODO Create Backend URL
        status, response = _NetworkAccess.post_to_url('box/tvcLog', param)
        LOGGER.info(("tvc_log: ", response))
    except Exception as e:
        LOGGER.warning(("tvc_log: ", e))


def start_get_device_status():
    _Tools.get_pool().apply_async(get_device_status)


def get_device_status():
    devices = _Global.get_devices_status()
    K_SIGNDLER.SIGNAL_GET_DEVICE_STAT.emit(json.dumps(devices))


FIRST_RUN_FLAG = True


def start_restart_mdd_service():
    global FIRST_RUN_FLAG
    if FIRST_RUN_FLAG is True:
        _Tools.get_pool().apply_async(restart_mdd_service)
        FIRST_RUN_FLAG = False


def restart_mdd_service():
    os.system('powershell restart-service MDDTopUpService -force')
    # process = subprocess.run('powershell restart-service MDDTopUpService -force', shell=True, stdout=subprocess.PIPE)
    # output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
    # # LOGGER.info(('[INFO] restart_mdd_service result : ', str(output)))
    # print("pyt : ", output)


def start_get_cash_data():
    _Tools.get_pool().apply_async(list_uncollected_cash)


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
    LOGGER.info(('Getting_list_cash', json.dumps(response)))


def start_begin_collect_cash():
    _Tools.get_pool().apply_async(begin_collect_cash)


def begin_collect_cash():
    # Add GRG Device Reset Function
    # if _Global.GRG['status'] is True:
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
    post_cash_collection(list_collect, _Tools.now())
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
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'collect/cash', param)
        LOGGER.info(("post_cash_collection : ", response))
    except Exception as e:
        LOGGER.warning(("post_cash_collection : ", e))


def start_adjust_table(p):
    _Tools.get_pool().apply_async(adjust_table, (p,))


def adjust_table(p, t='Receipts'):
    try:
        try:
            count_table = _DAO.check_table({'table': t})
            LOGGER.info(('Count Table ', t, str(count_table)))
        except Exception as e:
            LOGGER.info(('Table Not Found, ', e, 'Adjusting : ', p))
            _DAO.adjust_table(p)
    except Exception as e:
        LOGGER.warning(('adjust_table : ', e, t))


PREV_RECEIPT_RAW_DATA = None
PREV_BOOKING_CODE = None
PREV_PARAM_DATA = None
PREV_TIBOX_ID = None


def clear_prev_data():
    global PREV_RECEIPT_RAW_DATA, PREV_PARAM_DATA, PREV_BOOKING_CODE, PREV_TIBOX_ID
    PREV_PARAM_DATA = None
    PREV_BOOKING_CODE = None
    PREV_RECEIPT_RAW_DATA = None
    PREV_TIBOX_ID = None


def start_search_booking(bk):
    _Tools.get_pool().apply_async(search_booking, (bk,))


def search_booking(bk):
    global PREV_BOOKING_CODE
    PREV_BOOKING_CODE = bk
    try:
        param = {'bookingCode': bk}
        r = _DAO.search_receipt(param)
        if len(r) != 0:
            _s, _r = complete_booking_data(r[0])
            if _s is True:
                K_SIGNDLER.SIGNAL_BOOKING_SEARCH.emit(json.dumps(_r))
            else:
                K_SIGNDLER.SIGNAL_BOOKING_SEARCH.emit('ERROR')
            LOGGER.debug(('search_booking : ', bk, _r))
        else:
            K_SIGNDLER.SIGNAL_BOOKING_SEARCH.emit('NO_DATA')
            LOGGER.debug(('search_booking : ', str(r)))
    except Exception as e:
        K_SIGNDLER.SIGNAL_BOOKING_SEARCH.emit('ERROR')
        LOGGER.warning(('search_booking : ', e))


DUMMY_PROCESS = False


def complete_booking_data(p):
    global PREV_RECEIPT_RAW_DATA, PREV_PARAM_DATA, PREV_TIBOX_ID
    PREV_RECEIPT_RAW_DATA = p['receiptRaw']
    PREV_PARAM_DATA = p['receiptData']
    param_send = {
        'booking_code': p['bookingCode']
    }
    if DUMMY_PROCESS is False:
        _url = BACKEND_URL + 'booking/status'
        status, response = _NetworkAccess.post_to_url(url=_url, param=param_send)
        if status == 200 and response['result'] == 'OK':
            PREV_TIBOX_ID = response['data']['bk_id']
            p['t_booking_id'] = response['data']['bk_id']
            p['t_payment_status'] = response['data']['bk_payment_status']
            p['t_grand_total'] = response['data']['bk_grandtotal'].replace('.00', '')
            # p['t_rawData'] = json.dumps(response['data'])
            return True, p
        else:
            return False, p
    else:
        d = json.loads(p['receiptData'])
        PREV_TIBOX_ID = p['tiboxId']
        p['t_booking_id'] = p['tiboxId']
        p['t_payment_status'] = d['GET_PAYMENT_STATUS']
        p['t_grand_total'] = d['GET_INIT_FARE']
        # p['t_rawData'] = 'DUMMY'
        return True, p


HEADER = {'Content-Type': 'multipart/form-data'}
TIBOX_URL = _ConfigParser.get_value('TERMINAL', 'tibox^server')
TID = _ConfigParser.get_value('TERMINAL', 'tid')
TXT_BOOKING_STATUS = 'FAILED'


def start_recreate_payment(payment):
    _Tools.get_pool().apply_async(recreate_payment, (payment, ))


def recreate_payment(payment):
    global PREV_RECEIPT_RAW_DATA, PREV_PARAM_DATA, TXT_BOOKING_STATUS
    url_ = 'p_check_paid.php?val=' + payment + '&&tid=' + TID + '&&id=' + str(PREV_TIBOX_ID)
    print('pyt: start_recreate_payment', url_)
    try:
        trying = 0
        while True:
            trying += 1
            status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
            if status == 200 and 'OK' in response:
                TXT_BOOKING_STATUS = 'SUCCESS'
                if PREV_RECEIPT_RAW_DATA is not None:
                    update_param_data = json.loads(PREV_PARAM_DATA)
                    update_param_data['GET_UPDATE_PAYMENT'] = TXT_BOOKING_STATUS
                    PREV_PARAM_DATA = json.dumps(update_param_data)
                    PREV_PARAM_DATA = PREV_PARAM_DATA.replace('Payment Status', 'Booking Status')
                    PREV_RECEIPT_RAW_DATA = PREV_RECEIPT_RAW_DATA.split('Booking Status')[0]
                    PREV_RECEIPT_RAW_DATA += ('Booking Status   : ' + TXT_BOOKING_STATUS + '\r\n')
                LOGGER.info(('recreate_payment to vedaleon: ', str(response)))
                K_SIGNDLER.SIGNAL_RECREATE_PAYMENT.emit('SUCCESS')
                break
            if trying == 3:
                LOGGER.warning(('recreate_payment to vedaleon: ', str(response)))
                K_SIGNDLER.SIGNAL_RECREATE_PAYMENT.emit('ERROR')
                break
            time.sleep(2)
    except Exception as e:
        LOGGER.warning(('recreate_payment : ', e))
        K_SIGNDLER.SIGNAL_RECREATE_PAYMENT.emit('ERROR')


def start_get_admin_key():
    _Tools.get_pool().apply_async(get_admin_key)


def get_admin_key():
    tid = _ConfigParser.get_value('TERMINAL', 'tid')
    salt = datetime.datetime.now().strftime("%Y%m%d")
    K_SIGNDLER.SIGNAL_ADMIN_KEY.emit(tid+salt)


def start_check_wallet(amount):
    _Tools.get_pool().apply_async(check_wallet, (amount,))


def check_wallet(amount):
    try:
        param = {"amount": int(amount)}
        status, response = _NetworkAccess.post_to_url(BACKEND_URL + 'task/check-wallet', param)
        LOGGER.info(("check_wallet : ", response))
        if status == 200 and response is not None:
            K_SIGNDLER.SIGNAL_WALLET_CHECK.emit(json.dumps(response))
        else:
            K_SIGNDLER.SIGNAL_WALLET_CHECK.emit('ERROR')
    except Exception as e:
        LOGGER.warning(("check_wallet : ", e))
        K_SIGNDLER.SIGNAL_WALLET_CHECK.emit('ERROR')


def kiosk_get_product_stock():
    _Tools.get_pool().apply_async(get_product_stock, )


def get_product_stock():
    stock = []
    try:
        check_stock = _DAO.get_product_stock()
        if len(check_stock) > 0:
            stock = check_stock
            for s in stock:
                __image = ''
                s['image'] = __image
                if '|' in s['remarks']:
                    __image = s['remarks'].split('|')[1]
                    s['image'] = 'aAsset/' + __image
                    s['remarks'] = s['remarks'].split('|')[0]
        LOGGER.debug(("get_product_stock : ", str(stock)))
        K_SIGNDLER.SIGNAL_GET_PRODUCT_STOCK.emit(json.dumps(stock))
    except Exception as e:
        LOGGER.warning(("get_product_stock : ", e))
        K_SIGNDLER.SIGNAL_GET_PRODUCT_STOCK.emit(json.dumps(stock))


def start_store_transaction_global(param):
    _Tools.get_pool().apply_async(store_transaction_global, (param,))


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
    _Tools.get_pool().apply_async(store_transaction_global, (_param, _retry, ))


def store_transaction_global(param, retry=False):
    global GLOBAL_TRANSACTION_DATA, MEI_HISTORY, TRX_ID_SALE, PID_SALE, CARD_NO, PID_STOCK_SALE
    GLOBAL_TRANSACTION_DATA = json.loads(param)
    LOGGER.info(('GLOBAL_TRANSACTION_DATA', param))
    try:
        PID_SALE = GLOBAL_TRANSACTION_DATA['shop_type'] + str(GLOBAL_TRANSACTION_DATA['epoch'])
        _key = 'EMONEY' if 'Mandiri' in GLOBAL_TRANSACTION_DATA['provider'] else 'TAPCASH'

        if retry is False:
            _trxid = _Tools.get_uuid()
            TRX_ID_SALE = _trxid

            if 'payment_error' in GLOBAL_TRANSACTION_DATA.keys():
                if GLOBAL_TRANSACTION_DATA['shop_type'] == 'shop':
                    PID_SALE = GLOBAL_TRANSACTION_DATA['raw']['pid']
                GLOBAL_TRANSACTION_DATA['pid'] = PID_SALE
                GLOBAL_TRANSACTION_DATA['trxid'] = _trxid
                if GLOBAL_TRANSACTION_DATA['payment'] == 'cash':
                    # Saving The CASH
                    save_cash_local(GLOBAL_TRANSACTION_DATA['payment_received'], 'cancel')
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('PAYMENT_FAILED_CANCEL_TRIGGERED')
                return

            _param = {
                'pid': PID_SALE,
                'name': GLOBAL_TRANSACTION_DATA['provider'],
                'price': int(GLOBAL_TRANSACTION_DATA['value']),
                'details': param,
                'status': 1
            }

            check_prod = _DAO.check_product(PID_SALE)
            if len(check_prod) == 0:
                _DAO.insert_product(_param)

            status, response = _NetworkAccess.post_to_url(url=BACKEND_URL + 'sync/product', param=_param)
            if status == 200 and response['id'] == _param['pid']:
                _param['key'] = _param['pid']
                _DAO.mark_sync(param=_param, _table='Product', _key='pid')
            K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|STORE_PRODUCT-'+_param['pid'])

            if GLOBAL_TRANSACTION_DATA['payment'] == 'cash':
                # Saving The CASH
                save_cash_local(GLOBAL_TRANSACTION_DATA['payment_received'])

        # ================== RETRY MODE ==================
        _param_stock = dict()
        _trxid = TRX_ID_SALE
        _param = {
            'pid': PID_SALE,
            'name': GLOBAL_TRANSACTION_DATA['provider'],
            'price': int(GLOBAL_TRANSACTION_DATA['value']),
            'details': param,
            'status': 1
        }
        if GLOBAL_TRANSACTION_DATA['shop_type'] == 'shop':
            PID_STOCK_SALE = GLOBAL_TRANSACTION_DATA['raw']['pid']
            _param_stock = {
                'pid': PID_STOCK_SALE,
                'stock': int(GLOBAL_TRANSACTION_DATA['raw']['stock']) - int(GLOBAL_TRANSACTION_DATA['qty'])
            }
            _DAO.update_product_stock(_param_stock)
            K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|UPDATE_PRODUCT_STOCK-' + _param_stock['pid'])
            _key = 'SALE_' + _key
        __notes = json.dumps(GLOBAL_TRANSACTION_DATA['payment_details']) if len(MEI_HISTORY) == 0 else MEI_HISTORY
        __param = {
            'trxid': _trxid,
            'tid': TID,
            'mid': '',
            'pid': _param['pid'],
            # 'tpid': get_tpid(string=_key), Change To Hardcoded
            'tpid': '819316acd00b4bf5b153ee7414e727d4',
            'sale': _param['price'],
            'amount': _param['price'],
            'cardNo': GLOBAL_TRANSACTION_DATA['payment_details'].get('card_no', ''),
            'paymentType': get_payment(GLOBAL_TRANSACTION_DATA['payment']),
            'paymentNotes': __notes,
            'bankMid': '',
            'bankTid': ''
        }
        attempt = 0
        GLOBAL_TRANSACTION_DATA['pid'] = PID_SALE
        GLOBAL_TRANSACTION_DATA['trxid'] = _trxid
        while True:
            attempt += 1
            check_trx = _DAO.check_trx(_trxid)
            if len(check_trx) == 0:
                _DAO.insert_transaction(__param)
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|STORE_TRX-' + _trxid)
                if GLOBAL_TRANSACTION_DATA['shop_type'] == 'shop':
                    __param['left_stock'] = _param_stock['stock']
                    __param['pid_stock'] = _param_stock['pid']
                __param['createdAt'] = _Tools.now()
                status, response = _NetworkAccess.post_to_url(url=BACKEND_URL + 'sync/transaction-topup', param=__param)
                if status == 200 and response['id'] == __param['trxid']:
                    __param['key'] = __param['trxid']
                    _DAO.mark_sync(param=__param, _table='Transactions', _key='trxid')
                    K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('SUCCESS|UPLOAD_TRX-' + _trxid)
                    break
            if attempt == 3:
                LOGGER.warning(('store_transaction_global', 'max_attempt', str(attempt)))
                K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('FAILED|STORE_TRX-' + _trxid)
                break
            sleep(1)
    except Exception as e:
        LOGGER.warning(('store_transaction_global', str(retry), str(e)))
        K_SIGNDLER.SIGNAL_STORE_TRANSACTION.emit('ERROR')
    finally:
        MEI_HISTORY = ''
        CARD_NO = ''


TOPUP_AMOUNT_DATA = [
    {'bigDenom': 100000, 'tinyDenom': 20000, 'smallDenom': 50000, 'name': 'MANDIRI'},
    {'bigDenom': 100000, 'tinyDenom': 20000, 'smallDenom': 50000, 'name': 'BNI'}
]


def start_kiosk_get_topup_amount():
    _Tools.get_pool().apply_async(kiosk_get_topup_amount)


def kiosk_get_topup_amount():
    global TOPUP_AMOUNT_DATA
    LOGGER.info(('kiosk_get_topup_amount', str(TOPUP_AMOUNT_DATA)))
    if TID == '110322':
        TOPUP_AMOUNT_DATA = [
            {'bigDenom': 270, 'tinyDenom': 17, 'smallDenom': 170, 'name': 'MANDIRI'},
            {'bigDenom': 270, 'tinyDenom': 17, 'smallDenom': 170, 'name': 'BNI'}
        ]
    K_SIGNDLER.SIGNAL_GET_TOPUP_AMOUNT.emit(json.dumps(TOPUP_AMOUNT_DATA))


def start_store_topup_transaction(param):
    _Tools.get_pool().apply_async(store_topup_transaction, (param,))

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
            'rid': _Tools.get_uuid(),
            'trxid': TRX_ID_SALE,
            'cardNo': p['topup_details']['card_no'],
            'balance': p['topup_details']['last_balance'],
            'reportSAM': p['topup_details']['report_sam'],
            'reportKA': p['topup_details']['report_ka'],
            'status': 1,
            'remarks': param
        }
        _DAO.insert_topup_record(_param)
        _param['createdAt'] = _Tools.now()
        status, response = _NetworkAccess.post_to_url(url=BACKEND_URL + 'sync/topup-records', param=_param)
        LOGGER.info(('sync store_topup_transaction', str(_param), str(status), str(response)))
        if status == 200 and response['id'] == _param['rid']:
            _param['key'] = _param['rid']
            _DAO.mark_sync(param=_param, _table='TopUpRecords', _key='rid')
            K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|SUCCESS')
        else:
            K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|SUCCESS-SYNC-FAILED')
    except Exception as e:
        LOGGER.warning(('store_topup_transaction', e))
        K_SIGNDLER.SIGNAL_STORE_TOPUP.emit('STORE_TOPUP|ERROR')


def save_cash_local(amount, mode='normal'):
    try:
        csid = TRX_ID_SALE[::-1]
        param_cash = {
            'csid': csid,
            'tid': TID,
            'amount': int(amount),
            'pid': PID_SALE
        }
        _DAO.insert_cash(param_cash)
        LOGGER.info(('save_cash_local', mode, PID_SALE, str(amount)))
        return True
    except Exception as e:
        LOGGER.warning(('save_cash_local', mode, PID_SALE, str(amount)))
        return False


def first_init_call():
    LOGGER.info(('first_init_call', 'START'))
    try:
        _DAO.flush_table('TopUpRecords')
        time.sleep(1)
        _DAO.flush_table('Receipts')
        time.sleep(1)
        _DAO.flush_table('Settlement')
        time.sleep(1)
        _DAO.flush_table('Cash')
        time.sleep(1)
        _DAO.flush_table('Product')
        time.sleep(1)
        _DAO.flush_table('Transactions')
        LOGGER.info(('first_init_call', 'FINISH'))
        return 'FIRST_INIT_CLEANUP_SUCCESS'
    except Exception as e:
        LOGGER.warning(('first_init_call', str(e)))
        return 'FIRST_INIT_CLEANUP_FAILED'


def user_action_log(log):
    LOGGER.info(('[USER_ACTION]', str(log)))