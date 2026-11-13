# PriceLens command cheat sheet

My own reference: Windows, PowerShell, pnpm workspace. Add a line every time I look something up.

**Before running anything:** check the prompt. `PS C:\Users\bolua\PriceLens>` is the repo root; `...\PriceLens\apps\api>` is the API.

## Start a session

```powershell
cd C:\Users\bolua\PriceLens
git pull                     # get the latest from GitHub
docker compose up -d         # start Postgres (open Docker Desktop first)
pnpm check                   # format check + lint + build + tests; must be green before I start
pnpm dev                     # run web (localhost:5173) and API (localhost:3000)
```

## End a session

```powershell
pnpm check                   # green before every push
git add -A
git commit -m "Short, clear message"
git push
```

Then write the next small step in `docs/notes.md`, and spend 2 minutes listing tonight's commands from memory.

## Quick fixes for `pnpm check`

| Problem                               | Fix (from the root)                                      |
| ------------------------------------- | -------------------------------------------------------- |
| Prettier warns about a file           | `pnpm format`, then `pnpm check` again                   |
| "Cannot find module" in lint or tests | `pnpm install`; if still broken, clean reinstall (below) |
| `"check" not found`                   | I'm in a subfolder; `cd` to the root                     |

Clean reinstall:

```powershell
Remove-Item -Recurse -Force node_modules, apps\web\node_modules, apps\api\node_modules
pnpm install
```

## Packages (pnpm workspace)

| Task                               | Command                      | Where             |
| ---------------------------------- | ---------------------------- | ----------------- |
| Add a dev tool to the API          | `pnpm add -D <pkg>`          | `apps\api`        |
| Add to the web app                 | `pnpm add -D <pkg>`          | `apps\web`        |
| Add to the root (rare)             | `pnpm add -D -w <pkg>`       | root              |
| Remove from the root               | `pnpm remove -w <pkg>`       | root              |
| Remove from an app                 | `pnpm remove <pkg>`          | that app's folder |
| Is it installed?                   | `pnpm ls <pkg>`              | that app's folder |
| List an app's scripts              | `pnpm run`                   | that app's folder |
| Run one app's script from the root | `pnpm --filter api <script>` | root              |

`pnpm add` at the root without `-w` errors on purpose. That's a good thing.

## Database migrations (from `apps\api`)

```powershell
pnpm migrate create <name> --migration-file-language sql   # new file in db\migrations\ (repo root)
pnpm migrate up              # apply new migrations
pnpm migrate down            # undo the last one
```

- Test every new migration: up, then down, then up.
- Never edit a migration that has already run; add a new one.
- The script loads `.env` with dotenv-cli: `dotenv -e ../../.env -- node-pg-migrate -m ../../db/migrations`.
- "DATABASE_URL not set": the `.env` isn't being loaded (check the script), or the line is missing from `.env`.

## Postgres (psql)

```powershell
docker compose ps                                          # shows the service name
docker compose exec <service> psql -U <user> -d <dbname>   # user/db name from .env
```

Inside psql:

| Command      | Does                                  |
| ------------ | ------------------------------------- |
| `\dt`        | list tables                           |
| `\d charges` | show a table's columns, indexes, keys |
| `\q`         | quit                                  |

Postgres runs on host port **5433** (5432 is taken by a Windows install).

## SQL reminders

- Foreign key on a column: `hospital_id BIGINT NOT NULL REFERENCES hospitals (id)`. Use `FOREIGN KEY (col) REFERENCES ...` only on its own line at the end of the table.
- Drop tables in reverse order of creation (children before parents).

## Git: see what's going on

| Command                                       | Shows                                             |
| --------------------------------------------- | ------------------------------------------------- |
| `git status`                                  | what changed; whether I'm in sync with GitHub     |
| `git --no-pager diff <file>`                  | exact changes in a file, without the pager        |
| `git --no-pager log --oneline -5`             | my last 5 commits                                 |
| `git --no-pager log --oneline -5 origin/main` | GitHub's last 5 commits                           |
| `git fetch`                                   | download GitHub's state without changing my files |

Stuck at `:` (the pager)? Press `q`. Space scrolls.

## Git: undo things

| Situation                                     | Command                                                                  |
| --------------------------------------------- | ------------------------------------------------------------------------ |
| Throw away uncommitted changes to one file    | `git restore <file>`                                                     |
| Preview untracked files that would be deleted | `git clean -nd` (dry run, always first)                                  |
| Delete untracked files                        | `git clean -fd` (never add `-x`: it deletes `.env`)                      |
| Go back to a commit I haven't pushed          | `git reset --hard <commit>`                                              |
| Undo a commit that's already pushed           | `git revert --no-edit <commit>`, then `git push`                         |
| Laptop and GitHub "diverged", same files      | `git diff HEAD origin/main` (empty?) then `git reset --hard origin/main` |

Rule: pushed means revert, not reset. Never force-push.

## VS Code

| Task                          | How                |
| ----------------------------- | ------------------ |
| Save without formatting       | `Ctrl+K`, then `S` |
| Command Palette               | `Ctrl+Shift+P`     |
| Open a file from the terminal | `code <path>`      |

SQL format-on-save is turned off in `.vscode\settings.json`, because a formatter broke my migration.

## PowerShell

| Task                    | Command                          |
| ----------------------- | -------------------------------- |
| Where am I              | `pwd`                            |
| Go up one / two folders | `cd ..` / `cd ..\..`             |
| Find text in a file     | `Select-String '<text>' <file>`  |
| Does a file exist       | `Test-Path <file>`               |
| List hidden files       | `Get-ChildItem -Force`           |
| Prompt shows `>>`       | unfinished quote; press `Ctrl+C` |

## Reading errors

1. Read the **first** error line: it usually names the problem.
2. Find the file and line number.
3. Ask: which folder was I in, and what did the last command change?
4. Search the exact message, or `<tool> --help`.
