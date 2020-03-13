__author__ = "fitrah.wahyudi.imam@gmail.com"

import os
import logging
import sys
# import win32print, win32api, win32con
# from escpos.connections import getSerialPrinter
from _tTools import _Helper
from _cConfig import _Common
import subprocess

LOGGER = logging.getLogger()
PRINTER_PORT = _Common.PRINTER_PORT
PRINTER_BAUDRATE = _Common.PRINTER_BAUDRATE

PRINTER = dict(PORT=PRINTER_PORT, BAUDRATE=int(PRINTER_BAUDRATE), STATUS=True if PRINTER_PORT is not None else False)
_PRINTER = None

GHOSTSCRIPT_PATH = os.path.join(sys.path[0], '_lLib', 'gswin32c.exe')
GSPRINT_PATH = os.path.join(sys.path[0], '_lLib', 'gsprint.exe')
TEST_FILE = os.path.join(sys.path[0], '_lLib', 'test.pdf')
# DEFAULT_PRINTER = win32print.GetDefaultPrinter()
PDF_FILE = None


def init_printer():
    global _PRINTER, PRINTER_BAUDRATE, PRINTER_PORT
    # _PRINTER = getSerialPrinter()(dev=PRINTER_PORT, baudrate=PRINTER_BAUDRATE)


def test_print(text):
    global PRINTER, _PRINTER
    if not PRINTER['STATUS']:
        LOGGER.warning("undefined printer status")
        return
    init_printer()
    _PRINTER.text(str(text))
    _PRINTER.lf()


def print_file(file):
    with open(sys.path[0] + file, 'r') as f:
        lines = f.readlines()
    try:
        if lines is not None:
            init_printer()
            for line in lines:
                _PRINTER.text(line)
                _PRINTER.lf()
        else:
            LOGGER.debug("ERROR IN READING FILE")
    except Exception as e:
        LOGGER.warning(("ERROR PRINTING : ", e))


def start_default_print(path):
    _Helper.get_pool().apply_async(default_print, (path,))


def default_print(path):
    global PDF_FILE
    if path is None:
        return '[ERROR] No File Path Found!'
    else:
        PDF_FILE = path
    try:
        # send = win32api.ShellExecute(0, 'open', GSPRINT_PATH, '-ghostscript "'+GHOSTSCRIPT_PATH+'" -printer "'
        #                              + DEFAULT_PRINTER +'"' + PDF_FILE, '.', 0)
        _print = subprocess.Popen([GSPRINT_PATH, PDF_FILE], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        result, error = _print.communicate()
        _Common.update_receipt_count()
        LOGGER.debug(('[DEBUG] default print : ', str(result), str(error)))
        return result, error
    except Exception as e:
        _Common.PRINTER_ERROR = 'FAILED_TO_EXECUTE_DEFAULT_PRINT'
        LOGGER.warning(('[ERROR] default print : ', e))
        return '[ERROR] {}'.format(str(e))


def do_printout(path):
    global PDF_FILE
    if path is None:
        return '[ERROR] No File Path Found!'
    else:
        PDF_FILE = path
    try:
        _command = GSPRINT_PATH + ' -ghostscript ' + GHOSTSCRIPT_PATH + ' -dNOPAUSE -dNoCancel -noquery -from 1 -to 1 '\
                   + PDF_FILE
        # send = win32api.ShellExecute(0, 'open', GSPRINT_PATH, '-ghostscript "'+GHOSTSCRIPT_PATH+'" -printer "'
        #                              + DEFAULT_PRINTER +'"' + PDF_FILE, '.', 0)
        _print = subprocess.Popen(_command, shell=True, stdout=subprocess.PIPE)
        _result = _print.communicate()[0].decode('utf-8').strip().split("\r\n")
        _Common.update_receipt_count()
        # LOGGER.debug(('[DEBUG] default print : ', _result))
        return _result
    except Exception as e:
        _Common.PRINTER_ERROR = 'FAILED_TO_EXECUTE_do_printout'
        LOGGER.warning(('[ERROR] default print : ', e))
        return '[ERROR] {}'.format(str(e))


'''
 import win32api
 fname="C:\\somePDF.pdf"
 win32api.ShellExecute(0, "print", fname, None,  ".",  0)
'''

'''
from fpdf import FPDF

pdf=FPDF()
pdf.add_page()
pdf.set_font('Courier','B',16)
pdf.cell(40,10,'Hello World!')
pdf.output('tuto1.pdf','F')
'''

'''
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch

import cgi
import tempfile
import win32api

source_file_name = "c:/temp/temp.txt"
pdf_file_name = tempfile.mktemp (".pdf")

styles = getSampleStyleSheet ()
h1 = styles["h1"]
normal = styles["Normal"]

doc = SimpleDocTemplate (pdf_file_name)
#
# reportlab expects to see XML-compliant
#  data; need to escape ampersands &c.
#
text = cgi.escape (open (source_file_name).read ()).splitlines ()

#
# Take the first line of the document as a
#  header; the rest are treated as body text.
#
story = [Paragraph (text[0], h1)]
for line in text[1:]:
  story.append (Paragraph (line, normal))
  story.append (Spacer (1, 0.2 * inch))

doc.build (story)
win32api.ShellExecute (0, "print", pdf_file_name, None, ".", 0)
'''

'''
import win32ui
import win32print
import win32con

INCH = 1440

hDC = win32ui.CreateDC ()
hDC.CreatePrinterDC (win32print.GetDefaultPrinter ())
hDC.StartDoc ("Test doc")
hDC.StartPage ()
hDC.SetMapMode (win32con.MM_TWIPS)
hDC.DrawText ("TEST", (0, INCH * -1, INCH * 8, INCH * -2), win32con.DT_CENTER)
hDC.EndPage ()
hDC.EndDoc ()
'''

'''


import tempfile
import win32api
import win32print

filename = tempfile.mktemp (".txt")
open (filename, "w").write ("This is a test")
win32api.ShellExecute (
  0,
  "print",
  filename,
  #
  # If this is None, the default printer will
  # be used anyway.
  #
  '/d:"%s"' % win32print.GetDefaultPrinter (),
  ".",
  0
)

'''

'''
import os, sys
import win32print
printer_name = win32print.GetDefaultPrinter ()
#
# raw_data could equally be raw PCL/PS read from
#  some print-to-file operation
#
if sys.version_info >= (3,):
  raw_data = bytes ("This is a test", "utf-8")
else:
  raw_data = "This is a test"

hPrinter = win32print.OpenPrinter (printer_name)
try:
  hJob = win32print.StartDocPrinter (hPrinter, 1, ("test of raw data", None, "RAW"))
  try:
    win32print.StartPagePrinter (hPrinter)
    win32print.WritePrinter (hPrinter, raw_data)
    win32print.EndPagePrinter (hPrinter)
  finally:
    win32print.EndDocPrinter (hPrinter)
finally:
  win32print.ClosePrinter (hPrinter)

'''