import pg from "pg";

const { Client } = pg;

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store"
    }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/health") {
      if (!env.HYPERDRIVE?.connectionString) {
        return json({
          service: "Mafia Radical API",
          status: "degraded",
          database: "not_configured"
        }, 503);
      }

      const client = new Client({
        connectionString: env.HYPERDRIVE.connectionString
      });

      try {
        await client.connect();
        await client.query("SELECT 1");
        return json({
          service: "Mafia Radical API",
          status: "ok",
          database: "ok",
          adapter: "cloudflare-workers-hyperdrive"
        });
      } catch (error) {
        console.error("Health database check failed:", error?.name || "unknown_error");
        return json({
          service: "Mafia Radical API",
          status: "degraded",
          database: "unavailable"
        }, 503);
      } finally {
        try { await client.end(); } catch {}
      }
    }

    return json({
      error: {
        code: "ROUTE_NOT_MIGRATED",
        message: "This route has not yet been migrated to the Cloudflare Worker adapter."
      }
    }, 501);
  }
};
