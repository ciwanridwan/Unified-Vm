__author__ = "fitrah.wahyudi.imam@gmail.com"

import os
import sys
from PyQt5.QtCore import QUrl, QObject, pyqtSlot, QTranslator, Qt
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQuick import QQuickView
import wmi
import logging
import logging.handlers
import subprocess
from _cConfig import _ConfigParser, _Global
from _nNetwork import _NetworkAccess
from _dDB import _Database
from _sService import _KioskService
from _sService import _UserService
from _tTools import _Tibox
from _sSync import _Sync
from _dDevice import _EDC
from _dDevice import _MEI
from _dDevice import _QPROX
from _dDevice import _CD
from _tTools import _TicketTool
from _dDevice import _Printer
from _cCommand import _Command
from time import sleep
from _tTools import _CheckIn
from _tTools import _SalePrintTool
from _sService import _ProductService
from _dDevice import _GRG
from _sService import _TopupService
from _sService import _SettlementService
from _sService import _UpdateAppService
from _sService import _PPOBService
from _sService import _QRPaymentService
import json


print("""
    Kiosk Ver: """ + _Global.VERSION + """
Powered By: PT. MultiDaya Dinamika
              -2019-
""")

# Set Frame Size Here
GLOBAL_WIDTH = 1920
GLOBAL_HEIGHT = 1080


class SlotHandler(QObject):
    __qualname__ = 'SlotHandler'

    def set_language(self, s):
        print("pyt: selected_language ", s)
        translator.load(path + s)
    set_language = pyqtSlot(str)(set_language)

    def get_file_list(self, dir_):
        _KioskService.get_file_list(dir_=dir_)
    get_file_list = pyqtSlot(str)(get_file_list)

    def post_tvc_log(self, media):
        _KioskService.post_tvc_log(media)
    post_tvc_log = pyqtSlot(str)(post_tvc_log)

    def get_gui_version(self):
        _KioskService.get_gui_version()
    get_gui_version = pyqtSlot()(get_gui_version)

    def get_kiosk_name(self):
        _KioskService.get_kiosk_name()
    get_kiosk_name = pyqtSlot()(get_kiosk_name)

    def post_gui_version(self):
        _KioskService.post_gui_version()
    post_gui_version = pyqtSlot()(post_gui_version)

    def set_tvc_player(self, command):
        set_tvc_player(command)
    set_tvc_player = pyqtSlot(str)(set_tvc_player)

    def start_set_plan(self, param):
        _Tibox.start_set_plan(param)
    start_set_plan = pyqtSlot(str)(start_set_plan)

    def start_create_schedule(self):
        _Tibox.start_create_schedule()
    start_create_schedule = pyqtSlot()(start_create_schedule)

    def start_create_chart(self, param):
        _Tibox.start_create_chart(param)
    start_create_chart = pyqtSlot(str)(start_create_chart)

    def start_post_person(self, param):
        _Tibox.start_post_person(param)
    start_post_person = pyqtSlot(str)(start_post_person)

    def start_create_booking(self):
        _Tibox.start_create_booking()
    start_create_booking = pyqtSlot()(start_create_booking)

    def start_create_payment(self, amount):
        _Tibox.start_create_payment(payment=amount)
    start_create_payment = pyqtSlot(str)(start_create_payment)

    def start_create_print(self):
        _Tibox.start_create_print()
    start_create_print = pyqtSlot()(start_create_print)

    def start_clear_person(self):
        _Tibox.start_clear_person()
    start_clear_person = pyqtSlot()(start_clear_person)

    def create_sale_edc(self, amount):
        _EDC.create_sale_edc(amount=amount)
    create_sale_edc = pyqtSlot(str)(create_sale_edc)

    def start_get_payments(self):
        _KioskService.start_get_payments()
    start_get_payments = pyqtSlot()(start_get_payments)

    def start_confirm_schedule(self):
        _Tibox.start_confirm_schedule()
    start_confirm_schedule = pyqtSlot()(start_confirm_schedule)

    def start_accept_mei(self):
        _MEI.start_accept_mei()
    start_accept_mei = pyqtSlot()(start_accept_mei)

    def start_dis_accept_mei(self):
        _MEI.start_dis_accept_mei()
    start_dis_accept_mei = pyqtSlot()(start_dis_accept_mei)

    def start_stack_mei(self):
        _MEI.start_stack_mei()
    start_stack_mei = pyqtSlot()(start_stack_mei)

    def start_return_mei(self):
        _MEI.start_return_mei()
    start_return_mei = pyqtSlot()(start_return_mei)

    def start_store_es_mei(self):
        _MEI.start_store_es_mei()
    start_store_es_mei = pyqtSlot()(start_store_es_mei)

    def start_return_es_mei(self):
        _MEI.start_return_es_mei()
    start_return_es_mei = pyqtSlot()(start_return_es_mei)

    def start_dispense_cou_mei(self):
        _MEI.start_dispense_cou_mei()
    start_dispense_cou_mei = pyqtSlot()(start_dispense_cou_mei)

    def start_float_down_cou_mei(self):
        _MEI.start_float_down_cou_mei()
    start_float_down_cou_mei = pyqtSlot()(start_float_down_cou_mei)

    def start_dispense_val_mei(self, amount):
        _MEI.start_dispense_val_mei(amount=amount)
    start_dispense_val_mei = pyqtSlot(str)(start_dispense_val_mei)

    def start_float_down_all_mei(self):
        _MEI.start_float_down_all_mei()
    start_float_down_all_mei = pyqtSlot()(start_float_down_all_mei)

    def start_get_return_note(self):
        _MEI.start_get_return_note()
    start_get_return_note = pyqtSlot()(start_get_return_note)

    def start_init_qprox(self):
        _QPROX.start_init_qprox()
    start_init_qprox = pyqtSlot()(start_init_qprox)

    def start_debit_qprox(self, amount):
        _QPROX.start_debit_qprox(amount)
    start_debit_qprox = pyqtSlot(str)(start_debit_qprox)

    def start_auth_ka(self):
        _QPROX.start_auth_ka()
    start_auth_ka = pyqtSlot()(start_auth_ka)

    def start_check_balance(self):
        _QPROX.start_check_balance()
    start_check_balance = pyqtSlot()(start_check_balance)

    def start_top_up_mandiri(self, amount, trxid):
        _QPROX.start_top_up_mandiri(amount, trxid)
    start_top_up_mandiri = pyqtSlot(str, str)(start_top_up_mandiri)

    def start_ka_info(self):
        _QPROX.start_ka_info()
    start_ka_info = pyqtSlot()(start_ka_info)

    def start_create_online_info(self):
        _QPROX.start_create_online_info()
    start_create_online_info = pyqtSlot()(start_create_online_info)

    def start_init_online(self):
        _QPROX.start_init_online()
    start_init_online = pyqtSlot()(start_init_online)

    def set_rounded_fare(self, amount):
        _Tibox.set_rounded_fare(amount=amount)
    set_rounded_fare = pyqtSlot(str)(set_rounded_fare)

    def start_disconnect_mei(self):
        _MEI.start_disconnect_mei()
    start_disconnect_mei = pyqtSlot()(start_disconnect_mei)

    def start_disconnect_edc(self):
        _EDC.start_disconnect_edc()
    start_disconnect_edc = pyqtSlot()(start_disconnect_edc)

    def start_disconnect_qprox(self):
        _QPROX.start_disconnect_qprox()
    start_disconnect_qprox = pyqtSlot()(start_disconnect_qprox)

    def start_get_airport_name(self, prefix1, prefix2):
        _Tibox.start_get_airport_name(prefix1=prefix1, prefix2=prefix2)
    start_get_airport_name = pyqtSlot(str, str)(start_get_airport_name)

    def start_generate(self, mode):
        _TicketTool.start_generate(use=mode)
    start_generate = pyqtSlot(str)(start_generate)

    def start_default_print(self, path):
        _Printer.start_default_print(path)
    start_default_print = pyqtSlot(str)(start_default_print)

    def start_set_payment(self, payment):
        _TicketTool.start_set_payment(payment=payment)
    start_set_payment = pyqtSlot(str)(start_set_payment)

    def start_send_details_passenger(self):
        _Tibox.start_send_details_passenger()
    start_send_details_passenger = pyqtSlot()(start_send_details_passenger)

    def start_sort_flight_data(self, key, method):
        _Tibox.start_sort_flight_data(key=key, method=method)
    start_sort_flight_data = pyqtSlot(str, str)(start_sort_flight_data)

    def get_kiosk_status(self):
        _KioskService.get_kiosk_status()
    get_kiosk_status = pyqtSlot()(get_kiosk_status)

    def get_kiosk_price_setting(self):
        _KioskService.get_kiosk_price_setting()
    get_kiosk_price_setting = pyqtSlot()(get_kiosk_price_setting)

    def start_restart_mdd_service(self):
        _KioskService.start_restart_mdd_service()
    start_restart_mdd_service = pyqtSlot()(start_restart_mdd_service)

    def start_safely_shutdown(self, mode):
        safely_shutdown(mode)
    start_safely_shutdown = pyqtSlot(str)(start_safely_shutdown)

    def start_get_cash_data(self):
        _KioskService.start_get_cash_data()
    start_get_cash_data = pyqtSlot()(start_get_cash_data)

    def start_begin_collect_cash(self):
        _KioskService.start_begin_collect_cash()
    start_begin_collect_cash = pyqtSlot()(start_begin_collect_cash)

    def start_search_booking(self, bk):
        _KioskService.start_search_booking(bk)
    start_search_booking = pyqtSlot(str)(start_search_booking)

    def start_reprint(self, new_status):
        _TicketTool.start_reprint(new_status)
    start_reprint = pyqtSlot(str)(start_reprint)

    def start_recreate_payment(self, payment):
        _KioskService.start_recreate_payment(payment)
    start_recreate_payment = pyqtSlot(str)(start_recreate_payment)

    def start_mei_create_payment(self, payment):
        _MEI.start_mei_create_payment(payment)
    start_mei_create_payment = pyqtSlot(str)(start_mei_create_payment)

    def start_idle_mode(self):
        _Sync.start_idle_mode()
    start_idle_mode = pyqtSlot()(start_idle_mode)

    def stop_idle_mode(self):
        _Sync.stop_idle_mode()
    stop_idle_mode = pyqtSlot()(stop_idle_mode)

    def start_get_settlement(self):
        _EDC.start_get_settlement()
    start_get_settlement = pyqtSlot()(start_get_settlement)

    def start_print_global(self, i, u):
        _TicketTool.start_print_global(input_text=i, use_for=u)
    start_print_global = pyqtSlot(str, str)(start_print_global)

    def start_edc_settlement(self):
        _EDC.start_edc_settlement()
    start_edc_settlement = pyqtSlot()(start_edc_settlement)

    def start_void_data(self):
        _EDC.start_void_data()
    start_void_data = pyqtSlot()(start_void_data)

    def start_dummy_edc_receipt(self):
        _EDC.start_dummy_edc_receipt()
    start_dummy_edc_receipt = pyqtSlot()(start_dummy_edc_receipt)

    def start_check_booking_code(self, param):
        _CheckIn.start_check_booking_code(param)
    start_check_booking_code = pyqtSlot(str)(start_check_booking_code)

    def start_get_boarding_pass(self, param):
        _CheckIn.start_get_boarding_pass(param)
    start_get_boarding_pass = pyqtSlot(str)(start_get_boarding_pass)

    def start_get_admin_key(self):
        _KioskService.start_get_admin_key()
    start_get_admin_key = pyqtSlot()(start_get_admin_key)

    def start_check_wallet(self, amount):
        _KioskService.start_check_wallet(amount)
    start_check_wallet = pyqtSlot(str)(start_check_wallet)

    def kiosk_get_product_stock(self):
        _KioskService.kiosk_get_product_stock()
    kiosk_get_product_stock = pyqtSlot()(kiosk_get_product_stock)

    def start_sync_product_stock(self):
        _Sync.start_sync_product_stock()
    start_sync_product_stock = pyqtSlot()(start_sync_product_stock)

    def start_set_direct_price(self, price):
        _MEI.start_set_direct_price(price)
        _GRG.start_set_direct_price(price)
    start_set_direct_price = pyqtSlot(str)(start_set_direct_price)

    def start_multiple_eject(self, attempt, multiply):
        _CD.start_multiple_eject(attempt, multiply)
    start_multiple_eject = pyqtSlot(str, str)(start_multiple_eject)

    def start_store_transaction_global(self, param):
        _KioskService.start_store_transaction_global(param)
    start_store_transaction_global = pyqtSlot(str)(start_store_transaction_global)

    def start_kiosk_get_topup_amount(self):
        _KioskService.start_kiosk_get_topup_amount()
    start_kiosk_get_topup_amount = pyqtSlot()(start_kiosk_get_topup_amount)

    def start_get_topup_readiness(self):
        _QPROX.start_get_topup_readiness()
    start_get_topup_readiness = pyqtSlot()(start_get_topup_readiness)

    def start_sale_print_global(self):
        _SalePrintTool.start_sale_print_global()
    start_sale_print_global = pyqtSlot()(start_sale_print_global)

    def start_top_up_bni(self, amount, trxid):
        _QPROX.start_top_up_bni(amount, trxid)
    start_top_up_bni = pyqtSlot(str, str)(start_top_up_bni)

    def start_get_multiple_eject_status(self):
        _CD.start_get_multiple_eject_status()
    start_get_multiple_eject_status = pyqtSlot()(start_get_multiple_eject_status)

    def create_sale_edc_with_struct_id(self, amount, trxid):
        _EDC.create_sale_edc_with_struct_id(amount, trxid)
    create_sale_edc_with_struct_id = pyqtSlot(str, str)(create_sale_edc_with_struct_id)

    def start_store_topup_transaction(self, param):
        _KioskService.start_store_topup_transaction(param)
    start_store_topup_transaction = pyqtSlot(str)(start_store_topup_transaction)

    def start_get_topup_status_instant(self):
        _QPROX.start_get_topup_status_instant()
    start_get_topup_status_instant = pyqtSlot()(start_get_topup_status_instant)

    def get_kiosk_login(self, username, password):
        _UserService.get_kiosk_login(username, password)
    get_kiosk_login = pyqtSlot(str, str)(get_kiosk_login)

    def kiosk_get_machine_summary(self):
        _KioskService.kiosk_get_machine_summary()
    kiosk_get_machine_summary = pyqtSlot()(kiosk_get_machine_summary)

    def start_change_product_stock(self, port, stock):
        _ProductService.start_change_product_stock(port, stock)
    start_change_product_stock = pyqtSlot(str, str)(start_change_product_stock)

    def start_grg_receive_note(self):
        _GRG.start_grg_receive_note()
    start_grg_receive_note = pyqtSlot()(start_grg_receive_note)

    def stop_grg_receive_note(self):
        _GRG.stop_grg_receive_note()
    stop_grg_receive_note = pyqtSlot()(stop_grg_receive_note)

    def start_get_status_grg(self):
        _GRG.start_get_status_grg()
    start_get_status_grg = pyqtSlot()(start_get_status_grg)

    def start_do_topup_bni(self, slot):
        _TopupService.start_do_topup_bni(slot)
    start_do_topup_bni = pyqtSlot(str)(start_do_topup_bni)

    def start_define_topup_slot_bni(self):
        _TopupService.start_define_topup_slot_bni()
    start_define_topup_slot_bni = pyqtSlot()(start_define_topup_slot_bni)

    def start_init_grg(self):
        _GRG.start_init_grg()
    start_init_grg = pyqtSlot()(start_init_grg)

    def start_upload_device_state(self, device, state):
        _Global.start_upload_device_state(device, state)
    start_upload_device_state = pyqtSlot(str, str)(start_upload_device_state)

    def start_admin_print_global(self, struct_id):
        _SalePrintTool.start_admin_print_global(struct_id)
    start_admin_print_global = pyqtSlot(str)(start_admin_print_global)

    def start_reprint_global(self):
        _SalePrintTool.start_reprint_global()
    start_reprint_global = pyqtSlot()(start_reprint_global)

    # def start_manual_trigger_topup_bni(self):
    #     _Sync.start_manual_trigger_topup_bni()
    # start_manual_trigger_topup_bni = pyqtSlot()(start_manual_trigger_topup_bni)

    def start_master_activation_bni(self):
        _TopupService.start_master_activation_bni()
    start_master_activation_bni = pyqtSlot()(start_master_activation_bni)

    def start_slave_activation_bni(self):
        _TopupService.start_slave_activation_bni()
    start_slave_activation_bni = pyqtSlot()(start_slave_activation_bni)

    def do_reset_pending_master(self):
        _TopupService.do_reset_pending_master()
    do_reset_pending_master = pyqtSlot()(do_reset_pending_master)

    def do_reset_pending_slave(self):
        _TopupService.do_reset_pending_slave()
    do_reset_pending_slave = pyqtSlot()(do_reset_pending_slave)

    def retry_store_transaction_global(self):
        _KioskService.retry_store_transaction_global()
    retry_store_transaction_global = pyqtSlot()(retry_store_transaction_global)

    def kiosk_get_cd_readiness(self):
        _CD.kiosk_get_cd_readiness()
    kiosk_get_cd_readiness = pyqtSlot()(kiosk_get_cd_readiness)

    def user_action_log(self, log):
        _KioskService.user_action_log(log)
    user_action_log = pyqtSlot(str)(user_action_log)

    def python_dump(self, log):
        _KioskService.python_dump(log)
    python_dump = pyqtSlot(str)(python_dump)

    def start_do_mandiri_topup_settlement(self):
        _SettlementService.start_do_mandiri_topup_settlement()
    start_do_mandiri_topup_settlement = pyqtSlot()(start_do_mandiri_topup_settlement)

    def start_dummy_mandiri_topup_settlement(self):
        _SettlementService.start_dummy_mandiri_topup_settlement()
    start_dummy_mandiri_topup_settlement = pyqtSlot()(start_dummy_mandiri_topup_settlement)

    def start_reset_mandiri_settlement(self):
        _SettlementService.start_reset_mandiri_settlement()
    start_reset_mandiri_settlement = pyqtSlot()(start_reset_mandiri_settlement)

    def start_validate_update_balance(self):
        _SettlementService.start_validate_update_balance()
    start_validate_update_balance = pyqtSlot()(start_validate_update_balance)

    def start_do_bni_topup_by_trx(self):
        _Sync.start_do_bni_topup_by_trx()
    start_do_bni_topup_by_trx = pyqtSlot()(start_do_bni_topup_by_trx)

    def start_do_update(self):
        _UpdateAppService.start_do_update()
    start_do_update = pyqtSlot()(start_do_update)

    def start_get_ppob_product(self):
        _PPOBService.start_get_ppob_product()
    start_get_ppob_product = pyqtSlot()(start_get_ppob_product)

    def start_kiosk_get_payment_setting(self):
        _KioskService.start_kiosk_get_payment_setting()
    start_kiosk_get_payment_setting = pyqtSlot()(start_kiosk_get_payment_setting)

    def start_define_ads(self):
        _KioskService.start_define_ads()
    start_define_ads = pyqtSlot()(start_define_ads)

    def start_check_ppob_product(self, msisdn, product_id):
        _PPOBService.start_check_ppob_product(msisdn, product_id)
    start_check_ppob_product = pyqtSlot(str, str)(start_check_ppob_product)

    def start_do_pay_ppob(self, payload):
        _PPOBService.start_do_pay_ppob(payload)
    start_do_pay_ppob = pyqtSlot(str)(start_do_pay_ppob)

    def start_do_topup_ppob(self, payload):
        _PPOBService.start_do_topup_ppob(payload)
    start_do_topup_ppob = pyqtSlot(str)(start_do_topup_ppob)

    def start_check_trx_online(self, reff_no):
        _PPOBService.start_check_trx_online(reff_no)
    start_check_trx_online = pyqtSlot(str)(start_check_trx_online)

    def start_get_qr_gopay(self, payload):
        _QRPaymentService.start_get_qr_gopay(payload)
    start_get_qr_gopay = pyqtSlot(str)(start_get_qr_gopay)

    def start_get_qr_dana(self, payload):
        _QRPaymentService.start_get_qr_dana(payload)
    start_get_qr_dana = pyqtSlot(str)(start_get_qr_dana)

    def start_get_qr_ovo(self, payload):
        _QRPaymentService.start_get_qr_ovo(payload)
    start_get_qr_ovo = pyqtSlot(str)(start_get_qr_ovo)

    def start_get_qr_linkaja(self, payload):
        _QRPaymentService.start_get_qr_linkaja(payload)
    start_get_qr_linkaja = pyqtSlot(str)(start_get_qr_linkaja)

    def start_do_check_gopay_qr(self, payload):
        _QRPaymentService.start_do_check_gopay_qr(payload)
    start_do_check_gopay_qr = pyqtSlot(str)(start_do_check_gopay_qr)

    def start_do_check_dana_qr(self, payload):
        _QRPaymentService.start_do_check_dana_qr(payload)
    start_do_check_dana_qr = pyqtSlot(str)(start_do_check_dana_qr)

    def start_do_check_ovo_qr(self, payload):
        _QRPaymentService.start_do_check_ovo_qr(payload)
    start_do_check_ovo_qr = pyqtSlot(str)(start_do_check_ovo_qr)

    def start_do_check_linkaja_qr(self, payload):
        _QRPaymentService.start_do_check_linkaja_qr(payload)
    start_do_check_linkaja_qr = pyqtSlot(str)(start_do_check_linkaja_qr)

    def start_do_pay_ovo_qr(self, payload):
        _QRPaymentService.start_do_pay_ovo_qr(payload)
    start_do_pay_ovo_qr = pyqtSlot(str)(start_do_pay_ovo_qr)

    def start_confirm_ovo_qr(self, payload):
        _QRPaymentService.start_confirm_ovo_qr(payload)
    start_confirm_ovo_qr = pyqtSlot(str)(start_confirm_ovo_qr)

    def start_check_voucher(self, voucher):
        _ProductService.start_check_voucher(voucher)
    start_check_voucher = pyqtSlot(str)(start_check_voucher)

    def start_use_voucher(self, voucher, reff_no):
        _ProductService.start_use_voucher(voucher, reff_no)
    start_use_voucher = pyqtSlot(str, str)(start_use_voucher)

    def start_get_qr_global(self, payload):
        _QRPaymentService.start_get_qr_global(payload)
    start_get_qr_global = pyqtSlot(str)(start_get_qr_global)

    def start_direct_store_transaction_data(self, payload):
        _KioskService.start_direct_store_transaction_data(payload)
    start_direct_store_transaction_data = pyqtSlot(str)(start_direct_store_transaction_data)

    def start_check_diva_balance(self, username):
        _PPOBService.start_check_diva_balance(username)
    start_check_diva_balance = pyqtSlot(str)(start_check_diva_balance)

    def start_global_refund_balance(self, payload):
        _PPOBService.start_global_refund_balance(payload)
    start_global_refund_balance = pyqtSlot(str)(start_global_refund_balance)

    def start_update_balance_online(self, bank):
        _QPROX.start_update_balance_online(bank)
    start_update_balance_online = pyqtSlot(str)(start_update_balance_online)

    def start_fake_update_dki(self, card_no, amount):
        _QPROX.start_fake_update_dki(card_no, amount)
    start_fake_update_dki = pyqtSlot(str, str)(start_fake_update_dki)

    def start_check_init_cd(self, com):
        _CD.start_check_init_cd(com)
    start_check_init_cd = pyqtSlot(str)(start_check_init_cd)

    def start_log_book_cash(self, pid, amount):
        _GRG.start_log_book_cash(pid, amount)
    start_log_book_cash = pyqtSlot(str, str)(start_log_book_cash)

    def start_store_pending_balance(self, payload):
        _PPOBService.start_store_pending_balance(payload)
    start_store_pending_balance = pyqtSlot(str)(start_store_pending_balance)

    def start_do_force_topup_bni(self):
        _TopupService.start_do_force_topup_bni()
    start_do_force_topup_bni = pyqtSlot()(start_do_force_topup_bni)

    def start_mandiri_update_schedule(self):
        _SettlementService.start_trigger_mandiri_sam_update()
    start_mandiri_update_schedule = pyqtSlot()(start_mandiri_update_schedule)

    def start_reset_receipt_count(self, count):
        _Global.start_reset_receipt_count(count)
    start_reset_receipt_count = pyqtSlot(str)(start_reset_receipt_count)

    def start_trigger_edc_settlement(self):
        _SettlementService.start_trigger_edc_settlement()
    start_trigger_edc_settlement = pyqtSlot()(start_trigger_edc_settlement)

    def start_cancel_qr_global(self, trx_id):
        _QRPaymentService.start_cancel_qr_global(trx_id)
    start_cancel_qr_global = pyqtSlot(str)(start_cancel_qr_global)


def s_handler():
    _KioskService.K_SIGNDLER.SIGNAL_GET_FILE_LIST.connect(view.rootObject().result_get_file_list)
    _KioskService.K_SIGNDLER.SIGNAL_GET_GUI_VERSION.connect(view.rootObject().result_get_gui_version)
    _KioskService.K_SIGNDLER.SIGNAL_GET_KIOSK_NAME.connect(view.rootObject().result_get_kiosk_name)
    _Tibox.T_SIGNDLER.SIGNAL_SET_PLAN.connect(view.rootObject().result_set_plan)
    _Tibox.T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.connect(view.rootObject().result_create_schedule)
    _Tibox.T_SIGNDLER.SIGNAL_CREATE_CHART.connect(view.rootObject().result_create_chart)
    _Tibox.T_SIGNDLER.SIGNAL_POST_PERSON.connect(view.rootObject().result_post_person)
    _Tibox.T_SIGNDLER.SIGNAL_CREATE_BOOKING.connect(view.rootObject().result_create_booking)
    _Tibox.T_SIGNDLER.SIGNAL_CREATE_PAYMENT.connect(view.rootObject().result_create_payment)
    _Tibox.T_SIGNDLER.SIGNAL_CREATE_PRINT.connect(view.rootObject().result_create_print)
    _Tibox.T_SIGNDLER.SIGNAL_CLEAR_PERSON.connect(view.rootObject().result_clear_person)
    _EDC.E_SIGNDLER.SIGNAL_SALE_EDC.connect(view.rootObject().result_sale_edc)
    _KioskService.K_SIGNDLER.SIGNAL_GET_PAYMENTS.connect(view.rootObject().result_get_payment)
    _KioskService.K_SIGNDLER.SIGNAL_GET_REFUNDS.connect(view.rootObject().result_get_refund)
    _Tibox.T_SIGNDLER.SIGNAL_CONFIRM_SCHEDULE.connect(view.rootObject().result_confirm_schedule)
    _MEI.M_SIGNDLER.SIGNAL_ACCEPT_MEI.connect(view.rootObject().result_accept_mei)
    _MEI.M_SIGNDLER.SIGNAL_DIS_ACCEPT_MEI.connect(view.rootObject().result_dis_accept_mei)
    _MEI.M_SIGNDLER.SIGNAL_STACK_MEI.connect(view.rootObject().result_stack_mei)
    _MEI.M_SIGNDLER.SIGNAL_RETURN_MEI.connect(view.rootObject().result_return_mei)
    _MEI.M_SIGNDLER.SIGNAL_STORE_ES_MEI.connect(view.rootObject().result_store_es_mei)
    _MEI.M_SIGNDLER.SIGNAL_RETURN_ES_MEI.connect(view.rootObject().result_return_es_mei)
    _MEI.M_SIGNDLER.SIGNAL_DISPENSE_COU_MEI.connect(view.rootObject().result_dispense_cou_mei)
    _MEI.M_SIGNDLER.SIGNAL_FLOAT_DOWN_COU_MEI.connect(view.rootObject().result_float_down_cou_mei)
    _MEI.M_SIGNDLER.SIGNAL_DISPENSE_VAL_MEI.connect(view.rootObject().result_dispense_val_mei)
    _MEI.M_SIGNDLER.SIGNAL_FLOAT_DOWN_ALL_MEI.connect(view.rootObject().result_float_down_all_mei)
    _MEI.M_SIGNDLER.SIGNAL_RETURN_STATUS.connect(view.rootObject().result_return_status)
    _QPROX.QP_SIGNDLER.SIGNAL_INIT_QPROX.connect(view.rootObject().result_init_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_DEBIT_QPROX.connect(view.rootObject().result_debit_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_AUTH_QPROX.connect(view.rootObject().result_auth_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_BALANCE_QPROX.connect(view.rootObject().result_balance_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_TOPUP_QPROX.connect(view.rootObject().result_topup_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_KA_INFO_QPROX.connect(view.rootObject().result_ka_info_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_ONLINE_INFO_QPROX.connect(view.rootObject().result_online_info_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_INIT_ONLINE_QPROX.connect(view.rootObject().result_init_online_qprox)
    _QPROX.QP_SIGNDLER.SIGNAL_STOP_QPROX.connect(view.rootObject().result_stop_qprox)
    _Tibox.T_SIGNDLER.SIGNAL_GET_AIRPORT_NAME.connect(view.rootObject().result_airport_name)
    _TicketTool.PDF_SIGNDLER.SIGNAL_START_GENERATE.connect(view.rootObject().result_generate_pdf)
    _KioskService.K_SIGNDLER.SIGNAL_GENERAL.connect(view.rootObject().result_general)
    _Tibox.T_SIGNDLER.SIGNAL_DETAILS_PASSENGER.connect(view.rootObject().result_passenger)
    _Tibox.T_SIGNDLER.SIGNAL_FLIGHT_DATA_SORTED.connect(view.rootObject().result_flight_data_sorted)
    _KioskService.K_SIGNDLER.SIGNAL_GET_KIOSK_STATUS.connect(view.rootObject().result_kiosk_status)
    _KioskService.K_SIGNDLER.SIGNAL_PRICE_SETTING.connect(view.rootObject().result_price_setting)
    _KioskService.K_SIGNDLER.SIGNAL_LIST_CASH.connect(view.rootObject().result_list_cash)
    _KioskService.K_SIGNDLER.SIGNAL_COLLECT_CASH.connect(view.rootObject().result_collect_cash)
    _KioskService.K_SIGNDLER.SIGNAL_BOOKING_SEARCH.connect(view.rootObject().result_booking_search)
    _TicketTool.PDF_SIGNDLER.SIGNAL_REPRINT.connect(view.rootObject().result_reprint)
    _KioskService.K_SIGNDLER.SIGNAL_RECREATE_PAYMENT.connect(view.rootObject().result_recreate_payment)
    _EDC.E_SIGNDLER.SIGNAL_GET_SETTLEMENT_EDC.connect(view.rootObject().result_get_settlement)
    _TicketTool.PDF_SIGNDLER.SIGNAL_PRINT_GLOBAL.connect(view.rootObject().result_print_global)
    _EDC.E_SIGNDLER.SIGNAL_PROCESS_SETTLEMENT_EDC.connect(view.rootObject().result_process_settlement)
    _EDC.E_SIGNDLER.SIGNAL_VOID_SETTLEMENT_EDC.connect(view.rootObject().result_void_settlement)
    _CheckIn.CI_SIGNDLER.SIGNAL_CHECK_FLIGHTCODE.connect(view.rootObject().result_check_booking_code)
    _CheckIn.CI_SIGNDLER.SIGNAL_GET_BOARDINGPASS.connect(view.rootObject().result_get_boarding_pass)
    _CheckIn.CI_SIGNDLER.SIGNAL_PRINT_BOARDINGPASS.connect(view.rootObject().result_print_boarding_pass)
    _KioskService.K_SIGNDLER.SIGNAL_ADMIN_KEY.connect(view.rootObject().result_admin_key)
    _KioskService.K_SIGNDLER.SIGNAL_WALLET_CHECK.connect(view.rootObject().result_wallet_check)
    _CD.CD_SIGNDLER.SIGNAL_CD_HOLD.connect(view.rootObject().result_cd_hold)
    _CD.CD_SIGNDLER.SIGNAL_CD_MOVE.connect(view.rootObject().result_cd_move)
    _CD.CD_SIGNDLER.SIGNAL_CD_STOP.connect(view.rootObject().result_cd_stop)
    _KioskService.K_SIGNDLER.SIGNAL_GET_PRODUCT_STOCK.connect(view.rootObject().result_product_stock)
    _KioskService.K_SIGNDLER.SIGNAL_STORE_TRANSACTION.connect(view.rootObject().result_store_transaction)
    _KioskService.K_SIGNDLER.SIGNAL_GET_TOPUP_AMOUNT.connect(view.rootObject().result_topup_amount)
    _QPROX.QP_SIGNDLER.SIGNAL_GET_TOPUP_READINESS.connect(view.rootObject().result_topup_readiness)
    _SalePrintTool.SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.connect(view.rootObject().result_sale_print)
    _CD.CD_SIGNDLER.SIGNAL_MULTIPLE_EJECT.connect(view.rootObject().result_multiple_eject)
    _KioskService.K_SIGNDLER.SIGNAL_STORE_TOPUP.connect(view.rootObject().result_store_topup)
    _UserService.US_SIGNDLER.SIGNAL_USER_LOGIN.connect(view.rootObject().result_user_login)
    _KioskService.K_SIGNDLER.SIGNAL_GET_MACHINE_SUMMARY.connect(view.rootObject().result_kiosk_admin_summary)
    _ProductService.PR_SIGNDLER.SIGNAL_CHANGE_STOCK.connect(view.rootObject().result_change_stock)
    _GRG.GRG_SIGNDLER.SIGNAL_GRG_STATUS.connect(view.rootObject().result_grg_status)
    _GRG.GRG_SIGNDLER.SIGNAL_GRG_RECEIVE.connect(view.rootObject().result_grg_receive)
    _GRG.GRG_SIGNDLER.SIGNAL_GRG_STOP.connect(view.rootObject().result_grg_stop)
    _TopupService.TP_SIGNDLER.SIGNAL_DO_TOPUP_BNI.connect(view.rootObject().result_do_topup_bni)
    _SalePrintTool.SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.connect(view.rootObject().result_admin_print)
    _SalePrintTool.SPRINTTOOL_SIGNDLER.SIGNAL_SALE_REPRINT_GLOBAL.connect(view.rootObject().result_reprint_global)
    _GRG.GRG_SIGNDLER.SIGNAL_GRG_INIT.connect(view.rootObject().result_init_grg)
    _QPROX.QP_SIGNDLER.SIGNAL_REFILL_ZERO.connect(view.rootObject().result_activation_bni)
    _CD.CD_SIGNDLER.SIGNAL_CD_READINESS.connect(view.rootObject().result_cd_readiness)
    _SettlementService.ST_SIGNDLER.SIGNAL_MANDIRI_SETTLEMENT.connect(view.rootObject().result_mandiri_settlement)
    _UpdateAppService.UPDATEAPP_SIGNDLER.SIGNAL_UPDATE_APP.connect(view.rootObject().result_update_app)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_GET_PRODUCTS.connect(view.rootObject().result_get_ppob_product)
    _KioskService.K_SIGNDLER.SIGNAL_GET_PAYMENT_SETTING.connect(view.rootObject().result_get_payment_setting)
    _KioskService.K_SIGNDLER.SIGNAL_SYNC_ADS_CONTENT.connect(view.rootObject().result_sync_ads)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_CHECK_PPOB.connect(view.rootObject().result_check_ppob)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_TRX_PPOB.connect(view.rootObject().result_trx_ppob)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_TRX_CHECK.connect(view.rootObject().result_check_trx)
    _QRPaymentService.QR_SIGNDLER.SIGNAL_GET_QR.connect(view.rootObject().result_get_qr)
    _QRPaymentService.QR_SIGNDLER.SIGNAL_PAY_QR.connect(view.rootObject().result_pay_qr)
    _QRPaymentService.QR_SIGNDLER.SIGNAL_CHECK_QR.connect(view.rootObject().result_check_qr)
    _QRPaymentService.QR_SIGNDLER.SIGNAL_CONFIRM_QR.connect(view.rootObject().result_confirm_qr)
    _ProductService.PR_SIGNDLER.SIGNAL_CHECK_VOUCHER.connect(view.rootObject().result_check_voucher)
    _ProductService.PR_SIGNDLER.SIGNAL_USE_VOUCHER.connect(view.rootObject().result_use_voucher)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_CHECK_BALANCE.connect(view.rootObject().result_diva_balance_check)
    _PPOBService.PPOB_SIGNDLER.SIGNAL_TRANSFER_BALANCE.connect(view.rootObject().result_global_refund_balance)
    _QPROX.QP_SIGNDLER.SIGNAL_UPDATE_BALANCE_ONLINE.connect(view.rootObject().result_update_balance_online)
    _KioskService.K_SIGNDLER.SIGNAL_ADMIN_GET_PRODUCT_STOCK.connect(view.rootObject().result_admin_sync_stock)
    _CD.CD_SIGNDLER.SIGNAL_CD_PORT_INIT.connect(view.rootObject().result_init_check_cd)

LOGGER = None


def safely_shutdown(mode):
    print("pyt: safely_shutdown_initiated...")
    # _Command.handle_file(mode='w', param='315|', path=_Command.MI_GUI)
    # sleep(1)
    os.system('taskkill /f /im cmd.exe')
    sleep(1)
    if mode == 'RESTART':
        os.system('shutdown -r -f -t 5')
    elif mode == 'SHUTDOWN':
        os.system('shutdown /s')
    sleep(3)
    exit()


def config_log():
    global LOGGER
    try:
        if not os.path.exists(sys.path[0] + '/_lLog/'):
            os.makedirs(sys.path[0] + '/_lLog/')
        handler = logging.handlers.TimedRotatingFileHandler(filename=sys.path[0] + '/_lLog/debug.log',
                                                            when='MIDNIGHT',
                                                            interval=1,
                                                            backupCount=60)
        logging.basicConfig(handlers=[handler],
                            level=logging.DEBUG,
                            format='%(asctime)s %(levelname)s %(funcName)s:%(lineno)d: %(message)s',
                            datefmt='%d/%m %H:%M:%S')
        LOGGER = logging.getLogger()
        _Global.init_temp_data()
    except Exception as e:
        print("pyt: Logging Configuration ERROR : ", e)


def get_disk_info():
    encrypt_str = ''
    disk_info = []
    try:
        c = wmi.WMI()
        for physical_disk in c.Win32_DiskDrive():
            encrypt_str = encrypt_str + physical_disk.SerialNumber.strip()
    except Exception as e:
        LOGGER.warning((e))
    disk_info.append(encrypt_str)
    _NetworkAccess.DISK_SERIAL_NUMBER = disk_info[0]
    return disk_info[0] if disk_info[0] is not None else "N/A"


def get_screen_resolution():
    global GLOBAL_HEIGHT, GLOBAL_WIDTH
    try:
        import ctypes
        user32 = ctypes.windll.user32
        # user32.SetProcessDPIAware()
        resolution = [user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)]
        LOGGER.info(('get_screen_resolution : ', str(resolution)))
        screen_js = sys.path[0] + '/_qQml/screen.js'
        GLOBAL_WIDTH = resolution[0]
        GLOBAL_HEIGHT = resolution[1]
        content_js = 'var size = { "width": ' + str(resolution[0]) + ', "height": ' + str(resolution[1]) + '};'
        with open(screen_js, 'w+') as s:
            s.write(content_js)
            s.close()
        LOGGER.info(('write_screen_resolution : ', screen_js, content_js))
    except Exception as e:
        resolution = [0, 0]
        LOGGER.warning(('get_screen_resolution : ', e))
    # print(res)
    return resolution


def process_exist(processname):
    tlcall = 'TASKLIST', '/FI', 'imagename eq %s' % processname
    tlproc = subprocess.Popen(tlcall, shell=True, stdout=subprocess.PIPE)
    tlout = tlproc.communicate()[0].decode('utf-8').strip().split("\r\n")
    if len(tlout) > 1 and processname in tlout[-1]:
        # print('process "%s" is running!' % processname)
        return True
    else:
        # print('process "%s" is NOT running!' % processname)
        return False


def check_db(data_name):
    data_name = data_name + ".db" if ".db" not in data_name else data_name
    if not os.path.exists(sys.path[0] + '/_dDB/' + data_name):
        _Database.init_db()
    LOGGER.info(("DB : ", data_name))


def kill_explorer():
    if INITIAL_SETTING['dev_mode'] is False:
        # os.system('taskkill /f /im explorer.exe')
        pass
    else:
        LOGGER.info('Development Mode is ON')


def disable_screensaver():
    try:
        os.system('reg delete "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /f')
    except Exception as e:
        LOGGER.warning(('Screensaver Disabling ERROR : ', e))


def run_script(scripts):
    if len(scripts) == 0:
        return
    try:
        import platform
        os_ver = platform.platform()
        if 'Windows-7' in os_ver:
            for script in scripts:
                process = subprocess.Popen(sys.path[0] + script, shell=True, stdout=subprocess.PIPE)
                output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
                LOGGER.info(('[INFO] run_script result : ', str(output)))
        else:
            return
    except Exception as e:
        LOGGER.warning(('[ERROR] run_script: ', str(e)))
    # print(('init time result : ', init_time_result))


def check_path(new):
    try:
        process = subprocess.Popen("PATH", shell=True, stdout=subprocess.PIPE)
        output = process.communicate()[0].decode('utf-8').strip().split("\r\n")
        output_ = output[0].split(";")
        if new in output_:
            return True
        else:
            return False
    except Exception as e:
        LOGGER.warning(('check_path is failed : ', e))
        return False


def set_tvc_player(command):
    if command == "":
        return
    elif command == "STOP":
        os.system(sys.path[0] + '/_pPlayer/stop.bat')
        print('pyt: Execute Command --> /_pPlayer/stop.bat')
    elif command == "START":
        if not process_exist("TVCPlayer.scr"):
            print('pyt: Execute Command --> /_pPlayer/start.bat')
            os.system(sys.path[0] + '/_pPlayer/start.bat')
            while True:
                sleep(60)
                print('pyt: Auto Execute Command --> /_pPlayer/stop.bat')
                os.system(sys.path[0] + '/_pPlayer/stop.bat')
                # sleep(3000)
        else:
            pass


def set_ext_keyboard(command):
    if command == "":
        return
    elif command == "STOP":
        os.system('taskkill /f /IM osk.exe')
    elif command == "START":
        if not process_exist('osk.exe'):
            os.system('osk')
        else:
            print('pyt: External Keyboard is already running..!')
    else:
        return


INITIAL_SETTING = dict()
TEMP_CONFIG_JS = '''
var mandiri_update_schedule = "02:00";
var edc_settlement_schedule = "23:00";
var bank_ubal_online = ["MANDIRI", "BNI"];
var master_logo = ["20200226174450cs4c79p1DvSstTqxPV.png"];
var partner_logos = ["202002261744501WN95z1DClnpPR6COJ.png", "20200226174450E1r8h3I4g2NDfMMgvM.png"];
var backgrounds = ["202002261744502niSQy0MVpaktdm8z1.png"];
var running_text = "Silahkan Tekan Layar Untuk Mulai Transaksi";
var running_text_color = "steelblue";
var text_color = "white";
var frame_color = "steelblue";
var background_color = "black";
var tvc_waiting_time = 60;
'''


def init_setting():
    global INITIAL_SETTING
    qml_config = sys.path[0] + '/_qQML/config.js'
    if not os.path.exists(qml_config):
        with open(sys.path[0] + '/_qQML/config.js', 'w+') as qml:
            qml.write(TEMP_CONFIG_JS)
            qml.close()
        LOGGER.info(("CREATE INITIATION_QML_CONFIG ON ", qml_config))
    INITIAL_SETTING['dev_mode'] = _Global.TEST_MODE
    INITIAL_SETTING['db'] = _ConfigParser.get_value('TERMINAL', 'DB')
    INITIAL_SETTING['display'] = get_screen_resolution()
    INITIAL_SETTING['devices'] = _Global.get_devices()
    INITIAL_SETTING['tid'] = _Global.TID
    # setting['prepaid'] = _QPROX.BANKS
    INITIAL_SETTING['server'] = _Global.BACKEND_URL
    INITIAL_SETTING['reloadService'] = _Global.RELOAD_SERVICE
    INITIAL_SETTING['allowedSyncTask'] = _Global.ALLOWED_SYNC_TASK
    # setting['sftpMandiri'] = _Global.SFTP_MANDIRI
    # setting['ftp'] = _Global.FTP
    # setting['bankConfig'] = _Global.BANKS
    INITIAL_SETTING['serviceVersion'] = _Global.get_service_version()
    # pprint(setting)


def update_module(module_list):
    if len(module_list) == 0 or module_list is None:
        return
    try:
        if check_path("C:\Python34\Scripts") is False:
            os.system("PATH %PATH%;C:\Python34\Scripts")
        for mod in module_list:
            subprocess.call("pip install --upgrade " + mod)
            LOGGER.info((str(mod), 'is updated successfully'))
    except Exception as e:
        LOGGER.warning(("update module is failed : ", e))


def install_font():
    # vb script template
    _TEMPL = """ 
    Set objShell = CreateObject("Shell.Application")
    Set objFolder = objShell.Namespace("%s")
    Set objFolderItem = objFolder.ParseName("%s")
    objFolderItem.InvokeVerb("Install")
    """
    vbs_path = os.path.join(os.getcwd(), 'font_install.vbs')
    try:
        font_dir = os.path.join(os.getcwd(), '_fFonts')
        available_fonts = [f for f in os.listdir(font_dir) if f.endswith('.ttf')]
        system_font_dir = os.path.join('C:\\', 'Windows', 'Fonts')
        installed_fonts = [f for f in os.listdir(system_font_dir) if f.endswith('.ttf')]
        new_fonts = list(set(available_fonts) - set(installed_fonts))
        print('pyt: Found fonts to be installed : ' + json.dumps(new_fonts))
        if len(new_fonts) > 0:
            for font in new_fonts:
                f_path = os.path.join(font_dir, font)
                with open(vbs_path, 'w') as _f:
                    _f.write(_TEMPL % (font_dir, font))
                subprocess.call(['cscript.exe', vbs_path])
                print('pyt: Registering Font -> ' + f_path)
                sleep(1)
    except Exception as e:
        print('pyt: Error Register Font -> ' + str(e))
    finally:
        if os.path.exists(vbs_path):
            os.remove(vbs_path)


def check_git_status(log=False):
    process = subprocess.Popen('git status', shell=True, stdout=subprocess.PIPE)
    response = process.communicate()[0].decode('utf-8').strip().split("\r\n")
    if len(response) > 0 and log is True:
        print('pyt: check_git_status : ')
        for r in response:
            print(str(r))


if __name__ == '__main__':
    config_log()
    run_script({'/_setOnStartUp.bat'})
    update_module({})
    install_font()
    check_git_status()
    init_setting()
    disable_screensaver()
    if _Global.LIVE_MODE:
        kill_explorer()
    check_db(INITIAL_SETTING['db'])
    if os.name == 'nt':
        path = '_qQML/'
    else:
        path = sys.path[0] + '/_qQML/'
    SLOT_HANDLER = SlotHandler()
    app = QGuiApplication(sys.argv)
    view = QQuickView()
    context = view.rootContext()
    context.setContextProperty('_SLOT', SLOT_HANDLER)
    print("pyt: Checking Auth to Server...")
    _Sync.start_check_connection(url=INITIAL_SETTING['server'].replace('v2/', '')+'ping', param=INITIAL_SETTING)
    translator = QTranslator()
    translator.load(path + 'INA.qm')
    app.installTranslator(translator)
    view.engine().quit.connect(app.quit)
    view.setSource(QUrl(path + 'Main.qml'))
    s_handler()
    if _Global.LIVE_MODE:
        app.setOverrideCursor(Qt.BlankCursor)
    view.setFlags(Qt.WindowFullscreenButtonHint)
    view.setFlags(Qt.FramelessWindowHint)
    view.resize(GLOBAL_WIDTH, GLOBAL_HEIGHT - 1)
    print("pyt: Table Adjustment...")
    _KioskService.direct_alter_table(["ALTER TABLE PendingRefund ADD COLUMN channel VARCHAR(100) DEFAULT 'DIVA';"])
    sleep(1)
    print("pyt: HouseKeeping Old Local Data/Files...")
    _KioskService.house_keeping(age_month=3)
    sleep(1)
    print("pyt: Syncing Remote Task...")
    _Sync.start_sync_task()
    sleep(.5)
    print("pyt: Syncing Offline Item Transaction...")
    _Sync.start_sync_product_data()
    sleep(.5)
    print("pyt: Syncing Product Stock...")
    _Sync.start_sync_product_stock()
    sleep(.5)
    print("pyt: Syncing Transaction...")
    _Sync.start_sync_data_transaction()
    sleep(.5)
    print("pyt: Syncing Transaction Failure Data...")
    _Sync.start_sync_data_transaction_failure()
    sleep(.5)
    print("pyt: Syncing Topup Records...")
    _Sync.start_sync_topup_records()
    sleep(.5)
    print("pyt: Syncing Topup Amount...")
    _Sync.start_sync_topup_amount()
    sleep(.5)
    print("pyt: Syncing SAM Audit...")
    _Sync.start_sync_sam_audit()
    sleep(.5)
    print("pyt: Retrying Pending Refund...")
    _Sync.start_sync_pending_refund()
    sleep(.5)
    print("pyt: Syncing PPOB Product...")
    _PPOBService.start_init_ppob_product()
    sleep(.5)
    print("pyt: Syncing Machine Status...")
    _Sync.start_sync_machine_status()
    sleep(.5)
    if INITIAL_SETTING['reloadService'] is True:
        sleep(.5)
        print("pyt: Restarting MDDTopUpService...")
        _KioskService.start_restart_mdd_service()
    if _Global.GRG['status'] is True:
        sleep(1)
        print("pyt: Connecting to GRG Bill Acceptor...")
        _GRG.init_grg()
    if _Global.MEI['status'] is True:
        sleep(1)
        print("pyt: Connecting to MEI Bill Acceptor...")
        _MEI.mei_standby_mode()
    if _Global.QPROX['status'] is True:
        print("pyt: Connecting Into Prepaid Reader...")
        sleep(1)
        if _QPROX.open_qprox() is True:
            print("pyt: [INFO] Init Prepaid Reader...")
            _QPROX.init_qprox()
        else:
            print("pyt: [ERROR] Connect to Prepaid Reader...")
    if _Global.CD['status'] is True:
        sleep(.5)
        print("pyt: [INFO] Re-Init CD V2 Configuration...")
        _CD.reinit_v2_config()
    if _QPROX.INIT_MANDIRI is True:
        sleep(.5)
        print("pyt: Triggering Mandiri Balance Validation...")
        _SettlementService.start_validate_update_balance()
    if _QPROX.INIT_BNI is True:
        sleep(.5)
        print("pyt: Triggering BNI Settlement Sync...")
        _Sync.start_sync_settlement_bni()
        sleep(.5)
        print("pyt: Triggering BNI Balance Validation...")
        _TopupService.start_define_topup_slot_bni()
    print("pyt: Syncing Ads Content...")
    sleep(.5)
    _KioskService.start_define_ads(3)
    print("pyt: Do Pending Jobs...")
    sleep(.5)
    _Sync.start_do_pending_job()
    view.show()
    app.exec_()
    del view
