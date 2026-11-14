/**
 * Mafia Radical Cloudflare edge gateway.
 *
 * This deliberately proxies to the existing API instead of replacing its
 * PostgreSQL-backed data layer. It preserves HTTP paths, auth headers and
 * WebSocket upgrades. D1 migration is a separate, verified project.
 */
export default {
  async fetch(request, env) {
    const origin = String(env.BACKEND_ORIGIN || "").trim();
    if (!origin) {
      return Response.json(
        { service: "Mafia Radical Edge", status: "not_configured", error: "BACKEND_ORIGIN is required" },
        { status: 503, headers: { "cache-control": "no-store" } }
      );
    }

    let upstream;
    try {
      upstream = new URL(origin);
    } catch {
      return Response.json({ error: "invalid_backend_origin" }, { status: 500 });
    }
    if (upstream.protocol !== "https:" || upstream.username || upstream.password) {
      return Response.json({ error: "backend_origin_must_be_https" }, { status: 500 });
    }

    const incoming = new URL(request.url);
    upstream.pathname = incoming.pathname;
    upstream.search = incoming.search;

    const headers = new Headers(request.headers);
    headers.delete("host");
    headers.delete("cf-connecting-ip");
    headers.delete("x-forwarded-host");

    const init = {
      method: request.method,
      headers,
      redirect: "manual",
    };
    if (request.method !== "GET" && request.method !== "HEAD") {
      init.body = request.body;
    }

    try {
      const response = await fetch(new Request(upstream.toString(), init));
      const outputHeaders = new Headers(response.headers);
      outputHeaders.set("cache-control", "no-store");
      outputHeaders.set("x-mafia-radical-edge", "cloudflare-worker");
      return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers: outputHeaders,
      });
    } catch {
      return Response.json(
        { service: "Mafia Radical Edge", status: "upstream_unavailable" },
        { status: 502, headers: { "cache-control": "no-store" } }
      );
    }
  },
};
