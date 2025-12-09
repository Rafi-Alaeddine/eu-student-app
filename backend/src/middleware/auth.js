// src/middleware/auth.js
// Very small middleware that checks x-api-key header against MOBILE_API_KEY from .env.
// This is a lightweight shared-secret scheme appropriate for prototyping.
// For production, use a proper auth (OAuth2 / JWT) and rotate keys.

module.exports = function requireApiKey(req, res, next) {
  const expected = process.env.MOBILE_API_KEY;
  if (!expected) {
    // If no key configured, allow (useful for local dev). Log a warning.
    if (!req.app.get('warned_no_api_key')) {
      console.warn('WARNING: MOBILE_API_KEY not set in .env. Requests are not authenticated.');
      req.app.set('warned_no_api_key', true);
    }
    return next();
  }

  const provided = req.header('x-api-key') || req.query.api_key;
  if (!provided) {
    return res.status(401).json({ error: 'Missing API key (x-api-key header required)' });
  }
  if (provided !== expected) {
    return res.status(403).json({ error: 'Invalid API key' });
  }
  return next();
};