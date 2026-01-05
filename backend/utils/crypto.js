/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sentinel (Application Security Engineer)
 */

const crypto = require('crypto');

function sha256Base64(input) {
  return crypto.createHash('sha256').update(input, 'utf8').digest('base64');
}

module.exports = { sha256Base64 };


