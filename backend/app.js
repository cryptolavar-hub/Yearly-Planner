/**
 * Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
 * Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com
 *
 * Role: Forge (Backend Engineer - Node/Express)
 */

const express = require('express');
const dotenv = require('dotenv');
const pinoHttp = require('pino-http');
const helmet = require('helmet');
const cors = require('cors');
const cookieParser = require('cookie-parser');
const rateLimit = require('express-rate-limit');

const connectDB = require('./config/db');
const logger = require('./logger');

const userRoutes = require('./routes/user');
const taskRoutes = require('./routes/task');

dotenv.config();

const app = express();
app.set('trust proxy', 1);

app.use(helmet());
app.use(
  cors({
    origin: (origin, cb) => {
      const allow = (process.env.CORS_ORIGINS || 'http://localhost:3000')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);

      // allow same-origin / server-to-server calls (no origin header)
      if (!origin) return cb(null, true);
      if (allow.includes(origin)) return cb(null, true);
      return cb(new Error('CORS blocked'), false);
    },
    credentials: true,
  })
);
app.use(cookieParser());
app.use(express.json());
app.use(
  pinoHttp({
    logger,
    quietReqLogger: true,
  })
);

app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 300,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

app.get('/api/health', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);

// Centralized error handler (baseline; extended hardening occurs in later gates)
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  req.log?.error({ err }, 'Unhandled error');
  if (err && err.message === 'CORS blocked') {
    return res.status(403).json({ error: { message: 'CORS blocked' } });
  }
  res.status(500).json({ error: { message: 'Internal server error' } });
});

if (require.main === module) {
  connectDB();
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, () => logger.info({ port: PORT }, 'Server listening'));
}

module.exports = app;