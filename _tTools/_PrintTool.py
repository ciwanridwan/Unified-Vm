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
from _tTools import _Tibox
from _sService import _KioskService
from pprint import pprint
from time import sleep
import re

LOGGER = logging.getLogger()


class PrintToolSignalHandler(QObject):
    __qualname__ = 'PrintToolSignalHandler'
    SIGNAL_START_GENERATE = pyqtSignal(str)
    SIGNAL_REPRINT = pyqtSignal(str)
    SIGNAL_PRINT_GLOBAL = pyqtSignal(str)


PRINTTOOL_SIGNDLER = PrintToolSignalHandler()
PATH = os.path.join(sys.path[0], '_pPDF')
LOGO_PATH = os.path.join(sys.path[0], '_rReceipts', 'mandiri_logo.gif')


def get_paper_size(ls=None):
    p = {'WIDTH': 80, 'HEIGHT': 80}
    if ls is not None:
        ls = ls.split('\r\n')
        p['HEIGHT'] = p['WIDTH'] + (3.5 * len(ls))
    return p


MARGIN_LEFT = 0
HEADER_FONT_SIZE = 8.5
SPACING = 5
RECEIPT_TITLE = 'GLOBAL PRINT'


class PDF(FPDF):
    def header(self):
        # Logo
        # self.image(LOGO_PATH, 25, 5, 30)
        # Line break
        # self.ln(SPACING)
        self.set_font('Courier', 'B', HEADER_FONT_SIZE+1.5)
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, RECEIPT_TITLE, 0, 0, 'C')
        self.ln(SPACING*2)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, _KioskService.KIOSK_NAME, 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE,
                  'KIOSK ID:'+_Tibox.TID+' '+datetime.strftime(datetime.now(), '%Y-%m-%d %H:%M:%S'), 0, 1, 'C')
        self.ln(SPACING)

    def footer(self):
        self.set_font('Courier', 'B', HEADER_FONT_SIZE)
        self.set_y(-20)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, '-----', 0, 0, 'C')
        self.ln(SPACING)
        self.cell(MARGIN_LEFT, HEADER_FONT_SIZE, '---', 0, 0, 'C')


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


def chunk_text(text, lenght=24, delimiter="\r\n"):
    if len(text) <= lenght:
        return text
    else:
        return text[:lenght] + delimiter + text[lenght:]


def start_print_global(input_text, use_for):
    _Tools.get_pool().apply_async(print_global, (input_text, use_for,))


def print_global(input_text='\r\n', use_for='EDC_SETTLEMENT', ext='.pdf'):
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
            pdf.ln(4)
        pdf_file = get_path(file_name+ext)
        pdf.output(pdf_file, 'F')
        LOGGER.debug(('pdf print_global : ', file_name))
        # Print-out to printer
        print_ = _Printer.ghost_print(pdf_file)
        print("pyt : sending pdf to default printer : {}".format(str(print_)))
        PRINTTOOL_SIGNDLER.SIGNAL_PRINT_GLOBAL.emit(use_for+'|DONE')
    except Exception as e:
        LOGGER.warning(str(e))
        PRINTTOOL_SIGNDLER.SIGNAL_PRINT_GLOBAL.emit(use_for+'|ERROR')
    finally:
        RECEIPT_TITLE = 'GLOBAL PRINT'
        del pdf


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
