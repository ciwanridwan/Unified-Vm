__author__ = 'fitrah.wahyudi.imam@gmail.com'

import logging
import time
from pprint import pprint
import json
from _cConfig import _ConfigParser
from _nNetwork import _NetworkAccess
from _tTools import _Helper
from PyQt5.QtCore import QObject, pyqtSignal
import os
import sys
import threading
from _dDAO import _DAO
from string import capwords
from operator import itemgetter
from _sService import _KioskService
from _dDB import _AirportCity

LOCK = threading.Lock()


class TiboxSignalHandler(QObject):
    __qualname__ = 'TiboxSignalHandler'
    SIGNAL_SET_PLAN = pyqtSignal(str)
    SIGNAL_CREATE_SCHEDULE = pyqtSignal(str)
    SIGNAL_CREATE_CHART = pyqtSignal(str)
    SIGNAL_POST_PERSON = pyqtSignal(str)
    SIGNAL_CREATE_BOOKING = pyqtSignal(str)
    SIGNAL_CREATE_PAYMENT = pyqtSignal(str)
    SIGNAL_CREATE_PRINT = pyqtSignal(str)
    SIGNAL_CLEAR_PERSON = pyqtSignal(str)
    SIGNAL_CONFIRM_SCHEDULE = pyqtSignal(str)
    SIGNAL_GET_AIRPORT_NAME = pyqtSignal(str)
    SIGNAL_DETAILS_PASSENGER = pyqtSignal(str)
    SIGNAL_FLIGHT_DATA_SORTED = pyqtSignal(str)


T_SIGNDLER = TiboxSignalHandler()
LOGGER = logging.getLogger()
TID = _ConfigParser.get_value('TERMINAL', 'tid')
TIBOX_URL = _ConfigParser.get_value('TERMINAL', 'tibox^server')
HEADER = {'Content-Type': 'multipart/form-data'}
ID = None
BACKEND_URL = _ConfigParser.get_value('TERMINAL', 'backend^server')
PREFIX_ORIGIN = ""
PREFIX_DESTINATION = ""
IS_RESET = False

# ======================
SAMPLE = 'OK|JT-34^04:30 - 07:20^737-900ER�^JT^34^2018-04-08T04:30:00^2018-04-08T07:20:00^1^I�2|708000.0000|0|0|Q^JT^34^2018-04-08T04:30:00^2018-04-08T07:20:00^1^I�^JT^34^2018-04-08T04:30:00^2018-04-08T07:20:00^1^I;JT-38^05:00 - 07:50^737-900ER�^JT^38^2018-04-08T05:00:00^2018-04-08T07:50:00^1^I�2|708000.0000|0|0|Q^JT^38^2018-04-08T05:00:00^2018-04-08T07:50:00^1^I�^JT^38^2018-04-08T05:00:00^2018-04-08T07:50:00^1^I;JT-30^05:40 - 08:30^737-900ER�^JT^30^2018-04-08T05:40:00^2018-04-08T08:30:00^1^I�2|708000.0000|0|0|Q^JT^30^2018-04-08T05:40:00^2018-04-08T08:30:00^1^I�^JT^30^2018-04-08T05:40:00^2018-04-08T08:30:00^1^I;ID-6500^06:00 - 08:50^�^ID^6500^2018-04-08T06:00:00^2018-04-08T08:50:00^1^I�3|873000.0000|0|0|M^ID^6500^2018-04-08T06:00:00^2018-04-08T08:50:00^1^I�10|1830000.0000|0|0|I^ID^6500^2018-04-08T06:00:00^2018-04-08T08:50:00^1^I;JT-32^07:20 - 10:10^737-900ER�^JT^32^2018-04-08T07:20:00^2018-04-08T10:10:00^1^I�2|708000.0000|0|0|Q^JT^32^2018-04-08T07:20:00^2018-04-08T10:10:00^1^I�^JT^32^2018-04-08T07:20:00^2018-04-08T10:10:00^1^I;JT-28^08:20 - 11:10^737-900ER�^JT^28^2018-04-08T08:20:00^2018-04-08T11:10:00^1^I�2|708000.0000|0|0|Q^JT^28^2018-04-08T08:20:00^2018-04-08T11:10:00^1^I�^JT^28^2018-04-08T08:20:00^2018-04-08T11:10:00^1^I;ID-6512^10:55 - 13:55^737-900ER�^ID^6512^2018-04-08T10:55:00^2018-04-08T13:55:00^1^I�3|873000.0000|0|0|M^ID^6512^2018-04-08T10:55:00^2018-04-08T13:55:00^1^I�10|1830000.0000|0|0|I^ID^6512^2018-04-08T10:55:00^2018-04-08T13:55:00^1^I;JT-22^11:25 - 14:20^737-900ER�^JT^22^2018-04-08T11:25:00^2018-04-08T14:20:00^1^I�2|708000.0000|0|0|Q^JT^22^2018-04-08T11:25:00^2018-04-08T14:20:00^1^I�^JT^22^2018-04-08T11:25:00^2018-04-08T14:20:00^1^I;JT-36^12:30 - 15:20^737-900ER�^JT^36^2018-04-08T12:30:00^2018-04-08T15:20:00^1^I�2|708000.0000|0|0|Q^JT^36^2018-04-08T12:30:00^2018-04-08T15:20:00^1^I�^JT^36^2018-04-08T12:30:00^2018-04-08T15:20:00^1^I;JT-12^13:30 - 16:20^737-900ER�^JT^12^2018-04-08T13:30:00^2018-04-08T16:20:00^1^I�2|708000.0000|0|0|Q^JT^12^2018-04-08T13:30:00^2018-04-08T16:20:00^1^I�^JT^12^2018-04-08T13:30:00^2018-04-08T16:20:00^1^I;JT-18^14:45 - 17:35^737-900ER�^JT^18^2018-04-08T14:45:00^2018-04-08T17:35:00^1^I�2|708000.0000|0|0|Q^JT^18^2018-04-08T14:45:00^2018-04-08T17:35:00^1^I�^JT^18^2018-04-08T14:45:00^2018-04-08T17:35:00^1^I;JT-40^15:40 - 18:30^737-900ER�^JT^40^2018-04-08T15:40:00^2018-04-08T18:30:00^1^I�4|774000.0000|0|0|N^JT^40^2018-04-08T15:40:00^2018-04-08T18:30:00^1^I�^JT^40^2018-04-08T15:40:00^2018-04-08T18:30:00^1^I;ID-6516^16:50 - 19:40^�^ID^6516^2018-04-08T16:50:00^2018-04-08T19:40:00^1^I�^ID^6516^2018-04-08T16:50:00^2018-04-08T19:40:00^1^I�^ID^6516^2018-04-08T16:50:00^2018-04-08T19:40:00^1^I;JT-26^17:55 - 20:45^737-900ER�^JT^26^2018-04-08T17:55:00^2018-04-08T20:45:00^1^I�4|774000.0000|0|0|N^JT^26^2018-04-08T17:55:00^2018-04-08T20:45:00^1^I�^JT^26^2018-04-08T17:55:00^2018-04-08T20:45:00^1^I;JT-16^18:45 - 21:30^737-900ER�^JT^16^2018-04-08T18:45:00^2018-04-08T21:30:00^1^I�4|774000.0000|0|0|N^JT^16^2018-04-08T18:45:00^2018-04-08T21:30:00^1^I�^JT^16^2018-04-08T18:45:00^2018-04-08T21:30:00^1^I;JT-42^19:45 - 22:30^�^JT^42^2018-04-08T19:45:00^2018-04-08T22:30:00^1^I�^JT^42^2018-04-08T19:45:00^2018-04-08T22:30:00^1^I�^JT^42^2018-04-08T19:45:00^2018-04-08T22:30:00^1^I;JT-10^20:45 - 23:35^737-900ER�^JT^10^2018-04-08T20:45:00^2018-04-08T23:35:00^1^I�4|774000.0000|0|0|N^JT^10^2018-04-08T20:45:00^2018-04-08T23:35:00^1^I�^JT^10^2018-04-08T20:45:00^2018-04-08T23:35:00^1^I;JT-568^19:00 - 23:00^737-900ER�^JT^568^2018-04-08T19:00:00^2018-04-08T23:00:00^1^I�^JT^568^2018-04-08T19:00:00^2018-04-08T23:00:00^1^I�^JT^568^2018-04-08T19:00:00^2018-04-08T23:00:00^1^I;ID-7309^18:30 - 21:25^�^ID^7309^2018-04-08T18:30:00^2018-04-08T21:25:00^1^I�^ID^7309^2018-04-08T18:30:00^2018-04-08T21:25:00^1^I�^ID^7309^2018-04-08T18:30:00^2018-04-08T21:25:00^1^I;'
# ======================


def create_session():
    print("pyt: #1-create_session triggered : " + _Helper.time_string())
    url_ = 'web_create_session.php?tid='+TID
    try:
        # CLEAN PREVIOUS VALUE =======================================
        if IS_RESET is False:
            reset_value()
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200 and 'OK' in response:
            return True
        else:
            LOGGER.warning("create_session in response")
            return False
    except Exception as e:
        LOGGER.warning(("create_session : ", e))
        return False


def start_set_plan(param):
    _Helper.get_pool().apply_async(set_plan, (param,))


DEPART_DATE = None
RETURN_DATE = None
DATE_DEPART = ''
DATE_RETURN = ''
TRIP = ''


def set_plan(param):
    global ID, DEPART_DATE, RETURN_DATE, DATE_DEPART, DATE_RETURN, PREFIX_ORIGIN, PREFIX_DESTINATION, \
        IS_RESET, SCHEDULE_SEND_FLAG
    if param is None:
        LOGGER.warning('set_plan param is NONE')
        T_SIGNDLER.SIGNAL_SET_PLAN.emit('ERROR')
        return
    # CREATE SESSION =============================================
    session = create_session()
    print("pyt: #2-set_plan triggered : " + _Helper.time_string())
    # SET VALUE ==================================================
    param = json.loads(param)
    adult = param["adult"]
    origin = param["origin"]
    destination = param["destination"]
    depart = param["depart"]
    return_ = param["return_"]
    child = param["child"]
    infant = param["infant"]
    # RE-SET VALUE ===============================================
    IS_RESET = False
    SCHEDULE_SEND_FLAG = True
    PREFIX_ORIGIN = origin
    PREFIX_DESTINATION = destination
    url_ = 'web_create_session.php?tid='+TID
    #format_date depart & return = 'YYYY-MM-DD'
    one_way = '&btnSubmit=yes&txtDepart=' + depart + '&txtFrom=' + origin + '&txtTo=' + destination + '&txtADT=' + adult
    with_return = '&txtReturn=' + return_ + '&radio_ftype=Return'
    with_child = '&txtCNN=' + child + '&txtINF=' + infant
    is_with_return = True if return_ != "" or len(return_) > 1 else False
    is_with_child = True if child != "0" or infant != "0" else False
    DEPART_DATE = depart
    # '2018-05-10'
    # TRIP = 'Trip [' + origin + '] -> [' + destination + ']'
    DATE_DEPART = depart[8:10] + '-' + depart[5:7] + '-' + depart[:4]

    if is_with_return is True:
        RETURN_DATE = return_
        DATE_RETURN = return_[8:10] + '-' + return_[5:7] + '-' + return_[:4]
        # TRIP = 'Trip [' + origin + '] -> [' + destination + '] -> [' + origin + ']'
        if is_with_child is True:
            url__ = TIBOX_URL + url_ + one_way + with_return + with_child
        else:
            url__ = TIBOX_URL + url_ + one_way + with_return
    elif is_with_child is True:
        url__ = TIBOX_URL + url_ + one_way + with_child
    else:
        url__ = TIBOX_URL + url_ + one_way

    if session is True:
        try:
            status, response = _NetworkAccess.get_from_url(url=url__, header=HEADER)
            if status == 200 and 'FAIL|' not in response:
                ID = response.split('|')[1]
                T_SIGNDLER.SIGNAL_SET_PLAN.emit('SUCCESS')
            else:
                LOGGER.debug(('set_plan :', str(response)))
                T_SIGNDLER.SIGNAL_SET_PLAN.emit('ERROR')
        except Exception as e:
            LOGGER.warning(('set_plan :', e))
            T_SIGNDLER.SIGNAL_SET_PLAN.emit('ERROR')
    else:
        LOGGER.debug(('set_plan session :', str(session)))
        T_SIGNDLER.SIGNAL_SET_PLAN.emit('ERROR')


def start_create_schedule():
    _Helper.get_pool().apply_async(create_schedule)


SCHEDULE_SEND_FLAG = True


def create_schedule():
    global ID, SCHEDULE_SEND_FLAG
    print("pyt: #3-create_schedule triggered : " + _Helper.time_string())
    if TID is None or ID is None:
        LOGGER.warning('[ERROR] create_schedule : No ID-TID')
        T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit('NO ID-TID')
        return
    url_ = 'web_create_schedule.php?tid=' + TID + '&&id=' + ID
    try:
        if SCHEDULE_SEND_FLAG is False:
            LOGGER.warning('[WARNING] Tibox Server Multiple Response is Detected!')
            return
        else:
            SCHEDULE_SEND_FLAG = False
            status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200 and 'FAIL|' not in response:
            try:
                # res_ = parse_flight_data(response)
                res_ = new_parse_flight_data(response)
                # DEPART_DATE = RETURN_DATE = None
                print("pyt: #5-parse_flight_data finished : " + _Helper.time_string())
                if len(res_) == 0:
                    LOGGER.info('flight data count : NO DATA')
                    T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit('NO DATA')
                else:
                    LOGGER.info(('flight data count :', str(len(res_))))
                    T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit(json.dumps(res_))
            except Exception as e:
                LOGGER.warning(('[ERROR PARSE] create_schedule : ', e))
                T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit('ERROR')
        else:
            LOGGER.debug(('create_schedule : ', str(response)))
            T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit('ERROR')
    except Exception as e:
        LOGGER.warning(('create_schedule : ', e))
        T_SIGNDLER.SIGNAL_CREATE_SCHEDULE.emit('ERROR')


FLIGHT_LIST = None


def parse_flight_data(text):
    global DEPART_DATE, RETURN_DATE, FLIGHT_LIST
    print("pyt: #4-parse_flight_data started : " + _Helper.time_string())
    if text is None or text == "":
        return
    list_flight = []
    text = text[3:] if "OK|" in text else text
    flights = text.split(';')
    for flight in flights[:-1]:
        details = dict()
        flight_ = flight.split("#")
        for i in flight_:
            if DEPART_DATE in i:
                details["flight_status"] = "DEPARTURE"
                details["flight_date"] = DEPART_DATE
            if RETURN_DATE is not None and RETURN_DATE in i:
                details["flight_status"] = "RETURNING"
                details["flight_date"] = RETURN_DATE
            f__ = flight_[0].split('?')
            # details["raw_data_parent"] = flight.replace('^', '|').replace('�', '$$$')
            # details["raw_data_parent"] = flight.replace('?', '|')
            details["raw_data_promo"] = flight_[1]
            details["raw_data_eco"] = flight_[2]
            details["raw_data_bus"] = flight_[3]
            # details["raw_data"] = flight.replace('^', '|').replace('�', '$$$')
            # details["flight_name"] = "Lion Air" if f__[0].find("JT") > -1 else "Batik Air",
            details["flight_no"] = f__[0]
            details["flight_time"] = f__[1]
            details["flight_time_int"] = float(f__[1].split(' - ')[0].replace(':', '.'))
            details["flight_type"] = f__[2]
            promo = flight_[1].split('|')
            details["promo_qty"] = 0 if len(promo) == 1 else promo[0].replace("?", "")
            details["promo_price"] = 0 if len(promo) == 1 else int(promo[1].replace(".0000", ""))
            economy = flight_[2].split("|")
            details["eco_qty"] = 0 if len(economy) == 1 else economy[0].replace("?", "")
            details["eco_price"] = 0 if len(economy) == 1 else int(economy[1].replace(".0000", ""))
            business = flight_[3].split("|")
            details["bus_qty"] = 0 if len(business) == 1 else business[0].replace("?", "")
            details["bus_price"] = 0 if len(business) == 1 else int(business[1].replace(".0000", ""))
        if int(details["eco_qty"]) + int(details["promo_qty"]) + int(details["bus_qty"]) > 0:
            list_flight.append(details)
    # pprint(list_flight)
    FLIGHT_LIST = list_flight
    return list_flight


DEBUG_MODE = False
IS_PIR = True if _ConfigParser.get_set_value('TERMINAL', 'pir^usage', '0') == '1' else False


def new_parse_flight_data(text):
    global DEPART_DATE, RETURN_DATE, FLIGHT_LIST
    print("pyt: #4-parse_flight_data started : " + _Helper.time_string())
    if text is None or text == "":
        return
    list_flight = []
    all_list_flight = []
    try:
        text = text[3:] if "OK|" in text else text
        flights = text.split(';')
        for flight in flights[:-1]:
            details = dict()
            flight_ = flight.split("#")
            for item in flight_:
                # set default value for each button
                details["raw_data_promo"] = flight_[1]
                details["raw_data_eco"] = flight_[2]
                details["raw_data_bus"] = flight_[3]
                details["flight_status"] = "DEPARTURE"
                details["flight_date"] = DEPART_DATE
                details["route_trip"] = PREFIX_ORIGIN + ' - ' + PREFIX_DESTINATION
                details["origin"] = PREFIX_ORIGIN
                details["destination"] = PREFIX_DESTINATION
                # define valid_origin from economy price
                valid = flight_[2].split("?")
                if len(valid) == 16 or len(valid) == 10:
                    valid.insert(0, " ")
                new_origin = valid[8]
                new_destination = valid[9]
                details["new_origin"] = new_origin
                details["new_destination"] = new_destination

            # if len(valid) != 11:
                #     # Assuming raw split length more than 11 (transit data)
                #     new_destination = valid[9]

                if RETURN_DATE is not None and RETURN_DATE in flight_[2]:
                    if "?" + PREFIX_DESTINATION + "?" + PREFIX_ORIGIN + "?" in flight_[2]:
                        details["flight_status"] = "RETURNING"
                        details["flight_date"] = RETURN_DATE
                        details["route_trip"] = PREFIX_DESTINATION + ' - ' + PREFIX_ORIGIN
                        # details["origin"] = PREFIX_DESTINATION
                        new_origin = valid[9]
                        # details["new_origin"] = new_origin
                        # details["new_destination"] = new_destination

            # Flight Data : 1 Parent (Global Summary) + 3 Price Child
                f__ = flight_[0].split('?')
                details["flight_no"] = f__[0]
                details["flight_time"] = f__[1]
                details["flight_time_int"] = float(f__[1].split(' - ')[0].replace(':', '.'))
                details["flight_type"] = f__[2]
                # set default value for new param =================================================
                details["trans_flight_no"] = ""
                details["trans_flight_time"] = ""
                details["trans_flight_point"] = ""
                details["is_transit"] = 0
                details["is_same_origin"] = 1
                details["is_same_destination"] = 1

                if new_destination != details["destination"]:
                    details["is_same_destination"] = 0

                # define origin departure
                if new_origin != details["origin"]:
                    details["is_same_origin"] = 0
                    details["origin"] = new_origin
                    if details["flight_status"] == "DEPARTURE":
                        # details["route_trip"] = new_origin + ' - ' + new_destination
                        details["route_trip"] = valid[8] + ' - ' + valid[9]
                    else:
                        # details["route_trip"] = new_destination + ' - ' + new_origin
                        details["route_trip"] = valid[9] + ' - ' + valid[8]
                # define transit
                if len(f__[3]) > 1:
                    details["is_transit"] = 1
                    details["trans_flight_no"] = f__[3]
                    details["trans_flight_time"] = f__[4]
                    details["trans_flight_point"] = valid[10]
                    details["route_trip"] = valid[8] + ' - ' + valid[10] + ' - ' + valid[9]
                    # if len(valid) == 17:
                    #     pass
                    # if details["flight_status"] == "DEPARTURE":
                    #     pass
                    # else:
                    #     details["route_trip"] = valid[8] + ' - ' + valid[10] + ' - ' + new_origin
                # define price promo
                promo = flight_[1].split("|")
                details["promo_qty"] = 0
                details["promo_price"] = 0
                if len(promo) > 1 and flight_[1][0] != '?':
                    details["promo_qty"] = int(promo[0]) + 1
                    details["promo_price"] = int(promo[1].replace(".0000", ""))
                # define price eco
                economy = flight_[2].split("|")
                details["eco_qty"] = 0
                details["eco_price"] = 0
                if len(economy) > 1 and flight_[2][0] != '?':
                    details["eco_qty"] = int(economy[0]) + 1
                    details["eco_price"] = int(economy[1].replace(".0000", ""))
            # define price business
                business = flight_[3].split("|")
                details["bus_qty"] = 0
                details["bus_price"] = 0
                if len(business) > 1 and flight_[3][0] != '?':
                    details["bus_qty"] = int(business[0]) + 1
                    details["bus_price"] = int(business[1].replace(".0000", ""))

            if DEBUG_MODE is True:
                all_list_flight.append(details)
            #  only be available if price is available and same origin and same destination
            # if int(details["eco_qty"]) + int(details["promo_qty"]) + int(details["bus_qty"]) > 0:
            if (int(details["eco_qty"]) + int(details["promo_qty"]) + int(details["bus_qty"]) > 0 and
                    details["is_same_origin"] == 1 and details["is_same_destination"] == 1):
                list_flight.append(details)

        # pprint(list_flight)
        if DEBUG_MODE is True:
            LOGGER.info(("all_list_flight : ", str(len(all_list_flight)), str(all_list_flight)))
        LOGGER.info(("new_parsing_method : ", str(len(list_flight)), str(list_flight)))
        FLIGHT_LIST = list_flight
        return list_flight
    except Exception as e:
        print("pyt : [error] new_parsing_method : ", str(e))
        return []

'''
ID-7569?21:20 - 22:30??-? - ?
#??ID?7569?2018-06-19T21:20:00?2018-06-19T22:30:00?1?Z?HLP?SRG?
#?4|506000.0000|506000.0000|50100.0000|?ID?7569?2018-06-19T21:20:00?2018-06-19T22:30:00?1?Z?HLP?SRG?
#?12|737000.0000|737000.0000|73200.0000|?ID?7569?2018-06-19T21:20:00?2018-06-19T22:30:00?1?Z?HLP?SRG?;
DEPARTURE
JT-690?05:00 - 06:30?737-900ER?IW-1839?07:35 - 08:45?
#??JT?690?2018-06-19T05:00:00?2018-06-19T06:30:00?1?Z?CGK?SRG?SUB?IW?1839?2018-06-19T07:35:00?2018-06-19T08:45:00?2?
#??JT?690?2018-06-19T05:00:00?2018-06-19T06:30:00?1?Z?CGK?SRG?SUB?IW?1839?2018-06-19T07:35:00?2018-06-19T08:45:00?2?
#??JT?690?2018-06-19T05:00:00?2018-06-19T06:30:00?1?Z?CGK?SRG?SUB?IW?1839?2018-06-19T07:35:00?2018-06-19T08:45:00?2?;
RETURN
JT-503?17:15 - 18:20?737-900ER?-?10:30 - 11:40?
#225|316800.0000|0|0|X?JT?503?2018-07-02T17:15:00?2018-07-02T18:20:00?1?I?SRG?CGK?
#233|418000.0000|0|0|Q?JT?503?2018-07-02T17:15:00?2018-07-02T18:20:00?1?I?SRG?CGK?
#??JT?503?2018-07-02T17:15:00?2018-07-02T18:20:00?1?I?SRG?CGK?

'''


def start_sort_flight_data(key, method):
    _Helper.get_pool().apply_async(sort_flight_data, (key, method,))


def sort_flight_data(key, method):
    global FLIGHT_LIST
    sorted_list = FLIGHT_LIST
    if key == "price":
        if method == 'z-a':
            key = "bus_price"
        else:
            key = "eco_price"
    elif key == "time":
        key = "flight_time_int"
    try:
        if method == 'z-a':
            sorted_list = sorted(FLIGHT_LIST, key=itemgetter(key), reverse=True)
        else:
            sorted_list = sorted(FLIGHT_LIST, key=itemgetter(key))
    except Exception as e:
        sorted_list = FLIGHT_LIST
        LOGGER.warning(('[ERROR] sort_flight_data : ', str(e)))
    finally:
        T_SIGNDLER.SIGNAL_FLIGHT_DATA_SORTED.emit(json.dumps(sorted_list))
        # pprint(sorted_list)

"""
103.28.14.165/tibox/get_chart.php?stype=" + stype + "&&id=" + sid + "&&val=" + sval
stype=OB/IB (OB = berangkat, IB= pulangnnya)
id= id trx dari halaman sebelumya
"""

TIME_DEPART_DEP = ''
TIME_ARRIVAL_DEP = ''
TIME_DEPART_RET = ''
TIME_ARRIVAL_RET = ''
CREATE_CHART = []
TRANSIT_LIST = []


def start_create_chart(param):
    global CREATE_CHART
    check_value = ID + '||' + param
    if check_value not in CREATE_CHART:
        print('pyt: start_create_chart', str(time.time()*1000), check_value)
        _Helper.get_pool().apply_async(create_chart, (param,))
        CREATE_CHART.append(check_value)


def create_chart(param):
    #stype = OB/IB(OB=depart, IB=return)
    global TIME_DEPART_DEP, TIME_ARRIVAL_DEP, TIME_DEPART_RET, TIME_ARRIVAL_RET, TRIP, TRANSIT_LIST, ID
    if param is None:
        LOGGER.warning('[ERROR] create_chart param is None')
        T_SIGNDLER.SIGNAL_CREATE_CHART.emit('MISSING DATA')
        return
    try:
        param = json.loads(param)
        stype = param["stype"]
        # standardize sval
        _sval = param["sval"]
        # __sval = _sval[1:] if _sval[0] == '?' else _sval
        sval = _sval.replace('?', '|')
        route_trip = param["route_trip"]
        # normal flight
        # '5|928000.0000|0|0|Q|ID|6892|2018-05-24T17:00:00|2018-05-24T19:20:00|1||CGK|KNO|Q'
        #  with transit
        # '1|1626000.0000|0|0|B|JT|690|2018-05-31T05:00:00|2018-05-31T06:30:00|1||CGK|BDO|SUB|JT|916|2018-05-31T12:10:00|2018-05-31T13:30:00|2|M'
        value_list = sval.split('|')
        if stype == 'OB':
            if len(value_list) == 14 or len(value_list) == 20:
                TIME_DEPART_DEP = value_list[7].split('T')[1][:5]
                TIME_ARRIVAL_DEP = value_list[8].split('T')[1][:5]
            else:
                TIME_DEPART_DEP = value_list[8].split('T')[1][:5]
                TIME_ARRIVAL_DEP = value_list[9].split('T')[1][:5]

            TRIP = 'Trip [ ' + route_trip.replace('-', '->') + ' ]'
            transit_depart = define_transit(stype, sval)
            if transit_depart is not None:
                TRANSIT_LIST.append(transit_depart)
                # print("pyt: [info] departure transit :", str(TRANSIT_LIST))

        if stype == 'IB':
            if len(value_list) == 14 or len(value_list) == 20:
                TIME_DEPART_RET = value_list[7].split('T')[1][:5]
                TIME_ARRIVAL_RET = value_list[8].split('T')[1][:5]
            else:
                TIME_DEPART_RET = value_list[8].split('T')[1][:5]
                TIME_ARRIVAL_RET = value_list[9].split('T')[1][:5]

            TRIP = 'Round Trip [ ' + route_trip.replace('-', '->') + ' ]'
            transit_return = define_transit(stype, sval)
            if transit_return is not None:
                TRANSIT_LIST.append(transit_return)
                # print("pyt: [info] return transit :", str(TRANSIT_LIST))

        url_ = 'get_chart2.php?stype=' + stype + '&&id=' + ID + "&&val=" + sval
        try:
            status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
            if status == 200:
                # LOGGER.debug(('[INFO] create_chart : ', str(response)))
                T_SIGNDLER.SIGNAL_CREATE_CHART.emit(str(response))
            else:
                LOGGER.debug(('create_chart : ', str(response)))
                T_SIGNDLER.SIGNAL_CREATE_CHART.emit('ERROR')
        except Exception as e:
            LOGGER.warning(('create_chart : ', e))
            T_SIGNDLER.SIGNAL_CREATE_CHART.emit('ERROR')
    except Exception as e:
        print("pyt: [error] create_chart :", str(e))
        LOGGER.warning(('create_chart : ', e))
        T_SIGNDLER.SIGNAL_CREATE_CHART.emit('ERROR')


def define_transit(t, d):
    if d[0] == '|':
        d = d[1:]
    d = d.split('|')
    if len(d) == 14:
        return None
    elif len(d) >= 20:
        flight_type = "DEPART" if t == "OB" else "RETURN"
        return {"flight_type": flight_type, "transit_hub": d[13], "transit_flight": d[14]+"-"+d[15],
                "transit_date": d[16].split('T')[0], "transit_depart_time": d[16].split('T')[1][:5],
                "transit_depart_arrival": d[17].split('T')[1][:5],
                "transit_airport": _DAO.get_airport_name({"prefix": d[13]})[0]["name"]}
"""
tibox/get_person.php?stype=ADT/CNN/INF&id=
ADT = &order=???&txtAdultTitle=Mr&fname=RIO&lname=PERMANA&thome=0218900988&tmobile=0817888889999&mail=rio.permana82@gmail.com
CNN = &order=???&txtChildTitle=Mr&fname_cnn=ANAK&lname_cnn=KECIL&bdate_cnn=2010-05-31
INF = &order=???&txtInfantTitle=Mr&fname_inf=BAYI&lname_inf=IMUT&bdate_inf=2018-05-31
"""

PASSENGER_LIST = {}
ADT_LIST = []
CNN_LIST = []
INF_LIST = []
CUSTOMER_INFO = ''
PERSON_DATA = []
PERSON_DATA_RESULT = []
URL_POST_PERSON = []


def start_post_person(param):
    global PERSON_DATA
    check_person = ID + '||' + param
    if check_person not in PERSON_DATA:
        _Helper.get_pool().apply_async(post_person, (param,))
        PERSON_DATA.append(check_person)


def post_person(param):
    global HEADER, ID, TIBOX_URL, ADT_LIST, CNN_LIST, INF_LIST, CUSTOMER_INFO, PERSON_DATA_RESULT, URL_POST_PERSON
    if param is None:
        LOGGER.warning('[ERROR] post_person : Missing Data')
        T_SIGNDLER.SIGNAL_POST_PERSON.emit('MISSING DATA')
        return
    param = json.loads(param)
    stype = param["stype"]
    order = param["order"]
    title = param["title"]
    fname = param["fname"]
    lname = param["lname"]
    thome = param["thome"]
    tmobile = param["tmobile"]
    email = param["email"]
    bdate = param["bdate"]
    url_ = ''

    if order == '1':
        CUSTOMER_INFO = '|'.join([capwords(fname + ' ' + lname), thome, tmobile, email])

    if stype == 'ADT':
        url_ = 'get_person.php?stype=' + stype + '&&id=' + ID + '&txtAdultTitle=' + title \
               + '&fname=' + fname + '&lname=' + lname + '&thome=' + thome + '&tmobile=' + tmobile \
               + '&mail=' + email + '&&order=' + order
        ADT_LIST.append(capwords(fname + ' ' + lname))
    elif stype == 'CNN':
        url_ = 'get_person.php?stype=' + stype + '&&id=' + ID + '&txtChildTitle=' + title \
               + '&fname_cnn=' + fname + '&lname_cnn=' + lname + '&bdate_cnn=' + bdate + '&&order=' + order
        if order != '1':
            CNN_LIST.append(capwords(fname + ' ' + lname))
    elif stype == 'INF':
        url_ = 'get_person.php?stype=' + stype + '&&id=' + ID + '&txtInfantTitle=' + title \
               + '&fname_inf=' + fname + '&lname_inf=' + lname + '&bdate_inf=' + bdate + '&&order=' + order
        if order != '1':
            INF_LIST.append(capwords(fname + ' ' + lname))

    url__ = TIBOX_URL + url_
    try:
        if url__ not in URL_POST_PERSON:
            status, response = _NetworkAccess.get_from_url(url=url__, header=HEADER)
            URL_POST_PERSON.append(url__)
            if response not in PERSON_DATA_RESULT:
                if status == 200 and fname in response:
                    T_SIGNDLER.SIGNAL_POST_PERSON.emit('SUCCESS')
                else:
                    LOGGER.debug(('post_person : ', status))
                    T_SIGNDLER.SIGNAL_POST_PERSON.emit('ERROR')
                PERSON_DATA_RESULT.append(response)
    except Exception as e:
        LOGGER.warning(('post_person : ', e))
        T_SIGNDLER.SIGNAL_POST_PERSON.emit('ERROR')


'''
Host : GET http://103.28.14.165:88/tibox/web_create_booking.php?id=[id-halaman-sebelumnya]&&tid=110001
Result :
OK^BOOKING_CODE:VLOQVF^TOTAL:708000.00^PAYMENT_STATUS:WAIT^TID:110001^FTYPE:OneWay^OB:4|708000.0000|0|0|Q|JT|34|2018-03-18T04:30:00|2018-03-18T07:20:00|1|I^IB:

'''

BOOKING_CODE = ''
INIT_FARE = '0'


def init_passenger():
    global PASSENGER_LIST
    if (len(CNN_LIST) == 0 and len(INF_LIST) == 0) or (ADT_LIST == CNN_LIST == INF_LIST):
        PASSENGER_LIST = {'adt': ADT_LIST}
    elif len(CNN_LIST) > 0 and len(INF_LIST) == 0 and CNN_LIST != INF_LIST:
        PASSENGER_LIST = {'adt': ADT_LIST, 'cnn': CNN_LIST}
    elif len(CNN_LIST) == 0 and len(INF_LIST) > 0 and CNN_LIST != INF_LIST:
        PASSENGER_LIST = {'adt': ADT_LIST, 'inf': INF_LIST}
    elif len(CNN_LIST) > 0 and len(INF_LIST) > 0 and ADT_LIST != CNN_LIST != INF_LIST:
        PASSENGER_LIST = {'adt': ADT_LIST, 'cnn': CNN_LIST, 'inf': INF_LIST}
    pprint(PASSENGER_LIST)
    # PASSENGER_LIST = {'adt': ADT_LIST, 'cnn': CNN_LIST, 'inf': INF_LIST}
    return PASSENGER_LIST


def start_create_booking():
    _Helper.get_pool().apply_async(create_booking)


def create_booking():
    global HEADER, ID, TIBOX_URL, TID, BOOKING_CODE, INIT_FARE, FLIGHT_PRODUCT
    url_ = 'web_create_booking.php?id=' + ID + '&&tid=' + TID
    try:
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200 and 'BOOKING_CODE:?TOTAL' not in response:
            '''
OK?BOOKING_CODE:ZSTGZX?TOTAL:730000.00?PAYMENT_STATUS:WAIT?TID:110050?FTYPE:OneWay?OB:1|730000.0000|0|0|Q|JT|326|2018-04-06T15:10:00|2018-04-06T17:55:00|1|Z?IB:?'''
            print("pyt: [info] raw result from booking : ", response)
            try:
                booking_data = parse_booking_flight(response)
                BOOKING_CODE = booking_data["booking_code"]
                FLIGHT_PRODUCT = response
                INIT_FARE = booking_data["total_payment"].replace('.00', '')
                T_SIGNDLER.SIGNAL_CREATE_BOOKING.emit(json.dumps(booking_data))
            except ValueError:
                T_SIGNDLER.SIGNAL_CREATE_BOOKING.emit('ERROR')
            finally:
                log_product()
            LOGGER.debug(('create_booking response : ', response))
        else:
            LOGGER.debug(('create_booking : ', str(response)))
            T_SIGNDLER.SIGNAL_CREATE_BOOKING.emit('ERROR')
    except Exception as e:
        LOGGER.warning(('create_booking : ', e))
        T_SIGNDLER.SIGNAL_CREATE_BOOKING.emit('ERROR')

'''
Host : GET http://103.28.14.165:88/tibox/p_check_paid.php?val=[jumlah-uang-yg-dibayarkan]&&tid=110001
'''
FLIGHT_NO_DEPART = ''
FLIGHT_NO_RETURN = ''
FLIGHT_PRODUCT = ''
TERMINAL_DEPART = ''
TERMINAL_RETURN = ''

''' Add condition in getting flight name'''


def get_flight_name(d):
    if 'JT' in d:
        return "Lion Air"
    elif 'ID' in d:
        return "Batik Air"
    elif 'SL' in d:
        return "Thai Lion Air"
    elif 'OD' in d:
        return "Malindo Air"
    elif 'IW' in d:
        return "Wings Air"
    else:
        return "Lion Air"


def parse_booking_flight(data):
    global FLIGHT_NO_DEPART, FLIGHT_NO_RETURN, TERMINAL_DEPART, TERMINAL_RETURN
    data = data.split('?')
    FLIGHT_NO_DEPART = flight_brand(data[6].split('|')[5] + data[6].split('|')[6])
    if RETURN_DATE is not None and len(data[7]) > 5:
        FLIGHT_NO_RETURN = flight_brand(data[7].split('|')[5] + data[7].split('|')[6])

    booking_data = dict()
    '''
    ['OK', 'BOOKING_CODE:ZSTGZX', 'TOTAL:730000.00', 'PAYMENT_STATUS:WAIT', 'TID:110050', 'FTYPE:OneWay', 'OB:1|730000.0000|0|0|Q|JT|326|2018-04-06T15:10:00|2018-04-06T17:55:00|1|Z', 'IB:', '']
    '''
    try:
        flight = get_flight_name(data[6])
        td = _DAO.get_airport_terminal({"origin": PREFIX_ORIGIN, "destination": PREFIX_DESTINATION, "flight": flight})
        if len(td) > 0:
            TERMINAL_DEPART = td[0]["terminal"]

        if len(TERMINAL_DEPART) < 1 and len(TRANSIT_LIST) > 0:
            for x in range(len(TRANSIT_LIST)):
                if TRANSIT_LIST[x]["flight_type"] == "DEPART":
                    hub = TRANSIT_LIST[x]["transit_hub"]
                    td_ = _DAO.get_airport_terminal({"origin": PREFIX_ORIGIN, "destination": hub, "flight": flight})
                    if flight == "Malindo Air":
                        TERMINAL_DEPART = "2E"
                    else:
                        if len(td_) > 0:
                            TERMINAL_DEPART = td_[0]["terminal"]

        booking_data = {
            "booking_code": data[1].split(':')[1],
            "total_payment": data[2].split(':')[1].replace('.00', ''),
            "payment_status": data[3].split(':')[1],
            "flight_type": data[5].split(':')[1],
            "depart_raw": data[6],
            "return_raw": "",
            "terminal_depart": TERMINAL_DEPART,
            "terminal_return": ""
        }

        if RETURN_DATE is not None and len(data[7]) > 5:
            flight = get_flight_name(data[7])
            tr = _DAO.get_airport_terminal({"origin": PREFIX_DESTINATION, "destination": PREFIX_ORIGIN, "flight": flight})
            if len(tr) > 0:
                TERMINAL_RETURN = tr[0]["terminal"]

            if len(TERMINAL_RETURN) < 1 and len(TRANSIT_LIST) > 0:
                for y in range(len(TRANSIT_LIST)):
                    if TRANSIT_LIST[y]["flight_type"] == "RETURN":
                        hub = TRANSIT_LIST[y]["transit_hub"]
                        tr_ = _DAO.get_airport_terminal({"origin": hub, "destination": PREFIX_ORIGIN, "flight": flight})
                        if len(tr_) > 0:
                            TERMINAL_RETURN = tr_[0]["terminal"]

            booking_data["return_raw"] = data[7]
            booking_data["terminal_return"] = TERMINAL_RETURN

        LOGGER.info('booking_data : ', booking_data)
    except Exception as e:
        booking_data = {
            "booking_code": data[1].split(':')[1],
            "total_payment": data[2].split(':')[1].replace('.00', ''),
            "payment_status": data[3].split(':')[1],
            "flight_type": data[5].split(':')[1],
            "depart_raw": data[6],
            "return_raw": data[7],
        }
        LOGGER.warning(('booking_data : ', str(e)))
    finally:
        # print("pyt: booking_data : ", str(booking_data))
        return booking_data


def flight_brand(f_no):
    if 'JT' in f_no:
        f_no = f_no + '/LION AIR'
    elif 'ID' in f_no:
        f_no = f_no + '/BATIK AIR'
    elif 'OD' in f_no:
        f_no = f_no + '/MALINDO AIR'
    elif 'SL' in f_no:
        f_no = f_no + '/THAI LION AIR'
    elif 'IW' in f_no:
        f_no = f_no + '/WINGS AIR'
    return f_no


TXT_BOOKING_STATUS = 'WAITING'


def start_create_payment(payment):
    _Helper.get_pool().apply_async(create_payment, (payment,))


def create_payment(payment):
    global HEADER, ID, TIBOX_URL, TID, BOOKING_CODE, INIT_FARE, ROUNDED_FARE, TXT_BOOKING_STATUS
    url_ = 'p_check_paid.php?val=' + payment + '&&tid=' + TID + '&&id=' + ID
    try:
        trying = 0
        while True:
            trying += 1
            status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
            if status == 200 and 'OK' in response:
                TXT_BOOKING_STATUS = 'SUCCESS'
                if _KioskService.PREV_RECEIPT_RAW_DATA is not None:
                    update_param_data = json.loads(_KioskService.PREV_PARAM_DATA)
                    update_param_data['GET_UPDATE_PAYMENT'] = TXT_BOOKING_STATUS
                    _KioskService.PREV_PARAM_DATA = json.dumps(update_param_data)
                    _raw_receipt = _KioskService.PREV_RECEIPT_RAW_DATA
                    _KioskService.PREV_RECEIPT_RAW_DATA = _raw_receipt.replace('Payment Status', 'Booking Status')
                    _KioskService.PREV_RECEIPT_RAW_DATA = _KioskService.PREV_RECEIPT_RAW_DATA.split('Booking Status')[0]
                    _KioskService.PREV_RECEIPT_RAW_DATA += ('Booking Status   : ' + TXT_BOOKING_STATUS + '\r\n')
                LOGGER.info(('create_payment to vedaleon: ', str(response)))
                T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('SUCCESS')
                break
            if trying == 3:
                LOGGER.warning(('create_payment to vedaleon: ', str(response)))
                T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('ERROR')
                break
            time.sleep(1.5)
    except Exception as e:
        LOGGER.warning(('create_payment : ', e))
        T_SIGNDLER.SIGNAL_CREATE_PAYMENT.emit('ERROR')

'''
Host : GET http://103.28.14.165:88/tibox/web_ticket_print.php?id=[id-dari-halaman-sebelumnya]&&tid=110001
Result : 
"OK^BOOKING_CODE:".$row[bk_booking_code]."^TOTAL:".$row[bk_grandtotal]."^PAYMENT_STATUS:".$row[bk_payment_status]."^TID:".
                $row[bk_tid]."^FTYPE:".$row[bk_ftype]."^OB:".$row[bk_price_ob]."^IB:".$row[bk_price_ib]."^[NOTES]:".$responseArray2[soapBody][FlightInformationResponse][FlightInformationRS][FlightRouteServices][FlightRoutes][FlightRoute][FlightNotes]['string'];   
'''


def tibox_terminal():
    global HEADER, ID, TIBOX_URL, TID
    terminal_no = 'Terminal '
    url_ = 'web_ticket_print.php?id=' + ID + '&&tid=' + TID
    try:
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200:
            '''
            OK?BOOKING_CODE:?TOTAL:?PAYMENT_STATUS:?TID:?FTYPE:?OB:?IB:?[NOTES]:HLP-JOG CHECK-IN WITH BATIK AIR KEBERANGKATAN DARI HALIM P K
            '''
            check_terminal = response.split(' TERMINAL ')
            if len(check_terminal) == 2:
                terminal_no += check_terminal[1]
            if len(check_terminal) > 2:
                terminal_no += check_terminal[1] + '|' + check_terminal[3]
            LOGGER.info(('tibox_terminal : ', str(response)))
        else:
            LOGGER.debug(('tibox_terminal : ', str(response)))
    except Exception as e:
        LOGGER.warning(('tibox_terminal  : ', e))
    finally:
        return terminal_no


def start_create_print():
    _Helper.get_pool().apply_async(create_print)


PRINT_FILE = ""


def create_print():
    global HEADER, ID, TIBOX_URL, TID
    url_ = 'web_ticket_print.php?id=' + ID + '&&tid=' + TID
    try:
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200 and 'OK' in response:
            generate_file_print(response)
            T_SIGNDLER.SIGNAL_CREATE_PRINT.emit('SUCCESS')
        else:
            LOGGER.debug(('create_print : ', str(response)))
            T_SIGNDLER.SIGNAL_CREATE_PRINT.emit('ERROR')
    except Exception as e:
        LOGGER.warning(('create_print : ', e))
        T_SIGNDLER.SIGNAL_CREATE_PRINT.emit('ERROR')


def generate_file_print(r):
    global BOOKING_CODE, PRINT_FILE
    if r is None or r == "":
        return
    if not os.path.exists(sys.path[0] + '/_fFile/'):
        os.makedirs(sys.path[0] + '/_fFile/')
    PRINT_FILE = BOOKING_CODE + "_" + time.strftime("%Y%m%d-%H%M%S", time.gmtime()) + ".txt"
    try:
        try:
            LOCK.acquire()
            with open(PRINT_FILE, 'w') as f:
                f.write(r)
                f.close()
        except Exception as e:
            LOGGER.warning(('write generate_file_print : ', e))
        finally:
            LOCK.release()
    except Exception as e:
        LOGGER.warning(('generate_file_print : ', e))


def start_clear_person():
    _Helper.get_pool().apply_async(clear_person)


def clear_person():
    global ID
    url_ = 'get_person.php?stype=DELETE&&id=' + ID
    try:
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if status == 200:
            T_SIGNDLER.SIGNAL_CLEAR_PERSON.emit('SUCCESS')
        else:
            LOGGER.debug(('clear_person : ', status))
            T_SIGNDLER.SIGNAL_CLEAR_PERSON.emit('ERROR')
    except Exception as e:
        LOGGER.warning(('clear_person : ', e))
        T_SIGNDLER.SIGNAL_CLEAR_PERSON.emit('ERROR')


CONFIRM_SCHEDULE = []


def start_confirm_schedule():
    global CONFIRM_SCHEDULE
    check_confirm = ID + '||' + TID
    if check_confirm not in CONFIRM_SCHEDULE:
        _Helper.get_pool().apply_async(confirm_schedule)
        CONFIRM_SCHEDULE.append(check_confirm)


CONFIRM_SCHEDULE_RESULT = []


def confirm_schedule():
    global CONFIRM_SCHEDULE_RESULT, ID
    url_ = 'web_create_schedule_confirm.php?id=' + ID + '&&tid=' + TID
    try:
        status, response = _NetworkAccess.get_from_url(url=TIBOX_URL + url_, header=HEADER)
        if (response + '||' + ID + '||' + TID) not in CONFIRM_SCHEDULE_RESULT:
            if status == 200 and 'OK' in response:
                LOGGER.info(('[INFO] confirm_schedule response : ', response))
                T_SIGNDLER.SIGNAL_CONFIRM_SCHEDULE.emit('SUCCESS')
            else:
                LOGGER.debug(('confirm_schedule : ', str(response)))
                T_SIGNDLER.SIGNAL_CONFIRM_SCHEDULE.emit('ERROR')
            CONFIRM_SCHEDULE_RESULT.append(response + '||' + ID + '||' + TID)
    except Exception as e:
        LOGGER.warning(('confirm_schedule : ', e))
        T_SIGNDLER.SIGNAL_CONFIRM_SCHEDULE.emit('ERROR')


ROUNDED_FARE = '0'
MARGIN = '0'


def set_rounded_fare(amount):
    _Helper.get_pool().apply_async(rounded_fare, (amount,))


def rounded_fare(amount):
    global ROUNDED_FARE, MARGIN
    ROUNDED_FARE = amount
    MARGIN = str(int(ROUNDED_FARE) - int(INIT_FARE))


def start_get_airport_name(prefix1, prefix2):
    _Helper.get_pool().apply_async(get_airport_name, (prefix1, prefix2,))


AIRPORT_DEPART = ''
AIRPORT_ARRIVAL = ''
GET_AIRPORT_CITY_ONLY = True


def get_airport_name(prefix1, prefix2):
    global AIRPORT_DEPART, AIRPORT_ARRIVAL
    if prefix1 == "" or prefix1 is None or prefix2 == "" or prefix2 is None:
        T_SIGNDLER.SIGNAL_GET_AIRPORT_NAME.emit("ERROR")
        return
    else:
        param1 = {"prefix": prefix1}
        param2 = {"prefix": prefix2}
        airport_name = [_DAO.get_airport_name(param1)[0], _DAO.get_airport_name(param2)[0]]
        if GET_AIRPORT_CITY_ONLY is True:
            AIRPORT_DEPART = _AirportCity.LIST[prefix1]
            AIRPORT_ARRIVAL = _AirportCity.LIST[prefix2]
        else:
            AIRPORT_DEPART = airport_name[0]['name']
            AIRPORT_ARRIVAL = airport_name[1]['name']
        # print(airport_name)
        T_SIGNDLER.SIGNAL_GET_AIRPORT_NAME.emit(json.dumps(airport_name).encode().decode())


def start_send_details_passenger():
    _Helper.get_pool().apply_async(send_details_passenger)


def send_details_passenger():
    try:
        passenger_data = details_passenger()
        if passenger_data != "":
            T_SIGNDLER.SIGNAL_DETAILS_PASSENGER.emit(passenger_data.replace('\r\n', '\n'))
        else:
            T_SIGNDLER.SIGNAL_DETAILS_PASSENGER.emit('ERROR')
    except Exception as e:
        T_SIGNDLER.SIGNAL_DETAILS_PASSENGER.emit('ERROR')
        LOGGER.warning(('send_details_passenger : ', str(e)))


def details_passenger():
    passenger_info = ""
    try:
        pass_list = init_passenger()
        for k, v in pass_list.items():
            if k == 'adt':
                passenger_info += " Adult Passenger\r\n"
                for i in range(len(v)):
                    passenger_info += " Name ({})   : {}\r\n".format(str(i+1), v[i])
        # for k2, v2 in pass_list.items():
            if k == 'cnn' and len(v) > 0:
                passenger_info += " Child Passenger\r\n"
                for j in range(len(v)):
                    passenger_info += " Name ({})   : {}\r\n".format(str(j+1), v[j])
        # for k3, v3 in pass_list.items():
            if k == 'inf' and len(v) > 0:
                passenger_info += " Infant Passenger\r\n"
                for l in range(len(v)):
                    passenger_info += " Name ({})   : {}\r\n".format(str(l+1), v[l])
    finally:
        return passenger_info

'''
'GET_TICKET_PRICE': str(int(ROUNDED_FARE)-25000)
'''


def get_trip_summary():
    global AIRPORT_DEPART, AIRPORT_ARRIVAL
    if TERMINAL_DEPART != '' and PREFIX_ORIGIN == 'CGK':
        AIRPORT_DEPART += ' / Terminal ' + TERMINAL_DEPART
    if PREFIX_DESTINATION == 'CGK':
        flight = get_flight_name(FLIGHT_NO_DEPART)
        tr_cgk = _DAO.get_airport_terminal({"origin": PREFIX_ORIGIN,
                                            "destination": PREFIX_DESTINATION,
                                            "flight": flight})
        if len(tr_cgk) > 0:
            AIRPORT_ARRIVAL += ' / Terminal ' + tr_cgk[0]["terminal"]
        else:
            AIRPORT_ARRIVAL += ' / Arrival Terminal '

    airport_depart_list = AIRPORT_DEPART.split(' / ')
    if len(airport_depart_list) > 2:
        AIRPORT_DEPART = airport_depart_list[0] + ' / ' + airport_depart_list[1]

    return {'GET_TOTAL_COST': ROUNDED_FARE,
            'GET_BOOKING_CODE': BOOKING_CODE,
            'GET_TRIP': TRIP,
            'GET_AIRPORT_DEPART': AIRPORT_DEPART,
            'GET_AIRPORT_ARRIVAL': AIRPORT_ARRIVAL,
            'GET_FLIGHT_NO_DEPART': FLIGHT_NO_DEPART,
            'GET_FLIGHT_NO_RETURN': FLIGHT_NO_RETURN,
            'GET_DATE_DEPART': DATE_DEPART,
            'GET_DATE_RETURN': DATE_RETURN,
            'GET_TIME_DEPART_DEP': TIME_DEPART_DEP,
            'GET_TIME_ARRIVAL_DEP': TIME_ARRIVAL_DEP,
            'GET_TIME_DEPART_RET': TIME_DEPART_RET,
            'GET_TIME_ARRIVAL_RET': TIME_ARRIVAL_RET,
            'GET_TICKET_PRICE': str(rounding_price(INIT_FARE, _KioskService.KIOSK_MARGIN)),
            'GET_PASSENGER_LIST': details_passenger(),
            'GET_TRANSIT_STATUS': get_transit_status(),
            'GET_TRANSIT_DATA': TRANSIT_LIST,
            'GET_TIBOX_ID': ID,
            'GET_PAYMENT_STATUS': TXT_BOOKING_STATUS,
            'GET_INIT_FARE': str(INIT_FARE)
            }


def get_transit_status():
    if len(TRANSIT_LIST) > 0:
        if TRANSIT_LIST[0] is not None:
            return True
        elif TRANSIT_LIST[1] is not None:
            return True
    else:
        return False


def rounding_price(f, n):
    print('rounding_pricing with :', str(n))
    x_f = (n/100) * int(f)
    r_f = (int(f) + x_f) % 10000
    if r_f != 0:
        x_f_ = x_f + (10000 - r_f)
    else:
        x_f_ = x_f + 10000
    return int(f) + int(x_f_)


PID = ''


def get_tpid(string):
    param = {'string': string}
    t = _DAO.get_tpid(param)
    _tpid = t[0]['tpid']
    print('pyt: get transactionType code : ', _tpid)
    return _tpid


def log_product():
    global PID
    PID = _Helper.get_uuid()
    _url = BACKEND_URL + 'sync/product'
    '''
    :param param:
    pid             VARCHAR(100) PRIMARY KEY NOT NULL,
    name            VARCHAR(150)             NOT NULL,
    price           BIGINT,
    details         TEXT,
    status          INT,
    createdAt       BIGINT,
    :return:
    '''
    _param = {
        'pid': PID,
        'name': BOOKING_CODE,
        'price': int(INIT_FARE),
        'details': FLIGHT_PRODUCT + '#' + CUSTOMER_INFO + '#' + TRIP,
        'status': 0
    }
    _DAO.insert_product(_param)
    _param["createdAt"] = _Helper.now()
    status, response = _NetworkAccess.post_to_url(url=_url, param=_param)
    if status == 200 and response['id'] == _param['pid']:
        _param['key'] = _param['pid']
        _DAO.mark_sync(param=_param, _table='Product', _key='pid')


def reset_value():
    global BOOKING_CODE, ROUNDED_FARE, AIRPORT_ARRIVAL, AIRPORT_DEPART, DATE_RETURN, DATE_DEPART, RETURN_DATE, \
        DEPART_DATE, TRIP, TIME_ARRIVAL_RET, TIME_DEPART_RET, TIME_ARRIVAL_DEP, TIME_DEPART_DEP, INIT_FARE, \
        CUSTOMER_INFO, FLIGHT_LIST, PREFIX_ORIGIN, PREFIX_DESTINATION, TRANSIT_LIST, CREATE_CHART, TERMINAL_DEPART, \
        TERMINAL_RETURN, URL_POST_PERSON, PASSENGER_LIST, ADT_LIST, CNN_LIST, INF_LIST, IS_RESET, PERSON_DATA, \
        PERSON_DATA_RESULT, TRX_ID, TXT_BOOKING_STATUS
    try:
        TXT_BOOKING_STATUS = 'WAITING'
        BOOKING_CODE = None
        DEPART_DATE = None
        RETURN_DATE = None
        FLIGHT_LIST = None
        TRX_ID = None
        ROUNDED_FARE = '0'
        INIT_FARE = '0'
        AIRPORT_DEPART = ''
        AIRPORT_ARRIVAL = ''
        DATE_RETURN = ''
        DATE_DEPART = ''
        TRIP = ''
        TIME_DEPART_DEP = ''
        TIME_ARRIVAL_DEP = ''
        TIME_ARRIVAL_RET = ''
        TIME_DEPART_RET = ''
        CUSTOMER_INFO = ''
        PREFIX_ORIGIN = ''
        PREFIX_DESTINATION = ''
        TERMINAL_DEPART = ''
        TERMINAL_RETURN = ''
        CREATE_CHART = []
        TRANSIT_LIST = []
        URL_POST_PERSON = []
        ADT_LIST = []
        CNN_LIST = []
        INF_LIST = []
        PERSON_DATA = []
        PERSON_DATA_RESULT = []
        PASSENGER_LIST = {}
        IS_RESET = True
        print('pyt: [info] resetting global tibox values')
    except Exception as e:
        print('pyt: [error] resetting global tibox values : ', str(e))


TRX_ID = None


def save_trx_local(card_no, payment_method, payment_note):
    global TRX_ID
    if TRX_ID is None:
        TRX_ID = _Helper.get_uuid()
    _key = get_flight_name(FLIGHT_NO_DEPART).split()[0]
    _param = {
        'trxid': TRX_ID,
        'tid': TID,
        'mid': '',
        'pid': PID,
        'tpid': get_tpid(string=_key),
        'sale': int(ROUNDED_FARE),
        'amount': int(INIT_FARE),
        'cardNo': card_no,
        'paymentType': payment_method,
        'paymentNotes': json.dumps(payment_note),
        'bankMid': '',
        'bankTid': ''
    }
    check_trx = _DAO.check_trx(TRX_ID)
    if len(check_trx) == 0:
        _DAO.insert_transaction(_param)
    return _param


def update_trx_local(card_no, payment_method, payment_note):
    _key = get_flight_name(FLIGHT_NO_DEPART).split()[0]
    _param = {
        'trxid': TRX_ID,
        'tid': TID,
        'mid': '',
        'pid': PID,
        'tpid': get_tpid(string=_key),
        'sale': int(ROUNDED_FARE),
        'amount': int(INIT_FARE),
        'cardNo': card_no,
        'paymentType': payment_method,
        'paymentNotes': json.dumps(payment_note),
        'bankMid': '',
        'bankTid': ''
    }
    _DAO.update_transaction(_param)
    return _param


def save_cash_local(notes):
    param_cash = {
        'csid': TRX_ID[::-1],
        'tid': TID,
        'amount': notes,
        'pid': PID
    }
    _DAO.insert_cash(param_cash)


def update_cash_local(notes):
    param_cash = {
            'csid': TRX_ID[::-1],
            'amount': notes
    }
    _DAO.update_cash(param_cash)


def save_trx_server(_param):
    _url = BACKEND_URL + 'sync/transaction'
    if _param['paymentType'] == 'WALLET':
        _url = BACKEND_URL + 'sync/transaction-wallet'
    _param['createdAt'] = _Helper.now()
    status, response = _NetworkAccess.post_to_url(url=_url, param=_param)
    if status == 200 and response['id'] == _param['trxid']:
        _param['key'] = _param['trxid']
        _DAO.mark_sync(param=_param, _table='Transactions', _key='trxid')
        _DAO.update_product_status(param={'status': 1, 'pid': _param['pid']})
        return True
    else:
        return False


def save_receipt_local(r, d):
    param_receipt = {
        'rid': _Helper.get_uuid(),
        'bookingCode': BOOKING_CODE,
        'tid': ID,
        'receiptRaw': r,
        'receiptData': d,
        'createdAt': _Helper.now()
    }
    if param_receipt['bookingCode'] == '':
        try:
            param_receipt['bookingCode'] = json.loads(d)['GET_BOOKING_CODE']
            param_receipt['tid'] = json.loads(d)['GET_TIBOX_ID']
        except (ValueError, IndexError, KeyError):
            param_receipt['bookingCode'] = 'REPRINT'
            param_receipt['tid'] = 'REPRINT'
    if len(_DAO.search_receipt({'bookingCode': param_receipt['bookingCode']})) == 0:
        _DAO.insert_receipt(param_receipt)
    return param_receipt


def save_receipt_server(__param):
    _url = BACKEND_URL + 'sync/receipt'
    status, response = _NetworkAccess.post_to_url(url=_url, param=__param)
    if status == 200 and response['result'] == 'OK':
        __param['key'] = __param['rid']
        _DAO.mark_sync(param=__param, _table='Receipts', _key='rid')
        return True
    else:
        return False
