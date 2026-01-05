/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sable (QA Terminator - Bug Killer)
 */

const request = require('supertest');
const app = require('../app');

describe('Security gate tests (DB-independent)', () => {
  test('POST /api/users/register rejects weak password (no DB required)', async () => {
    const res = await request(app).post('/api/users/register').send({
      username: 'user1',
      email: 'user1@example.com',
      password: 'short',
    });
    expect(res.statusCode).toBe(400);
  });

  test('POST /api/users/login rejects invalid body (no DB required)', async () => {
    const res = await request(app).post('/api/users/login').send({
      email: 'not-an-email',
      password: 'x',
    });
    expect(res.statusCode).toBe(400);
  });

  test('GET /api/tasks requires auth (no DB required)', async () => {
    const res = await request(app).get('/api/tasks');
    expect(res.statusCode).toBe(401);
  });

  test('GET /api/tasks rejects invalid bearer token (no DB required)', async () => {
    const res = await request(app).get('/api/tasks').set('Authorization', 'Bearer not_a_real_token');
    expect(res.statusCode).toBe(401);
  });
});


