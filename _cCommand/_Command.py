__author__ = "fitrah.wahyudi.imam@gmail.com"

import logging
import os
import threading
from time import sleep, time
from _cConfig import _ConfigParser
import win32file
from _tTools import _Helper
from _cConfig import _Global
# import win32api
# import pywintypes
# import win32con
import json
import platform
from _nNetwork import _NetworkAccess

LOCK = threading.Lock()
LOGGER = logging.getLogger()
GET_PATH = _ConfigParser.get_value("TERMINAL", "path")
if 'Windows-7' in platform.platform():
    DISK = 'D'
else:
    DISK = 'C'
PATH = os.path.join(DISK+':\\', GET_PATH) if GET_PATH is not None else DISK + ':\\_SOCKET_'
MI_GUI = os.path.join(PATH, 'MI_GUI.txt')
MO_BALANCE = os.path.join(PATH, 'MO_BALANCE.txt')
MO_KA_INFO = os.path.join(PATH, 'MO_KA_INFO.txt')
MO_ERROR = os.path.join(PATH, 'MO_ERROR.txt')
MO_REPORT = os.path.join(PATH, 'MO_REPORT.txt')
MO_STATUS = os.path.join(PATH, 'MO_STATUS.txt')
MO_LIST = {
    'ERROR': MO_ERROR,
    'REPORT': MO_REPORT,
    'KA_INFO': MO_KA_INFO,
    'BALANCE': MO_BALANCE,
    'STATUS': MO_STATUS
}
MAX_TRIAL = 3
BUFFER = 2048
WAITING_TIME = 0.5


def handle_file(mode="r/w", param=None, path=None):
    if path is None:
        LOGGER.warning('[ERROR] no path to file to handle')
        return
    # path = os.path.join(win32api.GetTempPath(), path)
    # print(path)
    response = -1
    data = None
    try:
        if param is not None and mode == "w":
            param = param.replace('|', '\r\n')
            _handle = win32file.CreateFile(
                path,
                win32file.GENERIC_WRITE,
                win32file.FILE_SHARE_READ |
                win32file.FILE_SHARE_WRITE,
                None,
                win32file.OPEN_ALWAYS,
                0,
                None)
            try:
                response, data = win32file.WriteFile(_handle, param.encode(), None)
                # LOGGER.debug(('[DEBUG] writing to file with handle : ', response, data))
            except Exception as e:
                LOGGER.warning((path, e))
            finally:
                _handle.close()
                return response, data
                # os.unlink(path)

        if mode == "r":
            _handle = win32file.CreateFile(
                path,
                win32file.GENERIC_READ,
                win32file.FILE_SHARE_READ |
                win32file.FILE_SHARE_WRITE,
                None,
                win32file.OPEN_ALWAYS,
                0,
                None)
            try:
                response, data = win32file.ReadFile(_handle, BUFFER, None)
                # LOGGER.debug(('[DEBUG] reading to file with handle : ', response, data))
                data = data.decode('utf-8')
            except Exception as e:
                LOGGER.warning((path, e))
            finally:
                _handle.close()
                return response, data
                # os.unlink(path)
    except Exception as e:
        LOGGER.warning(e)
    finally:
        return response, data


def check_response_with_handle(path):
    # LOGGER.debug(('[DEBUG] check_response_with_handle input: ', path))
    response = -1, 'None'
    try:
        _res, _data = handle_file(mode="r", param=None, path=path)
        # LOGGER.debug(('[DEBUG] check_response_with_handle output: ', str(res), str(data)))
        if _res == 0:
            response = 0, _data
        else:
            response = -1, _data
    except Exception as e:
        LOGGER.warning(e)
        response = -1, e
    finally:
        # clear_content_of(file=path)
        return response


def check_response(path):
    # LOGGER.debug(('[DEBUG] check_response input: ', path))
    # check = '|'.join(param) if len(param) > 1 else param
    res = ""
    try:
        with open(path, 'r') as f:
            res = f.read().replace('\n', '|')
            f.close()
        # LOGGER.debug(('[DEBUG] check_response output: ', str(res)))
    except Exception as e:
        LOGGER.debug(e)
    if len(res) == 0 and res != "":
        return True
    else:
        return False


def get_response_with_handle(out, timestamp=False, flush=None, module=None, repl='#'):
    # LOGGER.debug(('[DEBUG] get_response_with_handle input: ', out))
    if flush is not None and module is None:
        module = 'AutoFlush_'+out
    try:
        res, data = handle_file(mode="r", param=None, path=out)
        if len(data) > 0 and data != '\r\n':
            if module is not None:
                LOGGER.debug((out, module, str(res), str(data)))
            else:
                LOGGER.debug((out, str(res), str(data)))
        # if (flush is not None and flush in data) or 'ERROR' in out:
        if flush is not None or flush is True:
            clear_content_of(file=out, pid=module)
        if timestamp is False:
            return res, data.replace('\r\n', repl)
        else:
            return res, data.replace('\r\n', repl), int(time()*1000)
    except Exception as e:
        LOGGER.warning(e)
        return -1, str(e)


def clear_content_of(file, pid=''):
    pass
    # open(file, 'w').close()
    # LOGGER.debug(('[' + pid + ']', file))


def get_response(out):
    LOGGER.debug(('[DEBUG] get_response input: ', out))
    res = None
    try:
        with open(out, 'r+') as f:
            res = f.read()
            #clear up ERROR after read
            if "ERROR" in out:
                f.truncate()
            f.close()
        # LOGGER.debug(('[DEBUG] get_response output : ', str(res)))
    except Exception as e:
        LOGGER.debug(('[ERROR] get_response output : ', e))
    if res == "":
        res = "0"
    return res


def send_command_with_handle(param=None, output=None, responding=True, flushing=MO_STATUS, wait_for=None, verify=False):
    global MI_GUI, MO_ERROR, MO_BALANCE, MO_KA_INFO, MO_REPORT, MO_STATUS
    # LOGGER.debug(('[DEBUG] send_request input: ', param, output))
    # param must be send using join of | char on each line
    r = _Helper.get_random_chars(length=5, chars='1234567890')
    if output is None:
        output = MO_ERROR
        clear_content_of(file=MO_ERROR, pid=r+'|'+param)
    else:
        clear_content_of(file=output, pid=r+'|'+param)

    if param is None:
        LOGGER.warning("Missing Parameter")
        return -1, "Missing_Parameter"

    write = 0
    try:
        # handle_file(mode='w', param=param, path=MI_GUI)
        while True:
            write += 1
            _res, _data = handle_file(mode='w', param=param, path=MI_GUI)
            # Keep Default Waiting Time from Global Waiting Time
            sleep(WAITING_TIME)
            res, data = check_response_with_handle(path=MO_STATUS)
            LOGGER.debug(('os_command', str(param), str(data)))
            if res == 0 and param.split('|')[0] in data:
                clear_content_of(file=flushing, pid=r)
                break
            if write == 15:
                if verify is True:
                    return -1, 'Failed To Write, Please Check MDDTopUpService'
                break
    except Exception as e:
        LOGGER.warning(e)
        return -1, str(e)

    if responding is True:
        if wait_for is not None:
            sleep(wait_for)
        else:
            sleep(WAITING_TIME)
        response, result = get_response_with_handle(out=output, module='Send_Command_'+param)
        return response, result
    else:
        return 0, param


LOCAL_URL = _Global.SERVICE_URL
# http://localhost:9000/Service/GET?type=json&cmd=000&param=com4


def set_output(p):
    __p = p[3:-1] if p[-1] == '|' else p[3:]
    if __p[0] == '|':
        __p = __p[1:]
    return __p


def send_request(param=None, output=None, responding=True, flushing=MO_STATUS, wait_for=None, verify=False):
    __unused_param = {
        'output': output,
        'responding': responding,
        'flushing': flushing,
        'wait_for': wait_for,
        'verify': verify
    }
    if param is None:
        return -1, 'MISSING_PARAM'
    ___cmd = param[:3]
    if len(param) <= 4:
        ___param = "0"
    else:
        ___param = set_output(param)
    ___stat, ___resp = _NetworkAccess.get_local(LOCAL_URL + ___cmd + '&param=' + ___param)
    if ___stat == 200:
        # {"Result":"0","Command":"000","Parameter":"com4","Response":null,"ErrorDesc":"Sukses"}
        if ___resp.get('Command') == ___cmd and ___resp.get('Parameter') == ___param and ___resp.get('Result') == '0':
            ___output = ___resp.get('Response') if ___resp.get('Response') is not None else ___resp.get('Result')
            # if output is None:
            #     ___output = ___resp.get('Result')
            return 0, ___output
        else:
            return -1, json.dumps(___resp)
    else:
        return -1, json.dumps(___resp)


def send_command(param=None, output=None):
    global MI_GUI, MO_ERROR, MO_BALANCE, MO_KA_INFO, MO_REPORT
    LOGGER.debug(('[DEBUG] os_command input: ', param, output))
    # param must be send using join of | char on each line
    if param is None:
        LOGGER.warning(("[ERROR] os_command : ", "Missing Parameter"))
        return
    if output is None:
        output = MO_ERROR
    param = param.split('|')
    try:
        with open(MI_GUI, 'a+') as f:
            f.writelines("%s\n" % line for line in param)
            # f.writelines(param)
            # for line in param:
            #     if line != "" or line != " ":
            #         f.write("{}\n".format(line))
            f.flush()
            os.fsync(f.fileno())
            f.close()
    except Exception as e:
        LOGGER.warning(('[ERROR] os_command : ', e))
    sleep(WAITING_TIME)
    trial = 0
    while True:
        trial += 1
        check = check_response(path=MI_GUI)
        if check is True:
            break
        if trial == MAX_TRIAL:
            break
        sleep(WAITING_TIME)
    sleep(WAITING_TIME * 2)
    response = get_response(out=output)
    # clean_up_output()
    return response


def clean_up_output():
    try:
        for MO in MO_LIST:
            with open(MO, 'w+') as m:
                m.truncate()
                m.close()
            LOGGER.info(('[INFO] clean_up_output : ', MO))
    except Exception as e:
        LOGGER.warning(('[ERROR] clean_up_output :', e))
