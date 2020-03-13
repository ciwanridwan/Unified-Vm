DROP TABLE IF EXISTS Receipts;
CREATE TABLE Receipts
(
  rid             VARCHAR(100) PRIMARY KEY NOT NULL,
  bookingCode     VARCHAR(50),
  tid         VARCHAR(50),
  receiptRaw      TEXT,
  receiptData     TEXT,
  syncFlag        INT,
  createdAt       BIGINT
);
