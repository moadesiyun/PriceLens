-- db/practice.sql
-- Week 2 SQL practice against db/dev-seed.sql data.

-- 1. All charges for one service code (CT head, 70450)
SELECT 
    s.code,
    s.code_type,
    s.description,
    c.gross_charge,
    c.discounted_cash,
    c.payer_name,
    c.plan_name,
    c.negotiated_dollar
FROM charges c
JOIN services s ON s.id = c.service_id 
WHERE s.code = '70450' AND s.code_type = 'CPT'


-- 2.Cash price per Hospital for one service code (CT head, 70450)
SELECT DISTINCT h.name, s.code, s.code_type, c.gross_charge, c.discounted_cash
FROM charges c
JOIN services s     ON s.id = c.service_id     
JOIN price_files pf ON pf.id = c.price_file_id
JOIN hospitals h    ON h.id = pf.hospital_id
WHERE s.code = '70450' AND s.code_type = 'CPT'
ORDER BY c.discounted_cash

-- 3: minimum, maximum and average cash price per service
SELECT 
    s.code,
    s.code_type,
    s.description,
    MAX(c.discounted_cash) AS max_cash, 
    MIN(c.discounted_cash)AS MIN_cash, 
    ROUND(AVG(c.discounted_cash), 2) AS AVG_cash,
    COUNT(*) AS rows,
    COUNT(c.discounted_cash) AS rows_with_cash
FROM charges c 
JOIN services s on s.id = c.service_id
GROUP BY s.code, s.code_type, s.description
ORDER BY s.code_type, s.code

-- 4 services without a matching charge
SELECT s.code, s.code_type, s.description
FROM services s
LEFT JOIN charges c ON c.service_id = s.id 
WHERE c.id is NULL
ORDER BY s.code_type, s.code

--5 number of distinct payers per hospital.
SELECT  
    h.name, 
    COUNT(c.payer_name) AS payer_rows, 
    COUNT(DISTINCT c.payer_name) AS distinct_payers
FROM charges c
JOIN price_files pf ON pf.id = c.price_file_id
JOIN hospitals h    ON h.id = pf.hospital_id
GROUP BY h.id, h.name 
ORDER BY h.name;
;
-- bonus
SELECT c.payer_name, COUNT(DISTINCT pf.hospital_id) AS hospital_count
FROM charges c
JOIN price_files pf ON pf.id = c.price_file_id
GROUP BY c.payer_name
ORDER BY hospital_count DESC;

--6 rank hospitals by cash price for each service
SELECT per_h.name, per_h.description, per_h.discounted_cash, per_h.code, per_h.code_type, 
       RANK() OVER (PARTITION BY per_h.code, per_h.code_type ORDER BY per_h.discounted_cash ASC) AS cash_rank
FROM (
    SELECT DISTINCT h.name, s.description, s.code_type, s.code, c.discounted_cash
    FROM charges c
  JOIN services s ON s.id = c.service_id
  JOIN price_files pf ON pf.id = c.price_file_id
  JOIN hospitals h    ON h.id = pf.hospital_id
  WHERE c.discounted_cash IS NOT NULL AND c.discounted_cash > 0
) AS per_h

ORDER BY code_type, code, cash_rank


-- 7 median negotiated price per service
SELECT s.code, s.code_type, s.description,
ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY c.negotiated_dollar)::numeric, 2) AS median_negotiated
FROM charges c
JOIN services s on s.id = c.service_id
WHERE c.negotiated_dollar > 0
GROUP BY s.code, s.code_type, s.description
ORDER BY s.code_type, s.code

-- 8 data quality check
SELECT *
FROM (
  SELECT 
    h.name, 
    s.code,
    s.code_type,
    s.description,
    c.gross_charge,
    c.discounted_cash,
    c.payer_name,
    c.plan_name,
    c.negotiated_dollar,
    c.allowed_median,
    c.allowed_p10,
    c.allowed_p90,
    concat_ws(', ',
    CASE WHEN c.discounted_cash IS NULL THEN 'missing cash' END,
    CASE WHEN c.discounted_cash <= 0     THEN 'zero/negative cash' END,
    CASE WHEN c.negotiated_dollar <= 0 THEN 'zero/negative negotiated' END,   
    CASE WHEN c.negotiated_dollar IS NULL AND c.negotiated_pct IS NULL THEN 'missing negotiated' END,   -- negotiated check
    CASE WHEN c.allowed_median IS NULL THEN 'missing allowed median' END,    -- allowed amounts check(s)
    CASE WHEN c.allowed_p10 IS NULL THEN 'missing allowed p10' END,    -- allowed amounts check(s)
    CASE WHEN c.allowed_p90 IS NULL THEN 'missing allowed p90' END,
    CASE WHEN c.allowed_count IS NULL THEN 'missing allowed count' END     -- allowed amounts check(s)
) AS issues
FROM charges c
JOIN services s ON s.id = c.service_id
JOIN price_files pf ON pf.id = c.price_file_id
JOIN hospitals h    ON h.id = pf.hospital_id) AS checked
WHERE issues <> ''
ORDER BY name, code;

--9 cheapest hospital per services for service
WITH per_h AS (
  SELECT DISTINCT h.name, s.description, s.code_type, s.code, c.discounted_cash
  FROM charges c
  JOIN services s ON s.id = c.service_id
  JOIN price_files pf ON pf.id = c.price_file_id
  JOIN hospitals h ON h.id = pf.hospital_id
  WHERE c.discounted_cash IS NOT NULL AND c.discounted_cash > 0
),
 ranked_hs AS (
  SELECT *,
  RANK() OVER (PARTITION BY code, code_type ORDER BY discounted_cash ASC) AS cash_rank
  FROM per_h
)
SELECT *
FROM ranked_hs
WHERE cash_rank = 1
ORDER BY code, code_type

--10 explain analyze
EXPLAIN ANALYZE
SELECT DISTINCT h.name, s.code, s.code_type, c.gross_charge, c.discounted_cash
FROM charges c
JOIN services s     ON s.id = c.service_id     
JOIN price_files pf ON pf.id = c.price_file_id
JOIN hospitals h    ON h.id = pf.hospital_id
WHERE s.code = '70450' AND s.code_type = 'CPT'
ORDER BY c.discounted_cash