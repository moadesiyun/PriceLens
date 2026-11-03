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
