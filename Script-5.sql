--SELECT 'DBeaver is working' AS status;


--DROP TABLE raw_transactions;

-- Table 1

CREATE TABLE raw_transactions (
    transaction_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    step            INTEGER NOT NULL,
    type            TEXT NOT NULL,
    amount          REAL NOT NULL,
    nameOrig        TEXT,
    oldbalanceOrg   REAL,
    newbalanceOrig  REAL,
    nameDest        TEXT,
    oldbalanceDest  REAL,
    newbalanceDest  REAL,
    isFraud         INTEGER NOT NULL DEFAULT 0,
    isFlaggedFraud  INTEGER NOT NULL DEFAULT 0,
    loaded_at       DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table 2

--CREATE TABLE ingestion_logs (
--    log_id          INTEGER PRIMARY KEY AUTOINCREMENT,
--    run_date        DATETIME DEFAULT CURRENT_TIMESTAMP,
--    rows_loaded     INTEGER,
--    rows_rejected   INTEGER,
--    status          TEXT CHECK(status IN ('SUCCESS', 'FAILED', 'PARTIAL')),
--    duration_secs   REAL,
--    notes           TEXT
--);

--Table 3

--CREATE TABLE transaction_categories (
--    category_id    INTEGER PRIMARY KEY AUTOINCREMENT,
--    type_code      TEXT UNIQUE NOT NULL,
--    description    TEXT,
--    risk_level     TEXT CHECK(risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
--);


-- Pre-populate it immediately after creating

--INSERT INTO transaction_categories (type_code, description, risk_level) VALUES
--    ('CASH-IN',   'Deposit from agent',           'LOW'),
--    ('CASH-OUT',  'Withdrawal via agent',          'HIGH'),
--    ('DEBIT',     'Bank-initiated debit',          'MEDIUM'),
--    ('PAYMENT',   'Merchant payment',              'LOW'),
--    ('TRANSFER',  'Peer-to-peer money transfer',   'HIGH');


--SELECT name FROM sqlite_master 
--WHERE type = 'table' 
--ORDER BY name;


