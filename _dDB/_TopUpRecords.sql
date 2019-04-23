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

DROP TABLE IF EXISTS Stock;
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

