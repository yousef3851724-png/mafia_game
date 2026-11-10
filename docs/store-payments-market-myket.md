# Mafia Radical store payments — Bazaar and Myket

## Release decision
- Initial distribution/payment providers: Cafe Bazaar and Myket only.
- Both store checkouts are Iranian-market, IRR-priced products configured in each developer console.
- USD is the planned international catalog currency only. No international checkout is enabled in this release.
- Do not enable the legacy direct Zarinpal route for in-app digital goods in this release.

## Security contract
1. Flutter selects a fixed product SKU from the server catalog; it never submits price, currency, reward quantity, or item ownership.
2. The native store SDK completes checkout and returns provider purchase data.
3. Flutter sends provider, product SKU, purchase token/order ID, and signed/original receipt data to the authenticated backend.
4. Backend verifies the receipt with the provider's official server API using server-held credentials. A client success callback or local signature check alone is not sufficient.
5. In one PostgreSQL transaction, lock/insert the unique provider+purchase_token purchase, mark it verified, append one inventory_ledger row, and grant the corresponding item. Replays must return the original result without granting again.
6. Refund/revocation notifications or reconciliation must reverse entitlement through a compensating ledger entry; never delete purchase history.
7. Consumables (coins/diamonds) are consumed according to the store SDK contract only after server verification. Permanent avatars/frames/tombstones are non-consumable entitlements and must not be consumed.

## Current implementation boundary
The migration creates the server-side catalog, idempotent purchase ledger, and inventory audit table. Provider-specific verification adapters and Flutter native billing integrations remain disabled until the exact current Bazaar/Myket API credentials, product SKUs, signing configuration, and SDK versions are supplied/confirmed. The backend must fail closed (503) while a provider adapter is unconfigured; never grant inventory on an unverified receipt.

## Product catalog
- Keep store product IDs stable and separate per provider if their SKU naming differs.
- price_irr is the price configured for Bazaar/Myket.
- price_usd_cents is reserved for future international catalog display/checkout; it does not authorize a USD payment path.
- Configure each store's own localized price; do not assume the same price or tax/commission in both stores.
