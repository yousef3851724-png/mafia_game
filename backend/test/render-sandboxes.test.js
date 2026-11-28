'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const express = require('express');
const { createRenderSandboxesRouter } = require('../src/render-sandboxes');

async function startTestServer({ creator = true, RenderClient }) {
  const app = express();
  const pool = {
    query: async () => ({ rowCount: creator ? 1 : 0 })
  };
  const auth = (req, res, next) => {
    req.auth = { sub: 'test-creator-id' };
    next();
  };

  app.use(express.json());
  app.use(
    '/api/v1/admin/sandboxes',
    createRenderSandboxesRouter({ pool, auth, RenderClient })
  );

  const server = http.createServer(app);
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();

  return {
    url: `http://127.0.0.1:${address.port}/api/v1/admin/sandboxes/diagnostics`,
    close: () => new Promise((resolve, reject) =>
      server.close(error => error ? reject(error) : resolve())
    )
  };
}

async function withRenderEnv(callback, configured = true) {
  const previousKey = process.env.RENDER_API_KEY;
  const previousWorkspace = process.env.RENDER_WORKSPACE_ID;

  if (configured) {
    process.env.RENDER_API_KEY = 'test-render-key';
    process.env.RENDER_WORKSPACE_ID = 'test-workspace';
  } else {
    delete process.env.RENDER_API_KEY;
    delete process.env.RENDER_WORKSPACE_ID;
  }

  try {
    await callback();
  } finally {
    if (previousKey === undefined) delete process.env.RENDER_API_KEY;
    else process.env.RENDER_API_KEY = previousKey;

    if (previousWorkspace === undefined) delete process.env.RENDER_WORKSPACE_ID;
    else process.env.RENDER_WORKSPACE_ID = previousWorkspace;
  }
}

test('non-creator receives 403 and Render is never initialized', async () => {
  await withRenderEnv(async () => {
    let initialized = false;
    class FakeRender {
      constructor() {
        initialized = true;
      }
    }

    const server = await startTestServer({ creator: false, RenderClient: FakeRender });
    try {
      const response = await fetch(server.url, { method: 'POST' });
      assert.equal(response.status, 403);
      assert.equal((await response.json()).error.code, 'CREATOR_ONLY');
      assert.equal(initialized, false);
    } finally {
      await server.close();
    }
  });
});

test('missing Render configuration returns 503 without initializing SDK', async () => {
  await withRenderEnv(async () => {
    let initialized = false;
    class FakeRender {
      constructor() {
        initialized = true;
      }
    }

    const server = await startTestServer({ RenderClient: FakeRender });
    try {
      const response = await fetch(server.url, { method: 'POST' });
      assert.equal(response.status, 503);
      assert.equal((await response.json()).error.code, 'SANDBOX_NOT_CONFIGURED');
      assert.equal(initialized, false);
    } finally {
      await server.close();
    }
  }, false);
});

test('successful diagnostics return bounded output and terminate sandbox without exposing its ID', async () => {
  await withRenderEnv(async () => {
    const calls = { terminated: [], command: null };

    class FakeRender {
      constructor() {
        this.sandboxes = {
          create: async options => {
            assert.equal(options.networkPolicy.type, 'deny-all');
            assert.equal(options.wait, true);
            return { id: 'private-sandbox-id' };
          },
          exec: async (id, command) => {
            calls.command = command;
            assert.equal(id, 'private-sandbox-id');
            return (async function* () {
              yield { type: 'output', stream: 'stdout', data: 'v22.0.0\\n' };
              yield { type: 'exit', exit_code: 0 };
            })();
          },
          terminate: async id => calls.terminated.push(id)
        };
      }
    }

    const server = await startTestServer({ RenderClient: FakeRender });
    try {
      const response = await fetch(server.url, { method: 'POST' });
      const body = await response.json();

      assert.equal(response.status, 200);
      assert.equal(body.sandbox.status, 'completed');
      assert.equal(body.exitCode, 0);
      assert.match(body.output, /v22\.0\.0/);
      assert.equal(calls.command, 'node --version && npm --version && uname -s');
      assert.deepEqual(calls.terminated, ['private-sandbox-id']);
      assert.equal(JSON.stringify(body).includes('private-sandbox-id'), false);
      assert.equal(JSON.stringify(body).includes('test-render-key'), false);
    } finally {
      await server.close();
    }
  });
});

test('sandbox is terminated when create fails after allocating an ID', async () => {
  await withRenderEnv(async () => {
    const terminated = [];

    class FakeRender {
      constructor() {
        this.sandboxes = {
          create: async () => {
            const error = new Error('provider wait failed');
            error.sandboxId = 'orphan-sandbox-id';
            throw error;
          },
          terminate: async id => terminated.push(id)
        };
      }
    }

    const server = await startTestServer({ RenderClient: FakeRender });
    try {
      const response = await fetch(server.url, { method: 'POST' });
      const body = await response.json();

      assert.equal(response.status, 502);
      assert.equal(body.error.code, 'SANDBOX_OPERATION_FAILED');
      assert.deepEqual(terminated, ['orphan-sandbox-id']);
      assert.equal(JSON.stringify(body).includes('orphan-sandbox-id'), false);
    } finally {
      await server.close();
    }
  });
});
