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