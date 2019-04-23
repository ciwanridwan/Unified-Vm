__author__ = "fitrah.wahyudi.imam@gmail.com"

import os
import sys
import logging
import paramiko
from _cConfig import _Global

LOGGER = logging.getLogger()
SFTP_SERVER = _Global.SFTP['host']
SFTP_USER = _Global.SFTP['user']
SFTP_PASS = _Global.SFTP['pass']
SFTP_PORT = _Global.SFTP['port']
REMOTE_PATH = '/home/tj-kiosk/topup/bni/'
LOCAL_PATH = os.path.join(sys.path[0], '_rRemoteFiles')
if not os.path.exists(sys.path[0] + '/_rRemoteFiles/'):
    os.makedirs(sys.path[0] + '/_rRemoteFiles/')

SFTP = None
SSH = None


def init_sftp():
    global SFTP, SSH
    try:
        # __transport = paramiko.Transport((SFTP_SERVER, int(SFTP_PORT)))
        # __transport.connect(username=SFTP_USER, password=SFTP_PASS)
        # SFTP = paramiko.SFTPClient.from_transport(__transport)
        SSH = paramiko.SSHClient()
        SSH.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        SSH.connect(SFTP_SERVER, SFTP_PORT, SFTP_USER, SFTP_PASS)
        SFTP = SSH.open_sftp()
        SFTP.sshclient = SSH
        # SFTP = pysftp.Connection(host=SFTP_SERVER, username=SFTP_USER, password=SFTP_PASS, cnopts=cnopts)
        LOGGER.debug(('init_sftp', 'TRUE'))
    except Exception as e:
        LOGGER.warning(('init_sftp', str(e)))
        if SFTP is not None:
            SFTP.close()
        SFTP = None
        if SSH is not None:
            SSH.close()
        SSH = None


def send_file(filename, local_path, remote_path=None):
    global SFTP, SSH
    result = False
    if remote_path is None:
        remote_path = REMOTE_PATH
    if SFTP is None:
        init_sftp()
    try:
        remote_path = os.path.join(remote_path, filename)
        LOGGER.debug(('send_file', filename, local_path, remote_path))
        SFTP.put(local_path, remote_path)
        result = True
    except Exception as e:
        LOGGER.warning(('send_file', str(e)))
    finally:
        if SFTP is not None:
            SFTP.close()
        SFTP = None
        if SSH is not None:
            SSH.close()
        SSH = None
        return result


def get_file(file, remote_path=None):
    global SFTP, SSH
    result = False
    if file is None:
        LOGGER.warning(('get_file', 'File Param is Missing'))
        return result
    if remote_path is None:
        remote_path = REMOTE_PATH
    if SFTP is None:
        init_sftp()
    try:
        remote_file = os.path.join(remote_path, file)
        local_file = os.path.join(LOCAL_PATH, file)
        SFTP.get(remote_file, local_file)
        if os.stat(local_file).st_size == 0:
            LOGGER.warning(('get_file', local_file, 'size 0'))
        else:
            result = True
    except Exception as e:
        LOGGER.warning(('get_file', str(e)))
    finally:
        if SFTP is not None:
            SFTP.close()
        SFTP = None
        if SSH is not None:
            SSH.close()
        SSH = None
        return result


def close_sftp():
    global SFTP, SSH
    if SFTP is not None:
        SFTP.close()
        SFTP = None
    if SSH is not None:
        SSH.close()
        SSH = None
