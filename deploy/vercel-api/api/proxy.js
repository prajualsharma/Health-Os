const CORS_METHODS = 'GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD';
const CORS_HEADERS =
  'Content-Type, Authorization, Accept, Origin, X-Requested-With';

function applyCors(req, res) {
  const origin = req.headers.origin;
  if (origin) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  } else {
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
  res.setHeader('Access-Control-Allow-Methods', CORS_METHODS);
  res.setHeader('Access-Control-Allow-Headers', CORS_HEADERS);
  res.setHeader('Access-Control-Max-Age', '86400');
}

export default async function handler(req, res) {
  applyCors(req, res);

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

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
      const lower = key.toLowerCase();
      // Node fetch decompresses gzip/br bodies; forwarding Content-Encoding
      // would make browsers fail with ERR_CONTENT_DECODING_FAILED.
      if (
        lower === 'transfer-encoding' ||
        lower === 'content-encoding' ||
        lower === 'content-length' ||
        lower.startsWith('access-control-')
      ) {
        return;
      }
      res.setHeader(key, value);
    });

    // Re-apply proxy CORS (browser talks to this origin, not the VM).
    applyCors(req, res);

    const body = await upstream.arrayBuffer();
    res.send(Buffer.from(body));
  } catch (error) {
    res.status(502).json({
      error: 'Bad gateway',
      message: error instanceof Error ? error.message : 'Upstream request failed',
    });
  }
}
