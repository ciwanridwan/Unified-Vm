__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
from fpdf import FPDF
import sys
import os
import json
from datetime import datetime
from _tTools import _Tools
from PyQt5.QtCore import QObject, pyqtSignal
from _dDevice import _Printer
from _sService import _KioskService
from _cConfig import _Global
from _sService import _UserService
from _sService import _ProductService
from _dDAO import _DAO
from time import sleep
import re

LOGGER = logging.getLogger()


class SPrintToolSignalHandler(QObject):
    __qualname__ = 'SPrintToolSignalHandler'
    SIGNAL_SALE_START_GENERATE = pyqtSignal(str)
    SIGNAL_SALE_PRINT_GLOBAL = pyqtSignal(str)
    SIGNAL_SALE_REPRINT_GLOBAL = pyqtSignal(str)
    SIGNAL_ADMIN_PRINT_GLOBAL = pyqtSignal(str)


SPRINTTOOL_SIGNDLER = SPrintToolSignalHandler()
PATH = os.path.join(sys.path[0], '_pPDF')
if not os.path.exists(PATH):
    os.makedirs(PATH)
FONT_PATH = os.path.join(sys.path[0], '_aAsset')
if not os.path.exists(FONT_PATH):
    os.makedirs(FONT_PATH)
LOGO_PATH = os.path.join(sys.path[0], '_aAsset', 'mandiri_logo.gif')


def get_paper_size(ls=None):
    p = {'WIDTH': 80, 'HEIGHT': 80}
    if ls is not None:
        ls = ls.split('\r\n')
        p['HEIGHT'] = p['WIDTH'] + (3.5 * len(ls))
    return p


MARGIN_LEFT = 0
HEADER_FONT_SIZE = 8.5
SPACING = 5
RECEIPT_TITLE = 'SALE GLOBAL PRINT'


class PDF(FPDF):
    def header(self):
        # Logo
        if os.path.isfile(LOGO_PATH):
            self.image(LOGO_PATH, 25, 5, 30)
        self.ln(SPACING*2)
        self.set_font(USED_FONT, '', HEADER_FONT_SIZE)
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'VM ID : '+_KioskService.TID, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'VM Name : '+_KioskService.KIOSK_NAME, 0, 1, 'C')

    def footer(self):
        self.set_font(USED_FONT, '', HEADER_FONT_SIZE)
        self.set_y(-20)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, '--Terima Kasih--', 0, 0, 'C')
        # self.ln(SPACING)
        # self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'Layanan Pelanggan Hubungi 0812-XXXX-XXXX', 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, '-APP VER: ' + _KioskService.VERSION+'-', 0, 0, 'C')


class GeneralPDF(FPDF):
    def header(self):
        self.set_font(USED_FONT, '', 7)
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, 'VM ACCESS REPORT', 0, 0, 'C')
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, 'VM ID : '+_KioskService.TID, 0, 0, 'C')
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, 'VM Name : '+_KioskService.KIOSK_NAME, 0, 1, 'C')

    def footer(self):
        self.set_font(USED_FONT, '', 7)
        self.set_y(-20)
        self.cell(MARGIN_LEFT, 7, '(TTD Petugas TJ)   (TTD Petugas MDD)', 0, 0, 'C')
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, '--Internal Use Only--', 0, 0, 'C')


def load_strings(param):
    strings_list = []
    for i in range(len(param)):
        strings_list.append(param[i])
    return '\r\n'.join(strings_list)


def get_path(file):
    return os.path.join(PATH, file)


PARAM = {}
GET_PAYMENT_METHOD = None
GET_CARD_NO = None
GET_PAYMENT_NOTES = None
GET_TOTAL_NOTES = 0
MAX_LENGTH = 36
USED_FONT = 'Courier'


def chunk_text(text, lenght=24, delimiter="\r\n"):
    if len(text) <= lenght:
        return text
    else:
        return text[:lenght] + delimiter + text[lenght:]


def font_path(font):
    return os.path.join(sys.path[0], '_aAsset', font)


def justifying(left, right):
    return left + (" " * (MAX_LENGTH-len(left)-len(right))) + right


def start_sale_print_global():
    _Tools.get_pool().apply_async(sale_print_global,)

    # '{"date":"Thursday, March 07, 2019","epoch":1551970698740,"payment":"cash","shop_type":"shop","time":"9:58:18 PM",
    # "qty":4,"value":"3000","provider":"Kartu Prabayar","raw":{"init_price":500,"syncFlag":1,"createdAt":1551856851000,
    # "stock":99,"pid":"testprod001","name":"Test Product","status":1,"sell_price":750,"stid":"stid001",
    # "remarks":"TEST STOCK PRODUCT"},"notes":"DEBUG_TEST - 1551970698879"}'

    # '{"date":"Thursday, March 07, 2019","epoch":1551970911009,"payment":"debit","shop_type":"topup","time":"10:01:51 PM",
    # "qty":1,"value":"50000","provider":"e-Money Mandiri","raw":{"provider":"e-Money Mandiri","value":"50000"},
    # "notes":"DEBUG_TEST - 1551970911187"}')


def start_reprint_global():
    _Tools.get_pool().apply_async(sale_reprint_global,)


LAST_TRX = None


def sale_print_global(ext='.pdf'):
    global LAST_TRX
    if _KioskService.GLOBAL_TRANSACTION_DATA is None:
        LOGGER.warning(('Cannot Generate Receipt Data', 'GLOBAL_TRANSACTION_DATA', 'None'))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
        return
    LAST_TRX = _KioskService.GLOBAL_TRANSACTION_DATA
    p = LAST_TRX
    pdf = None
    # Init Variables
    tiny_space = 5
    extra_size = 9
    line_size = 9
    padding_left = 0
    trxid = ''
    failure = 'USER_CANCELLATION'
    cash = 0
    try:
        cash = int(p['payment_received'])
        # paper_ = get_paper_size('\r\n'.join(p.keys()))
        pdf = PDF('P', 'mm', (80, 120))
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+p['shop_type']
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%Y-%m-%d')+' Jam : ' +
                 datetime.strftime(datetime.now(), '%H:%M'), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        trxid = p['shop_type']+str(p['epoch'])
        pdf.cell(padding_left, 0, 'TRX ID : '+trxid, 0, 0, 'L')
        pdf.ln(extra_size)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, p['shop_type'].upper()+' '+p['provider'], 0, 0, 'L')
        if 'payment_error' not in p.keys():
            if p['shop_type'] == 'topup':
                if 'topup_details' in p.keys():
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    if 'Mandiri' in p['provider']:
                        pdf.cell(padding_left, 0, 'TID : ' + _Global.TID_MAN, 0, 0, 'L')
                    else:
                        pdf.cell(padding_left, 0, 'TID : ' + _Global.TID_BNI, 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'No. Kartu : ' + p['topup_details']['card_no'], 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    saldo_awal = int(p['topup_details']['last_balance']) - (int(p['value']) - int(p['admin_fee']))
                    pdf.cell(padding_left, 0, 'Saldo Awal : Rp. ' + clean_number(str(saldo_awal)), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    __refill = int(p['value']) - int(p['admin_fee'])
                    pdf.cell(padding_left, 0, 'Isi Ulang : Rp. ' + clean_number(str(__refill)), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'Biaya Admin : Rp. ' + clean_number(p['admin_fee']), 0, 0, 'L')
                    pdf.ln(extra_size)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(0, 0, 'SALDO AKHIR : Rp. ' + clean_number(str(p['final_balance'])), 0, 0, 'L')
                else:
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'NO. KARTU : ' + p['raw']['card_no'], 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'SALDO : Rp. ' + clean_number(p['raw']['prev_balance']), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'STATUS ISI ULANG KARTU GAGAL', 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0,
                             'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
                    failure = 'TOPUP_FAILURE'
            # pdf.ln(extra_size)
            # pdf.set_font(USED_FONT, '', line_size)
            # sub_total = str(int(int(p['value'])/1.1))
            # vat = str(int(p['value'])-int(sub_total))
            # pdf.cell(padding_left, 0, 'SubTotal: Rp. ' + clean_number(sub_total), 0, 0, 'R')
            # if p['shop_type'] == 'topup':
            # pdf.ln(tiny_space)
            # pdf.set_font('UniSpace', '', line_size)
            # pdf.cell(padding_left, 0, 'VAT 10%: Rp. ' + clean_number(vat), 0, 0, 'R')
            # pdf.ln(tiny_space)
            # pdf.set_font(USED_FONT, '', line_size)
            # pdf.cell(padding_left, 0, 'Payment: ' + p['payment'].upper(), 0, 0, 'R')
            # pdf.ln(tiny_space)
            # pdf.set_font(USED_FONT, '', line_size)
            # if 'payment_received' in p.keys():
            # return_money = str(int(p['payment_received']) - int(p['value']))
            # pdf.cell(padding_left, 0, 'Total Pay: Rp. ' + clean_number(p['payment_received']), 0, 0, 'R')
            # pdf.ln(tiny_space)
            # pdf.set_font(USED_FONT, '', line_size)
            # pdf.cell(padding_left, 0, 'Change: Rp. ' + clean_number(return_money), 0, 0, 'R')
            # else:
            # pdf.cell(padding_left, 0, 'Total Pay: Rp. ' + clean_number(p['value']), 0, 0, 'R')
            # pdf.ln(tiny_space)
            # pdf.set_font(USED_FONT, '', line_size)
            # pdf.cell(padding_left, 0, 'Change: Rp. 0', 0, 0, 'R')
            # if p['shop_type'] == 'topup':
            # pdf.ln(tiny_space)
            # pdf.set_font(USED_FONT, '', line_size)
            # if p['payment'] == 'cash':
            #     pdf.cell(0, 0, 'TOTAL: Rp. ' + clean_number(p['value']), 0, 0, 'R')
            # else:
            #     ___total = str(int(p['value']) + int(p['admin_fee']))
            #     pdf.cell(0, 0, 'TOTAL: Rp. ' + clean_number(___total), 0, 0, 'R')
            else:
                pdf.ln(tiny_space)
                pdf.set_font(USED_FONT, '', line_size)
                price_unit = str(int(int(p['value'])/p['qty']))
                # sub_total = p['value']
                # if p['payment'] == 'cash' and p['shop_type'] == 'topup':
                #     sub_total = str(int(p['value']) - int(p['admin_fee']))
                #     price_unit = str(int(int(sub_total) / p['qty']))
                pdf.cell(padding_left, 0, str(p['qty']) + ' x ' + clean_number(price_unit), 0, 0, 'R')
                pdf.ln(extra_size)
                pdf.set_font(USED_FONT, '', extra_size+2)
                pdf.cell(0, 0, 'TOTAL: Rp. ' + clean_number(p['value']), 0, 0, 'L')
        else:
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'TERJADI BATAL/GAGAL BAYAR TRANSAKSI', 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
        pdf.ln(tiny_space)
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf sale_print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|DONE')
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Global.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
    finally:
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Global.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
        save_receipt_local(trxid[-6:], json.dumps(p), 'CUSTOMER_TRX')
        del pdf


def sale_reprint_global(ext='.pdf'):
    if LAST_TRX is None:
        LOGGER.warning(('Cannot Generate Receipt Data', 'LAST GLOBAL_TRANSACTION_DATA', 'None'))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_REPRINT_GLOBAL.emit('SALE-REPRINT|ERROR')
        return
    pdf = None
    # Init Variables
    tiny_space = 4
    extra_size = 9
    line_size = 8.5
    padding_left = 0
    failure = 'USER_CANCELLATION'
    trxid = ''
    p = dict()
    cash = 0
    try:
        p = LAST_TRX
        cash = int(p['payment_received'])
        pdf = PDF('P', 'mm', (80, 120))
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+p['shop_type']+'_reprint'
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%Y-%m-%d')+' Jam : ' +
                 datetime.strftime(datetime.now(), '%H:%M'), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        trxid = p['shop_type']+str(p['epoch'])
        pdf.cell(padding_left, 0, 'TRX ID : '+trxid, 0, 0, 'L')
        pdf.ln(extra_size)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, p['shop_type'].upper()+' '+p['provider'], 0, 0, 'L')
        if 'payment_error' not in p.keys():
            if p['shop_type'] == 'topup':
                if 'topup_details' in p.keys():
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    if 'Mandiri' in p['provider']:
                        pdf.cell(padding_left, 0, 'TID : ' + _Global.TID_MAN, 0, 0, 'L')
                    else:
                        pdf.cell(padding_left, 0, 'TID : ' + _Global.TID_BNI, 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'No. Kartu : ' + p['topup_details']['card_no'], 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    saldo_awal = int(p['topup_details']['last_balance']) - (int(p['value']) - int(p['admin_fee']))
                    pdf.cell(padding_left, 0, 'Saldo Awal : Rp. ' + clean_number(str(saldo_awal)), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    __refill = int(p['value']) - int(p['admin_fee'])
                    pdf.cell(padding_left, 0, 'Isi Ulang : Rp. ' + clean_number(str(__refill)), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'Biaya Admin : Rp. ' + clean_number(p['admin_fee']), 0, 0, 'L')
                    pdf.ln(extra_size)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(0, 0, 'SALDO AKHIR : Rp. ' + clean_number(str(p['final_balance'])), 0, 0, 'L')
                else:
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'NO. KARTU : ' + p['raw']['card_no'], 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'SALDO : Rp. ' + clean_number(p['raw']['prev_balance']), 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'STATUS ISI ULANG KARTU GAGAL', 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0,
                             'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, 'HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
                    pdf.ln(tiny_space)
                    pdf.set_font(USED_FONT, '', line_size)
                    pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
                    failure = 'TOPUP_FAILURE'
            else:
                pdf.ln(tiny_space)
                pdf.set_font(USED_FONT, '', line_size)
                price_unit = str(int(int(p['value'])/p['qty']))
                pdf.cell(padding_left, 0, str(p['qty']) + ' x ' + clean_number(price_unit), 0, 0, 'R')
                pdf.ln(extra_size)
                pdf.set_font(USED_FONT, '', extra_size+2)
                pdf.cell(0, 0, 'TOTAL: Rp. ' + clean_number(p['value']), 0, 0, 'L')
        else:
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'TERJADI BATAL/GAGAL BAYAR TRX', 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, 'HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
            pdf.ln(tiny_space)
            pdf.set_font(USED_FONT, '', line_size)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
        pdf.ln(4)
        pdf.set_font(USED_FONT, '', 4)
        pdf.cell(padding_left, 0, '--COPY 2--', 0, 0, 'C')
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf sale_reprint_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_REPRINT_GLOBAL.emit('SALE-REPRINT|DONE')
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Global.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_REPRINT_GLOBAL.emit('SALE-REPRINT|ERROR')
    finally:
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Global.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
        save_receipt_local(trxid[-6:], json.dumps(p), 'CUSTOMER_TRX_REPRINT')
        del pdf


def clean_number(sn):
    return re.sub(r'(?<!^)(?=(\d{3})+$)', r'.', str(sn))


def pdf_print(pdf_file, rotate=False):
    if pdf_file is None:
        LOGGER.warning('Missing PDF File')
        return None
    try:
        if rotate is True:
            pdf_file = rotate_pdf(pdf_file)
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
    except Exception as e:
        LOGGER.warning(str(e))


def rotate_pdf(path_file):
    try:
        from PyPDF2 import PdfFileWriter, PdfFileReader
        pdf_writer = PdfFileWriter()
        pdf_reader = PdfFileReader(path_file)
        page = pdf_reader.getPage(0).rotateClockwise(90)
        pdf_writer.addPage(page)
        output_file = path_file.replace('.pdf', '_rotated.pdf')

        with open(output_file, 'wb') as fh:
            pdf_writer.write(fh)
        return output_file
    except Exception as e:
        LOGGER.warning(str(e))
        return None


def get_admin_data():
    global CARD_ADJUSTMENT
    __data = dict()
    try:
        __data['trx_top10k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 10000 '
                                                 ' AND bankMid = "" AND bankTid = "" ')[0]['__']
        __data['trx_top20k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 20000 '
                                                 ' AND bankMid = "" AND bankTid = "" ')[0]['__']
        __data['trx_top50k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 50000 '
                                                 ' AND bankMid = "" AND bankTid = "" ')[0]['__']
        __data['trx_top100k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 100000 '
                                                  'AND bankMid = "" AND bankTid = "" ')[0]['__']
        __data['amt_top10k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' bankMid = "" AND bankTid = "" AND '
                                                 ' sale = 10000 ')[0]['__']
        __data['amt_top20k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' bankMid = "" AND bankTid = "" AND '
                                                 ' sale = 20000 ')[0]['__']
        __data['amt_top50k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' bankMid = ""  AND bankTid = "" AND '
                                                 ' sale = 50000 ')[0]['__']
        __data['amt_top100k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                  ' bankMid = "" AND bankTid = "" AND '
                                                  ' sale = 100000 ')[0]['__']
        __data['amt_card10k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                  ' bankMid = "" AND bankTid = "" AND '
                                                  ' sale = 30000 ')[0]['__']
        __data['trx_card10k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 30000 '
                                                  ' AND bankMid = "" AND bankTid = "" ')[0]['__']
        __data['slot1'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            'status = 101 ')[0]['__']
        __data['slot2'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            'status = 102 ')[0]['__']
        __data['slot3'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            'status = 103 ')[0]['__']
        __data['all_cash'] = _DAO.custom_query(' SELECT IFNULL(SUM(amount), 0) AS __ FROM Cash WHERE  '
                                               ' collectedAt = 19900901 ')[0]['__']
        __data['all_amount'] = int(__data['amt_card10k']) + int(__data['amt_top10k']) + int(__data['amt_top20k']) + \
                               int(__data['amt_top50k']) + int(__data['amt_top100k'])
        __data['failed_amount'] = int(__data['all_cash']) - int(__data['all_amount'])
        # SELECT sum(amount) as total FROM Cash WHERE collectedAt is null
        __data['init_slot1'] = __data['slot1']
        __data['init_slot2'] = __data['slot2']
        __data['init_slot3'] = __data['slot3']
        if len(_ProductService.LAST_UPDATED_STOCK) > 0:
            CARD_ADJUSTMENT = json.dumps(_ProductService.LAST_UPDATED_STOCK)
            for update in _ProductService.LAST_UPDATED_STOCK:
                if update['status'] == 101:
                    __data['init_slot1'] = update['stock']
                if update['status'] == 102:
                    __data['init_slot2'] = update['stock']
                if update['status'] == 103:
                    __data['init_slot3'] = update['stock']
        LOGGER.info(('get_admin_data', str(__data), str(_ProductService.LAST_UPDATED_STOCK)))
    except Exception as e:
        __data = False
        LOGGER.warning(('get_admin_data', str(e)))
    finally:
        return __data


CARD_ADJUSTMENT = ''


def save_receipt_local(__id, __data, __type):
    try:
        param_receipt = {
            'rid': _Tools.get_uuid(),
            'bookingCode': __id,
            'tiboxId': _Global.TID,
            'receiptRaw': __type,
            'receiptData': __data,
            'createdAt': _Tools.now()
        }
        _DAO.insert_receipt(param_receipt)
        return True
    except Exception as e:
        LOGGER.warning(('save_receipt_local', str(e)))
        return False


def start_admin_print_global(struct_id):
    _Tools.get_pool().apply_async(admin_print_global, (struct_id, ))


def admin_print_global(struct_id, ext='.pdf'):
    pdf = None
    # Init Variables
    tiny_space = 3
    line_size = 7
    padding_left = 0
    print_copy = 2
    user = 'mdd_operator'
    s = False
    if _UserService.USER is not None:
        user = _UserService.USER['username']
    try:
        # paper_ = get_paper_size('\r\n'.join(p.keys()))
        pdf = GeneralPDF('P', 'mm', (80, 120))
        s = get_admin_data()
        if s is False:
            LOGGER.warning(('get_admin_data', str(s)))
            SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.emit('ADMIN_PRINT|ERROR')
            return
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+user
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%Y-%m-%d')+'  Jam : ' +
                 datetime.strftime(datetime.now(), '%H:%M:%S'), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Pengguna : '+user, 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'TRX ID : '+struct_id, 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'CARD SALE', 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        qty_card = s['trx_card10k']
        total_card = str(int(qty_card) * 30000)
        pdf.cell(padding_left, 0,
                 '- Jaklingko10K : '+str(qty_card)+' x 30.000 = ', 0, 0, 'L')
        pdf.ln(tiny_space-1)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, '                 Rp. '+clean_number(total_card), 0, 0, 'L')
        pdf.ln(tiny_space+1)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'TOPUP', 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        qty_t10k = s['trx_top10k']
        total_t10k = str(int(qty_t10k) * 10000)
        pdf.cell(padding_left, 0,
                 '- 10K : '+str(qty_t10k)+' x 10.000 = Rp. '+clean_number(total_t10k), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        qty_t20k = s['trx_top20k']
        total_t20k = str(int(qty_t20k) * 20000)
        pdf.cell(padding_left, 0,
                 '- 20K : '+str(qty_t20k)+' x 20.000 = Rp. '+clean_number(total_t20k), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        qty_t50k = s['trx_top50k']
        total_t50k = str(int(qty_t50k) * 50000)
        pdf.cell(padding_left, 0,
                 '- 50K : '+str(qty_t50k)+' x 50.000 = Rp. '+clean_number(total_t50k), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        qty_t100k = s['trx_top100k']
        total_t100k = str(int(qty_t100k) * 100000)
        pdf.cell(padding_left, 0,
                 '- 100K : '+str(qty_t100k)+' x 100.000 = Rp. '+clean_number(total_t100k), 0, 0, 'L')
        pdf.ln(line_size)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'CARD UPDATE', 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        adjust_slot1 = int(s['slot1']) - int(s['init_slot1'])
        pdf.cell(padding_left, 0,
                 '- Slot 1 : ' + str(s['init_slot1']) + ' + ' + str(adjust_slot1) + ' = ' + str(s['slot1']), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        adjust_slot2 = int(s['slot2']) - int(s['init_slot2'])
        pdf.cell(padding_left, 0,
                 '- Slot 2 : ' + str(s['init_slot2']) + ' + ' + str(adjust_slot2) + ' = ' + str(s['slot2']), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        adjust_slot3 = int(s['slot3']) - int(s['init_slot3'])
        pdf.cell(padding_left, 0,
                 '- Slot 3 : ' + str(s['init_slot3']) + ' + ' + str(adjust_slot3) + ' = ' + str(s['slot3']), 0, 0, 'L')
        pdf.ln(line_size+1)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Failed TRX : Rp. ' + clean_number(str(s['failed_amount'])), 0, 0, 'L')
        pdf.set_font(USED_FONT, '', line_size+3)
        pdf.ln(tiny_space)
        total_amount = str(s['all_amount'])
        pdf.cell(padding_left, 0, 'TOTAL CASH = Rp. ' + clean_number(total_amount), 0, 0, 'L')
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf admin_print_global : ', file_name))
        # Print-out to printer
        for i in range(print_copy):
            print_ = _Printer.ghost_print(pdf_file)
            print("pyt : ({}) Printing to Default Printer : {}".format(str(i), str(print_)))
            sleep(1)
        SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.emit('ADMIN_PRINT|DONE')
        # Send To Backend
        _Global.upload_admin_access(struct_id, user, str(total_amount), '0', CARD_ADJUSTMENT, json.dumps(s))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.emit('ADMIN_PRINT|ERROR')
    finally:
        save_receipt_local(struct_id, json.dumps(s), 'ACCESS_REPORT')
        _ProductService.LAST_UPDATED_STOCK = []
        mark_sync_collected_data(s)
        del pdf


def mark_sync_collected_data(s):
    if s is not False:
        if int(s['trx_top10k']) > 0:
            _DAO.custom_update(' UPDATE Transactions SET bankMid = "999", bankTid = "999" WHERE sale = 10000 ')
            sleep(.25)
        if int(s['trx_top20k']) > 0:
            _DAO.custom_update(' UPDATE Transactions SET bankMid = "999", bankTid = "999" WHERE sale = 20000 ')
            sleep(.25)
        if int(s['trx_top50k']) > 0:
            _DAO.custom_update(' UPDATE Transactions SET bankMid = "999", bankTid = "999" WHERE sale = 50000 ')
            sleep(.25)
        if int(s['trx_top100k']) > 0:
            _DAO.custom_update(' UPDATE Transactions SET bankMid = "999", bankTid = "999" WHERE sale = 100000 ')
            sleep(.25)
        if int(s['trx_card10k']) > 0:
            _DAO.custom_update(' UPDATE Transactions SET bankMid = "999", bankTid = "999" WHERE sale = 30000 ')
        operator = 'OPERATOR'
        if _UserService.USER is not None:
            operator = _UserService.USER['first_name']
        # Reset Cash Log
        _DAO.custom_update(
            ' UPDATE Cash SET collectedAt = ' + str(_Tools.now()) + ', collectedUser = "' + str(operator) + '"  '
            ' WHERE collectedAt = 19900901 ')
        return True
    else:
        return False
