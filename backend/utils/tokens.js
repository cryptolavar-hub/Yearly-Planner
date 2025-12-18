/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sentinel (Application Security Engineer)
 */

const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { sha256Base64 } = require('./crypto');

function requireEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing required environment variable: ${name}`);
  return v;
}

function signAccessToken({ userId }) {
  const secret = requireEnv('JWT_SECRET');
  const expiresIn = process.env.JWT_ACCESS_EXPIRES_IN || '15m';
  return jwt.sign({ sub: userId, typ: 'access' }, secret, { expiresIn });
}

function createRefreshToken() {
  // random token (not a JWT); stored hashed in DB, raw value set in httpOnly cookie
  return crypto.randomBytes(48).toString('base64url');
}

function hashRefreshToken(refreshToken) {
  return sha256Base64(refreshToken);
}

function verifyAccessToken(token) {
  const secret = requireEnv('JWT_SECRET');
  const payload = jwt.verify(token, secret);
  if (!payload || payload.typ !== 'access' || !payload.sub) {
    const err = new Error('Invalid token');
    err.statusCode = 401;
    throw err;
  }
  return payload;
}

function refreshCookieOptions() {
  const isProd = process.env.NODE_ENV === 'production';
  return {
    httpOnly: true,
    secure: isProd,
    sameSite: 'lax',
    path: '/api/users',
    maxAge: 1000 * 60 * 60 * 24 * 30, // 30 days
  };
}

module.exports = {
  signAccessToken,
  createRefreshToken,
  hashRefreshToken,
  verifyAccessToken,
  refreshCookieOptions,
};


