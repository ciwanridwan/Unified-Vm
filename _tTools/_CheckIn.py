__author__ = "fitrah.wahyudi.imam@gmail.com"

import json
import logging
from time import sleep

from PyQt5.QtCore import QObject, pyqtSignal

from _cCommand import _Command
from _tTools import _Helper
from _tTools import _PDFTool

from _dDevice import _Printer


LOGGER = logging.getLogger()
CMD = {
    "CHECK_CODE": "401",
    "GET_BOARDING": "402"
}


class CheckInSignalHandler(QObject):
    __qualname__ = 'CheckInSignalHandler'
    SIGNAL_CHECK_FLIGHTCODE = pyqtSignal(str)
    SIGNAL_GET_BOARDINGPASS = pyqtSignal(str)
    SIGNAL_PRINT_BOARDINGPASS = pyqtSignal(str)


CI_SIGNDLER = CheckInSignalHandler()
BOOKING_CODE = None
LF_NAME = None
FLIGHT_NO = None


def start_check_booking_code(param):
    _Helper.get_pool().apply_async(check_booking_code, (param,))


def check_booking_code(param=None):
    global BOOKING_CODE, LF_NAME
    if param is None:
        LOGGER.warning('Missing Parameter')
        return
    try:
        # Cleanup Previous Error
        _Command.clear_content_of(_Command.MO_ERROR)
        LOGGER.info(("check_booking_code : ", str(param)))
        p = json.loads(param)
        BOOKING_CODE = p['booking_code'].upper()
        LF_NAME = p['lf_name'].upper()
        param = CMD["CHECK_CODE"] + "|" + BOOKING_CODE + "|" + LF_NAME + "|" + p['card_royalty'] + "|" + p['gender'].upper()
        response, result = _Command.send_request(param=param,
                                                 output=_Command.MO_REPORT)
        if response == 0:
            handling_booking_code()
        else:
            CI_SIGNDLER.SIGNAL_CHECK_FLIGHTCODE.emit('ERROR')
            LOGGER.warning(("RESPONSE : ", str(response), result))
    except Exception as e:
        CI_SIGNDLER.SIGNAL_CHECK_FLIGHTCODE.emit('ERROR')
        LOGGER.warning(str(e))


MAX_ATTEMPTS = 90
SEEK_CODE1 = 'OPEN FOR CHECK-IN'
DUMMY_RESPONSE = False
SAMPLE_RESPONSE = '''JT 26|FRI, 30 NOV 18|CGK17:55|DPS20:45|OPEN FOR CHECK-IN|MR RIAN AJJ<>1|MR RIAN AJJ|22D|Already checked in<>01B#A|01C#A|02A#A|02B#A|02C#A|02D#A|02E#A|02F#A|03A#A|03B#A|03C#A|03D#A|03E#A|03F#A|04A#A|04B#A|04C#A|04D#A|04E#A|04F#A|05A#A|05B#A|05C#A|05D#A|05E#A|05F#A|06A#A|06B#A|06C#A|06D#A|06E#A|06F#A|07A#A|07B#A|07C#A|07D#A|07E#A|07F#A|08A#A|08B#A|08C#A|08D#A|08E#A|08F#A|09A#A|09B#A|09C#A|09D#A|09E#A|09F#A|10A#A|10B#A|10C#A|10D#A|10E#A|10F#A|11A#A|11B#A|11C#A|11D#A|11E#A|11F#A|12A#A|12B#A|12C#A|12D#A|12E#A|12F#A|15A#A|15B#A|15C#A|15D#A|15E#A|15F#A|16A#A|16B#A|16C#A|16D#A|16E#A|16F#A|17A#A|17B#A|17C#A|17D#A|17E#A|17F#A|18A#A|18B#A|18C#A|18D#A|18E#A|18F#A|19A#A|19B#A|19C#A|19D#A|19E#A|19F#A|20A#N/A|20B#N/A|20C#N/A|20D#N/A|20E#N/A|20F#N/A|21A#N/A|21B#N/A|21C#N/A|21D#N/A|21E#N/A|21F#N/A|22A#A|22B#A|22C#A|22D#N/A|22E#A|22F#A|23A#A|23B#A|23C#A|23D#A|23E#A|23F#A|24A#A|24B#A|24C#A|24D#A|24E#A|24F#A|25A#A|25B#A|25C#A|25D#A|25E#A|25F#A|26A#A|26B#A|26C#A|26D#A|26E#A|26F#A|27A#A|27B#A|27C#A|27D#A|27E#A|27F#A|28A#A|28B#A|28C#A|28D#A|28E#A|28F#A|29A#A|29B#A|29C#A|29D#A|29E#A|29F#A|30A#A|30B#A|30C#A|30D#A|30E#A|31B#N/A|31C#N/A|31D#N/A|31E#N/A|32A#N/A|32B#N/A|32C#N/A|32D#N/A|32E#N/A|32F#N/A|33A#A|33B#A|33C#A|33D#A|33E#A|33F#A|34A#A|34B#A|34C#A|34D#A|34E#A|34F#A|35A#A|35B#A|35C#A|35D#A|35E#A|35F#A|36A#A|36B#A|36C#A|36D#A|36E#A|36F#A|37A#A|37B#A|37C#A|37D#A|37E#A|37F#A|38A#A|38B#A|38C#A|38D#A|38E#A|38F#A|39A#A|39B#A|39C#A|39D#A|39E#A|39F#A'''
SAMPLE_BOARDING = 'MR RIAN AJJ|MALE Adult|22D|JT 26|FRI, 30 NOV 18|CGK17:55|DPS20:45|B7<>2018-12-07-113214_bp.pdf'


def handling_booking_code():
    attempt = 0
    result_list = []
    pid = '[' + _Helper.get_random_chars(5, '1234567890') + ']'
    _replacement = '#'
    while True:
        attempt += 1
        if attempt >= MAX_ATTEMPTS:
            LOGGER.info(('[Break] by MAX_ATTEMPTS:', str(MAX_ATTEMPTS)))
            CI_SIGNDLER.SIGNAL_CHECK_FLIGHTCODE.emit('ERROR')
            break
        if DUMMY_RESPONSE is True:
            sleep(3)
            response = 0
            result = SAMPLE_RESPONSE
        else:
            response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, repl=_replacement,
                                                                 module='CHECK-IN_' + BOOKING_CODE + '_' + pid)
        if response == 0:
            # Try TO Handle Chinese Code
            # result = open(_Command.MO_REPORT, 'r').readlines()
            if result not in result_list:
                result_list.append(result)
            if SEEK_CODE1 in result:
                output = parse_data(result, _replacement)
                LOGGER.info(('[Break] Final Result Check Booking :', str(output)))
                CI_SIGNDLER.SIGNAL_CHECK_FLIGHTCODE.emit(json.dumps(output))
                break
        sleep(1)


def split_list(_list, _per):
    return [_list[i:i + _per] for i in range(0, len(_list), _per)]


INCLUDE_EMERGENCY = False


def parse_data(result, _replacement):
    global FLIGHT_NO
    output = dict()
    _f = result.split(_replacement)[0].split('|')
    # Set Delimiter Character Here
    _delimit = '<>'
    FLIGHT_NO = _f[0]
    flight = {
        'booking_code': BOOKING_CODE,
        'passenger_name': _f[5],
        'flight_no': _f[0],
        'depart_date': _f[1],
        'origin': _f[2][:3],
        'depart_time': _f[2][3:],
        'destination': _f[3][:3],
        'arrival_time': _f[3][3:],
        'status': _f[4],
        'raw': _f
    }
    # print('flight > ' + str(flight))
    output['flight'] = flight
    raw_seats = result.split(_replacement)[2].split('|')
    raw_seats.sort()
    # print('raw_seats > ' + str(raw_seats))
    # Default Seat Number Alphabetic
    _alpha = ['A', 'B', 'C', 'D', 'E', 'F']
    # Getting Seat Number Numeric
    raw_no = []
    seat_no = []
    for seat in raw_seats:
        raw_no.append(seat[:2])
        seat_no.append(seat[:3])
    raw_no.sort()
    # print('raw_no > ' + str(raw_no))
    seat_no.sort()
    # print('seat_no > ' + str(seat_no))
    new_raw_no = list(set(raw_no))
    new_raw_no.sort()
    # print('new_raw_no > ' + str(new_raw_no))
    # Finding Missing Seat Number
    miss_seat = []
    for a in _alpha:
        for _no in new_raw_no:
            if (_no + a) not in seat_no:
                new_seat = _no + a + _delimit + 'D'
                miss_seat.append(new_seat)
                # print('add new_seat > ' + str(new_seat))
            else:
                continue
    new_miss_seat = list(set(miss_seat))
    # print('new_miss_seat > ' + str(new_miss_seat))
    # Assuming Missing Seat 13 and 14 are Emergency row
    if '13A' not in seat_no and '14A' not in seat_no and INCLUDE_EMERGENCY is True:
        emergency_seat = ['13A'+_delimit+'E', '13B'+_delimit+'E', '13C'+_delimit+'E', '13D'+_delimit+'E', '13E'+_delimit+'E', '13F'+_delimit+'E',
                          '14A'+_delimit+'E', '14B'+_delimit+'E', '14C'+_delimit+'E', '14D'+_delimit+'E', '14E'+_delimit+'E', '14F'+_delimit+'E']
        new_raw_seats = raw_seats + new_miss_seat + emergency_seat
        len_raw_no = len(new_raw_no) + len(['13', '14'])
    else:
        new_raw_seats = raw_seats + new_miss_seat
        len_raw_no = len(new_raw_no)
    new_raw_seats.sort()
    # Validating Seat Count
    if len_raw_no * len(_alpha) != len(new_raw_seats):
        LOGGER.warning('[WARNING] Seats Data Not Match!')
        print('Seats Data Not Match!')
    # Grouping Seat into 6
    split_seats = split_list(new_raw_seats, len(_alpha))
    # print('split_seats > ' + str(split_seats))
    # Render Seat Output
    seats = []
    _row_seat = 0
    for s in split_seats:
        _row_seat += 1
        _seat_pos = 'MIDDLE'
        if _row_seat == 1:
            _seat_pos = 'FRONT'
        if _row_seat == len(split_seats):
            _seat_pos = 'BACK'
        s.sort()
        _seat_type = 'REGULAR'
        if _delimit+'E' in s[0]:
            _seat_type = 'EMERGENCY'
        seats.append({
            'seat_no': _row_seat,
            'seat_pos': _seat_pos,
            'seat_type': _seat_type,
            'delimit': _delimit,
            'seat_a': s[0][:5] + get_status_seat(s[0].split(_delimit)[1]),
            'seat_b': s[1][:5] + get_status_seat(s[1].split(_delimit)[1]),
            'seat_c': s[2][:5] + get_status_seat(s[2].split(_delimit)[1]),
            'seat_d': s[3][:5] + get_status_seat(s[3].split(_delimit)[1]),
            'seat_e': s[4][:5] + get_status_seat(s[4].split(_delimit)[1]),
            'seat_f': s[5][:5] + get_status_seat(s[5].split(_delimit)[1])
        })
    # print('seats > ' + str(seats))
    output['seats'] = seats
    return output


def get_status_seat(s):
    if s == 'A':
        return 'AVAILABLE'
    elif s == 'E':
        return 'EMERGENCY'
    elif s == 'D':
        return 'DUMMY'
    else:
        return 'NOT_AVAILABLE'


def start_get_boarding_pass(param):
    _Helper.get_pool().apply_async(get_boarding_pass, (param,))


BOARDING_FILE = None


def get_boarding_pass(param):
    if param is None:
        LOGGER.warning('Missing Param')
        return
    try:
        seat_no = json.loads(param)['seat_no']
        param = CMD["GET_BOARDING"] + "|" + seat_no
        response, result = _Command.send_request(param=param,
                                                 output=_Command.MO_REPORT,
                                                 flushing=_Command.MO_REPORT)
        if response == 0:
            handling_boarding_pass()
        else:
            CI_SIGNDLER.SIGNAL_GET_BOARDINGPASS.emit('ERROR')
            LOGGER.warning(("RESPONSE : ", str(response), result))
    except Exception as e:
        CI_SIGNDLER.SIGNAL_GET_BOARDINGPASS.emit('ERROR')
        LOGGER.warning(str(e))


SEEK_CODE2 = '_bp.pdf'


def handling_boarding_pass():
    global BOARDING_FILE
    attempt = 0
    result_list = []
    pid = '[' + _Helper.get_random_chars(5, '1234567890') + ']'
    _replacement = '<>'
    while True:
        attempt += 1
        if attempt >= MAX_ATTEMPTS:
            LOGGER.info(('[Break] by MAX_ATTEMPTS:', str(MAX_ATTEMPTS)))
            CI_SIGNDLER.SIGNAL_GET_BOARDINGPASS.emit('ERROR')
            break
        if DUMMY_RESPONSE is True:
            sleep(3)
            response = 0
            result = SAMPLE_BOARDING
        else:
            response, result = _Command.get_response_with_handle(out=_Command.MO_REPORT, repl=_replacement,
                                                                 module='GET-BOARDING_' + BOOKING_CODE + '_' + pid)
        if response == 0:
            if result not in result_list:
                result_list.append(result)
            if SEEK_CODE2 in result.lower():
                BOARDING_FILE = result.split(_replacement)[1]
                result = {
                    'boarding_pass': BOARDING_FILE,
                    'passenger': result.split(_replacement)[0]
                }
                LOGGER.info(('[Break] Final Result Get Boarding :', str(result)))
                CI_SIGNDLER.SIGNAL_GET_BOARDINGPASS.emit(json.dumps(result))
                BOARDING_FILE = _PDFTool.rotate_pdf(BOARDING_FILE, BOOKING_CODE, FLIGHT_NO)
                if BOARDING_FILE is not False:
                    _Printer.do_printout(BOARDING_FILE)
                    CI_SIGNDLER.SIGNAL_PRINT_BOARDINGPASS.emit('PRINTING|SUCCESS')
                else:
                    CI_SIGNDLER.SIGNAL_PRINT_BOARDINGPASS.emit('PRINTING|FAILED')
                break
        sleep(1)
