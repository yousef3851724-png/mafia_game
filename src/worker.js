/**
 * Mafia Radical Cloudflare Worker.
 *
 * Initial safe scaffold: forwards API and WebSocket traffic to the existing
 * Node.js backend when API_ORIGIN is configured. It does not access or modify
 * the database. Configure API_ORIGIN only after the backend origin is verified.
 */
const SERVICE_NAME = "Mafia Radical API";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/health" && request.method === "GET") {
      return Response.json({
        service: SERVICE_NAME,
        status: "worker_ok",
        backend: env.API_ORIGIN ? "configured" : "not_configured",
        websocket: "/lobby"
      });
    }

    if (!env.API_ORIGIN) {
      return Response.json({
        error: {
          code: "BACKEND_NOT_CONFIGURED",
          message: "The Mafia Radical backend origin has not been configured."
        }
      }, { status: 503 });
    }

    let origin;
    try {
      origin = new URL(env.API_ORIGIN);
      if (origin.protocol !== "https:" && origin.hostname !== "localhost") {
        throw new Error("API_ORIGIN must use HTTPS.");
      }
    } catch {
      return Response.json({
        error: { code: "INVALID_BACKEND_CONFIGURATION" }
      }, { status: 500 });
    }

    const upstream = new URL(url.pathname + url.search, origin);
    const headers = new Headers(request.headers);
    headers.delete("host");
    headers.set("x-forwarded-host", url.host);
    headers.set("x-forwarded-proto", "https");

    try {
      return await fetch(new Request(upstream, {
        method: request.method,
        headers,
        body: ["GET", "HEAD"].includes(request.method) ? undefined : request.body,
        redirect: "manual"
      }));
    } catch {
      return Response.json({
        error: {
          code: "BACKEND_UNAVAILABLE",
          message: "The Mafia Radical backend could not be reached."
        }
      }, { status: 502 });
    }
  }
};
