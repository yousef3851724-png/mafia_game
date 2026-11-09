export default {
  async fetch(request) {
    const url = new URL(request.url);
    if (request.method === 'GET' && url.pathname === '/health') {
      return Response.json({
        service: 'Mafia Radical API Worker',
        status: 'ok',
        database: 'not_configured',
        websocket: 'not_configured',
        phase: 'preview-skeleton'
      }, { headers: { 'cache-control': 'no-store' } });
    }
    return Response.json({
      error: {
        code: 'NOT_IMPLEMENTED',
        message: 'This preview Worker is a health-check skeleton; production API routes are not enabled.'
      }
    }, { status: 501, headers: { 'cache-control': 'no-store' } });
  }
};