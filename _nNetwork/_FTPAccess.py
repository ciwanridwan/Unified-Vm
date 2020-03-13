__author__ = "fitrah.wahyudi.imam@gmail.com"

import os
import sys
import logging
import ftplib
from _cConfig import _Common

LOGGER = logging.getLogger()
FTP_SERVER = _Common.FTP['host']
FTP_USER = _Common.FTP['user']
FTP_PASS = _Common.FTP['pass']
FTP_PORT = _Common.FTP['port']
BUFFER = 1024
REMOTE_PATH = '/home/tj-kiosk/topup/bni/'
LOCAL_PATH = os.path.join(sys.path[0], '_rRemoteFiles')
if not os.path.exists(sys.path[0] + '/_rRemoteFiles/'):
    os.makedirs(sys.path[0] + '/_rRemoteFiles/')

FTP = None


def init_ftp():
    global FTP
    try:
        FTP = ftplib.FTP(FTP_SERVER, FTP_USER, FTP_PASS)
        LOGGER.debug(('init_ftp', 'TRUE'))
    except Exception as e:
        LOGGER.warning(('init_ftp', str(e)))
        if FTP is not None:
            FTP.quit()


def send_file(local_path, remote_path=None):
    global FTP
    result = False
    if remote_path is None:
        remote_path = REMOTE_PATH
    if FTP is None:
        init_ftp()
    try:
        FTP.cwd(remote_path)
        local_file = open(local_path)
        file_name = local_path.split('/')[-1]
        FTP.storbinary('STOR '+file_name, local_file)
        local_file.close()
        LOGGER.debug(('send_file', file_name, local_path, remote_path))
        result = True
    except Exception as e:
        LOGGER.warning(('send_file', str(e)))
    finally:
        if FTP is not None:
            FTP.quit()
        FTP = None
        return result


def get_file(file, remote_path=None):
    global FTP
    result = False
    if file is None:
        LOGGER.warning(('get_file', 'File Param is Missing'))
        return result
    if remote_path is None:
        remote_path = REMOTE_PATH
    if FTP is None:
        init_ftp()
    try:
        remote_file = os.path.join(remote_path, file)
        local_file = os.path.join(LOCAL_PATH, file)
        local_file_create = open(local_file, 'wb')
        FTP.retrbinary('RETR ' + remote_file, local_file_create.write, BUFFER)
        local_file_create.close()
        local_file_check = open(local_file, 'r').readlines()
        if len(local_file_check) == 0:
            os.remove(local_file)
            LOGGER.warning(('get_file', remote_file, 'Not Exist'))
        else:
            LOGGER.debug(('get_file', local_file, remote_file))
            result = True
    except Exception as e:
        LOGGER.warning(('get_file', str(e)))
    finally:
        if FTP is not None:
            FTP.quit()
        FTP = None
        return result

