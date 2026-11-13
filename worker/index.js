const json = (data, status = 200) => new Response(JSON.stringify(data), {
  status,
  headers: {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "GET, POST, OPTIONS",
    "access-control-allow-headers": "authorization, content-type"
  }
});

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "GET, POST, OPTIONS",
          "access-control-allow-headers": "authorization, content-type",
          "access-control-max-age": "86400"
        }
      });
    }

    if (url.pathname === "/" && request.method === "GET") {
      if (env.ASSETS) return env.ASSETS.fetch(request);
      return json({ service: "Mafia Radical API", status: "ok" });
    }

    if ((url.pathname === "/health" || url.pathname === "/api/v1/health") && request.method === "GET") {
      try {
        const result = await env.DB.prepare("SELECT 1 AS ok").first();
        if (result?.ok !== 1) throw new Error("D1 health check failed");
        const tables = await env.DB.prepare(
          "SELECT COUNT(*) AS count FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'"
        ).first();
        return json({
          service: "Mafia Radical API",
          status: "ok",
          database: "ok",
          databaseBinding: "DB",
          tableCount: Number(tables?.count ?? 0)
        });
      } catch {
        return json({
          service: "Mafia Radical API",
          status: "degraded",
          database: "unavailable"
        }, 503);
      }
    }

    if (url.pathname.startsWith("/api/")) {
      return json({ error: { code: "NOT_IMPLEMENTED", message: "این مسیر هنوز پیاده‌سازی نشده است." } }, 501);
    }

    if (env.ASSETS) return env.ASSETS.fetch(request);
    return json({ error: { code: "NOT_FOUND", message: "مسیر پیدا نشد." } }, 404);
  }
};
