# 🚀 Deployment Guide (Yearly Planner)

Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform  
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Relay (DevOps/SRE) -->

**Status**: ✅ Aligned to current repo structure  
**Last Updated**: 2025-12-18

[Back to root README](../README.md)  
[Back to docs index](README.md)

## Overview

This repository contains:
- **Backend**: `backend/` (Node/Express + MongoDB via Mongoose)
- **Frontend**: `frontend/` (React via Create React App + Tailwind)

The backend exposes endpoints under `/api` (see [docs/API.md](API.md)).

## Prerequisites

- Node.js (recommended: Node 18+)
- npm (bundled with Node)
- MongoDB (local or managed)

Repository policy:
- `.env` files are not committed. Configure environment variables via your local `.env` (ignored) or a secrets manager.
- See [docs/ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) for the full list.

## Local development (recommended)

### Backend (local)

1. Open a terminal at repo root and go to backend:

```bash
cd backend
```

2. Install dependencies:

```bash
npm install --no-fund --no-audit
```

3. Set required environment variables (at minimum `MONGO_URI` and `JWT_SECRET`).

4. Start dev server:

```bash
npm run dev
```

5. Verify:
  - `GET /api/health` should return `{ "status": "ok" }`

### Frontend (local)

1. In a separate terminal:

```bash
cd frontend
```

2. Install dependencies:

```bash
npm install --no-fund --no-audit
```

3. Start dev server:

```bash
npm start
```

4. API connectivity options:
  - Recommended: set `REACT_APP_API_BASE_URL` to your backend origin (example: `http://localhost:5000`) and set backend `CORS_ORIGINS` to allow the frontend origin.

## Production build

### Backend

Run the backend as a long-lived process behind a reverse proxy:
- Start command:

```bash
cd backend
npm install --omit=dev --no-fund --no-audit
npm start
```

Minimum required env vars:
- `MONGO_URI`
- `JWT_SECRET`

Recommended env vars:
- `NODE_ENV=production`
- `CORS_ORIGINS=https://your-frontend-domain`

### Frontend

Build static assets:

```bash
cd frontend
npm install --omit=dev --no-fund --no-audit
npm run build
```

Serve `frontend/build` via your web server (Nginx, etc.).

## Testing before deploy

Use the authoritative test run plan/log:
- [docs/TESTING_REPORT.md](TESTING_REPORT.md)

## 🔗 Related documents

- 🧭 Docs hub: [docs/README.md](README.md)
- 🔌 API spec: [docs/API.md](API.md)
- 🗄️ Database model: [docs/DATABASE_ERD.md](DATABASE_ERD.md)
- 🔐 Environment variables: [docs/ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md)
- 🔒 Security report: [docs/SECURITY_REPORT.md](SECURITY_REPORT.md)
- 🤖 Workflow: [docs/WORKFLOW.md](WORKFLOW.md)

## Troubleshooting

- Backend fails to start:
  - Verify `MONGO_URI` and Mongo connectivity.
  - Verify `JWT_SECRET` is set.
  - Check backend logs.

- Frontend API calls fail:
  - Confirm `REACT_APP_API_BASE_URL` points to backend origin.
  - Confirm backend `CORS_ORIGINS` includes the frontend origin.
  - Confirm browser sends credentials for refresh flow (`withCredentials: true`).

<!-- Signed-off-by: Relay (DevOps/SRE) -->