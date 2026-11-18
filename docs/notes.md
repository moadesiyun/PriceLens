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

## Sat Nov 7 — done (Week 1 complete)

Missed Wed/Thu; caught up in Saturday's block.

**Done**

- CMS v3.0.0 samples downloaded to `data/samples` (tall, wide, JSON); field list written above
- `docs/spec.md`: problem, users, scope, data, 20 target services, similar tools, disclaimer
- `pnpm format:check` and `pnpm build` pass
- CI on every push: install, format:check, lint, build, test (green)
- API: `buildApp()` in `app.ts`; `/health` tests with mocked DB (200 and 503)
- Web: Vitest + jsdom + Testing Library; 2 tests on the starter page (rewrite in Week 7)
- `pnpm check` runs everything CI runs; use before every push

**Decisions**

- **Primary user = hospital compliance / revenue-cycle analyst;** secondary = pricing/health
  data analyst; patients out of scope in this phase. Why: matches the compliance angle and the healthcare
  data roles I'm targeting.
- **PriceLens is a study project in a market that already exists** (CMS validator, Turquoise
  Health, PriceTransparency.io). Differentiate on engineering and clear explanations, not novelty.
- **20 services:** 5 imaging, 5 labs, 4 visits, 6 procedures (CPT + MS-DRG). Codes to be
  checked against the CMS 70 shoppable services list.
- **TypeScript 7 + 6 side by side (apps/web):** `typescript` → TS 6.0 (alias of
  `@typescript/typescript6`) so ESLint/Vite get the compiler API; `@typescript/native` → TS 7.0
  for `tsc`. Why: typescript-eslint crashes on TS 7.0, which has no API until 7.1.
  Undo when typescript-eslint supports TS 7.1+ (track typescript-eslint issue #10940).
  Repeat in apps/api when ESLint is added there.
  Tests: mock DB for route logic; real Postgres in CI from Week 2. `app.inject()`, not Supertest
- Test files excluded from the API build (CI was running them twice from `dist`)
- Node 24.15+ required (`engines` + `.npmrc engine-strict`); laptop upgraded 22.13 → 24.22.2

**Lessons**

- Always check the newest CI run; old red runs stay in the list
- Same code, different result on CI → suspect versions (Node, Prettier) first

## Week 2 plan (Nov 9–15): data model and SQL

Done when: schema migrated, 10 practice queries saved.

- Mon: choose migration tool; first migration (hospitals, files)
- Tue: services + charges tables (gross, cash, negotiated by payer/plan, allowed-amount stats);
  seed the 20 target services from the spec
- Wed (learn): SQL practice — joins, GROUP BY, window functions
- Thu: Postgres service container in CI; run migrations there; ESLint for the API if time
- Sat: 10 practice queries in `db/queries.sql`; weekly review; plan Week 3
  Carry-overs: verify 20 codes against CMS list; `.env.example` placeholders

## Next small step (Mon Nov 9)

- Start Docker Desktop, `docker compose up -d`, `pnpm dev`; confirm `/health`
- Compare migration tools (node-pg-migrate vs. others) — pick one in 20 min, write why here

## Week 2: Data model and SQL (Nov 9–15)

### Mon Nov 9

Missed. Made up on Wed (make up within the same week; don't shift the schedule).

### Wed Nov 11 (~2 hrs, catch-up build)

Done:

- Reset the repo to a clean state: reverted the earlier node-pg-migrate commits. GitHub history has a duplicate revert + merge (harmless). Laptop and origin/main in sync.
- `apps/api` dev dependencies: node-pg-migrate 9.0.0, dotenv-cli 11.1.0.
- Script: `"migrate": "dotenv -e ../../.env -- node-pg-migrate -m ../../db/migrations"`.
- First migration `db/migrations/<timestamp>_init-schema.sql` (plain SQL):
  `hospitals`, `price_files`, `services` (unique code + code_type), `charges` (gross, cash, payer/plan,
  negotiated $/%/algorithm, methodology, min/max, 2026 allowed-amount median/p10/p90/count);
  indexes on `charges(service_id)` and `charges(price_file_id)`.
- Tested up → down → up: clean.
- `.vscode/settings.json`: format-on-save off for SQL.
- Added `docs/commands.md` (command cheat sheet).

Decisions:

- **Migrations: node-pg-migrate with plain SQL files.** Sits on the `pg` package already in use; every table is SQL I wrote (Week 2 goal). No ORM for now; row types written by hand (maybe Kysely later).
- **Load `.env` with dotenv-cli** in the script; `--envPath` didn't work. CI will use a separate `migrate:ci` script without dotenv.
- **Migrations live at the repo root** (`db/migrations`), not inside `apps/api`.

Gotchas:

- `pnpm add` at the root needs `-w`; run app packages inside the app folder. A root removal broke `apps/web` ESLint until `pnpm install`.
- A VS Code SQL formatter rewrote the migration on save and added invalid `FOREIGN KEY` text inside column lines. Save without formatting: Ctrl+K, then S.
- Column-level foreign key = `REFERENCES table (id)` only; `FOREIGN KEY (col) REFERENCES …` goes on its own line at the end of the table.
- Pushed commit → `git revert`, not reset. Pager `:` → press `q`.

Next small step (Thu):

- Migration `seed-target-services`: insert the 20 services from `docs/spec.md`.
- `db/dev-seed.sql`: 3 made-up hospitals, ~30 charges, including a zero, a negative, a missing cash price and missing allowed-amount fields.
- `db/practice.sql`: start the 10 queries (WHERE/JOIN first).

Still open for Week 2:

- Thu: 10 practice queries.
- Sat: Postgres container in CI + `migrate:ci`; ESLint for the API; Week 3 reading (CMS tall layout, csv-parse streaming, Node streams); check the 20 codes against the CMS list; `.env.example` placeholders.
  Run `pnpm format` before you commit, then commit `docs/notes.md` together with `docs/commands.md`.

## Thu, Nov 12

- Done: migration `seed-target-services` (20 services: 5 imaging, 5 lab, 4 visit, 6 procedure); up/down/up clean.
- Done: `db/dev-seed.sql`: 3 fake hospitals, 30 charges, deliberate bad values (zero cash, negative negotiated, missing cash, missing allowed amounts). Re-runnable.
- Gotcha: visit codes were first tagged `procedure`; fixed before pushing. After a migration is pushed, fix it with a new migration instead of editing it.
- psql: docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
- Run a file: Get-Content db/dev-seed.sql | docker compose exec -T db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1'

## Next small step (Fri, Nov 13)

- `db/practice.sql` queries 1–3: Q1 = 6 rows; Q2 = Bayou 950, Cypress 700, Gulf 1200; Q3 avg for 45378 = 1800 (AVG skips NULLs).
- Then queries 4–10, commit, `pnpm check`, push.

## Week 2 · Practice queries (Nov 14–16) · SDLC stage: design (data model)

### Biggest takeaways (rewrite in your own words)

- Predict the result before running a query. When the result differs, explain why before changing anything.
- Know the grain: what does one row of the result stand for? One problem can show up on many rows.

### SQL lessons

1. **Filter on the full key.** A service is unique by `code` + `code_type`, so filter on both, not just `code`.
2. **Avoid `SELECT *` in joins.** Pick the columns that answer the question, with table aliases (`s.code`, `c.discounted_cash`).
3. **Gross charge and cash price don't change by payer.** They repeat on every payer row. Use `DISTINCT` to get one row per hospital, not `AVG`.
4. **`GROUP BY` lists use commas:** `GROUP BY a, b, c`. Not `AND`, not `+`.
5. **NULL vs. zero.** `AVG` skips `NULL` but counts `0`. `COUNT(*)` counts every row; `COUNT(col)` skips `NULL`s.
6. **Missing matches:** `LEFT JOIN` keeps every row from the left table. Find "no match" with `WHERE <right table>.id IS NULL`. Test a column that is never NULL in a real row.
7. **Distinct counts don't add up.** 2 + 3 + 2 distinct payers per hospital, but only 3 payers in total, because payers are shared.
8. **Window functions keep every row.** `RANK() OVER (PARTITION BY group ORDER BY value)` ranks within each group. `RANK` keeps ties (both get 1); `ROW_NUMBER` hides them.
9. **Scope:** aliases inside a subquery (`h`, `s`, `c`) don't exist outside it. The outer query only sees the subquery's output columns.
10. **`WHERE` keeps rows; it doesn't exclude them.** To exclude A or B, write `NOT A AND NOT B` (De Morgan's law). `IS NOT NULL OR != 0` still keeps zeros.
11. **SQL runs in this order:** FROM/JOIN → WHERE → GROUP BY → SELECT → ORDER BY. So `WHERE` can't use a `SELECT` alias (wrap the query or use a CTE), but `ORDER BY` can.
12. **CTEs** (`WITH a AS (...), b AS (...)`) are named steps. One `WITH`, steps separated by commas. Easier to read than nested subqueries.
13. **Data-quality labels:** `concat_ws(', ', CASE ... END, ...)` lists every issue on a row. A `CASE` with no `ELSE` returns NULL, and `concat_ws` skips NULLs.
14. **`EXPLAIN ANALYZE`:** read it from the most indented line outward. `charges_service_idx` was used. Compare estimated vs. actual rows. `DISTINCT` adds a sort step. Rerun in Week 10 with real data.

### Design decisions

- Missing, zero or negative cash prices are excluded from rankings and medians; Week 5 rules will flag them.
- Ties for cheapest hospital show both (`RANK`), with no tiebreaker.
- The allowed-amount checks stay separate (median, p10, p90, count), so a hospital knows which field to fix.
- Week 5 quality score: count cash issues per hospital + service, and negotiated/allowed issues per payer row.

### Tooling gotchas

- The VS Code PostgreSQL extension is Microsoft's "PostgreSQL" one, not "SQL Server (mssql)". The "pre-login handshake" error means the wrong extension.
- Port 5433, not 5432. Something else on 5432 rejects the password.
- Copilot is off for SQL while practicing.

### Next small step

- Add the missing semicolons and the `allowed_count` check in query 8; commit and push; then the CI Postgres service container.
