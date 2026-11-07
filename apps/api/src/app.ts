import Fastify from "fastify";
import { pool } from "./db.js";

export function buildApp(options: { logger?: boolean } = {}) {
  const app = Fastify({ logger: options.logger ?? true });

  app.get("/health", async (request, reply) => {
    try {
      await pool.query("SELECT 1");
      return { status: "ok", database: "ok" };
    } catch (err) {
      request.log.error(err, "database health check failed");
      return reply.code(503).send({ status: "error", database: "down" });
    }
  });

  app.addHook("onClose", async () => {
    await pool.end();
  });

  return app;
}
