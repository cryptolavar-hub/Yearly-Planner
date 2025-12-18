/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sentinel (Application Security Engineer)
 */

const { verifyAccessToken } = require('../utils/tokens');

function requireAuth(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({ error: { message: 'Missing bearer token' } });
    }

    const payload = verifyAccessToken(token);
    req.user = { id: payload.sub };
    return next();
  } catch (err) {
    const status = err.statusCode || 401;
    return res.status(status).json({ error: { message: 'Unauthorized' } });
  }
}

module.exports = { requireAuth };


