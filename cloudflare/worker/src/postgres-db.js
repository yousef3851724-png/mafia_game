import pg from 'pg';

const { Client } = pg;

/**
 * Hyperdrive owns the origin connection pool. Create a short-lived pg Client
 * per Worker request; do not create a process-wide Pool in the Workers runtime.
 */
export async function withPostgres(env, callback, ClientConstructor = Client) {
  const connectionString = env?.HYPERDRIVE?.connectionString;
  if (!connectionString) {
    const error = new Error('HYPERDRIVE binding is not configured');
    error.code = 'HYPERDRIVE_NOT_CONFIGURED';
    throw error;
  }

  // Use the injected constructor in tests; production defaults to pg.Client.
  const client = new ClientConstructor({
    connectionString,
    application_name: 'mafia-radical-cloudflare-worker',
    connectionTimeoutMillis: 5000
  });

  let connected = false;
  try {
    await client.connect();
    connected = true;
    return await callback(client);
  } finally {
    if (connected) {
      await client.end().catch(() => {});
    }
  }
}
