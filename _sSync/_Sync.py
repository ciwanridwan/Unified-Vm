__author__ = 'fitrah.wahyudi.imam@gmail.com'
import os
import sys
from _tTools import _Tools
from _dDAO import _DAO
from time import sleep
from _cConfig import _ConfigParser, _Global
from _nNetwork import _NetworkAccess
import logging
from _sService import _KioskService
from _dDevice import _EDC
from _dDevice import _GRG
from _dDevice import _QPROX
from operator import itemgetter
import json
from _sService import _UserService
from _sService import _SettlementService
from _sService import _TopupService
from datetime import datetime

LOGGER = logging.getLogger()
URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
SETTING_PARAM = []


def start_check_connection(url, param):
    _Tools.get_pool().apply_async(check_connection, (url, param,))


def check_connection(url, param):
    global SETTING_PARAM
    SETTING_PARAM = param
    modulus = 0
    while True:
        if _Tools.is_online(source='check_connection') is True and IDLE_MODE is True:
            modulus += 1
            try:
                status, response = _NetworkAccess.get_from_url(url=url)
                if status == 200:
                    print('STATUS: Connected To Backend Server')
                    _KioskService.KIOSK_STATUS = 'ONLINE'
                    _KioskService.KIOSK_REAL_STATUS = 'ONLINE'
                else:
                    # Disable Connection Status Change
                    # _KioskService.KIOSK_STATUS = 'OFFLINE'
                    _KioskService.KIOSK_REAL_STATUS = 'OFFLINE'
                    print('STATUS: Disconnected From Backend Server')
                _KioskService.LAST_SYNC = _Tools.time_string()
                _KioskService.kiosk_status()
                # Run on the first sync only
                if modulus == 1:
                    # _SettlementService.start_do_bni_topup_settlement()
                    _url = URL + 'get/setting'
                    # LOGGER.info((_url, str(SETTING_PARAM)))
                    s, r = _NetworkAccess.post_to_url(url=_url, param=SETTING_PARAM)
                    if s == 200 and r['result'] == 'OK':
                        _KioskService.update_kiosk_status(r)
                        # _KioskService.update_machine_stat(URL + 'kiosk/status')
                # Add TVC Buffer Killer every 5 minutes
                # if modulus % 5 == 0:
                # os.system(sys.path[0] + '/_pPlayer/stop.bat')
                # Handler BNI Topup Settlement
                # if modulus % 15 == 0:
                #     _SettlementService.start_do_bni_topup_settlement()
            except Exception as e:
                LOGGER.debug(e)
        sleep(61.7)


def start_idle_mode():
    _Tools.get_pool().apply_async(change_idle_mode, ('START',))


def stop_idle_mode():
    _Tools.get_pool().apply_async(change_idle_mode, ('STOP',))


def change_idle_mode(s):
    global IDLE_MODE
    if s == 'START':
        IDLE_MODE = True
        _UserService.USER = None
    elif s == 'STOP':
        IDLE_MODE = False


IDLE_MODE = True


def start_sync_machine_status():
    _Tools.get_pool().apply_async(sync_machine_status)


def sync_machine_status():
    __url = URL + 'kiosk/status'
    __param = dict()
    while True:
        try:
            if _Tools.is_online(source='sync_machine_status') is True and IDLE_MODE is True:
                if IDLE_MODE is True:
                    __param = _KioskService.machine_summary()
                    __param['on_usage'] = 'IDLE' if IDLE_MODE is True else 'ON_USED'
                    # LOGGER.info((__url, str(__param)))
                    _NetworkAccess.post_to_url(url=__url, param=__param)
                else:
                    LOGGER.debug(('Sending Kiosk Status : ', str(IDLE_MODE)))
        except Exception as e:
            LOGGER.warning(e)
        sleep(25.5)


def start_kiosk_sync():
    _Tools.get_pool().apply_async(kiosk_sync)


def kiosk_sync():
    sync_task()
    sync_product_data()
    sync_data_transaction()
    sync_machine_status()
    sync_topup_records()


def start_sync_topup_records():
    _Tools.get_pool().apply_async(sync_topup_records)


def sync_topup_records():
    url = URL + 'sync/topup-records'
    _table_ = 'TopUpRecords'
    while True:
        try:
            if _Tools.is_online(source='sync_topup_records') is True and IDLE_MODE is True:
                topup_records = _DAO.not_synced_data(param={'syncFlag': 0}, _table=_table_)
                if len(topup_records) > 0:
                    print('pyt : Re-Sync Topup Records Data...')
                    for t in topup_records:
                        status, response = _NetworkAccess.post_to_url(url=url, param=t)
                        # LOGGER.info(('sync_topup_records', json.dumps(t), str(status), str(response)))
                        if status == 200 and response['id'] == t['rid']:
                            LOGGER.info(response)
                            t['key'] = t['rid']
                            _DAO.mark_sync(param=t, _table=_table_, _key='rid')
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(44.5)


def start_sync_data_transaction():
    _Tools.get_pool().apply_async(sync_data_transaction)


def sync_data_transaction():
    url = URL + 'sync/transaction-topup'
    _table_ = 'Transactions'
    while True:
        try:
            if _Tools.is_online(source='sync_data_transaction') is True and IDLE_MODE is True:
                transactions = _DAO.not_synced_data(param={'syncFlag': 0}, _table=_table_)
                if len(transactions) > 0:
                    print('pyt : Re-Sync Transaction Data...')
                    for t in transactions:
                        status, response = _NetworkAccess.post_to_url(url=url, param=t)
                        if status == 200 and response['id'] == t['trxid']:
                            LOGGER.info(response)
                            t['key'] = t['trxid']
                            _DAO.mark_sync(param=t, _table=_table_, _key='trxid')
                            _DAO.update_product_status(param={'status': 1, 'pid': t['pid']})
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(99.9)


def start_sync_data_transaction_failure():
    _Tools.get_pool().apply_async(sync_data_transaction_failure)


def sync_data_transaction_failure():
    url = URL + 'sync/transaction-failure'
    _table_ = 'TransactionFailure'
    while True:
        try:
            if _Tools.is_online(source='sync_data_transaction_failure') is True and IDLE_MODE is True:
                transaction_failures = _DAO.not_synced_data(param={'syncFlag': 0}, _table=_table_)
                if len(transaction_failures) > 0:
                    print('pyt : Re-Sync Transaction Failure Data...')
                    for t in transaction_failures:
                        status, response = _NetworkAccess.post_to_url(url=url, param=t)
                        if status == 200 and response['id'] == t['trxid']:
                            LOGGER.info(response)
                            t['key'] = t['trxid']
                            _DAO.mark_sync(param=t, _table=_table_, _key='trxid')
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(99.9)


def start_sync_product_data():
    _Tools.get_pool().apply_async(sync_product_data)


def sync_product_data():
    url = URL + 'sync/product'
    _table_ = 'Product'
    while True:
        try:
            if _Tools.is_online(source='sync_product_data') is True and IDLE_MODE is True:
                products = _DAO.not_synced_data(param={'syncFlag': 0}, _table=_table_)
                if len(products) > 0:
                    print('pyt : Re-Sync Product Data...')
                    for p in products:
                        status, response = _NetworkAccess.post_to_url(url=url, param=p)
                        if status == 200 and response['id'] == p['pid']:
                            LOGGER.info(response)
                            p['key'] = p['pid']
                            _DAO.mark_sync(param=p, _table=_table_, _key='pid')
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(55.5)


def start_sync_sam_audit():
    _Tools.get_pool().apply_async(sync_sam_audit)


def sync_sam_audit():
    url = URL + 'sync/sam-audit'
    _table_ = 'SAMAudit'
    while True:
        try:
            if _Tools.is_online(source='sync_sam_audit') is True and IDLE_MODE is True:
                audits = _DAO.not_synced_data(param={'syncFlag': 0}, _table=_table_)
                if len(audits) > 0:
                    print('pyt : Re-Sync SAM Audit...')
                    for a in audits:
                        status, response = _NetworkAccess.post_to_url(url=url, param=a)
                        if status == 200 and response['id'] == a['lid']:
                            LOGGER.info(response)
                            a['key'] = a['lid']
                            _DAO.mark_sync(param=a, _table=_table_, _key='lid')
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(77.7)


def start_sync_settlement_bni():
    bank = 'BNI'
    _Tools.get_pool().apply_async(sync_settlement_data, (bank, ))


def sync_settlement_data(bank):
    _url = _Global.SMT_CONFIG['full_url']
    _table_ = 'Settlement'
    while True:
        try:
            if _Tools.is_online(source='sync_settlement_data') is True and IDLE_MODE is True:
                settlements = _DAO.custom_query(' SELECT * FROM ' + _table_ + ' WHERE status = "TOPUP_PREPAID|OPEN" AND '
                                                                              ' createdAt > 1554783163354 ')
                if len(settlements) > 0:
                    print('pyt : Re-Sync Settlement Data...')
                    for s in settlements:
                        _param = {
                            'mid': _Global.SMT_CONFIG['mid'],
                            'token': _Global.SMT_CONFIG['token'],
                            'tid': 'TJ-TOPUP-VM'+_Global.TID,
                            'path_file': os.path.join(sys.path[0], '_rRemoteFiles', s['filename']),
                            'filename': s['filename'],
                            'row': s['row'],
                            'amount': s['amount'],
                            'bank': bank,
                            'bid': _Global.BID[bank],
                            'settlement_created_at': datetime.fromtimestamp(s['createdAt']).strftime('%Y-%m-%d %H:%M:%S')
                        }
                        status, response = _NetworkAccess.post_to_url(url=_url, param=_param)
                        if status == 200:
                            _DAO.update_settlement({'sid': s['sid'], 'status': 'TOPUP_PREPAID|CLOSED'})
                            LOGGER.info(response)
                        else:
                            LOGGER.warning(response)
        except Exception as e:
            LOGGER.warning(e)
        sleep(888.8)


def start_sync_task():
    _Tools.get_pool().apply_async(sync_task)


def sync_task():
    _url = URL + 'task/check'
    while True:
        try:
            if _Tools.is_online(source='sync_task') is True and IDLE_MODE is True:
                status, response = _NetworkAccess.get_from_url(url=_url, log=False)
                if status == 200 and response['result'] == 'OK':
                    if len(response['data']) > 0:
                        handle_tasks(response['data'])
                    else:
                        print('pyt : No Remote Task Given..!')
                else:
                    print('pyt : Failed To Check Remote Task..!')
        except Exception as e:
            LOGGER.warning(e)
        sleep(33.3)


def handle_tasks(tasks):
    if len(tasks) == 0:
        return
    '''
    {
    "no": 1,
    "tid": "110321",
    "taskName": "REBOOT",
    "status": "OPEN",
    "result": null,
    "createdAt": "2018-04-14 00:00:00",
    "initedAt": "2018-04-14 23:38:46",
    "updatedAt": null,
    "userId": null
    }
    '''
    for task in tasks:
        if task['taskName'] == 'REBOOT':
            if IDLE_MODE is True:
                result = 'EXECUTED_INTO_MACHINE'
                _KioskService.K_SIGNDLER.SIGNAL_GENERAL.emit('REBOOT')
                update_task(task, result)
                sleep(30)
                _KioskService.execute_command('shutdown -r -f -t 0')
            else:
                result = 'FAILED_EXECUTED_VM_ON_USED'
                update_task(task, result)
        if task['taskName'] == 'EDC_CLEAR_BATCH':
            result = _EDC.void_settlement_data()
            update_task(task, result)
        if task['taskName'] == 'EDC_SETTLEMENT':
            result = _EDC.backend_edc_settlement()
            update_task(task, result)
        if task['taskName'] == 'RESET_GRG':
            if IDLE_MODE is True:
                _GRG.start_init_grg()
                result = 'EXECUTED_INTO_GRG'
            else:
                result = 'FAILED_EXECUTED_VM_ON_USED'
            update_task(task, result)
        if task['taskName'] == 'RESET_DB':
            result = 'DISABLED_FOR_TEST_MODE'
            if not _Global.TEST_MODE:
                if IDLE_MODE is True:
                    result = _KioskService.first_init_call()
                else:
                    result = 'FAILED_EXECUTED_VM_ON_USED'
            update_task(task, result)
        if task['taskName'] == 'DO_TOPUP_BNI_1' or 'DO_TOPUP_BNI_2':
            _slot = int(task['taskName'][-1])
            result = _TopupService.do_topup_bni(slot=_slot, force=True)
            update_task(task, result)
        if task['taskName'] == 'SAM_TO_SLOT_1' or 'SAM_TO_SLOT_2':
            _slot = int(task['taskName'][-1])
            result = _Global.sam_to_slot(_slot)
            update_task(task, result)
        if task['taskName'] == 'UPDATE_APP':
            # TODO ADD APP UPDATE HANDLER
            LOGGER.debug((task['taskName'], 'is Not Handled Yet..!'))
            update_task(task, 'ACTION_NOT_DEFINED')
        if task['taskName'] == 'RESET_STOCK_PRODUCT':
            _DAO.clear_stock_product()
            update_task(task, 'RESET_STOCK_PRODUCT_SUCCESS')
        if task['taskName'] == 'UPDATE_KIOSK':
            update_task(task)
            _url = URL + 'get/setting'
            LOGGER.info((_url, str(SETTING_PARAM)))
            s, r = _NetworkAccess.post_to_url(url=_url, param=SETTING_PARAM)
            if s == 200 and r['result'] == 'OK':
                _KioskService.update_kiosk_status(r)
        if 'RESET_OFFLINE_USER|' in task['taskName']:
            __hash = task['taskName'].split('|')[1]
            result = _UserService.reset_offline_user(__hash)
            update_task(task, result)
    # TODO Add Another TaskType


def update_task(task, result='TRIGGERED_TO_SYSTEM'):
    _url = URL + 'task/finish'
    task['result'] = result
    while True:
        status, response = _NetworkAccess.post_to_url(url=_url, param=task)
        if status == 200 and response['result'] == 'OK':
            break
        sleep(11.1)


def start_sync_product_stock():
    _Tools.get_pool().apply_async(start_get_product_stock)


def start_get_product_stock():
    _url = URL + 'get/product-stock'
    while True:
        if _Tools.is_online(source='start_get_product_stock') is True and IDLE_MODE is True:
            s, r = _NetworkAccess.get_from_url(url=_url)
            if s == 200 and r['result'] == 'OK':
                products = r['data']
                _DAO.flush_table('ProductStock')
                for product in products:
                    _DAO.insert_product_stock(product)
                _KioskService.get_product_stock()
        sleep(66.6)


def start_get_topup_amount():
    _Tools.get_pool().apply_async(get_topup_amount)


def get_topup_amount():
    _url = URL + 'get/topup-amount'
    while True:
        if _Tools.is_online(source='get_topup_amount') is True and IDLE_MODE is True:
            s, r = _NetworkAccess.get_from_url(url=_url)
            if s == 200 and r['result'] == 'OK':
                _KioskService.TOPUP_AMOUNT_DATA = parse_topup_data(r['data'])
                _KioskService.kiosk_get_topup_amount()
        sleep(333.3)


def parse_topup_data(topups):
    topups = sorted(topups, key=itemgetter('name', 'sell_price'), reverse=True)
    topup_provider = []
    for topup in topups:
        if topup['name'] not in topup_provider:
            topup_provider.append(topup['name'])
    list_amount = []
    for topup in topups:
        if topup['sell_price'] not in list_amount:
            list_amount.append(topup['sell_price'])
    topup_data = []
    for provider in topup_provider:
        _new_item = dict()
        for x in range(len(topups)):
            if provider == topups[x]['name']:
                _new_item['name'] = provider
                if topups[x]['sell_price'] == list_amount[0]:
                    if _Global.TID == '110322':
                        _new_item['bigDenom'] = 270
                    else:
                        _new_item['bigDenom'] = topups[x]['sell_price']
                if topups[x]['sell_price'] == list_amount[1]:
                    if _Global.TID == '110322':
                        _new_item['smallDenom'] = 170
                    else:
                        _new_item['smallDenom'] = topups[x]['sell_price']
                if topups[x]['sell_price'] == list_amount[2]:
                    if _Global.TID == '110322':
                        _new_item['tinyDenom'] = 17
                    else:
                        _new_item['tinyDenom'] = topups[x]['sell_price']
        topup_data.append(_new_item)
    return topup_data


def get_amount(idx, listx):
    output = 0
    try:
        output = listx[idx]
    except IndexError:
        output = 0
    finally:
        return output


def start_automate_topup_bni():
    _Tools.get_pool().apply_async(automate_topup_bni)


def automate_topup_bni():
    while True:
        if IDLE_MODE is True and _Tools.is_online(source='automate_topup_bni') is True:
            _QPROX.get_bni_wallet_status()
            if _Global.BNI_SAM_1_WALLET <= _Global.MINIMUM_AMOUNT:
                _TopupService.TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_1')
                _TopupService.do_topup_bni(slot=1)
                LOGGER.debug(('manual_topup_bni 1', str(_Global.BNI_SAM_1_WALLET), 'swap_to_slot 2'))
                _Global.BNI_ACTIVE = 2
            if _Global.BNI_SAM_2_WALLET <= _Global.MINIMUM_AMOUNT:
                _TopupService.TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_2')
                _TopupService.do_topup_bni(slot=2)
                LOGGER.debug(('manual_topup_bni 2', str(_Global.BNI_SAM_2_WALLET), 'swap_to_slot 1'))
                _Global.BNI_ACTIVE = 1
            _Global.save_sam_config()
        sleep(900)


def start_manual_trigger_topup_bni():
    _Tools.get_pool().apply_async(manual_trigger_topup_bni)


def manual_trigger_topup_bni():
    while True:
        if _Global.TRIGGER_MANUAL_TOPUP is True:
            _Global.TRIGGER_MANUAL_TOPUP = False
            if IDLE_MODE is True:
                _QPROX.get_bni_wallet_status()
            if _Global.BNI_SAM_1_WALLET <= _Global.MINIMUM_AMOUNT:
                _TopupService.TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_1')
                _TopupService.do_topup_bni(slot=1)
                LOGGER.debug(('manual_topup_bni 1', str(_Global.BNI_SAM_1_WALLET), 'swap_to_slot 2'))
                _Global.BNI_ACTIVE = 2
            if _Global.BNI_SAM_2_WALLET <= _Global.MINIMUM_AMOUNT:
                _TopupService.TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.emit('INIT_TOPUP_BNI_2')
                _TopupService.do_topup_bni(slot=2)
                LOGGER.debug(('manual_topup_bni 2', str(_Global.BNI_SAM_2_WALLET), 'swap_to_slot 1'))
                _Global.BNI_ACTIVE = 1
            _Global.save_sam_config()
        sleep(3.3)
