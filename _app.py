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

print("""
    Kiosk Ver: """ + _KioskService.VERSION + """
Powered By: PT. MultiDaya Dinamika
              -2019-
""")

# Set Frame Size Here
GLOBAL_WIDTH = 1920
GLOBAL_HEIGHT = 1080


class SlotHandler(QObject):
    __qualname__ = 'SlotHandler'

    @staticmethod
    def set_language(string):
        print("pyt : selected_language ", string)
        translator.load(path + string)
    set_language = pyqtSlot(str)(set_language)

    @staticmethod
    def get_file_list(dir_):
        _KioskService.get_file_list(dir_=dir_)
    get_file_list = pyqtSlot(str)(get_file_list)

    @staticmethod
    def post_tvc_log(media):
        _KioskService.post_tvc_log(media)
    post_tvc_log = pyqtSlot(str)(post_tvc_log)

    @staticmethod
    def get_gui_version():
        _KioskService.get_gui_version()
    get_gui_version = pyqtSlot()(get_gui_version)

    @staticmethod
    def get_kiosk_name():
        _KioskService.get_kiosk_name()
    get_kiosk_name = pyqtSlot()(get_kiosk_name)

    @staticmethod
    def post_gui_version():
        _KioskService.post_gui_version()
    post_gui_version = pyqtSlot()(post_gui_version)

    @staticmethod
    def set_tvc_player(command):
        set_tvc_player(command)
    set_tvc_player = pyqtSlot(str)(set_tvc_player)

    @staticmethod
    def start_set_plan(param):
        _Tibox.start_set_plan(param)
    start_set_plan = pyqtSlot(str)(start_set_plan)

    @staticmethod
    def start_create_schedule():
        _Tibox.start_create_schedule()
    start_create_schedule = pyqtSlot()(start_create_schedule)

    @staticmethod
    def start_create_chart(param):
        _Tibox.start_create_chart(param)
    start_create_chart = pyqtSlot(str)(start_create_chart)

    @staticmethod
    def start_post_person(param):
        _Tibox.start_post_person(param)
    start_post_person = pyqtSlot(str)(start_post_person)

    @staticmethod
    def start_create_booking():
        _Tibox.start_create_booking()
    start_create_booking = pyqtSlot()(start_create_booking)

    @staticmethod
    def start_create_payment(amount):
        _Tibox.start_create_payment(payment=amount)
    start_create_payment = pyqtSlot(str)(start_create_payment)

    @staticmethod
    def start_create_print():
        _Tibox.start_create_print()
    start_create_print = pyqtSlot()(start_create_print)

    @staticmethod
    def start_clear_person():
        _Tibox.start_clear_person()
    start_clear_person = pyqtSlot()(start_clear_person)

    @staticmethod
    def create_sale_edc(amount):
        _EDC.create_sale_edc(amount=amount)
    create_sale_edc = pyqtSlot(str)(create_sale_edc)

    @staticmethod
    def start_get_device_status():
        _KioskService.start_get_device_status()
    start_get_device_status = pyqtSlot()(start_get_device_status)

    @staticmethod
    def start_confirm_schedule():
        _Tibox.start_confirm_schedule()
    start_confirm_schedule = pyqtSlot()(start_confirm_schedule)

    @staticmethod
    def start_accept_mei():
        _MEI.start_accept_mei()
    start_accept_mei = pyqtSlot()(start_accept_mei)

    @staticmethod
    def start_dis_accept_mei():
        _MEI.start_dis_accept_mei()
    start_dis_accept_mei = pyqtSlot()(start_dis_accept_mei)

    @staticmethod
    def start_stack_mei():
        _MEI.start_stack_mei()
    start_stack_mei = pyqtSlot()(start_stack_mei)

    @staticmethod
    def start_return_mei():
        _MEI.start_return_mei()
    start_return_mei = pyqtSlot()(start_return_mei)

    @staticmethod
    def start_store_es_mei():
        _MEI.start_store_es_mei()
    start_store_es_mei = pyqtSlot()(start_store_es_mei)

    @staticmethod
    def start_return_es_mei():
        _MEI.start_return_es_mei()
    start_return_es_mei = pyqtSlot()(start_return_es_mei)

    @staticmethod
    def start_dispense_cou_mei():
        _MEI.start_dispense_cou_mei()
    start_dispense_cou_mei = pyqtSlot()(start_dispense_cou_mei)

    @staticmethod
    def start_float_down_cou_mei():
        _MEI.start_float_down_cou_mei()
    start_float_down_cou_mei = pyqtSlot()(start_float_down_cou_mei)

    @staticmethod
    def start_dispense_val_mei(amount):
        _MEI.start_dispense_val_mei(amount=amount)
    start_dispense_val_mei = pyqtSlot(str)(start_dispense_val_mei)

    @staticmethod
    def start_float_down_all_mei():
        _MEI.start_float_down_all_mei()
    start_float_down_all_mei = pyqtSlot()(start_float_down_all_mei)

    @staticmethod
    def start_get_return_note():
        _MEI.start_get_return_note()
    start_get_return_note = pyqtSlot()(start_get_return_note)

    @staticmethod
    def start_init_qprox():
        _QPROX.start_init_qprox()
    start_init_qprox = pyqtSlot()(start_init_qprox)

    @staticmethod
    def start_debit_qprox(amount):
        _QPROX.start_debit_qprox(amount)
    start_debit_qprox = pyqtSlot(str)(start_debit_qprox)

    @staticmethod
    def start_auth_ka():
        _QPROX.start_auth_ka()
    start_auth_ka = pyqtSlot()(start_auth_ka)

    @staticmethod
    def start_check_balance():
        _QPROX.start_check_balance()
    start_check_balance = pyqtSlot()(start_check_balance)

    @staticmethod
    def start_top_up_mandiri(amount, trxid):
        _QPROX.start_top_up_mandiri(amount, trxid)
    start_top_up_mandiri = pyqtSlot(str, str)(start_top_up_mandiri)

    @staticmethod
    def start_ka_info():
        _QPROX.start_ka_info()
    start_ka_info = pyqtSlot()(start_ka_info)

    @staticmethod
    def start_create_online_info():
        _QPROX.start_create_online_info()
    start_create_online_info = pyqtSlot()(start_create_online_info)

    @staticmethod
    def start_init_online():
        _QPROX.start_init_online()
    start_init_online = pyqtSlot()(start_init_online)

    @staticmethod
    def set_rounded_fare(amount):
        _Tibox.set_rounded_fare(amount=amount)
    set_rounded_fare = pyqtSlot(str)(set_rounded_fare)

    @staticmethod
    def start_disconnect_mei():
        _MEI.start_disconnect_mei()
    start_disconnect_mei = pyqtSlot()(start_disconnect_mei)

    @staticmethod
    def start_disconnect_edc():
        _EDC.start_disconnect_edc()
    start_disconnect_edc = pyqtSlot()(start_disconnect_edc)

    @staticmethod
    def start_disconnect_qprox():
        _QPROX.start_disconnect_qprox()
    start_disconnect_qprox = pyqtSlot()(start_disconnect_qprox)

    @staticmethod
    def start_get_airport_name(prefix1, prefix2):
        _Tibox.start_get_airport_name(prefix1=prefix1, prefix2=prefix2)
    start_get_airport_name = pyqtSlot(str, str)(start_get_airport_name)

    @staticmethod
    def start_generate(mode):
        _TicketTool.start_generate(use=mode)
    start_generate = pyqtSlot(str)(start_generate)

    @staticmethod
    def start_default_print(path):
        _Printer.start_default_print(path)
    start_default_print = pyqtSlot(str)(start_default_print)

    @staticmethod
    def start_set_payment(payment):
        _TicketTool.start_set_payment(payment=payment)
    start_set_payment = pyqtSlot(str)(start_set_payment)

    @staticmethod
    def start_send_details_passenger():
        _Tibox.start_send_details_passenger()
    start_send_details_passenger = pyqtSlot()(start_send_details_passenger)

    @staticmethod
    def start_sort_flight_data(key, method):
        _Tibox.start_sort_flight_data(key=key, method=method)
    start_sort_flight_data = pyqtSlot(str, str)(start_sort_flight_data)

    @staticmethod
    def get_kiosk_status():
        _KioskService.get_kiosk_status()
    get_kiosk_status = pyqtSlot()(get_kiosk_status)

    @staticmethod
    def get_kiosk_price_setting():
        _KioskService.get_kiosk_price_setting()
    get_kiosk_price_setting = pyqtSlot()(get_kiosk_price_setting)

    @staticmethod
    def start_restart_mdd_service():
        _KioskService.start_restart_mdd_service()
    start_restart_mdd_service = pyqtSlot()(start_restart_mdd_service)

    @staticmethod
    def start_safely_shutdown(mode):
        safely_shutdown(mode)
    start_safely_shutdown = pyqtSlot(str)(start_safely_shutdown)

    @staticmethod
    def start_get_cash_data():
        _KioskService.start_get_cash_data()
    start_get_cash_data = pyqtSlot()(start_get_cash_data)

    @staticmethod
    def start_begin_collect_cash():
        _KioskService.start_begin_collect_cash()
    start_begin_collect_cash = pyqtSlot()(start_begin_collect_cash)

    @staticmethod
    def start_search_booking(bk):
        _KioskService.start_search_booking(bk)
    start_search_booking = pyqtSlot(str)(start_search_booking)

    @staticmethod
    def start_reprint(new_status):
        _TicketTool.start_reprint(new_status)
    start_reprint = pyqtSlot(str)(start_reprint)

    @staticmethod
    def start_recreate_payment(payment):
        _KioskService.start_recreate_payment(payment)
    start_recreate_payment = pyqtSlot(str)(start_recreate_payment)

    @staticmethod
    def start_mei_create_payment(payment):
        _MEI.start_mei_create_payment(payment)
    start_mei_create_payment = pyqtSlot(str)(start_mei_create_payment)

    @staticmethod
    def start_idle_mode():
        _Sync.start_idle_mode()
    start_idle_mode = pyqtSlot()(start_idle_mode)

    @staticmethod
    def stop_idle_mode():
        _Sync.stop_idle_mode()
    stop_idle_mode = pyqtSlot()(stop_idle_mode)

    @staticmethod
    def start_get_settlement():
        _EDC.start_get_settlement()
    start_get_settlement = pyqtSlot()(start_get_settlement)

    @staticmethod
    def start_print_global(i, u):
        _TicketTool.start_print_global(input_text=i, use_for=u)
    start_print_global = pyqtSlot(str, str)(start_print_global)

    @staticmethod
    def start_edc_settlement():
        _EDC.start_edc_settlement()
    start_edc_settlement = pyqtSlot()(start_edc_settlement)

    @staticmethod
    def start_void_data():
        _EDC.start_void_data()
    start_void_data = pyqtSlot()(start_void_data)

    @staticmethod
    def start_dummy_edc_receipt():
        _EDC.start_dummy_edc_receipt()
    start_dummy_edc_receipt = pyqtSlot()(start_dummy_edc_receipt)

    @staticmethod
    def start_check_booking_code(param):
        _CheckIn.start_check_booking_code(param)
    start_check_booking_code = pyqtSlot(str)(start_check_booking_code)

    @staticmethod
    def start_get_boarding_pass(param):
        _CheckIn.start_get_boarding_pass(param)
    start_get_boarding_pass = pyqtSlot(str)(start_get_boarding_pass)

    @staticmethod
    def start_get_admin_key():
        _KioskService.start_get_admin_key()
    start_get_admin_key = pyqtSlot()(start_get_admin_key)

    @staticmethod
    def start_check_wallet(amount):
        _KioskService.start_check_wallet(amount)
    start_check_wallet = pyqtSlot(str)(start_check_wallet)

    @staticmethod
    def kiosk_get_product_stock():
        _KioskService.kiosk_get_product_stock()
    kiosk_get_product_stock = pyqtSlot()(kiosk_get_product_stock)

    @staticmethod
    def start_sync_product_stock():
        _Sync.start_sync_product_stock()
    start_sync_product_stock = pyqtSlot()(start_sync_product_stock)

    @staticmethod
    def start_set_direct_price(price):
        _MEI.start_set_direct_price(price)
    start_set_direct_price = pyqtSlot(str)(start_set_direct_price)

    @staticmethod
    def start_multiple_eject(attempt, multiply):
        _CD.start_multiple_eject(attempt, multiply)
    start_multiple_eject = pyqtSlot(str, str)(start_multiple_eject)

    @staticmethod
    def start_store_transaction_global(param):
        _KioskService.start_store_transaction_global(param)
    start_store_transaction_global = pyqtSlot(str)(start_store_transaction_global)

    @staticmethod
    def start_kiosk_get_topup_amount():
        _KioskService.start_kiosk_get_topup_amount()
    start_kiosk_get_topup_amount = pyqtSlot()(start_kiosk_get_topup_amount)

    @staticmethod
    def start_get_topup_readiness():
        _QPROX.start_get_topup_readiness()
    start_get_topup_readiness = pyqtSlot()(start_get_topup_readiness)

    @staticmethod
    def start_sale_print_global():
        _SalePrintTool.start_sale_print_global()
    start_sale_print_global = pyqtSlot()(start_sale_print_global)

    @staticmethod
    def start_top_up_bni(amount, trxid):
        _QPROX.start_top_up_bni(amount, trxid)
    start_top_up_bni = pyqtSlot(str, str)(start_top_up_bni)

    @staticmethod
    def start_get_multiple_eject_status():
        _CD.start_get_multiple_eject_status()
    start_get_multiple_eject_status = pyqtSlot()(start_get_multiple_eject_status)

    @staticmethod
    def create_sale_edc_with_struct_id(amount, trxid):
        _EDC.create_sale_edc_with_struct_id(amount, trxid)
    create_sale_edc_with_struct_id = pyqtSlot(str, str)(create_sale_edc_with_struct_id)

    @staticmethod
    def start_store_topup_transaction(param):
        _KioskService.start_store_topup_transaction(param)
    start_store_topup_transaction = pyqtSlot(str)(start_store_topup_transaction)

    @staticmethod
    def start_get_topup_status_instant():
        _QPROX.start_get_topup_status_instant()
    start_get_topup_status_instant = pyqtSlot()(start_get_topup_status_instant)

    @staticmethod
    def get_kiosk_login(username, password):
        _UserService.get_kiosk_login(username, password)
    get_kiosk_login = pyqtSlot(str, str)(get_kiosk_login)

    @staticmethod
    def kiosk_get_machine_summary():
        _KioskService.kiosk_get_machine_summary()
    kiosk_get_machine_summary = pyqtSlot()(kiosk_get_machine_summary)

    @staticmethod
    def start_change_product_stock(port, stock):
        _ProductService.start_change_product_stock(port, stock)
    start_change_product_stock = pyqtSlot(str, str)(start_change_product_stock)

    @staticmethod
    def start_grg_receive_note():
        _GRG.start_grg_receive_note()
    start_grg_receive_note = pyqtSlot()(start_grg_receive_note)

    @staticmethod
    def stop_grg_receive_note():
        _GRG.stop_grg_receive_note()
    stop_grg_receive_note = pyqtSlot()(stop_grg_receive_note)

    @staticmethod
    def start_get_status_grg():
        _GRG.start_get_status_grg()
    start_get_status_grg = pyqtSlot()(start_get_status_grg)

    @staticmethod
    def start_do_topup_bni(slot):
        _TopupService.start_do_topup_bni(slot)
    start_do_topup_bni = pyqtSlot(str)(start_do_topup_bni)

    @staticmethod
    def start_define_topup_slot_bni():
        _TopupService.start_define_topup_slot_bni()
    start_define_topup_slot_bni = pyqtSlot()(start_define_topup_slot_bni)

    @staticmethod
    def start_init_grg():
        _GRG.start_init_grg()
    start_init_grg = pyqtSlot()(start_init_grg)

    @staticmethod
    def start_upload_device_state(device, state):
        _Global.start_upload_device_state(device, state)
    start_upload_device_state = pyqtSlot(str, str)(start_upload_device_state)

    @staticmethod
    def start_admin_print_global(struct_id):
        _SalePrintTool.start_admin_print_global(struct_id)
    start_admin_print_global = pyqtSlot(str)(start_admin_print_global)

    @staticmethod
    def start_reprint_global():
        _SalePrintTool.start_reprint_global()
    start_reprint_global = pyqtSlot()(start_reprint_global)

    # def start_manual_trigger_topup_bni(self):
    #     _Sync.start_manual_trigger_topup_bni()
    # start_manual_trigger_topup_bni = pyqtSlot()(start_manual_trigger_topup_bni)

    @staticmethod
    def start_master_activation_bni():
        _TopupService.start_master_activation_bni()

    start_master_activation_bni = pyqtSlot()(start_master_activation_bni)

    @staticmethod
    def start_slave_activation_bni():
        _TopupService.start_slave_activation_bni()
    start_slave_activation_bni = pyqtSlot()(start_slave_activation_bni)

    @staticmethod
    def do_reset_pending_master():
        _TopupService.do_reset_pending_master()
    do_reset_pending_master = pyqtSlot()(do_reset_pending_master)

    @staticmethod
    def do_reset_pending_slave():
        _TopupService.do_reset_pending_slave()
    do_reset_pending_slave = pyqtSlot()(do_reset_pending_slave)

    @staticmethod
    def retry_store_transaction_global():
        _KioskService.retry_store_transaction_global()
    retry_store_transaction_global = pyqtSlot()(retry_store_transaction_global)

    @staticmethod
    def kiosk_get_cd_readiness():
        _CD.kiosk_get_cd_readiness()
    kiosk_get_cd_readiness = pyqtSlot()(kiosk_get_cd_readiness)

    @staticmethod
    def user_action_log(log):
        _KioskService.user_action_log(log)
    user_action_log = pyqtSlot(str)(user_action_log)

    @staticmethod
    def start_do_mandiri_topup_settlement():
        _SettlementService.start_do_mandiri_topup_settlement()
    start_do_mandiri_topup_settlement = pyqtSlot()(start_do_mandiri_topup_settlement)

    @staticmethod
    def start_dummy_mandiri_topup_settlement():
        _SettlementService.start_dummy_mandiri_topup_settlement()
    start_dummy_mandiri_topup_settlement = pyqtSlot()(start_dummy_mandiri_topup_settlement)

    @staticmethod
    def start_reset_mandiri_settlement():
        _SettlementService.start_reset_mandiri_settlement()
    start_reset_mandiri_settlement = pyqtSlot()(start_reset_mandiri_settlement)

    @staticmethod
    def start_validate_update_balance():
        _SettlementService.start_validate_update_balance()
    start_validate_update_balance = pyqtSlot()(start_validate_update_balance)

    @staticmethod
    def start_do_bni_topup_by_trx():
        _Sync.start_do_bni_topup_by_trx()
    start_do_bni_topup_by_trx = pyqtSlot()(start_do_bni_topup_by_trx)

    @staticmethod
    def start_do_update():
        _UpdateAppService.start_do_update()
    start_do_update = pyqtSlot()(start_do_update)


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
    _KioskService.K_SIGNDLER.SIGNAL_GET_DEVICE_STAT.connect(view.rootObject().result_get_device)
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


LOGGER = None


def safely_shutdown(mode):
    print("safely_shutdown_initiated...")
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
    except Exception as e:
        print("Logging Configuration ERROR : ", e)


def get_disk_info():
    encrypt_str = ''
    disk_info = []
    try:
        c = wmi.WMI()
        for physical_disk in c.Win32_DiskDrive():
            encrypt_str = encrypt_str + physical_disk.SerialNumber.strip()
    except Exception as e:
        LOGGER.warning(('get_disk_info : ', e))
    disk_info.append(encrypt_str)
    _NetworkAccess.DISK_SERIAL_NUMBER = disk_info[0]
    return disk_info[0] if disk_info[0] is not None else "N/A"


def get_screen_resolution():
    try:
        import ctypes
        user32 = ctypes.windll.user32
        # user32.SetProcessDPIAware()
        _RES = [user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)]
        LOGGER.info(('get_screen_resolution : ', str(_RES)))
        screen_js = sys.path[0] + '/_qQml/screen.js'
        content_js = 'var size = { "width": ' + str(_RES[0]) + ', "height": ' + str(_RES[1]) + '};'
        with open(screen_js, 'w+') as s:
            s.write(content_js)
            s.close()
        LOGGER.info(('write_screen_resolution : ', screen_js, content_js))
    except Exception as e:
        _RES = [0, 0]
        LOGGER.warning(('get_screen_resolution : ', e))
    # print(res)
    return _RES


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
    if setting['dev_mode'] is False:
        os.system('taskkill /f /im explorer.exe')
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
    global setting
    if command == "":
        return
    elif command == "STOP":
        os.system(sys.path[0] + '/_pPlayer/stop.bat')
        # print("pyt: External Command Disabled for 64 Bit")
    elif command == "START":
        if not process_exist("TVCPlayer.scr"):
            os.system(sys.path[0] + '/_pPlayer/start.bat')
            # print("pyt: External Command Disabled for 64 Bit")
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
            print('External Keyboard is already running..!')
    else:
        return


setting = dict()


def init_setting():
    global setting
    if _ConfigParser.get_value('TERMINAL', 'mode') == "dev":
        setting['dev_mode'] = True
    else:
        setting['dev_mode'] = False
    setting['db'] = _ConfigParser.get_value('TERMINAL', 'DB')
    setting['display'] = get_screen_resolution()
    setting['devices'] = _Global.get_devices()
    setting['tid'] = _Global.TID
    setting['prepaid'] = _QPROX.BANKS
    setting['server'] = _Global.BACKEND_URL
    setting['reloadService'] = _Global.RELOAD_SERVICE
    setting['sftpMandiri'] = _Global.SFTP_MANDIRI
    setting['ftp'] = _Global.FTP
    setting['testUsage'] = _Global.TEST_MODE
    setting['bankConfig'] = _Global.BANKS
    setting['serviceVersion'] = _Global.get_service_version()
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
        for filename in os.listdir(font_dir):
            f_path = os.path.join(font_dir, filename)
            if f_path[-4:] == ".ttf":
                with open(vbs_path, 'w') as _f:
                    _f.write(_TEMPL % (font_dir, filename))
                subprocess.call(['cscript.exe', vbs_path])
                print('pyt : Registering Font -> ' + font_dir + filename)
                sleep(1)
    except Exception as e:
        print('pyt : Error Register Font -> ' + str(e))
    finally:
        os.remove(vbs_path)


if __name__ == '__main__':
    config_log()
    run_script({'/_setOnStartUp.bat'})
    update_module({})
    init_setting()
    disable_screensaver()
    if not _Global.TEST_MODE:
        kill_explorer()
    check_db(setting['db'])
    if os.name == 'nt':
        path = '_qQML/'
    else:
        path = sys.path[0] + '/_qQML/'
    SLOT_HANDLER = SlotHandler()
    app = QGuiApplication(sys.argv)
    view = QQuickView()
    context = view.rootContext()
    context.setContextProperty('_SLOT', SLOT_HANDLER)
    translator = QTranslator()
    translator.load(path + 'INA.qm')
    app.installTranslator(translator)
    view.engine().quit.connect(app.quit)
    view.setSource(QUrl(path + 'Main.qml'))
    s_handler()
    if not _Global.TEST_MODE:
        app.setOverrideCursor(Qt.BlankCursor)
    view.setFlags(Qt.WindowFullscreenButtonHint)
    view.setFlags(Qt.FramelessWindowHint)
    view.resize(GLOBAL_WIDTH, GLOBAL_HEIGHT - 1)
    print("Checking Auth to Server...")
    _Sync.start_check_connection(url=setting['server'] + 'ping', param=setting)
    sleep(1)
    print("Getting Machine Status...")
    _Sync.start_sync_machine_status()
    sleep(1)
    # print("Adjusting Local Table...")
    # _KioskService.adjust_table('_AdjustReceipts.sql')
    # _KioskService.adjust_table('_TopUpRecords.sql', 'TopUpRecords')
    # _KioskService.adjust_table('_SAMAudit.sql', 'SAMAudit')
    # _KioskService.adjust_table('_TransactionFailure.sql', 'TransactionFailure')
    # sleep(1)
    print("Remove Improper Data...")
    _KioskService.reset_db_record()
    sleep(1)
    print("HouseKeeping Old Local Data...")
    _KioskService.house_keeping(age_month=2)
    sleep(1)
    print("Syncing Remote Task...")
    _Sync.start_sync_task()
    sleep(1)
    print("Syncing Product Item...")
    _Sync.start_sync_product_data()
    sleep(.5)
    print("Syncing Transaction...")
    _Sync.start_sync_data_transaction()
    sleep(.5)
    print("Syncing Topup Records...")
    _Sync.start_sync_topup_records()
    sleep(.5)
    print("Syncing Topup Amount...")
    _Sync.start_get_topup_amount()
    sleep(.5)
    # print("Syncing Product Stock...")
    # _Sync.start_sync_product_stock()
    # sleep(.5)
    print("Syncing SAM Audit...")
    _Sync.start_sync_sam_audit()
    sleep(.5)
    print("Syncing Transaction Failure Data...")
    _Sync.start_sync_data_transaction_failure()
    sleep(.5)
    # print("Syncing BNI Settlement...")
    # _Sync.start_sync_settlement_bni()
    if setting['reloadService'] is True:
        sleep(.5)
        print("Restarting MDDTopUpService...")
        _KioskService.start_restart_mdd_service()
    if _Global.MEI['status'] is True:
        sleep(1)
        print("Connecting to MEI Bill Acceptor...")
        _MEI.mei_standby_mode()
    if _Global.GRG['status'] is True:
        sleep(1)
        print("Connecting to GRG Bill Acceptor...")
        _GRG.init_grg()
    if _Global.QPROX['status'] is True:
        sleep(1)
        print("Connecting Into Prepaid Reader...")
        if _QPROX.open_qprox() is True:
            sleep(1)
            print("INIT Prepaid Reader...")
            _QPROX.init_qprox()
        else:
            print("[ERROR] Connect to Prepaid Reader...")
    sleep(.5)
    if _Global.CD['status'] is True:
        print("[INFO] Re-Init CD V2 Configuration...")
        _CD.reinit_v2_config()
    sleep(.5)
    print("Triggering Mandiri Balance Validation...")
    _SettlementService.start_validate_update_balance()
    #     sleep(.25)
    #     print("[INFO] Test Connecting Into Card Dispenser...102")
    #     _CD.start_multiple_eject('102')
    #     sleep(.25)
    #     print("[INFO] Test Connecting Into Card Dispenser...103")
    #     _CD.start_multiple_eject('103')
    # if _Global.TEST_MODE is True:
    #     print("[INFO] Test Push File Over SFTP")
    #     _SFTPAccess.get_file('kiosk.ver')
    view.show()
    app.exec_()
    del view
