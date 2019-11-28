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

