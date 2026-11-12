-- Up Migration
CREATE TABLE hospitals (
  id         bigserial   PRIMARY KEY,
  name       TEXT        NOT NULL,
  npi        TEXT       ,
  state      CHAR (2)   ,
  created_at timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE price_files (
  id               bigserial   PRIMARY KEY,
  hospital_id      BIGINT      NOT NULL REFERENCES hospitals (id) ON DELETE CASCADE,
  format           TEXT        NOT NULL CHECK (format IN ('csv_tall', 'csv_wide', 'json')),
  template_version TEXT       ,
  last_updated_on  DATE       ,
  source_name      TEXT       ,
  imported_at      timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE services (
  id          bigserial PRIMARY KEY,
  code        TEXT      NOT NULL,
  code_type   TEXT      NOT NULL,
  description TEXT      NOT NULL,
  category    TEXT     ,
  UNIQUE (code, code_type)
);

CREATE TABLE charges (
  id                   bigserial       PRIMARY KEY,
  price_file_id        BIGINT          NOT NULL REFERENCES price_files (id) ON DELETE CASCADE,
  service_id           BIGINT          NOT NULL REFERENCES services (id),
  setting              TEXT            CHECK (setting IN ('inpatient', 'outpatient', 'both')),
  gross_charge         NUMERIC (12, 2),
  discounted_cash      NUMERIC (12, 2),
  payer_name           TEXT           ,
  plan_name            TEXT           ,
  negotiated_dollar    NUMERIC (12, 2),
  negotiated_pct       NUMERIC (7, 4) ,
  negotiated_algorithm TEXT           ,
  methodology          TEXT           ,
  min_charge           NUMERIC (12, 2),
  max_charge           NUMERIC (12, 2),
  allowed_median       NUMERIC (12, 2),
  allowed_p10          NUMERIC (12, 2),
  allowed_p90          NUMERIC (12, 2),
  allowed_count        INT            
);

CREATE INDEX charges_service_idx
  ON charges(service_id);

CREATE INDEX charges_file_idx
  ON charges(price_file_id);

-- Down Migration
DROP TABLE charges;

DROP TABLE services;

DROP TABLE price_files;

DROP TABLE hospitals;