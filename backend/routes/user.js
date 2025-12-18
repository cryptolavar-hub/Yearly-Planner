/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Sentinel (Application Security Engineer)
 */

const express = require('express');
const rateLimit = require('express-rate-limit');
const bcrypt = require('bcryptjs');
const { z } = require('zod');

const User = require('../models/User');
const { createRefreshToken, hashRefreshToken, refreshCookieOptions, signAccessToken } = require('../utils/tokens');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
});

const registerSchema = z.object({
  username: z.string().min(3).max(32),
  email: z.string().email(),
  password: z.string().min(12).max(128),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1).max(128),
});

router.post('/register', authLimiter, async (req, res, next) => {
  try {
    const { username, email, password } = registerSchema.parse(req.body);

    const existing = await User.findOne({ $or: [{ email }, { username }] });
    if (existing) return res.status(409).json({ error: { message: 'User already exists' } });

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await User.create({ username, email, passwordHash });

    return res.status(201).json({ user: user.toJSON() });
  } catch (err) {
    if (err?.name === 'ZodError') return res.status(400).json({ error: { message: 'Invalid input', details: err.errors } });
    return next(err);
  }
});

router.post('/login', authLimiter, async (req, res, next) => {
  try {
    const { email, password } = loginSchema.parse(req.body);

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: { message: 'Invalid credentials' } });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ error: { message: 'Invalid credentials' } });

    const accessToken = signAccessToken({ userId: user.id });
    const refreshToken = createRefreshToken();
    user.refreshTokenHash = hashRefreshToken(refreshToken);
    await user.save();

    res.cookie('refresh_token', refreshToken, refreshCookieOptions());
    return res.status(200).json({ accessToken, user: user.toJSON() });
  } catch (err) {
    if (err?.name === 'ZodError') return res.status(400).json({ error: { message: 'Invalid input', details: err.errors } });
    return next(err);
  }
});

router.post('/refresh', async (req, res, next) => {
  try {
    const refreshToken = req.cookies?.refresh_token;
    if (!refreshToken) return res.status(401).json({ error: { message: 'Missing refresh token' } });

    const refreshTokenHash = hashRefreshToken(refreshToken);
    const user = await User.findOne({ refreshTokenHash });
    if (!user) return res.status(401).json({ error: { message: 'Invalid refresh token' } });

    const accessToken = signAccessToken({ userId: user.id });
    return res.status(200).json({ accessToken });
  } catch (err) {
    return next(err);
  }
});

router.post('/logout', async (req, res, next) => {
  try {
    const refreshToken = req.cookies?.refresh_token;
    if (refreshToken) {
      const refreshTokenHash = hashRefreshToken(refreshToken);
      await User.updateOne({ refreshTokenHash }, { $set: { refreshTokenHash: null } });
    }

    res.clearCookie('refresh_token', refreshCookieOptions());
    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
});

router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ error: { message: 'Not found' } });
    return res.status(200).json({ user: user.toJSON() });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;