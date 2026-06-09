-- 1. Row count check
SELECT COUNT(*) AS total_rows 
FROM raw_transactions;

-- 2. Quick data preview
SELECT * FROM raw_transactions 
LIMIT 10;

-- 3. Check for NULLs in critical columns
SELECT 
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END)    AS null_amounts,
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END)      AS null_types,
    SUM(CASE WHEN isFraud IS NULL THEN 1 ELSE 0 END)  AS null_fraud_flags
FROM raw_transactions;

-- 4. Transaction type breakdown
SELECT type, COUNT(*) AS count 
FROM raw_transactions 
GROUP BY type 
ORDER BY count DESC;

-- 5. Fraud flag check
SELECT isFraud, COUNT(*) AS count 
FROM raw_transactions 
GROUP BY isFraud;


SELECT COUNT(*) FROM raw_transactions;



