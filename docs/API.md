# 🔌 Yearly Planner API Specification

Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform  
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Forge (Backend Engineer - Node/Express) -->

**Status**: ✅ Implemented and aligned to code  
**Last Updated**: 2025-12-18

[Back to root README](../README.md)  
[Back to docs index](README.md)

## 🎯 Overview

This repository exposes a Node/Express JSON API used by the React frontend.

- **Backend**: `backend/`
- **Frontend**: `frontend/`
- **Base URL**: `/api`

## 🔐 Authentication model (implemented)

This system uses:
- **Access token**: JWT, returned by `POST /api/users/login`, sent as `Authorization: Bearer <token>`.
- **Refresh token**: random token stored in an **httpOnly cookie** named `refresh_token`.
  - The cookie is set on login, then used by `POST /api/users/refresh` to mint a new access token.
  - Frontend must send cookies: Axios uses `withCredentials: true`.

## 🌐 Global endpoints

### Health

- **GET** `/api/health`
- **Response**:

```json
{ "status": "ok" }
```

## 👤 User endpoints

### Register

- **POST** `/api/users/register`
- **Request body**:

```json
{
  "username": "string (min 3, max 32)",
  "email": "string (email)",
  "password": "string (min 12, max 128)"
}
```

- **Response (201)**:

```json
{
  "user": {
    "_id": "ObjectId",
    "username": "string",
    "email": "string",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

- **Notes**
  - Password is stored as a bcrypt hash and is never returned.

### Login

- **POST** `/api/users/login`
- **Request body**:

```json
{
  "email": "string (email)",
  "password": "string"
}
```

- **Response (200)**:

```json
{
  "accessToken": "jwt-string",
  "user": {
    "_id": "ObjectId",
    "username": "string",
    "email": "string",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

- **Cookie side effect**
  - Sets `refresh_token` as an httpOnly cookie (used by refresh/logout).

### Refresh access token

- **POST** `/api/users/refresh`
- **Auth**: uses the `refresh_token` cookie (no Authorization header required)
- **Response (200)**:

```json
{
  "accessToken": "jwt-string"
}
```

### Logout

- **POST** `/api/users/logout`
- **Auth**: uses the `refresh_token` cookie (if present)
- **Response (204)**: empty body

### Current user profile

- **GET** `/api/users/me`
- **Headers**:
  - `Authorization: Bearer <accessToken>`
- **Response (200)**:

```json
{
  "user": {
    "_id": "ObjectId",
    "username": "string",
    "email": "string",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

## ✅ Task endpoints (all protected)

All task endpoints require:
- `Authorization: Bearer <accessToken>`
- Tasks are always scoped to the authenticated user; cross-user access is not permitted.

### Create task

- **POST** `/api/tasks`
- **Request body**:

```json
{
  "title": "string (min 1, max 200)",
  "description": "string (max 5000, optional)",
  "dueDate": "ISO8601 datetime string (optional)",
  "completed": "boolean (optional)"
}
```

- **Response (201)**:

```json
{
  "task": {
    "_id": "ObjectId",
    "title": "string",
    "description": "string",
    "dueDate": "ISO8601 or null",
    "completed": false,
    "user": "ObjectId",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

### List tasks

- **GET** `/api/tasks`
- **Query params**:
  - `completed`: `true` | `false` (optional)
  - `skip`: integer (optional, default 0)
  - `limit`: integer (optional, default 50, max 100)
- **Response (200)**:

```json
{
  "tasks": [
    {
      "_id": "ObjectId",
      "title": "string",
      "description": "string",
      "dueDate": "ISO8601 or null",
      "completed": false,
      "user": "ObjectId",
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601",
      "__v": 0
    }
  ]
}
```

### Get task by id

- **GET** `/api/tasks/:id`
- **Response (200)**:

```json
{
  "task": {
    "_id": "ObjectId",
    "title": "string",
    "description": "string",
    "dueDate": "ISO8601 or null",
    "completed": false,
    "user": "ObjectId",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

### Update task

- **PUT** `/api/tasks/:id`
- **Request body**: any subset of create fields
- **Response (200)**:

```json
{
  "task": {
    "_id": "ObjectId",
    "title": "string",
    "description": "string",
    "dueDate": "ISO8601 or null",
    "completed": false,
    "user": "ObjectId",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601",
    "__v": 0
  }
}
```

### Delete task

- **DELETE** `/api/tasks/:id`
- **Response (204)**: empty body

## ⚠️ Error responses (implemented patterns)

The code currently returns error objects in the following general shape:

```json
{
  "error": {
    "message": "string",
    "details": "optional"
  }
}
```

Common statuses:
- `400` invalid input / invalid query / invalid id
- `401` missing or invalid bearer token / invalid credentials
- `403` CORS blocked (server-side)
- `404` not found
- `409` user already exists
- `500` internal server error

## 🚧 Not implemented in this repository (as of 2025-12-18)

The following were present in older docs but are not implemented in current code:
- Projects
- Comments

## 🔗 Related documents

- 🧭 Docs hub: [docs/README.md](README.md)
- 🚀 Deployment: [docs/DEPLOYMENT.md](DEPLOYMENT.md)
- 🗄️ Database model: [docs/DATABASE_ERD.md](DATABASE_ERD.md)
- 🔐 Environment variables: [docs/ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md)
- 🧪 Testing report: [docs/TESTING_REPORT.md](TESTING_REPORT.md)
- 🔒 Security report: [docs/SECURITY_REPORT.md](SECURITY_REPORT.md)

<!-- Signed-off-by: Forge (Backend Engineer - Node/Express) -->