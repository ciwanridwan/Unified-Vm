import evdev
from evdev import *
import sys


BARCODE_TYPE = 'CM5680SR'
RESULT_BARCODES = ""
KEY_PREFIX = 'GSK'
BARCODE_LEN = 17
SCANNER = None
LIMIT_MODE = True


def read_barcode():
    global RESULT_BARCODES
    if SCANNER is None:
        sys.exit("Error Read Barcode From " + BARCODE_TYPE)
    print("Reading Barcodes From " + BARCODE_TYPE)
    for event in SCANNER.read_loop():
        if event.type == evdev.ecodes.EV_KEY and event.value == 1:
            __ = categorize(event).keycode
            RESULT_BARCODES += __[4:]
            if LIMIT_MODE is True:
                if RESULT_BARCODES[-3:] == KEY_PREFIX:
                    send_barcode_result(RESULT_BARCODES)
                else:
                    send_barcode_result(RESULT_BARCODES, False)


COUNTER = 0


def send_barcode_result(result, flush=True):
    global RESULT_BARCODES, COUNTER
    COUNTER += 1
    result = result.replace('LEFTSHIFT', '')[-BARCODE_LEN:]
    print('(' + str(COUNTER) + ') >>>  ' + result)
    if flush is True:
        RESULT_BARCODES = ""


def init_scanner():
    devices = [evdev.InputDevice(fn) for fn in evdev.list_devices()]
    __device = None
    for d in devices:
        if BARCODE_TYPE in d.name:
            print("Found Scanner Device " + d.name)
            __device = d
    return __device


if __name__ == '__main__':
    SCANNER = init_scanner()
    if SCANNER is None:
        sys.exit("Unable To Find " + BARCODE_TYPE)
    else:
        read_barcode()
