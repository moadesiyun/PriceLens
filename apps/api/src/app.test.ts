// Test tools from Vitest:
// (describe): groups related tests; (it): defines one test case; (expect): checks a result; (vi): creates mocks (fakes)
// - beforeEach: runs setup before every test
import { describe, it, expect, vi, beforeEach } from "vitest";

// Replace the real database module with a fake one. Vitest moves this to the top of the file, so the real db.ts never runs:
// no DATABASE_URL and no Postgres needed (important for CI). The fake pool has the two methods our app uses: query() and end().
vi.mock("./db.js", () => ({
  pool: { query: vi.fn(), end: vi.fn() },
}));

// These imports now receive the FAKE pool, and an app wired to the fake pool.
import { pool } from "./db.js";
import { buildApp } from "./app.js";

describe("GET /health", () => {
  // Before each test, wipe any fake behavior set by the previous test,
  // so tests can't affect each other.
  beforeEach(() => {
    vi.mocked(pool.query).mockReset();
  });

  it("reports ok when the database answers", async () => {
    // Arrange: make the next database query succeed.
    // "as never" tells TypeScript not to check the fake result's shape;
    // the route ignores the result anyway.
    vi.mocked(pool.query).mockResolvedValueOnce({ rows: [] } as never);
    // Build a fresh app with logging off, so test output stays readable.
    const app = buildApp({ logger: false });

    // Act: send a fake GET /health request straight into Fastify
    // (no real port, no network).
    const res = await app.inject({ method: "GET", url: "/health" });

    // Assert: check both the status code and the JSON body.
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({ status: "ok", database: "ok" });

    // Clean up: close the app (this also calls the fake pool.end()).
    await app.close();
  });

  it("returns 503 when the database is down", async () => {
    // Arrange: make the next database query fail, as if Postgres were unreachable.
    vi.mocked(pool.query).mockRejectedValueOnce(new Error("connection refused"));
    const app = buildApp({ logger: false });

    // Act: same request as before.
    const res = await app.inject({ method: "GET", url: "/health" });

    // Assert: the route should report the failure with a 503
    // and a short body that doesn't leak connection details.
    expect(res.statusCode).toBe(503);
    expect(res.json()).toEqual({ status: "error", database: "down" });

    // Clean up.
    await app.close();
  });
});
