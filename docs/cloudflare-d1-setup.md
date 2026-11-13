# Cloudflare Worker / D1 setup

This branch configures the existing D1 database for the `mafia-radical` Worker.

## Safety
- Does not create, drop, rename, or migrate any D1 table.
- Does not modify player balances or account records.
- `GET /health` and `GET /api/v1/health` run read-only D1 checks.
- Other `/api/*` routes intentionally return HTTP 501 until their behavior is ported and tested against the existing schema.

## Bindings
- `DB`: existing D1 database `mafia-radical-db`.
- `ASSETS`: existing static files in `site/`.

## Deploy
After reviewing this branch and confirming the Cloudflare Pages/Workers deployment configuration, deploy this branch's Worker using Wrangler. Do not run the PostgreSQL migration files against D1; they use PostgreSQL-specific SQL and target a different schema.
