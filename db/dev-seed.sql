-- db/dev-seed.sql
-- Made-up dev data for practice queries. NOT a migration; safe to re-run.
-- Deliberate bad values: zero cash (Gulf, CBC), negative negotiated price
-- (Cypress, CMP), missing cash (Cypress, colonoscopy), missing allowed amounts (several rows).

BEGIN;

-- Re-run safety: remove earlier dev rows (CASCADE removes their files and charges)
DELETE FROM hospitals WHERE name LIKE 'Dev %';

INSERT INTO hospitals (name, npi, state) VALUES
  ('Dev Bayou General',              '0000000001', 'TX'),
  ('Dev Gulf Medical Center',        '0000000002', 'TX'),
  ('Dev Cypress Community Hospital', '0000000003', 'TX');

INSERT INTO price_files (hospital_id, format, template_version, last_updated_on, source_name)
SELECT id, 'csv_tall', '3.0.0', DATE '2026-10-01', 'dev-seed'
FROM hospitals WHERE name LIKE 'Dev %';

INSERT INTO charges (
  price_file_id, service_id, setting, gross_charge, discounted_cash,
  payer_name, plan_name, negotiated_dollar, negotiated_pct, methodology,
  allowed_median, allowed_p10, allowed_p90
)
SELECT pf.id, s.id, v.setting, v.gross, v.cash,
       v.payer, v.plan, v.neg_dollar, v.neg_pct, v.methodology,
       v.med, v.p10, v.p90
FROM (VALUES
  -- hospital, code, code_type, setting, gross, cash, payer, plan, neg $, neg %, methodology, median, p10, p90
  ('Dev Bayou General', '70450', 'CPT', 'outpatient', 2400.00, 950.00, 'Bluebonnet Health', 'PPO', 780.00, NULL, 'fee schedule', 760.00, 610.00, 900.00),
  ('Dev Bayou General', '70450', 'CPT', 'outpatient', 2400.00, 950.00, 'Lone Star Care', 'HMO', 690.00, NULL, 'fee schedule', 700.00, 580.00, 820.00),
  ('Dev Bayou General', '80053', 'CPT', 'outpatient', 180.00, 45.00, 'Bluebonnet Health', 'PPO', 32.00, NULL, 'fee schedule', 30.00, 24.00, 38.00),
  ('Dev Bayou General', '80053', 'CPT', 'outpatient', 180.00, 45.00, 'Lone Star Care', 'HMO', 28.00, NULL, 'fee schedule', NULL, NULL, NULL),
  ('Dev Bayou General', '85025', 'CPT', 'outpatient', 120.00, 30.00, 'Bluebonnet Health', 'PPO', 18.00, NULL, 'fee schedule', 17.00, 13.00, 22.00),
  ('Dev Bayou General', '85025', 'CPT', 'outpatient', 120.00, 30.00, 'Lone Star Care', 'HMO', 16.00, NULL, 'fee schedule', 15.00, 12.00, 19.00),
  ('Dev Bayou General', '99213', 'CPT', 'outpatient', 210.00, 110.00, 'Bluebonnet Health', 'PPO', 95.00, NULL, 'fee schedule', 92.00, 80.00, 105.00),
  ('Dev Bayou General', '99213', 'CPT', 'outpatient', 210.00, 110.00, 'Lone Star Care', 'HMO', 88.00, NULL, 'fee schedule', 86.00, 75.00, 98.00),
  ('Dev Bayou General', '470', 'MS-DRG', 'inpatient', 68000.00, 32000.00, 'Bluebonnet Health', 'PPO', 29500.00, NULL, 'case rate', 29000.00, 26000.00, 33000.00),
  ('Dev Bayou General', '470', 'MS-DRG', 'inpatient', 68000.00, 32000.00, 'Lone Star Care', 'HMO', NULL, 45.0000, 'percent of total billed charges', 30100.00, 27000.00, 34000.00),

  ('Dev Gulf Medical Center', '70450', 'CPT', 'outpatient', 3100.00, 1200.00, 'Bluebonnet Health', 'PPO', 910.00, NULL, 'fee schedule', 890.00, 720.00, 1050.00),
  ('Dev Gulf Medical Center', '70450', 'CPT', 'outpatient', 3100.00, 1200.00, 'Lone Star Care', 'HMO', 840.00, NULL, 'fee schedule', 830.00, 700.00, 960.00),
  ('Dev Gulf Medical Center', '80053', 'CPT', 'outpatient', 220.00, 60.00, 'Bluebonnet Health', 'PPO', 41.00, NULL, 'fee schedule', 40.00, 31.00, 48.00),
  ('Dev Gulf Medical Center', '85025', 'CPT', 'outpatient', 150.00, 0.00, 'Bluebonnet Health', 'PPO', 22.00, NULL, 'fee schedule', 21.00, 17.00, 26.00),
  ('Dev Gulf Medical Center', '85025', 'CPT', 'outpatient', 150.00, 0.00, 'Lone Star Care', 'HMO', 20.00, NULL, 'fee schedule', 19.00, 15.00, 24.00),
  ('Dev Gulf Medical Center', '99213', 'CPT', 'outpatient', 260.00, 130.00, 'Bluebonnet Health', 'PPO', 102.00, NULL, 'fee schedule', 100.00, 88.00, 115.00),
  ('Dev Gulf Medical Center', '99213', 'CPT', 'outpatient', 260.00, 130.00, 'Lone Star Care', 'HMO', 97.00, NULL, 'fee schedule', 95.00, 84.00, 108.00),
  ('Dev Gulf Medical Center', '45378', 'CPT', 'outpatient', 4200.00, 1800.00, 'Bluebonnet Health', 'PPO', 1500.00, NULL, 'fee schedule', 1480.00, 1250.00, 1700.00),
  ('Dev Gulf Medical Center', '45378', 'CPT', 'outpatient', 4200.00, 1800.00, 'Lone Star Care', 'HMO', 1390.00, NULL, 'fee schedule', NULL, NULL, NULL),
  ('Dev Gulf Medical Center', '470', 'MS-DRG', 'inpatient', 74000.00, 36000.00, 'Bluebonnet Health', 'PPO', 33000.00, NULL, 'case rate', 32500.00, 29000.00, 37000.00),

  ('Dev Cypress Community Hospital', '70450', 'CPT', 'outpatient', 1900.00, 700.00, 'Bluebonnet Health', 'PPO', 600.00, NULL, 'fee schedule', 590.00, 480.00, 700.00),
  ('Dev Cypress Community Hospital', '70450', 'CPT', 'outpatient', 1900.00, 700.00, 'Coastal Mutual', 'EPO', 640.00, NULL, 'fee schedule', 630.00, 510.00, 740.00),
  ('Dev Cypress Community Hospital', '80053', 'CPT', 'outpatient', 140.00, 35.00, 'Bluebonnet Health', 'PPO', 26.00, NULL, 'fee schedule', 25.00, 20.00, 31.00),
  ('Dev Cypress Community Hospital', '80053', 'CPT', 'outpatient', 140.00, 35.00, 'Coastal Mutual', 'EPO', -12.00, NULL, 'fee schedule', NULL, NULL, NULL),
  ('Dev Cypress Community Hospital', '85025', 'CPT', 'outpatient', 95.00, 22.00, 'Coastal Mutual', 'EPO', 14.00, NULL, 'fee schedule', 13.00, 10.00, 17.00),
  ('Dev Cypress Community Hospital', '99213', 'CPT', 'outpatient', 180.00, 90.00, 'Bluebonnet Health', 'PPO', 80.00, NULL, 'fee schedule', 79.00, 68.00, 90.00),
  ('Dev Cypress Community Hospital', '99213', 'CPT', 'outpatient', 180.00, 90.00, 'Lone Star Care', 'HMO', 78.00, NULL, 'fee schedule', 77.00, 66.00, 88.00),
  ('Dev Cypress Community Hospital', '99213', 'CPT', 'outpatient', 180.00, 90.00, 'Coastal Mutual', 'EPO', 82.00, NULL, 'fee schedule', 81.00, 70.00, 93.00),
  ('Dev Cypress Community Hospital', '45378', 'CPT', 'outpatient', 3600.00, NULL, 'Bluebonnet Health', 'PPO', 1250.00, NULL, 'fee schedule', 1230.00, 1050.00, 1420.00),
  ('Dev Cypress Community Hospital', '45378', 'CPT', 'outpatient', 3600.00, NULL, 'Coastal Mutual', 'EPO', 1300.00, NULL, 'fee schedule', NULL, NULL, NULL)
) AS v(hospital, code, code_type, setting, gross, cash, payer, plan, neg_dollar, neg_pct, methodology, med, p10, p90)
JOIN hospitals   h  ON h.name = v.hospital
JOIN price_files pf ON pf.hospital_id = h.id
JOIN services    s  ON s.code = v.code AND s.code_type = v.code_type;

COMMIT;