__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
from fpdf import FPDF
import sys
import os
import json
from datetime import datetime
from _tTools import _Helper
from PyQt5.QtCore import QObject, pyqtSignal
from _dDevice import _Printer
from _sService import _KioskService
from _cConfig import _Common
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
FONT_PATH = os.path.join(sys.path[0], '_fFonts')
if not os.path.exists(FONT_PATH):
    os.makedirs(FONT_PATH)
LOGO_PATH = os.path.join(sys.path[0], '_rReceipts', _Common.RECEIPT_LOGO)


def get_paper_size(ls=None):
    p = {'WIDTH': 80, 'HEIGHT': 80}
    if ls is not None:
        ls = ls.split('\r\n')
        p['HEIGHT'] = p['WIDTH'] + (3.5 * len(ls))
    return p


MARGIN_LEFT = 0
SPACING = 4
USED_FONT = 'Courier'
GLOBAL_FONT_SIZE = 8
RECEIPT_TITLE = 'SALE GLOBAL PRINT'
HEADER_TEXT1 = 'ISI ULANG'
HEADER_TEXT2 = 'MANDIRI E-MONEY'


class PDF(FPDF):
    def header(self):
        # Logo
        self.set_font(USED_FONT, '', GLOBAL_FONT_SIZE)
        if os.path.isfile(LOGO_PATH):
            self.image(LOGO_PATH, 25, 5, 30)
        self.ln(SPACING*4)
        # self.ln(SPACING)
        # self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE, HEADER_TEXT1, 0, 0, 'C')
        # self.ln(SPACING)
        # self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE, HEADER_TEXT2, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE, 'TERMINAL : '+_Common.TID, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE, 'LOKASI : '+_Common.KIOSK_NAME, 0, 1, 'C')

    def footer(self):
        self.set_font(USED_FONT, '', GLOBAL_FONT_SIZE-1)
        # self.ln(SPACING)
        # self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'Layanan Pelanggan Hubungi 0812-XXXX-XXXX', 0, 0, 'C')
        # self.cell(MARGIN_LEFT, FOOTER_FONT_SIZE, '-APP VER: ' + _KioskService.VERSION+'-', 0, 0, 'C')
        self.set_y(-20)
        if len(_Common.CUSTOM_RECEIPT_TEXT) > 5:
            for custom_text in _Common.CUSTOM_RECEIPT_TEXT.split('|'):
                self.ln(SPACING-1)
                self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE-1, custom_text, 0, 0, 'C')
        self.ln(SPACING-1)
        self.cell(MARGIN_LEFT, GLOBAL_FONT_SIZE-1, 'TERIMA KASIH', 0, 0, 'C')


class GeneralPDF(FPDF):
    def header(self):
        self.set_font(USED_FONT, '', 7)
        self.ln(3*3)
        self.cell(MARGIN_LEFT, 7, 'COLLECTION REPORT', 0, 0, 'C')
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, 'VM ID : '+_Common.TID, 0, 0, 'C')
        self.ln(3)
        self.cell(MARGIN_LEFT, 7, 'VM Name : '+_Common.KIOSK_NAME, 0, 1, 'C')

    def footer(self):
        self.set_font(USED_FONT, '', 7)
        self.set_y(-20)
        self.cell(MARGIN_LEFT, 7, '(TTD Korlap)   (TTD Teknisi MDD)', 0, 0, 'C')
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


def chunk_text(text, length=24, delimiter="\r\n"):
    if len(text) <= length:
        return text
    else:
        return text[:length] + delimiter + text[length:]


def font_path(font):
    return os.path.join(sys.path[0], '_fFonts', font)


def justifying(left, right):
    return left + (" " * (MAX_LENGTH-len(left)-len(right))) + right


def start_sale_print_global():
    _Helper.get_pool().apply_async(sale_print_global, )

    # '{"date":"Thursday, March 07, 2019","epoch":1551970698740,"payment":"cash","shop_type":"shop","time":"9:58:18 PM",
    # "qty":4,"value":"3000","provider":"Kartu Prabayar","raw":{"init_price":500,"syncFlag":1,"createdAt":1551856851000,
    # "stock":99,"pid":"testprod001","name":"Test Product","status":1,"sell_price":750,"stid":"stid001",
    # "remarks":"TEST STOCK PRODUCT"},"notes":"DEBUG_TEST - 1551970698879"}'

    # '{"date":"Thursday, March 07, 2019","epoch":1551970911009,"payment":"debit","shop_type":"topup","time":"10:01:51 PM",
    # "qty":1,"value":"50000","provider":"e-Money Mandiri","raw":{"provider":"e-Money Mandiri","value":"50000"},
    # "notes":"DEBUG_TEST - 1551970911187"}')


def start_reprint_global():
    _Helper.get_pool().apply_async(sale_reprint_global, )


LAST_TRX = None
SMALL_SPACE = 3.5
REGULAR_SPACE = 8
PADDING_LEFT = 0


def sale_print_global(ext='.pdf', use_last=False):
    global LAST_TRX, HEADER_TEXT1
    if not use_last:
        if _KioskService.GLOBAL_TRANSACTION_DATA is None:
            LOGGER.warning(('Cannot Generate Receipt Data', 'GLOBAL_TRANSACTION_DATA', 'None'))
            SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
            return
        LAST_TRX = _KioskService.GLOBAL_TRANSACTION_DATA
    p = LAST_TRX
    if p['shop_type'] == 'topup':    
        print_topup_trx(p, 'ISI ULANG PRABAYAR')    
    if p['shop_type'] == 'shop':    
        print_shop_trx(p, 'PEMBELIAN PRABAYAR')
    if p['shop_type'] == 'ppob':    
        print_ppob_trx(p, 'PEMBELIAN/PEMBAYARAN')


def print_topup_trx(p, t, ext='.pdf'):
    global HEADER_TEXT1
    if _Common.empty(p):
        LOGGER.warning(('Cannot Generate Receipt Data', 'GLOBAL_TRANSACTION_DATA', 'None'))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
        return
    pdf = None
    # Init Variables
    small_space = SMALL_SPACE
    regular_space = REGULAR_SPACE
    padding_left = PADDING_LEFT
    trxid = ''
    # failure = 'USER_CANCELLATION'
    cash = 0
    try:
        cash = int(p['payment_received'])
        HEADER_TEXT1 = t
        # paper_ = get_paper_size('\r\n'.join(p.keys()))
        pdf = PDF('P', 'mm', (80, 140))
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+p['shop_type']
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%d-%m-%Y'), 0, 0, 'L')
        pdf.cell(padding_left, 0, 'Jam : ' + datetime.strftime(datetime.now(), '%H:%M'), 0, 0, 'R')
        pdf.ln(small_space*2)
        pdf.set_font(USED_FONT, '', regular_space)
        __title = t
        pdf.cell(padding_left, 0, __title, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        trxid = p['shop_type']+str(p['epoch'])
        pdf.cell(padding_left, 0, 'NO TRX    : '+trxid, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'PEMBAYARAN: ' + p['payment'].upper(), 0, 0, 'L')
        # pdf.set_font(USED_FONT, '', regular_space)
        # pdf.cell(padding_left, 0, p['shop_type'].upper()+' '+p['provider'], 0, 0, 'L')
        if 'payment_error' not in p.keys() and 'process_error' not in p.keys():
            if 'topup_details' in p.keys():
                # pdf.ln(small_space)
                # pdf.set_font(USED_FONT, '', regular_space)
                # if 'Mandiri' in p['provider']:
                #     pdf.cell(padding_left, 0, 'TID : ' + _Common.TID_MAN, 0, 0, 'L')
                # else:
                #     pdf.cell(padding_left, 0, 'TID : ' + _Common.TID_BNI, 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'ISI ULANG  : Rp. ' + clean_number(p['denom']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'BIAYA ADMIN: Rp. ' + clean_number(p['admin_fee']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'TOTAL BAYAR: Rp. ' + clean_number(p['value']), 0, 0, 'L')
                # pdf.ln(small_space)
                # pdf.set_font(USED_FONT, '', regular_space)
                # pdf.cell(padding_left, 0, 'UANG MASUK : Rp. ' + clean_number(str(cash)), 0, 0, 'L')
                # pdf.ln(small_space)
                # pdf.set_font(USED_FONT, '', regular_space)
                # pdf.cell(padding_left, 0, 'UANG KEMBALI: Rp. ' + clean_number('0'), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NO. KARTU  : ' + p['topup_details']['card_no'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                # saldo_awal = int(p['topup_details']['last_balance']) - (int(p['value']) - int(p['admin_fee']))
                pdf.cell(padding_left, 0, 'SALDO AWAL : Rp. ' + clean_number(p['raw']['prev_balance']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'SALDO AKHIR: Rp. ' + clean_number(str(p['final_balance'])), 0, 0, 'L')
                if 'refund_status' in p.keys():
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    pdf.cell(padding_left, 0, 'UANG DITERIMA: Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
                pdf.ln(small_space*2)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(0, 0, 'DENGAN ISI ULANG INI, PEMEGANG', 0, 0, 'L')
                pdf.ln(small_space-1)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(0, 0, 'KARTU MENYATAKAN TUNDUK DAN', 0, 0, 'L')
                pdf.ln(small_space-1)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(0, 0, 'MENGIKAT DIRI PADA SYARAT DAN', 0, 0, 'L')
                pdf.ln(small_space-1)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(0, 0, 'KETENTUAN BANK PENERBIT KARTU', 0, 0, 'L')
                # pdf.ln(small_space-1)
                # pdf.set_font(USED_FONT, '', regular_space-1)
                # pdf.cell(0, 0, 'PADA WWW.BANKMANDIRI.CO.ID', 0, 0, 'L')
            else:
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NO. KARTU   : ' + p['raw']['card_no'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'SISA SALDO  : Rp. ' + clean_number(p['raw']['prev_balance']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS ISI ULANG KARTU GAGAL', 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'UANG DITERIMA: Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
                if 'refund_status' in p.keys():
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space-1)
                pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
                    # failure = 'TOPUP_FAILURE'
        else:
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'NO. KARTU   : ' + p['raw']['card_no'], 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'SISA SALDO  : Rp. ' + clean_number(p['raw']['prev_balance']), 0, 0, 'L')
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'TERJADI BATAL/GAGAL BAYAR TRANSAKSI', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'UANG DITERIMA: Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
            if 'refund_status' in p.keys():
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
            pdf.ln(small_space*4)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
        pdf.ln(small_space)
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf sale_print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.do_printout(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|DONE')
        # failure = 'USER_CANCELLATION'
        # if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
        #     if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
        #         failure = 'TOPUP_FAILURE'
        #     # Send Failure To Backend
        #     _Common.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
        #                                     json.dumps(p))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
    finally:
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Common.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
        # save_receipt_local(trxid[-6:], json.dumps(p), 'CUSTOMER_TOPUP_TRX')
        if p['payment'].upper() == 'DEBIT' and _Common.LAST_EDC_TRX_RECEIPT is not None:
            print__ = _Printer.do_printout(_Common.LAST_EDC_TRX_RECEIPT)
            print("pyt : sending pdf to default printer : {}".format(str(print__)))
            _Common.LAST_EDC_TRX_RECEIPT = None
        del pdf


def print_shop_trx(p, t, ext='.pdf'):
    global HEADER_TEXT1
    if _Common.empty(p):
        LOGGER.warning(('Cannot Generate Receipt Data', 'GLOBAL_TRANSACTION_DATA', 'None'))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
        return
    pdf = None
    # Init Variables
    small_space = SMALL_SPACE
    regular_space = REGULAR_SPACE
    padding_left = PADDING_LEFT
    trxid = ''
    # failure = 'USER_CANCELLATION'
    cash = 0
    try:
        cash = int(p['payment_received'])
        HEADER_TEXT1 = t
        # paper_ = get_paper_size('\r\n'.join(p.keys()))
        pdf = PDF('P', 'mm', (80, 140))
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+p['shop_type']
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%d-%m-%Y'), 0, 0, 'L')
        pdf.cell(padding_left, 0, 'Jam : ' + datetime.strftime(datetime.now(), '%H:%M'), 0, 0, 'R')
        pdf.ln(small_space*2)
        pdf.set_font(USED_FONT, '', regular_space)
        __title = t
        pdf.cell(padding_left, 0, __title, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        trxid = p['shop_type']+str(p['epoch'])
        pdf.cell(padding_left, 0, 'NO TRX    : '+trxid, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'PEMBAYARAN: ' + p['payment'].upper(), 0, 0, 'L')
        # pdf.set_font(USED_FONT, '', regular_space)
        # pdf.cell(padding_left, 0, p['shop_type'].upper()+' '+p['provider'], 0, 0, 'L')
        if 'payment_error' not in p.keys() and 'process_error' not in p.keys():
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'TIPE KARTU  : ' + p['provider'], 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'QTY KARTU   : ' + str(p['qty']), 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, str(p['qty']) + ' x ' + clean_number(p['value']), 0, 0, 'R')
            # pdf.ln(small_space)
            # pdf.set_font(USED_FONT, '', regular_space)
            # pdf.cell(padding_left, 0, 'UANG MASUK  : Rp. ' + clean_number(str(cash)), 0, 0, 'L')
            if 'refund_status' in p.keys():
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'UANG DITERIMA: Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
                # price_unit = str(int(int(p['value'])/p['qty']))
                # sub_total = p['value']
                # if p['payment'] == 'cash' and p['shop_type'] == 'topup':
                #     sub_total = str(int(p['value']) - int(p['admin_fee']))
                #     price_unit = str(int(int(sub_total) / p['qty']))
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space+2)
            total_pay = str(int(int(p['value']) * int(p['qty'])))
            pdf.cell(0, 0, 'TOTAL BAYAR : Rp. ' + clean_number(total_pay), 0, 0, 'L')
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space-1)
            pdf.cell(0, 0, 'PEMEGANG KARTU MENYATAKAN TUNDUK DAN', 0, 0, 'L')
            pdf.ln(small_space-1)
            pdf.set_font(USED_FONT, '', regular_space-1)
            pdf.cell(0, 0, 'MENGIKAT DIRI PADA SYARAT DAN', 0, 0, 'L')
            pdf.ln(small_space-1)
            pdf.set_font(USED_FONT, '', regular_space-1)
            pdf.cell(0, 0, 'KETENTUAN BANK PENERBIT KARTU', 0, 0, 'L')
            pdf.set_font(USED_FONT, '', regular_space-1)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
            # failure = 'TOPUP_FAILURE'
        else:
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'TERJADI BATAL/GAGAL BAYAR TRANSAKSI', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
            if 'refund_status' in p.keys():
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
            pdf.ln(small_space*4)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
        pdf.ln(small_space)
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf sale_print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.do_printout(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|DONE')
        # failure = 'USER_CANCELLATION'
        # if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
        #     if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
        #         failure = 'TOPUP_FAILURE'
        #     # Send Failure To Backend
        #     _Common.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
        #                                     json.dumps(p))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
    finally:
        failure = 'USER_CANCELLATION'
        if 'payment_error' in p.keys() or (p['shop_type'] == 'topup' and 'topup_details' not in p.keys()):
            if p['shop_type'] == 'topup' and 'topup_details' not in p.keys():
                failure = 'TOPUP_FAILURE'
            # Send Failure To Backend
            _Common.store_upload_failed_trx(trxid, p.get('pid', ''), cash, failure, p.get('payment', 'cash'),
                                            json.dumps(p))
        # save_receipt_local(trxid[-6:], json.dumps(p), 'CUSTOMER_SHOP_TRX')
        if p['payment'].upper() == 'DEBIT' and _Common.LAST_EDC_TRX_RECEIPT is not None:
            print__ = _Printer.do_printout(_Common.LAST_EDC_TRX_RECEIPT)
            print("pyt : sending pdf to default printer : {}".format(str(print__)))
            _Common.LAST_EDC_TRX_RECEIPT = None
        del pdf


def print_ppob_trx(p, t, ext='.pdf'):
    global HEADER_TEXT1
    if _Common.empty(p):
        LOGGER.warning(('Cannot Generate Receipt Data', 'GLOBAL_TRANSACTION_DATA', 'None'))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
        return
    pdf = None
    # Init Variables
    small_space = SMALL_SPACE
    regular_space = REGULAR_SPACE
    padding_left = PADDING_LEFT
    trxid = ''
    # failure = 'USER_CANCELLATION'
    cash = 0
    try:
        cash = int(p['payment_received'])
        HEADER_TEXT1 = t
        # paper_ = get_paper_size('\r\n'.join(p.keys()))
        pdf = PDF('P', 'mm', (80, 140))
        # LOGGER.info(('Registering New Font', font_path('UnispaceBold.ttf')))
        # pdf.add_font('UniSpace', '', font_path('UnispaceBold.ttf'), uni=True)
        pdf.add_page()
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+p['shop_type']
        # Layouting
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%d-%m-%Y'), 0, 0, 'L')
        pdf.cell(padding_left, 0, 'Jam : ' + datetime.strftime(datetime.now(), '%H:%M'), 0, 0, 'R')
        pdf.ln(small_space*2)
        pdf.set_font(USED_FONT, '', regular_space)
        __title = t
        pdf.cell(padding_left, 0, __title, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        trxid = p['shop_type']+str(p['epoch'])
        pdf.cell(padding_left, 0, 'NO TRX    : '+trxid, 0, 0, 'L')
        pdf.ln(small_space)
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'PEMBAYARAN: ' + p['payment'].upper(), 0, 0, 'L')
        # pdf.ln(small_space)
        # pdf.set_font(USED_FONT, '', regular_space)
        # pdf.cell(padding_left, 0, 'KATEGORI  : ' + str(p['category']), 0, 0, 'L')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'PROVIDER  : ' + str(p['provider']), 0, 0, 'L')
        pdf.ln(small_space)
        pdf.set_font(USED_FONT, '', regular_space)
        pdf.cell(padding_left, 0, 'MSISDN    : ' + str(p['msisdn']), 0, 0, 'L')
        # pdf.set_font(USED_FONT, '', regular_space)
        # pdf.cell(padding_left, 0, p['shop_type'].upper()+' '+p['provider'], 0, 0, 'L')
        if 'payment_error' not in p.keys() and 'process_error' not in p.keys():
            if p['ppob_mode'] == 'tagihan':
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'PELANGGAN  : Rp. ' + str(p['customer']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'TAGIHAN    : Rp. ' + clean_number(str(p['value'])), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'BIAYA ADMIN: Rp. ' + clean_number(str(p['admin_fee'])), 0, 0, 'L')
            else:
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'JUMLAH     : ' + str(p['qty']), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'HARGA/UNIT : Rp. ' + clean_number(str(p['value'])), 0, 0, 'L')
                if 'sn' in p['ppob_details'].keys():
                    pdf.ln(small_space)
                    pdf.set_font(USED_FONT, '', regular_space)
                    label_sn = 'S/N '
                    if p['category'].lower() == 'listrik':
                        label_sn = 'TOKEN '
                        if str(p['ppob_details']['sn']) == '[]':
                            pdf.cell(padding_left, 0, 'TOKEN DALAM PROSES, HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
                        else:    
                            pdf.cell(padding_left, 0, label_sn + str(p['ppob_details']['sn'][:24]), 0, 0, 'L')
                    else:
                        pdf.cell(padding_left, 0, label_sn + str(p['ppob_details']['sn'][:24]), 0, 0, 'L')
            if 'refund_status' in p.keys():
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'UANG DITERIMA: Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space+2)
            total_pay = str(int(int(p['value']) * int(p['qty'])))
            pdf.cell(0, 0, 'TOTAL BAYAR : Rp. ' + clean_number(total_pay), 0, 0, 'L')
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space-1)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
            # failure = 'TOPUP_FAILURE'
        else:
            pdf.ln(small_space*2)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'TERJADI BATAL/GAGAL BAYAR TRANSAKSI', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'UANG DITERIMA : Rp. ' + clean_number(str(p['payment_received'])), 0, 0, 'L')
            if 'refund_status' in p.keys():
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'STATUS REFUND: ' + p['refund_number'] + ' ' + p['refund_status'], 0, 0, 'L')
                pdf.ln(small_space)
                pdf.set_font(USED_FONT, '', regular_space)
                pdf.cell(padding_left, 0, 'NILAI REFUND : Rp. ' + clean_number(str(p['refund_amount'])), 0, 0, 'L')
            pdf.ln(small_space*4)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, 'SILAKAN HUBUNGI LAYANAN PELANGGAN', 0, 0, 'L')
            pdf.ln(small_space)
            pdf.set_font(USED_FONT, '', regular_space)
            pdf.cell(padding_left, 0, '(SIMPAN STRUK INI SEBAGAI BUKTI)', 0, 0, 'L')
        pdf.ln(small_space)
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf sale_print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.do_printout(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|DONE')
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_SALE_PRINT_GLOBAL.emit('SALEPRINT|ERROR')
    finally:
        # save_receipt_local(trxid[-6:], json.dumps(p), 'CUSTOMER_PPOB_TRX')
        if p['payment'].upper() == 'DEBIT' and _Common.LAST_EDC_TRX_RECEIPT is not None:
            print__ = _Printer.do_printout(_Common.LAST_EDC_TRX_RECEIPT)
            print("pyt : sending pdf to default printer : {}".format(str(print__)))
            _Common.LAST_EDC_TRX_RECEIPT = None
        del pdf


def sale_reprint_global(ext='.pdf'):
    sale_print_global(ext=ext, use_last=True)


def clean_number(sn):
    return re.sub(r'(?<!^)(?=(\d{3})+$)', r'.', str(sn))


def pdf_print(pdf_file, rotate=False):
    if pdf_file is None:
        LOGGER.warning('Missing PDF File')
        return None
    try:
        if rotate is True:
            pdf_file = rotate_pdf(pdf_file)
        print_ = _Printer.do_printout(pdf_file)
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

# -------------------------
CARD_SALE = 0 # Will Count All Card Shop TRX
# -------------------------


def get_admin_data():
    global CARD_ADJUSTMENT
    __data = dict()
    try:
        __data['trx_top10k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 10000 '
                                                 ' AND isCollected = 0 AND pid like "topup%" ')[0]['__']
        __data['trx_top20k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 20000 '
                                                 ' AND isCollected = 0 AND pid like "topup%" ')[0]['__']
        __data['trx_top50k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 50000 '
                                                 ' AND isCollected = 0 AND pid like "topup%" ')[0]['__']
        __data['trx_top100k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 100000 '
                                                  'AND isCollected = 0 AND pid like "topup%" ')[0]['__']
        __data['trx_top200k'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale = 200000 '
                                                  'AND isCollected = 0 AND pid like "topup%" ')[0]['__']
        __data['amt_top10k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' isCollected = 0 AND sale = 10000 AND pid like "topup%"')[0]['__']
        __data['amt_top20k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' isCollected = 0 AND sale = 20000 AND pid like "topup%"')[0]['__']
        __data['amt_top50k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                 ' isCollected = 0 AND sale = 50000 AND pid like "topup%" ')[0]['__']
        __data['amt_top100k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                  ' isCollected = 0 AND sale = 100000 AND pid like "topup%" ')[0]['__']
        __data['amt_top200k'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                  ' isCollected = 0 AND sale = 200000 AND pid like "topup%" ')[0]['__']
        __data['slot1'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            ' status = 101 ')[0]['__']
        __data['slot2'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            ' status = 102 ')[0]['__']
        __data['slot3'] = _DAO.custom_query(' SELECT IFNULL(SUM(stock), 0) AS __ FROM ProductStock WHERE '
                                            ' status = 103 ')[0]['__']
        __data['all_cash'] = _DAO.custom_query(' SELECT IFNULL(SUM(amount), 0) AS __ FROM Cash WHERE  '
                                               ' collectedAt = 19900901 ')[0]['__']        
        __data['all_cards'] = _DAO.custom_query(' SELECT pid, sell_price FROM ProductStock ')
        __data['ppob_cash'] = _DAO.custom_query(' SELECT IFNULL(SUM(amount), 0) AS __ FROM Cash WHERE pid LIKE "ppob%" '
                                               ' AND collectedAt = 19900901 ')[0]['__']    
        # __data['amt_card'] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
        #                                        ' bankMid = "" AND bankTid = "" AND sale > ' + str(CARD_SALE) +
        #                                        ' AND  pid like "shop%" ')[0]['__']
        # __data['trx_card'] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE sale > ' + str(CARD_SALE) +
        #                                        ' AND bankMid = "" AND bankTid = "" AND pid like "shop%" ')[0]['__']
        __data['amt_card'] = 0
        __data['trx_card'] = 0
        __data['card_trx_summary'] = []
        if len(__data['all_cards']) > 0:
            for card in __data['all_cards']:
                pid = card['pid']
                price = card['sell_price']
                __data['amt_card_'+str(pid)] = _DAO.custom_query(' SELECT IFNULL(SUM(sale), 0) AS __ FROM Transactions WHERE '
                                                ' isCollected = 0 AND pidStock = "' + str(pid) +'" ')[0]['__']
                __data['amt_card'] += __data['amt_card_'+str(pid)]
                __data['trx_card_'+str(pid)] = _DAO.custom_query(' SELECT count(*) AS __ FROM Transactions WHERE amount = ' + str(price) +
                                                       ' AND isCollected = 0 AND pidStock = "'+str(pid)+'" ')[0]['__']
                __data['trx_card'] += __data['trx_card_'+str(pid)]
                __data['card_trx_summary'].append({
                    'pid': pid,
                    'price': price,
                    'count': __data['trx_card_'+str(pid)],
                    'amount': __data['amt_card_'+str(pid)]
                })
        # SELECT sum(amount) as total FROM Cash WHERE collectedAt is null
        __data['all_amount'] = int(__data['amt_card']) + int(__data['amt_top10k']) + int(__data['amt_top20k']) + \
                               int(__data['amt_top50k']) + int(__data['amt_top100k'] + int(__data['amt_top200k']))
        __data['failed_amount'] = 0
        if int(__data['all_cash']) > (int(__data['all_amount']) + int(__data['ppob_cash'])):
            __data['failed_amount'] = int(__data['all_cash']) - (int(__data['all_amount']) + int(__data['ppob_cash']))
        __data['init_slot1'] = __data['slot1']
        __data['init_slot2'] = __data['slot2']
        __data['init_slot3'] = __data['slot3']
        __data['sam_1_balance'] = '0'
        __data['sam_2_balance'] = '0'
        __notes = []
        for money in _DAO.custom_query(' SELECT paymentNotes AS note FROM Transactions WHERE paymentType = "MEI" '
                                       ' AND isCollected = 0 '):
            __notes.append(json.loads(money['note'])['history'])
        __data['notes_summary'] = '|'.join(__notes)
        # Status Bank BNI in Global
        if _Common.BANKS[0]['STATUS'] is True:
            __data['sam_1_balance'] = str(_Common.MANDIRI_ACTIVE_WALLET)
            __data['sam_2_balance'] = str(_Common.BNI_ACTIVE_WALLET)
        if len(_ProductService.LAST_UPDATED_STOCK) > 0:
            CARD_ADJUSTMENT = json.dumps(_ProductService.LAST_UPDATED_STOCK)
            for update in _ProductService.LAST_UPDATED_STOCK:
                if update['status'] == 101:
                    __data['init_slot1'] = update['stock']
                if update['status'] == 102:
                    __data['init_slot2'] = update['stock']
                if update['status'] == 103:
                    __data['init_slot3'] = update['stock']
        _KioskService.python_dump(str(__data))
        _KioskService.python_dump(str(_ProductService.LAST_UPDATED_STOCK))
        # LOGGER.info(('get_admin_data', str(__data), str(_ProductService.LAST_UPDATED_STOCK)))
    except Exception as e:
        __data = False
        LOGGER.warning(str(e))
    finally:
        return __data


CARD_ADJUSTMENT = ''


def save_receipt_local(__id, __data, __type):
    try:
        param_receipt = {
            'rid': _Helper.get_uuid(),
            'bookingCode': __id,
            'tid': _Common.TID,
            'receiptRaw': __type,
            'receiptData': __data,
            'createdAt': _Helper.now()
        }
        _DAO.insert_receipt(param_receipt)
        return True
    except Exception as e:
        LOGGER.warning((e))
        return False


def start_admin_print_global(struct_id):
    _Helper.get_pool().apply_async(admin_print_global, (struct_id,))

# TODO: Enhance Admin Printout Details
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
        pdf = GeneralPDF('P', 'mm', (80, 140))
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
        pdf.cell(padding_left, 0, 'Tanggal : '+datetime.strftime(datetime.now(), '%d-%m-%Y')+'  Jam : ' +
                 datetime.strftime(datetime.now(), '%H:%M:%S'), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Operator : ' + user + ' | ' + struct_id, 0, 0, 'L')
        # pdf.ln(tiny_space)
        # pdf.set_font(USED_FONT, '', line_size)
        # pdf.cell(padding_left, 0, 'TRX ID : '+struct_id, 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, '_' * MAX_LENGTH, 0, 0, 'C')
        pdf.ln(tiny_space*2)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'CARD SALE', 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        # qty_card = s['trx_card']
        # total_card = str(int(qty_card) * CARD_SALE)
        for cs in s['card_trx_summary']:
            pdf.cell(padding_left, 0,
                    '- '+cs['pid']+' : '+str(cs['count'])+' x '+clean_number(str(cs['price']))+'  = Rp. '+clean_number(str(cs['amount'])), 0, 0, 'L')
            pdf.ln(tiny_space-1)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, '                 Rp. '+clean_number(str(s['amt_card'])), 0, 0, 'L')
        pdf.ln(tiny_space+1)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'TOPUP', 0, 0, 'L')
        pdf.ln(tiny_space)
        if not _Common.BANKS[0]['STATUS']:
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
        if _Common.BANKS[0]['STATUS']:
            pdf.set_font(USED_FONT, '', line_size)
            qty_t200k = s['trx_top200k']
            total_t200k = str(int(qty_t200k) * 200000)
            pdf.cell(padding_left, 0,
                     '- 200K : '+str(qty_t200k)+' x 200.000 = Rp. '+clean_number(total_t200k), 0, 0, 'L')
        pdf.ln(tiny_space+1)
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
        pdf.cell(padding_left, 0, 'MDR Wallet : Rp. ' + clean_number(str(s['sam_1_balance'])), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'BNI Wallet : Rp. ' + clean_number(str(s['sam_2_balance'])), 0, 0, 'L')
        pdf.ln(line_size)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'Failed/Exceed TRX: Rp. ' + clean_number(str(s['failed_amount'])), 0, 0, 'L')
        pdf.ln(tiny_space)
        pdf.set_font(USED_FONT, '', line_size)
        pdf.cell(padding_left, 0, 'PPOB Cash TRX: Rp. ' + clean_number(str(s['ppob_cash'])), 0, 0, 'L')
        pdf.set_font(USED_FONT, '', line_size+3)
        pdf.ln(tiny_space)
        # total_amount = str(int(s['all_amount']) + int(s['failed_amount']))
        # if total_amount == '0':
        #     total_amount = str(s['failed_amount'])
        pdf.cell(padding_left, 0, 'TOTAL CASH = Rp. ' + clean_number(str(s['all_cash'])), 0, 0, 'L')
        # End Layouting
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf admin_print_global : ', file_name))
        # Print-out to printer
        for i in range(print_copy):
            print_ = _Printer.do_printout(pdf_file)
            # LOGGER.debug(("pyt : ({}) Printing to Default Printer : {}".format(str(i), str(print_))))
            print("pyt : ({}) Printing to Default Printer : {}".format(str(i), str(print_)))
            if '[ERROR]' in print_:
                break
            sleep(1)
        SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.emit('ADMIN_PRINT|DONE')
        # Send To Backend
        _Common.upload_admin_access(struct_id, user, str(s['all_cash']), '0', CARD_ADJUSTMENT, json.dumps(s))
    except Exception as e:
        LOGGER.warning(str(e))
        SPRINTTOOL_SIGNDLER.SIGNAL_ADMIN_PRINT_GLOBAL.emit('ADMIN_PRINT|ERROR')
    finally:
        mark_sync_collected_data(s)
        # save_receipt_local(struct_id, json.dumps(s), 'ACCESS_REPORT')
        _ProductService.LAST_UPDATED_STOCK = []
        del pdf


def mark_sync_collected_data(s):
    if not _Common.empty(s):
        _DAO.custom_update(' UPDATE Transactions SET isCollected = 1 WHERE isCollected = 0 ')
        operator = 'OPERATOR'
        if _UserService.USER is not None:
            operator = _UserService.USER['first_name']
        # Reset Cash Log
        __update_cash_str = ' UPDATE Cash SET collectedAt = ' + str(_Helper.now()) + ', collectedUser = "' + str(operator) + \
            '"  WHERE collectedAt = 19900901 '
        # _KioskService.python_dump(str(__update_cash_str))
        __exec_cash_update = _DAO.custom_update(__update_cash_str)
        # _KioskService.python_dump(str(__exec_cash_update))
        return True
    else:
        return False
