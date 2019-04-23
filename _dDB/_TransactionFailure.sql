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

