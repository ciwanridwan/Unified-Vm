__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
from PyPDF2 import PdfFileReader, PdfFileWriter
import os

LOGGER = logging.getLogger()

PDF_PATH = os.path.join(os.getcwd(), '_pPDF')


def validate_path(pdf):
    if "D:\\" not in pdf or '_DOWNLOAD_' not in pdf:
        pdf = os.path.join('D:\\', '_DOWNLOAD_', pdf)
        LOGGER.info('Validating PDF File Path Into -> '+pdf)
    return pdf


def rotate_pdf(pdf_file, booking_code="", flight_no=""):
    if pdf_file is None:
        LOGGER.warning('PDF File is Missing')
        return False
    if not pdf_file.endswith('.pdf'):
        LOGGER.warning('File ['+pdf_file+'] is Not PDF File')
        return False
    if not os.path.exists(validate_path(pdf_file)):
        LOGGER.warning('File ['+pdf_file+'] is Not Found')
        return False
    try:
        pdf_in = open(validate_path(pdf_file), 'rb')
        LOGGER.info('Read File ['+pdf_file+']')
        pdf_reader = PdfFileReader(pdf_in)
        if pdf_reader.isEncrypted:
            try:
                pdf_reader.decrypt('')
                LOGGER.debug('Decrypting File ['+pdf_file+']')
            except Exception as e:
                LOGGER.warning(e)
        pdf_writer = PdfFileWriter()
        page = pdf_reader.getPage(0)
        page.rotateClockwise(90)
        pdf_writer.addPage(page)
        new_pdf = os.path.join(PDF_PATH, 'CHECK-IN_'+booking_code+'_'+flight_no.replace(' ', '')+'.pdf')
        pdf_out = open(new_pdf, 'wb')
        pdf_writer.write(pdf_out)
        LOGGER.info('Write File ['+new_pdf+']')
        pdf_out.close()
        pdf_in.close()
        return new_pdf
    except Exception as e:
        LOGGER.warning(str(e))
        return False

