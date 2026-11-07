# Notes

## Mon Nov 2 — done

- pnpm workspace (apps/web, apps/api)
- React + Vite + TS web app (ESLint included)
- Fastify + TS API with GET /health
- Root scripts: dev, build, lint, test
- `pnpm dev` starts both: web on :5173, API on :3000
- Started Tuesday early: .env/.env.example, docker-compose.yml, Postgres 17 running

## Next small step (Tue Nov 3)

- Start Docker Desktop, then `docker compose up -d`
- `pnpm add pg` in apps/api; make /health run `SELECT 1` and report database ok
- Then ESLint + Prettier for both apps

## Tue Nov 3 — done

- API connects to Postgres with `pg` (pool in `apps/api/src/db.ts`)
- `GET /health` runs `SELECT 1` → `{ status: "ok", database: "ok" }`; returns 503 if the DB is down
- `.env` loaded via `tsx watch --env-file=../../.env`
- Prettier at the root: `.prettierrc.json`, `.prettierignore`, scripts `format` and `format:check` (passes)

**Gotcha:** a PostgreSQL installed on Windows already uses port 5432.
Docker's Postgres is mapped to **5433** (`"5433:5432"`), and `DATABASE_URL` uses 5433.
Start Docker Desktop before `docker compose up -d`. If you see "password authentication failed", check that Docker is running first.

**Moved:** ESLint for the API → Thursday if time, otherwise Week 2.
Check TypeScript 7.0.2 vs typescript-eslint support first.

## Next small step (Wed Nov 4, Learn session)

- Open the CMS hospital price transparency template docs and data dictionary (github.com/CMSgov/hospital-price-transparency)
- Download the sample files (CSV tall, CSV wide, JSON) into `data/samples`
- In this file, list the fields PriceLens will read and check, including the 2026 additions (allowed-amount median/10th/90th, NPI)

## CMS template v3.0.0 — fields (Sat Nov 7)

Layout (CSV tall): rows 1–2 = hospital info (names, values); row 3 = column headers; data from row 4.
Pipes: in headers = nesting (`code | 1 | type`); in values = lists (`npi1 | npi2`).
One row per service × payer × plan. Codes can appear in any `code | N` column.

**Hospital info (rows 1–2):** hospital_name, last_updated_on, version, location_name,
hospital_address, license_number|STATE, type_2_npi, attestation (TRUE), attester_name,
general_contract_provisions

**PriceLens reads:** description; code|N + code|N|type (CPT, HCPCS, DRG, RC...); setting;
standard_charge|gross; standard_charge|discounted_cash; payer_name; plan_name;
standard_charge|negotiated_dollar / negotiated_percentage / negotiated_algorithm;
median_amount, 10th_percentile, 90th_percentile, count (2026 allowed-amount fields);
standard_charge|min / max; standard_charge|methodology

**Compliance check ideas (confirm rules in the data dictionary in Week 5):**

- version present; last_updated_on present and recent
- type_2_npi present, each 10 digits
- attestation TRUE and attester_name present
- every row: description, at least one code + type, setting
- when the rate is a percentage/algorithm: allowed-amount fields filled
- no zero/negative prices; min ≤ max; 10th ≤ median ≤ 90th
