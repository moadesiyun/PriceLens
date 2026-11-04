import Fastify from "fastify";
import { pool } from "./db.js";

const app = Fastify({ logger: true });

app.get("/health", async (request, reply) => {
  try {
    await pool.query("SELECT 1");
    return { status: "ok", database: "ok" };
  } catch (err) {
    request.log.error(err, "Database health check failed");
    return reply.status(503).send({ status: "error", database: "down" });
    }
});

app.addHook("onClose", async () => {
  await pool.end();
});

const port = Number(process.env.PORT ?? 3000);

try {
  await app.listen({ port, host: "127.0.0.1" });
} catch (err) {
  app.log.error(err);
  process.exit(1);
}