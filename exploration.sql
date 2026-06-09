-- ============================================
-- KEY FINDINGS — PAYSIM EXPLORATION
-- ============================================
-- 1. Only cashout & Transfer have fraud whereas Payment, cash_in, debit have zero fraud.
--
-- 2. The Fraud flagged by the system is only 16 but the total number of fraud occured is 8181.
--
-- 3. The existing fraud detection system (isFlaggedFraud)
--    caught only 16 out of 8,197 fraud cases.
--    That is a 0.2% detection rate — 99.8% of fraud went undetected.
--    This is the business problem this pipeline solves.
--
-- 4. TRANSFER has a higher fraud RATE (0.77%) while CASH_OUT has
--    higher fraud VOLUME (4,100 cases) due to transaction count.
--    Both need monitoring but for different reasons.
-- 
-- 5. There are 41 suspicious transactions where sender balance didn't decrease after sending.
--
-- 6. LOW VOLUME DAYS HAVE DISPROPORTIONATELY HIGH FRAUD RATES:
--    Day 31: 279 transactions — 100% fraud rate, avg $1.6M per transaction
--    Day 3:  6,749 transactions — 4.53% fraud rate (vs 0.13% average)
--    Day 18: 29,249 transactions — 0.93% fraud rate
--    Pattern: when transaction volume drops sharply, fraud concentration 
--    spikes significantly. High-value + low-volume = highest risk signal.
--    This pattern becomes a detection rule in Phase 5 AI agent.


--Query 1 — Date range of the dataset
SELECT 
    MIN(step) AS first_step,
    MAX(step) AS last_step,
    MAX(step) - MIN(step) AS total_steps,
    ROUND((MAX(step) - MIN(step)) / 24.0, 1) AS total_days
FROM raw_transactions;

--Query 2 — Transaction volume by type
SELECT 
    type,
    COUNT(*)                                                    AS total_transactions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)         AS pct_of_total,
    ROUND(SUM(amount), 2)                                      AS total_amount,
    ROUND(AVG(amount), 2)                                      AS avg_amount
FROM raw_transactions
GROUP BY type
ORDER BY total_transactions DESC;

--Query 3 — Fraud overview
SELECT 
    isFraud,
    COUNT(*)                                                    AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 4)         AS pct_of_total,
    ROUND(SUM(amount), 2)                                      AS total_amount,
    ROUND(AVG(amount), 2)                                      AS avg_amount
FROM raw_transactions
GROUP BY isFraud;

--Query 4 — Fraud by transaction type
SELECT 
    type,
    COUNT(*)                                                    AS total_txns,
    SUM(isFraud)                                               AS fraud_count,
    ROUND(SUM(isFraud) * 100.0 / COUNT(*), 4)                 AS fraud_rate_pct,
    ROUND(SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END), 2) AS fraud_amount
FROM raw_transactions
GROUP BY type
ORDER BY fraud_count DESC;

--Query 5 — Average transaction amount by type
SELECT 
    type,
    ROUND(MIN(amount), 2)    AS min_amount,
    ROUND(MAX(amount), 2)    AS max_amount,
    ROUND(AVG(amount), 2)    AS avg_amount,
    ROUND(SUM(amount), 2)    AS total_amount
FROM raw_transactions
GROUP BY type
ORDER BY avg_amount DESC;

--Query 6 — Transaction volume by hour (step)
SELECT 
    step,
    COUNT(*)            AS transaction_count,
    SUM(isFraud)        AS fraud_count
FROM raw_transactions
GROUP BY step
ORDER BY step ASC
LIMIT 48;

--Query 7 — Top 10 highest value fraudulent transactions
SELECT 
    transaction_id,
    step,
    type,
    ROUND(amount, 2)          AS amount,
    nameOrig,
    nameDest,
    oldbalanceOrg,
    newbalanceOrig
FROM raw_transactions
WHERE isFraud = 1
ORDER BY amount DESC
LIMIT 10;

--Query 8 — Balance anomaly detection (manual)
SELECT 
    COUNT(*) AS suspicious_count
FROM raw_transactions
WHERE isFraud = 1
  AND newbalanceOrig = oldbalanceOrg
  AND amount > 0;

--Query 9 — Flagged vs actual fraud comparison
SELECT 
    isFlaggedFraud,
    isFraud,
    COUNT(*) AS count
FROM raw_transactions
GROUP BY isFlaggedFraud, isFraud
ORDER BY isFlaggedFraud DESC;

--Query 10 — Daily transaction summary (every 24 steps = 1 day)
SELECT 
    CAST(step / 24 AS INTEGER) + 1              AS day_number,
    COUNT(*)                                     AS total_transactions,
    SUM(isFraud)                                 AS fraud_count,
    ROUND(SUM(amount), 2)                        AS total_volume,
    ROUND(AVG(amount), 2)                        AS avg_transaction
FROM raw_transactions
GROUP BY CAST(step / 24 AS INTEGER)
ORDER BY day_number;

