export default async function handler(req, res) {
  const backend = process.env.BACKEND_URL?.replace(/\/$/, '');
  if (!backend) {
    res.status(500).json({ error: 'BACKEND_URL is not configured' });
    return;
  }

  const pathParam = req.query.path;
  const path = Array.isArray(pathParam)
    ? pathParam.join('/')
    : pathParam
      ? String(pathParam)
      : '';

  const incoming = new URL(req.url, 'http://localhost');
  incoming.searchParams.delete('path');
  const query = incoming.search;

  const target = `${backend}/${path}${query}`;

  const headers = { ...req.headers };
  delete headers.host;
  delete headers.connection;
  delete headers['content-length'];

  const init = {
    method: req.method,
    headers,
  };

  if (req.method !== 'GET' && req.method !== 'HEAD' && req.body !== undefined) {
    init.body =
      typeof req.body === 'string' ? req.body : JSON.stringify(req.body);
    if (!headers['content-type']) {
      headers['content-type'] = 'application/json';
    }
  }

  try {
    const upstream = await fetch(target, init);
    res.status(upstream.status);

    upstream.headers.forEach((value, key) => {
      if (key.toLowerCase() === 'transfer-encoding') return;
      res.setHeader(key, value);
    });

    const body = await upstream.arrayBuffer();
    res.send(Buffer.from(body));
  } catch (error) {
    res.status(502).json({
      error: 'Bad gateway',
      message: error instanceof Error ? error.message : 'Upstream request failed',
    });
  }
}
