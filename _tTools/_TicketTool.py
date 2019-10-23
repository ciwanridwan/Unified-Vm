__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
from fpdf import FPDF
import sys
import os
import json
from datetime import datetime
from _tTools import _Helper
from PyQt5.QtCore import QObject, pyqtSignal
from _tTools import _Tibox
from _dDevice import _MEI
from _dDevice import _EDC
from _dDevice import _Printer
from _dDAO import _DAO
from _nNetwork import _NetworkAccess
from pprint import pprint
from _sService import _KioskService
from time import sleep
import re

LOGGER = logging.getLogger()


class PDFSignalHandler(QObject):
    __qualname__ = 'PDFSignalHandler'
    SIGNAL_START_GENERATE = pyqtSignal(str)
    SIGNAL_REPRINT = pyqtSignal(str)
    SIGNAL_PRINT_GLOBAL = pyqtSignal(str)


PDF_SIGNDLER = PDFSignalHandler()
PATH = os.path.join(sys.path[0], '_pPDF')
LOGO_PATH = os.path.join(sys.path[0], '_rReceipts', 'receipt_logo.gif')


def get_paper_size(ls=None):
    p = {'WIDTH': 80, 'HEIGHT': 80}
    if ls is not None:
        ls = ls.split('\r\n')
        p['HEIGHT'] = p['WIDTH'] + (3.5 * len(ls))
    return p


MARGIN_LEFT = 0
HEADER_FONT_SIZE = 8
SPACING = 3
RECEIPT_TITLE = 'TICKET SALE RECEIPT'
# KIOSK_NAME = _DAO.init_kiosk()[0]["name"]


class PDF(FPDF):
    def header(self):
        # Logo
        self.image(LOGO_PATH, 25, 5, 30)
        # Line break
        self.ln(SPACING)
        self.set_font('Courier', 'B', HEADER_FONT_SIZE)
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, RECEIPT_TITLE, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, _KioskService.KIOSK_NAME, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE,
                  'KIOSK ID:'+_Tibox.TID+' '+datetime.strftime(datetime.now(), '%Y-%m-%d %H:%M:%S'), 0, 1, 'C')
        self.ln(SPACING)

    def footer(self):
        self.set_font('Courier', 'I', HEADER_FONT_SIZE)
        self.set_y(-20)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'Please check-in at least 2 hours', 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'before departure. For further information,', 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, 'Please call Lion Air contact-center', 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, '(+6221-63798000)', 0, 0, 'C')


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
GET_STRUCK_ID = None


def chunk_text(text, lenght=24, delimiter="\r\n"):
    if len(text) <= lenght:
        return text
    else:
        return text[:lenght] + delimiter + text[lenght:]


def get_param_value():
    global PARAM, GET_CARD_NO, GET_PAYMENT_NOTES, GET_TOTAL_NOTES, GET_STRUCK_ID
    try:
        PARAM = _Tibox.get_trip_summary()
        PARAM['ADMIN_FEE'] = str(_KioskService.KIOSK_ADMIN)
        PARAM['LEN_NUMBER'] = len(delimit(PARAM['GET_TOTAL_COST']))
        PARAM['TRANSACTION_DATE'] = datetime.strftime(datetime.now(), '%Y-%m-%d %H:%M:%S')
        if GET_PAYMENT_METHOD == 'EDC':
            PARAM['GET_TOTAL_PAID'] = PARAM['GET_TOTAL_COST']
            GET_PAYMENT_NOTES = _EDC.get_payment_result()
            GET_STRUCK_ID = _EDC.get_payment_result()['struck_id']
            GET_CARD_NO = _EDC.get_payment_result()['card_no']
            PARAM['PAYMENT_METHOD'] = _EDC.get_payment_result()['card_type']
            PARAM['ADMIN_FEE'] = str(int(PARAM['GET_TOTAL_COST']) - int(PARAM['GET_TICKET_PRICE']))
            PARAM['GET_CARD_NO'] = GET_CARD_NO
        if GET_PAYMENT_METHOD == 'QPROX':
            PARAM['GET_TOTAL_PAID'] = PARAM['GET_TOTAL_COST']
            GET_CARD_NO = 'QPROX_1234****789'
            GET_PAYMENT_NOTES = 'QPROX_PaymentResult'
            PARAM['PAYMENT_METHOD'] = 'PREPAID CARD'
            PARAM['GET_CARD_NO'] = GET_CARD_NO
        if GET_PAYMENT_METHOD == 'MEI':
            PARAM['GET_CARD_NO'] = ''
            PARAM['GET_TOTAL_PAID'] = _MEI.get_collected_cash()
            GET_PAYMENT_NOTES = _MEI.get_cash_history()
            GET_TOTAL_NOTES = _MEI.get_total_cash()
            PARAM['PAYMENT_METHOD'] = 'CASH'
            must_paid = int(PARAM['GET_TICKET_PRICE']) + _KioskService.KIOSK_ADMIN
            if GET_TOTAL_NOTES < must_paid:
                PARAM['GET_PAYMENT_STATUS'] = 'FAILED (MINUS ' + str(must_paid-GET_TOTAL_NOTES) + ')'
        if GET_PAYMENT_METHOD == 'WALLET':
            PARAM['GET_CARD_NO'] = ''
            PARAM['GET_TOTAL_PAID'] = PARAM['GET_TOTAL_COST']
            GET_PAYMENT_NOTES = 'N/A'
            GET_CARD_NO = PARAM['GET_CARD_NO']
            GET_TOTAL_NOTES = PARAM['GET_TOTAL_COST']
            PARAM['PAYMENT_METHOD'] = GET_PAYMENT_METHOD
        if PARAM['GET_TRANSIT_STATUS'] is True:
            if len(PARAM["GET_TRANSIT_DATA"]) == 1:
                PARAM['GET_TIME_ARRIVAL_DEP'] = PARAM["GET_TRANSIT_DATA"][0]["transit_depart_arrival"]
                PARAM["GET_TRANSIT_DATA"][0]["transit_airport"] = PARAM["GET_TRANSIT_DATA"][0]["transit_airport"]. \
                    replace("International", "Int.")
            if len(PARAM["GET_TRANSIT_DATA"]) == 2:
                PARAM['GET_TIME_ARRIVAL_RET'] = PARAM["GET_TRANSIT_DATA"][1]["transit_depart_arrival"]
                PARAM["GET_TRANSIT_DATA"][1]["transit_airport"] = PARAM["GET_TRANSIT_DATA"][1]["transit_airport"]. \
                    replace("International", "Int.")
        PARAM["GET_AIRPORT_DEPART"] = PARAM["GET_AIRPORT_DEPART"].replace("International", "Int.")
        PARAM["GET_AIRPORT_ARRIVAL"] = PARAM["GET_AIRPORT_ARRIVAL"].replace("International", "Int.")
        PARAM['GET_AIRPORT_DEPART'] = chunk_text(PARAM['GET_AIRPORT_DEPART'])
        PARAM['GET_AIRPORT_ARRIVAL'] = chunk_text(PARAM['GET_AIRPORT_ARRIVAL'])
        pprint(PARAM)
    except Exception as e:
        print("pyt: [error] get_param_value => ", str(e))
        LOGGER.warning(('[ERROR] get_param_value : ', str(e)))
        PARAM = None
    finally:
        return PARAM


def start_set_payment(payment):
    _Helper.get_pool().apply_async(set_payment, (payment,))


def set_payment(payment):
    global GET_PAYMENT_METHOD
    GET_PAYMENT_METHOD = payment


EXT = '.pdf'


def get_return_info(param):
    if param['GET_DATE_RETURN'] != '':
        return '''Return Date      : {}\r\n
Return Flight    : {}\r\n
Return Departure : {}\r\n
Return Arrival   : {}\r\n
'''.format(param['GET_DATE_RETURN'], param['GET_FLIGHT_NO_RETURN'], param['GET_TIME_DEPART_RET'],
           param['GET_TIME_ARRIVAL_RET'])
    else:
        return ''


def get_transit_info_depart(param):
    if param['GET_TRANSIT_STATUS'] is True and len(param["GET_TRANSIT_DATA"]) > 0:
        if len(param["GET_TRANSIT_DATA"][0]) > 0:
            return '''Transit in       : {}\r\n
Airport Transit  : {}\r\n
Transit Flight   : {}\r\n
Transit Depart   : {}\r\n'''.format(param["GET_TRANSIT_DATA"][0]["transit_hub"],
                                    chunk_text(param["GET_TRANSIT_DATA"][0]["transit_airport"]),
                                    param["GET_TRANSIT_DATA"][0]["transit_flight"],
                                    param["GET_TRANSIT_DATA"][0]["transit_depart_time"])
        else:
            return ''
    else:
        return ''


def get_transit_info_return(param):
    if param['GET_TRANSIT_STATUS'] is True and len(param["GET_TRANSIT_DATA"]) > 1:
        if len(param["GET_TRANSIT_DATA"][1]) > 0:
            return '''Transit in       : {}\r\n
Airport Transit  : {}\r\n
Transit Flight   : {}\r\n
Transit Depart   : {}\r\n'''.format(param["GET_TRANSIT_DATA"][1]["transit_hub"],
                                    chunk_text(param["GET_TRANSIT_DATA"][1]["transit_airport"]),
                                    param["GET_TRANSIT_DATA"][1]["transit_flight"],
                                    param["GET_TRANSIT_DATA"][1]["transit_depart_time"])
        else:
            return ''
    else:
        return ''


def template_test():
    return '''
Payment Type     : TEST\r\n
Booking Code     : TES123\r\n Trip [T1] -> [T2]\r\n
Departure Date   : 10-10-2018\r\n
Departure Flight : TEST12\LION AIR\r\n
Departure Airport: Test Departure Airport\r\n
Departure Time   : 08:00\r\n
Arrival Airport  : Test Arrival Airport\r\n
Arrival Time     : 10:00\r\n
\r\n
Adult Passenger\r\n
    Name (1)     : Test 1\r\n
    Name (2)     : Test 2\r\n
\r\n
Price\r\n
Ticket Price     : Rp. 35.000,-\r\n
Admin Fee        : Rp. 25.000,-\r\n
Total Payment    : Rp. 50.000,-\r\n
Total Paid       : Rp. 50.000,-\r\n
Changes          : -\r\n
'''


def template_ticket(payment, p):
    if payment == 'TICKET_MEI' or payment == 'TICKET_WALLET':
        return '''
Payment Type     : {}\r\n
Booking Code     : {}\r\n{}\r\n
Departure Date   : {}\r\n
Departure Flight : {}\r\n
Departure Airport: {}\r\n
Departure Time   : {}\r\n
'''.format(p['PAYMENT_METHOD'], p['GET_BOOKING_CODE'], ' '+p['GET_TRIP'], p['GET_DATE_DEPART'],
           p['GET_FLIGHT_NO_DEPART'], p['GET_AIRPORT_DEPART'], p['GET_TIME_DEPART_DEP']) + \
               get_transit_info_depart(p) + '''Arrival Airport  : {}\r\n
Arrival Time     : {}\r\n
'''.format(p['GET_AIRPORT_ARRIVAL'], p['GET_TIME_ARRIVAL_DEP']) + get_return_info(p) + \
               get_transit_info_return(p) + p['GET_PASSENGER_LIST'] + ''' Price\r\n
Ticket Price     : {}\r\n
Admin Fee        : {}\r\n
Total Cost       : {}\r\n
Total Paid       : {}\r\n
Booking Status   : {}\r\n
'''.format('Rp. ' + delimit(p['GET_TICKET_PRICE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['ADMIN_FEE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['GET_TOTAL_COST']) + ',-', 'Rp. ' + delimit(p['GET_TOTAL_PAID']) + ',-',
           p['GET_PAYMENT_STATUS'])
    if payment == 'TICKET_QPROX':
        return '''
Payment Type     : {}\r\n
Card No          : {}\r\n
Booking Code     : {}\r\n{}\r\n
Departure Date   : {}\r\n
Departure Flight : {}\r\n
Departure Airport: {}\r\n
Departure Time   : {}\r\n
'''.format(p['PAYMENT_METHOD'], GET_CARD_NO, p['GET_BOOKING_CODE'], ' '+p['GET_TRIP'], p['GET_DATE_DEPART'],
           p['GET_FLIGHT_NO_DEPART'], p['GET_AIRPORT_DEPART'], p['GET_TIME_DEPART_DEP']) + \
               get_transit_info_depart(p) + '''Arrival Airport  : {}\r\n
Arrival Time     : {}\r\n
'''.format(p['GET_AIRPORT_ARRIVAL'], p['GET_TIME_ARRIVAL_DEP']) + get_return_info(p) + \
               get_transit_info_return(p) + p['GET_PASSENGER_LIST'] + ''' Price\r\n
Ticket Price     : {}\r\n
Admin Fee        : {}\r\n
Total Cost       : {}\r\n
Total Paid       : {}\r\n
Booking Status   : {}\r\n
'''.format('Rp. ' + delimit(p['GET_TICKET_PRICE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['ADMIN_FEE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['GET_TOTAL_COST']) + ',-', 'Rp. ' + delimit(p['GET_TOTAL_PAID']) + ',-',
           p['GET_PAYMENT_STATUS'])
    if payment == 'TICKET_EDC':
        return '''
TRXID            : {}\r\n
Payment Type     : {}\r\n
Card No          : {}\r\n
Booking Code     : {}\r\n{}\r\n
Departure Date   : {}\r\n
Departure Flight : {}\r\n
Departure Airport: {}\r\n
Departure Time   : {}\r\n
'''.format(GET_STRUCK_ID, p['PAYMENT_METHOD'], GET_CARD_NO, p['GET_BOOKING_CODE'], ' '+p['GET_TRIP'], p['GET_DATE_DEPART'],
           p['GET_FLIGHT_NO_DEPART'], p['GET_AIRPORT_DEPART'], p['GET_TIME_DEPART_DEP']) + \
               get_transit_info_depart(p) + '''Arrival Airport  : {}\r\n
Arrival Time     : {}\r\n
'''.format(p['GET_AIRPORT_ARRIVAL'], p['GET_TIME_ARRIVAL_DEP']) + get_return_info(p) + \
               get_transit_info_return(p) + p['GET_PASSENGER_LIST'] + ''' Price\r\n
Ticket Price     : {}\r\n
Admin Fee        : {}\r\n
Total Cost       : {}\r\n
Total Paid       : {}\r\n
Booking Status   : {}\r\n
'''.format('Rp. ' + delimit(p['GET_TICKET_PRICE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['ADMIN_FEE']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['GET_TOTAL_COST']).rjust(p['LEN_NUMBER']) + ',-', 'Rp. ' +
           delimit(p['GET_TOTAL_PAID']) + ',-', p['GET_PAYMENT_STATUS'])


def delimit(s):
    _s = re.sub("(\d)(?=(\d{3})+(?!\d))", r"\1,", "%d" % int(s))
    return _s.replace(',', '.')


def start_generate(use):
    _Helper.get_pool().apply_async(generate, (use,))


GLOBAL_PDF_FILE = None
GLOBAL_FILENAME = None


def generate(use_case, store_receipt=True, receipt_text=template_test()):
    global PARAM, GET_PAYMENT_METHOD, GET_CARD_NO, GLOBAL_PDF_FILE, GLOBAL_FILENAME
    pdf = None
    text_ = None
    try:
        if use_case != 'TEST':
            trial = 0
            while True:
                trial += 1
                text_ = get_param_value()
                if text_ is not None:
                    break
                if trial == 3:
                    break
            if text_ is None:
                LOGGER.warning('generate_receipt_error')
                return
            receipt_text = template_ticket(use_case, text_)
        paper_ = get_paper_size(receipt_text)
        pdf = PDF('P', 'mm', (paper_['WIDTH'], paper_['HEIGHT']))
        strings = receipt_text.split('\r\n')
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'_'+PARAM['GET_BOOKING_CODE']
        pdf.add_page()
        for string in strings:
            pdf.set_font('Courier', 'B', 5)
            pdf.cell(-10, 0, '', 0, 0, 'L')
            pdf.set_font('Courier', 'B', 8.5)
            pdf.cell(-10, 0, string, 0, 0, 'L')
            pdf.ln(4)
        if PARAM['GET_TOTAL_PAID'] >= PARAM['GET_TOTAL_COST'] and (PARAM['GET_PAYMENT_STATUS'] == 'FAILED' or
                                                                   PARAM['GET_PAYMENT_STATUS'] == 'WAITING'):
            pdf.set_font('Courier', 'B', 10)
            pdf.cell(0, 10, '(PLEASE DO "RE-PRINT" IN MACHINE)', 0, 0, 'C')
            pdf.ln(4)
        if 'MINUS' in PARAM['GET_PAYMENT_STATUS']:
            pdf.set_font('Courier', 'B', 10)
            pdf.cell(0, 10, '(PLEASE CONTACT CUSTOMER SERVICE)', 0, 0, 'C')
            pdf.ln(4)
            file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'_'+PARAM['GET_BOOKING_CODE']+'_CANCEL'
        pdf_file = get_path(file_name+EXT)
        GLOBAL_PDF_FILE = pdf_file
        GLOBAL_FILENAME = file_name
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf generate : ', file_name))
        PDF_SIGNDLER.SIGNAL_START_GENERATE.emit('GENERATE|'+file_name)
        # Logging Receipt Data
        if store_receipt is True:
            _trial_ = 0
            while True:
                _trial_ += 1
                __store__local = _Tibox.save_receipt_local(receipt_text, json.dumps(PARAM))
                __receipt = _Tibox.save_receipt_server(__store__local)
                if __receipt is True:
                    break
                if _trial_ == 3:
                    break
        # Logging Transaction #1
        store_1 = attempt_store_data(GLOBAL_FILENAME)
        if store_1 is False:
            store_2 = attempt_store_data(GLOBAL_FILENAME)
            LOGGER.info(('store_2 trx logging for', GLOBAL_FILENAME, store_2))
    except Exception as e:
        if 'OSError' in e or 'Invalid argument' in e:
            # Logging Transaction #2
            store_3 = attempt_store_data(GLOBAL_FILENAME)
            if store_3 is False:
                store_4 = attempt_store_data(GLOBAL_FILENAME)
                LOGGER.info(('store_4 trx logging for', GLOBAL_FILENAME, store_4))
        # LOGGER.warning(('pdf generate error, attempt #2 try : ', e))
        # PDF_SIGNDLER.SIGNAL_START_GENERATE.emit('GENERATE|ERROR')
    finally:
        if use_case != 'TEST':
            # Print-out to printer
            print_ = _Printer.ghost_print(GLOBAL_PDF_FILE)
            print("pyt : sending pdf to default printer : {}".format(str(print_)))
        reset_param()
        del pdf
        del text_


def attempt_store_data(file):
    trial = 0
    while True:
        trial += 1
        _result = log_transaction()
        if _result is True:
            LOGGER.info('Success Logging Data for ' + file)
            return True
        if trial == 3:
            LOGGER.warning('Failed Logging Data Within Max Trial')
            PDF_SIGNDLER.SIGNAL_START_GENERATE.emit('GENERATE|ERROR')
            return False
        sleep(int(1/3))


def start_reprint(new_status):
    _Helper.get_pool().apply_async(reprint, (new_status,))


def reprint(new_status):
    pdf = None
    text_ = None
    try:
        if new_status == 'SUCCESS' or new_status == 'CONFIRMED':
            _raw_receipt = _KioskService.PREV_RECEIPT_RAW_DATA
            _KioskService.PREV_RECEIPT_RAW_DATA = _raw_receipt.replace('Payment Status', 'Booking Status')
            _KioskService.PREV_RECEIPT_RAW_DATA = _KioskService.PREV_RECEIPT_RAW_DATA.split('Booking Status')[0]
            _KioskService.PREV_RECEIPT_RAW_DATA += ('Booking Status   : ' + new_status + '\r\n')
        paper_ = get_paper_size(_KioskService.PREV_RECEIPT_RAW_DATA)
        pdf = PDF('P', 'mm', (paper_['WIDTH'], paper_['HEIGHT']))
        strings = _KioskService.PREV_RECEIPT_RAW_DATA.split('\r\n')
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'_'+_KioskService.PREV_BOOKING_CODE+'_REPRINT'
        pdf.add_page()
        for string in strings:
            pdf.set_font('Courier', 'B', 5)
            pdf.cell(-10, 0, '', 0, 0, 'L')
            pdf.set_font('Courier', 'B', 8.5)
            pdf.cell(-10, 0, string, 0, 0, 'L')
            pdf.ln(4)
        pdf_file = get_path(file_name+EXT)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf reprint : ', file_name))
        # PDF_SIGNDLER.SIGNAL_REPRINT.emit('REPRINT|'+file_name)
        # Logging Receipt Data
        _trial_ = 0
        while True:
            _trial_ += 1
            __store__local = _Tibox.save_receipt_local(_KioskService.PREV_RECEIPT_RAW_DATA,
                                                       _KioskService.PREV_PARAM_DATA)
            __receipt = _Tibox.save_receipt_server(__store__local)
            if __receipt is True:
                break
            if _trial_ == 3:
                break
        # Print-out to printer
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending trx receipt to printer : {}".format(str(print_)))
        PDF_SIGNDLER.SIGNAL_REPRINT.emit('REPRINT|DONE')
    # Cleaning-out prev data
        _KioskService.clear_prev_data()
    except Exception as e:
        LOGGER.warning(('pdf reprint : ', e))
        PDF_SIGNDLER.SIGNAL_REPRINT.emit('REPRINT|ERROR')
    finally:
        del pdf
        del text_


def reset_param():
    global PARAM, MODE_TEST, GET_PAYMENT_METHOD, GET_CARD_NO, GET_PAYMENT_NOTES, GET_TOTAL_NOTES, GLOBAL_PDF_FILE, \
        GLOBAL_FILENAME, GET_STRUCK_ID
    PARAM = {}
    MODE_TEST = False
    GET_PAYMENT_METHOD = None
    GET_CARD_NO = None
    GET_PAYMENT_NOTES = None
    GET_TOTAL_NOTES = 0
    GLOBAL_PDF_FILE = None
    GLOBAL_FILENAME = None
    GET_STRUCK_ID = None
    # _Tibox.reset_value()


def log_transaction():
    print("pyt: log_transaction into local DB")
    try:
        if GET_PAYMENT_METHOD == 'MEI':
            if len(GET_PAYMENT_NOTES.split('|')) > 55:
                _param_ = _Tibox.update_trx_local(GET_CARD_NO, GET_PAYMENT_METHOD, GET_PAYMENT_NOTES)
                _Tibox.update_cash_local(GET_TOTAL_NOTES)
            else:
                _param_ = _Tibox.save_trx_local(GET_CARD_NO, GET_PAYMENT_METHOD, GET_PAYMENT_NOTES)
                _Tibox.save_cash_local(GET_TOTAL_NOTES)
        else:
            _param_ = _Tibox.save_trx_local(GET_CARD_NO, GET_PAYMENT_METHOD, GET_PAYMENT_NOTES)
        return _Tibox.save_trx_server(_param_)
    except Exception as e:
        LOGGER.warning(str(e))
        return False


def start_print_global(input_text, use_for):
    _Helper.get_pool().apply_async(print_global, (input_text, use_for,))


def print_global(input_text='\r\n', use_for='EDC_SETTLEMENT'):
    global RECEIPT_TITLE
    RECEIPT_TITLE = use_for
    pdf = None
    try:
        paper_ = get_paper_size(input_text)
        pdf = PDF('P', 'mm', (paper_['WIDTH'], paper_['HEIGHT']))
        strings = input_text.split('\r\n')
        file_name = datetime.strftime(datetime.now(), '%Y%m%d%H%M%S')+'-'+use_for
        pdf.add_page()
        for string in strings:
            pdf.set_font('Courier', 'B', 5)
            pdf.cell(-10, 0, '', 0, 0, 'L')
            pdf.set_font('Courier', 'B', 8.5)
            pdf.cell(-10, 0, string, 0, 0, 'L')
            pdf.ln(3)
        pdf_file = get_path(file_name+EXT)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        PDF_SIGNDLER.SIGNAL_PRINT_GLOBAL.emit(use_for+'|DONE')
    except Exception as e:
        LOGGER.warning(str(e))
        PDF_SIGNDLER.SIGNAL_PRINT_GLOBAL.emit(use_for+'|ERROR')
    finally:
        RECEIPT_TITLE = 'TICKET SALE RECEIPT'
        del pdf
