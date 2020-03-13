DROP TABLE IF EXISTS Airport;
CREATE TABLE Airport
(
  prefix          VARCHAR(3)   PRIMARY KEY NOT NULL,
  name            VARCHAR(100)             NOT NULL,
  description     VARCHAR(255)
);
DROP TABLE IF EXISTS Bank;
CREATE TABLE Bank 
(
  bid             VARCHAR(100) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)             NOT NULL,
  status          INT                      NOT NULL,
  serviceList     VARCHAR(255),
  createdAt       BIGINT,
  bankMid         VARCHAR(100),
  bankTid         VARCHAR(100)
);
DROP TABLE IF EXISTS Settlement;
CREATE TABLE Settlement
(
  sid             VARCHAR(100) PRIMARY KEY NOT NULL,
  tid             VARCHAR(100)             NOT NULL,
  bid             VARCHAR(100),
  filename        VARCHAR(255),
  status          VARCHAR(50),
  amount          BIGINT,
  row             BIGINT,
  createdAt       BIGINT,
  updatedAt       BIGINT
);
DROP TABLE IF EXISTS Cash;
CREATE TABLE Cash
(
  csid            VARCHAR(100) PRIMARY KEY NOT NULL,
  tid             VARCHAR(100)             NOT NULL,
  pid             VARCHAR(100),
  amount          BIGINT                   NOT NULL,
  createdAt       BIGINT,
  updatedAt       BIGINT,
  collectedUser   VARCHAR(100),
  collectedAt     BIGINT
);
DROP TABLE IF EXISTS Product;
CREATE TABLE Product
(
  pid             VARCHAR(100) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)             NOT NULL,
  price           BIGINT,
  description     VARCHAR(255),
  status          INT,
  createdAt       BIGINT,
  syncFlag        INT
);

DROP TABLE IF EXISTS Terminal;
CREATE TABLE Terminal 
(
  tid             VARCHAR(100) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)             NOT NULL,
  locationId      VARCHAR(255)             NOT NULL,
  status          INT,
  token           VARCHAR(100),
  createdAt       BIGINT,
  terminalMid     VARCHAR(100),
  defaultMargin   INT,
  defaultAdmin    INT
);
DROP TABLE IF EXISTS Transactions;
CREATE TABLE Transactions
(
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
  createdAt       BIGINT,
  syncFlag        INT,
  bankMid         VARCHAR(100),
  bankTid         VARCHAR(100),
  pidStock        VARCHAR(100),
  isCollected     INT DEFAULT 0
);


DROP TABLE IF EXISTS TransactionType;
CREATE TABLE TransactionType 
(
  tpid            VARCHAR(100) PRIMARY KEY NOT NULL,
  name            VARCHAR(150)             NOT NULL,
  description     VARCHAR(255)
);

DROP TABLE IF EXISTS AirportTerminal;
CREATE TABLE AirportTerminal
(
  no	            INT(11) PRIMARY KEY NOT NULL,
  flight_no	      VARCHAR(100),
  flight_name	    VARCHAR(100),
  origin	        VARCHAR(10),
  destination 	  VARCHAR(10),
  terminal	      VARCHAR(10)
);

DROP TABLE IF EXISTS Receipts;
CREATE TABLE Receipts
(
  rid             VARCHAR(100) PRIMARY KEY NOT NULL,
  bookingCode     VARCHAR(50),
  tid             VARCHAR(50),
  receiptRaw      TEXT,
  receiptData     TEXT,
  syncFlag        INT,
  createdAt       BIGINT
);

DROP TABLE IF EXISTS PendingRefund;
CREATE TABLE PendingRefund
(
  id              VARCHAR(100) PRIMARY KEY NOT NULL,
  tid             VARCHAR(100)             NOT NULL,
  trxid           VARCHAR(100),
  amount          BIGINT,
  customer        VARCHAR(100),
  refundType      VARCHAR(100),
  paymentType     VARCHAR(100),
  isSuccess       INT,
  remarks         TEXT,
  createdAt       BIGINT,
  updatedAt       BIGINT
);

DROP TABLE IF EXISTS SAMAudit;
CREATE TABLE SAMAudit
(
  lid               VARCHAR(100) PRIMARY KEY NOT NULL,
  trxid             VARCHAR(100),
  samCardNo         VARCHAR(100),
  samCardSlot       INT,
  samPrevBalance    BIGINT,
  samLastBalance    BIGINT,
  topupCardNo       VARCHAR(100),
  topupPrevBalance  BIGINT,
  topupLastBalance  BIGINT,
  status            TEXT,
  remarks           TEXT,
  syncFlag          INT,
  createdAt         BIGINT
);

DROP TABLE IF EXISTS TopUpRecords;
CREATE TABLE TopUpRecords
(
  rid             VARCHAR(100) PRIMARY KEY NOT NULL,
  trxid           VARCHAR(100),
  cardNo          TEXT,
  balance         INT,
  reportSAM       TEXT,
  reportKA        TEXT,
  status          INT,
  remarks         TEXT,
  syncFlag        INT,
  createdAt       BIGINT
);

DROP TABLE IF EXISTS SAMRecords;
CREATE TABLE SAMRecords
(
  smid            VARCHAR(100) PRIMARY KEY NOT NULL,
  fileName        TEXT,
  fileContent     TEXT,
  status          INT,
  remarks         TEXT,
  createdAt       BIGINT
);

DROP TABLE IF EXISTS ProductStock;
CREATE TABLE ProductStock
(
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
  updatedAt       BIGINT,
  syncFlag        INT
);

DROP TABLE IF EXISTS TransactionFailure;
CREATE TABLE TransactionFailure
(
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
);


CREATE UNIQUE INDEX UK_airpref001a ON Airport(prefix);
CREATE UNIQUE INDEX UK_bankid002b ON Bank(bid);
CREATE UNIQUE INDEX UK_setid003c ON Settlement(sid);
CREATE UNIQUE INDEX UK_mercid004d ON Merchant(mid);
CREATE UNIQUE INDEX UK_prodid005e ON Product(pid);
CREATE UNIQUE INDEX UK_termid006f ON Terminal(tid);
CREATE UNIQUE INDEX UK_trxid007g ON Transactions(trxid);
CREATE INDEX FK_trxidtid001a ON Transactions(tid);
CREATE INDEX FK_setidbid002b ON Settlement(bid);
CREATE INDEX FK_trxidpid003c ON Transactions(pid);
CREATE INDEX FK_trxidtpid004d ON Transactions(tpid);
