__author__ = 'fitrah.wahyudi.imam@gmail.com'

from _dDB import _Database
from _tTools import _Helper
# sql = 'UPDATE express SET TakeTime=:takeTime,SyncFlag = :syncFlag,Version = :version,Status = :status,staffTakenUser_id=:staffTakenUser_id WHERE id=:id'
# sql = 'INSERT INTO Express (id, ExpressNumber, expressType, overdueTime, status, StoreTime, SyncFlag, TakeUserPhoneNumber, ValidateCode, Version, box_id, logisticsCompany_id, mouth_id, operator_id, storeUser_id,groupName) VALUES (:id,:expressNumber,:expressType,:overdueTime,:status,:storeTime,:syncFlag,:takeUserPhoneNumber,:validateCode,:version,:box_id,:logisticsCompany_id,:mouth_id,:operator_id,:storeUser_id,:groupName)'


def init_kiosk():
    # must bring {tid:xxx} in param
    sql = "SELECT * FROM Terminal WHERE tid is not NULL"
    return _Database.get_query(sql=sql, parameter={})


def get_airport():
    sql = "SELECT prefix, name FROM Airport"
    return _Database.get_query(sql=sql, parameter={})


def insert_airport(param):
    # must bring prefix, name, desription in param
    sql = "INSERT INTO Airport (prefix, name, description) VALUES (:prefix, :name, :description)"
    return _Database.insert_update(sql=sql, parameter=param)


def get_bank_id(param):
    # must bring name, and status
    sql = "SELECT bankMid, bankTid FROM Bank WHERE name=:name AND status=:status"
    return _Database.get_query(sql=sql, parameter=param)


def insert_bank(param):
    # insert new bank details, must bring bid, name, status, bankMid, bankTid
    param['createdAt'] = _Helper.now()
    param['serviceList'] = "[]"
    sql = "INSERT INTO Bank (bid, name, status, serviceList, createdAt, bankMid, bankTid) " \
          "VALUES (:bid, :name, :status, :serviceList, :createdAt, :bankMid, :bankTid)"
    return _Database.insert_update(sql=sql, parameter=param)


def insert_transaction(param):
    """
      trxid           VARCHAR(100) PRIMARY KEY NOT NULL,
      tid             VARCHAR(100)             NOT NULL,
      mid             VARCHAR(100),
      pid             VARCHAR(100),
      tpid            VARCHAR(100),
      amount          BIGINT,
      sale            BIGINT,
      cardNo          VARCHAR(100),
      paymentType     VARCHAR(150),
      paymentNotes    TEXT,
      bankTid         VARCHAR(100),
      bankMid         VARCHAR(100),
    """
    param["createdAt"] = _Helper.now()
    param["syncFlag"] = 0
    sql = "INSERT INTO Transactions (trxid, tid, mid, pid, tpid, paymentType, amount, sale, createdAt, syncFlag, " \
          "bankMid, bankTid, paymentNotes, cardNo) VALUES (:trxid, :tid, :mid, :pid, :tpid, :paymentType, :amount, " \
          ":sale, :createdAt, :syncFlag, :bankMid, :bankTid, :paymentNotes, :cardNo)"
    return _Database.insert_update(sql=sql, parameter=param)


def insert_transaction_failure(param):
    """
      trxid           VARCHAR(100) PRIMARY KEY NOT NULL,
      tid             VARCHAR(100)             NOT NULL,
      mid             VARCHAR(100),
      pid             VARCHAR(100),
      amount          BIGINT,
      cardNo          VARCHAR(100),
      failureType     VARCHAR(255),
      paymentMethod   VARCHAR(255),
      createdAt       BIGINT,
      syncFlag        INT,
      remarks         TEXT
    """
    param["createdAt"] = _Helper.now()
    param["syncFlag"] = 0
    sql = "INSERT INTO TransactionFailure (trxid, tid, mid, pid, amount, cardNo, createdAt, syncFlag, " \
          "failureType, paymentMethod, remarks) VALUES (:trxid, :tid, :mid, :pid, :amount, :cardNo, " \
          ":createdAt, :syncFlag, :failureType, :paymentMethod, :remarks)"
    return _Database.insert_update(sql=sql, parameter=param)


def update_transaction(param):
    """
      trxid           VARCHAR(100) PRIMARY KEY NOT NULL,
      amount          BIGINT,
      paymentNotes    VARCHAR(255)
    """
    param["syncFlag"] = 0
    sql = "UPDATE Transactions SET amount=:amount, syncFlag=:syncFlag, paymentNotes=:paymentNotes WHERE trxid=:trxid "
    return _Database.insert_update(sql=sql, parameter=param)


def mark_sync(param, _table, _key, _syncFlag=1):
    """
    :param param: syncFlag, trxid
    :return: _Database.insert_update
    """
    sql = "UPDATE " + str(_table) + " SET syncFlag=" + str(_syncFlag) + "  WHERE " + str(_key) + "=:key"
    return _Database.insert_update(sql=sql, parameter=param)


def insert_cash(param):
    """
	`csid`	VARCHAR(100) NOT NULL,
	`tid`	VARCHAR(100) NOT NULL,
	`pid`   VARCHAR(100),
	`amount`	BIGINT NOT NULL,
    :param param: _Database.insert_update
    :return:
    """
    param["createdAt"] = _Helper.now()
    sql = "INSERT INTO Cash (csid, tid, amount, pid, createdAt) VALUES (:csid, :tid, :amount, :pid, :createdAt)"
    return _Database.insert_update(sql=sql, parameter=param)


def update_cash(param):
    """
    'csid'
    'amount'
    'updatedAt'
    :param param:
    :return:
    """
    param["updatedAt"] = _Helper.now()
    sql = "UPDATE Cash SET amount=:amount, updatedAt=:updatedAt WHERE csid=:csid"
    return _Database.insert_update(sql=sql, parameter=param)


def collect_cash(param):
    """
    :param param:
    'csid'
    'collectedAt'
    'collectedUser'
    :return: _Database.insert_update
    """
    param["updatedAt"] = _Helper.now()
    sql = "UPDATE Cash SET updatedAt=:updatedAt, collectedAt=:collectedAt, collectedUser=:collectedUser" \
          " WHERE csid=:csid"
    return _Database.insert_update(sql=sql, parameter=param)


def list_uncollected_cash():
    sql = "SELECT * FROM Cash Where collectedAt is Null"
    return _Database.get_query(sql=sql, parameter={})


def insert_product(param):
    '''
    :param param:
    pid             VARCHAR(100) PRIMARY KEY NOT NULL,
    name            VARCHAR(150)             NOT NULL,
    price           BIGINT,
    details         TEXT,
    status          INT,
    :return:
    '''
    param["createdAt"] = _Helper.now()
    param["syncFlag"] = 0
    sql = "INSERT INTO Product (pid, name, price, details, status, createdAt, syncFlag) VALUES " \
          "(:pid, :name, :price, :details, :status, :createdAt, :syncFlag)"
    return _Database.insert_update(sql=sql, parameter=param)


def update_product_status(param):
    '''
    :param param: pid, status
    :return:
    '''
    sql = "UPDATE Product SET status=:status WHERE pid=:pid"
    return _Database.insert_update(sql=sql, parameter=param)


def update_product_price(param):
    '''
    :param param: pid, price
    :return:
    '''
    sql = "UPDATE Product SET price=:price WHERE pid=:pid"
    return _Database.insert_update(sql=sql, parameter=param)


def insert_settlement(param):
    '''
    :param param:
    `sid`	VARCHAR(100) NOT NULL,
	`tid`	VARCHAR(100) NOT NULL,
	`bid`	VARCHAR(100),
	`filename`	VARCHAR(255),
	`status` VARCHAR,
	`amount`	BIGINT,
	`row`	BIGINT,
    :return:
    '''
    param["createdAt"] = _Helper.now()
    sql = "INSERT INTO Settlement (sid, tid, bid, filename, status, amount, row, createdAt) VALUES (:sid, :tid, :bid, " \
          ":filename, :status, :amount, :row, :createdAt)"
    return _Database.insert_update(sql=sql, parameter=param)


def update_settlement(param):
    '''
    :param param:
    `sid`	VARCHAR(100) NOT NULL,
    `status` VARCHAR,
    `updatedAt`
    :return:
    '''
    param["updatedAt"] = _Helper.now()
    sql = "UPDATE Settlement SET status=:status, updatedAt=:updatedAt WHERE sid=:sid"
    return _Database.insert_update(sql=sql, parameter=param)


def insert_product_stock(param):
    '''
  stid            VARCHAR(100) PRIMARY KEY NOT NULL,
  pid             VARCHAR(100)             NOT NULL,
  tid             VARCHAR(100),
  name            VARCHAR(255),
  init_price      INT,
  sell_price      INT,
  remarks         TEXT,
  stock           INT,
  status          INT,
  createdAt       BIGINT,
  updatedAt       BIGINT, -> This Field is removed in Main Server, replaced to lastUserUpdate
  syncFlag        INT
    '''
    param["createdAt"] = _Helper.now()
    param["syncFlag"] = 1
    sql = "INSERT INTO ProductStock (stid, pid, tid, name, init_price, sell_price, remarks, stock, status, " \
          "createdAt, syncFlag) VALUES (:stid, :pid, :tid, :name, :init_price, :sell_price, :remarks, :stock, " \
          ":status, :createdAt, :syncFlag) "
    return _Database.insert_update(sql=sql, parameter=param, log=False)


def update_product_stock(param):
    '''
      pid             VARCHAR(100)             NOT NULL,
      stock           INT,
    :param param:
    :return:
    '''
    param["updatedAt"] = _Helper.now()
    sql = " UPDATE ProductStock SET stock = :stock WHERE pid = :pid "
    return _Database.insert_update(sql=sql, parameter=param)


def get_product_stock():
    sql = " SELECT * FROM ProductStock WHERE status > 1 "
    return _Database.get_query(sql=sql, parameter={})


def check_product_stock(param):
    sql = " SELECT count(*) as count FROM ProductStock WHERE stid = :stid AND pid = :pid LIMIT 0,1 "
    return _Database.get_query(sql=sql, parameter=param)

def check_product_status_by_pid(param):
    sql = " SELECT * FROM ProductStock WHERE pid = :pid LIMIT 0,1 "
    return _Database.get_query(sql=sql, parameter=param)


def clear_stock_product():
    flush_table('ProductStock')


def get_airport_name(param):
    '''
    :param param: prefix1 = CGK, prefix2=DPS
    :return: Soekarno-Hatta International Airport
    '''
    sql = "SELECT name FROM Airport where prefix=:prefix"
    return _Database.get_query(sql=sql, parameter=param)


def not_synced_data(param, _table):
    sql = "SELECT * FROM " + _table + " WHERE syncFlag = :syncFlag"
    return _Database.get_query(sql=sql, parameter=param)


def insert_transaction_type(param):
    '''
    :param param:
    tpid            VARCHAR(100) PRIMARY KEY NOT NULL,
    name            VARCHAR(150)             NOT NULL,
    status          INT,
    description     VARCHAR(255),
    createdAt       BIGINT,
    syncFlag        INT
    :return:
    '''
    param['syncFlag'] = 0
    param['createdAt'] = _Helper.now()
    sql = "INSERT INTO TransactionType(tpid, name, status, description, createdAt, syncFlag) " \
          "VALUES(:tpid, :name, :status, :description, :createdAt, :syncFlag)"
    return _Database.insert_update(sql=sql, parameter=param)


def get_tpid(param):
    sql = 'SELECT * FROM TransactionType WHERE name like "%{}%" ORDER BY name ASC LIMIT 0,1 '.format(param['string'])
    return _Database.get_query(sql=sql, parameter=param)


def get_airport_terminal(param):
    sql = 'SELECT terminal FROM AirportTerminal WHERE origin=:origin and destination=:destination and ' \
          'flight_name=:flight '
    return _Database.get_query(sql=sql, parameter=param)


def update_kiosk_data(param):
    sql = ' INSERT INTO `Terminal`(`tid`,`name`,`locationId`,`status`,`token`,`defaultMargin`, `defaultAdmin`) ' \
          'VALUES (:tid, :name, :locationId, :status, :token, :defaultMargin, :defaultAdmin ) '
    return _Database.insert_update(sql=sql, parameter=param)


def flush_table(_table, _where=None):
    if _where is None:
        sql = ' DELETE FROM {} '.format(_table)
    else:
        sql = ' DELETE FROM {} WHERE {} '.format(_table, _where)
    _Database.delete_row(sql=sql)


def adjust_table(_path):
    _Database.adjust_db(db=_path)


def insert_receipt(param):
    param['syncFlag'] = 0
    '''
    rid,
    bookingCode,
    tiboxId,
    receiptRaw,
    receiptData,
    createdAt,
    '''
    sql = "  INSERT INTO Receipts(rid, bookingCode, tiboxId, receiptRaw, receiptData, syncFlag, createdAt) " \
          "VALUES(:rid, :bookingCode, :tiboxId, :receiptRaw, :receiptData, :syncFlag, :createdAt)  "
    return _Database.insert_update(sql=sql, parameter=param)


def search_receipt(param):
    '''

    :param param:
    booking_code
    :return:
    1 full row
    '''

    sql = " SELECT * FROM Receipts WHERE bookingCode = :bookingCode ORDER BY createdAt ASC LIMIT 0,1 "
    return _Database.get_query(sql=sql, parameter=param)


def check_table(param):
    sql = " SELECT count(*) FROM {} ".format(param['table'])
    return _Database.get_query(sql=sql, parameter={})


def check_trx(trxid):
    sql = " SELECT * FROM Transactions WHERE trxid = '{}' ".format(trxid)
    return _Database.get_query(sql=sql, parameter={})


def check_trx_failure(trxid):
    sql = " SELECT * FROM TransactionFailure WHERE trxid = '{}' ".format(trxid)
    return _Database.get_query(sql=sql, parameter={})


def check_product(pid):
    sql = " SELECT * FROM Product WHERE pid = '{}' ".format(pid)
    return _Database.get_query(sql=sql, parameter={})


def check_settlement(status='EDC|OPEN'):
    sql = " SELECT * FROM Settlement WHERE status = '{}' ".format(status)
    return _Database.get_query(sql=sql, parameter={})


def insert_topup_record(param):
    '''

    :param param:
    :return:
    '''
    param['syncFlag'] = 0
    param['createdAt'] = _Helper.now()
    sql = " INSERT INTO TopUpRecords(rid, trxid, cardNo, balance, reportSAM, reportKA, status, remarks, " \
          "syncFlag, createdAt) VALUES (:rid, :trxid, :cardNo, :balance, :reportSAM, :reportKA, :status, :remarks, " \
          ":syncFlag, :createdAt) "
    return _Database.insert_update(sql=sql, parameter=param)


def insert_sam_record(param):
    '''
      smid            VARCHAR(100) PRIMARY KEY NOT NULL,
      fileName        TEXT,
      fileContent     TEXT,
      status          INT,
      remarks         TEXT,
    :param param:
    :return:
    '''
    param['createdAt'] = _Helper.now()
    sql = " INSERT INTO SAMRecords(smid, fileName, fileContent, status, remarks, createdAt) VALUES (:smid, :fileName, " \
          " :fileContent, :status, :remarks, :createdAt) "
    return _Database.insert_update(sql=sql, parameter=param)


def get_total_count(table, condition=None):
    sql = ' SELECT * FROM ' + table
    if condition is not None:
        sql += ' WHERE ' + condition
    return len(_Database.get_query(sql=sql, parameter={}, log=False))


def get_query_from(table, condition=None):
    sql = ' SELECT * FROM ' + table
    if condition is not None:
        sql += ' WHERE ' + condition
    return _Database.get_query(sql=sql, parameter={}, log=False)


def custom_query(sql):
    return _Database.get_query(sql=sql, parameter={}, log=False)


def custom_update(sql):
    return _Database.insert_update(sql=sql, parameter={}, log=False)


def insert_sam_audit(param):
    sql = ' INSERT INTO SAMAudit(lid, trxid, samCardNo, samCardSlot, samPrevBalance, samLastBalance, topupCardNo, ' \
          'topupPrevBalance, topupLastBalance, status, remarks, syncFlag, createdAt) VALUES (:lid, :trxid, :samCardNo,'\
          ':samCardSlot, :samPrevBalance, :samLastBalance, :topupCardNo, :topupPrevBalance, :topupLastBalance, :status,'\
          ':remarks, :syncFlag, :createdAt) '
    param['syncFlag'] = 0
    param['createdAt'] = _Helper.now()
    return _Database.insert_update(sql=sql, parameter=param)


def clean_old_data(tables, key='', age_month=0):
    if type(tables) != list or len(tables) == 0 or len(key) == 0 or age_month == 0:
        return False
    expired = _Helper.now()
    if age_month > 0:
        expired = _Helper.now() - (age_month * 30 * 24 * 60 * 60)
    for _table in tables:
        _where = str(key) + ' < ' + str(expired)
        flush_table(_table=_table, _where=_where)
    return True





