Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Relay (DevOps/SRE) -->

## Environment Variables (Yearly Planner)

This repository intentionally does not store `.env` files. Use your preferred secrets manager or local `.env` (ignored by git) to configure these values.

## Backend (`backend/`)

### Required

- **MONGO_URI**
  - MongoDB connection string
  - Example: `mongodb://localhost:27017/yearly_planner`

- **JWT_SECRET**
  - Secret used to sign JWT access tokens
  - Requirement: long, random, not shared, not checked into source control

### Recommended

- **PORT**
  - Default: `5000`

- **NODE_ENV**
  - Values: `development` | `test` | `production`

- **LOG_LEVEL**
  - Default: `info`

- **JWT_ACCESS_EXPIRES_IN**
  - Default: `15m`

- **CORS_ORIGINS**
  - Comma-separated allowed origins for the browser client
  - Default behavior: allows `http://localhost:3000` if not set
  - Example: `http://localhost:3000,https://yourdomain.com`

## Frontend (`frontend/`)

### Recommended

- **REACT_APP_API_BASE_URL**
  - Base URL for API calls
  - Default: empty (same-origin)
  - Example (dev): `http://localhost:5000`

<!-- Signed-off-by: Relay (DevOps/SRE) -->


