Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Sable (QA Terminator - Bug Killer) -->

## Bug Audit and Execution Plan (Approval-Gated)

Non-negotiables for this repository (per CryptoLavar):
- No code changes without explicit approval.
- No commits without explicit command.
- No emoji/icons in code (Windows compatibility).

This document provides:
- An issue register discovered from a deep dive of the current codebase and docs.
- Proposed solution options with pros/cons/impact.
- A staged execution plan for approval before implementation begins.

## Quick architecture snapshot (current code)

- `frontend/`: React app with Login/Register/Home screens and Tailwind CSS.
- `backend/`: Express app with MongoDB (Mongoose) and basic user/task routes.
- `api/`: FastAPI router file that appears orphaned / not integrated with the running app.
- `docs/`: API/ERD/deployment/testing/security documents (some mismatch reality).

## Severity scale

- **Blocker**: Cannot run/build or would be unsafe to expose publicly.
- **Critical**: Severe security/data exposure/corruption risk.
- **High**: Major functional gap; likely to break user flows or leak data in common cases.
- **Medium**: Correctness/maintainability gap; can become High under scale.
- **Low**: Cosmetic or minor improvements.

## Issue register (discovered)

### B-001 (Blocker): Backend missing `package.json` (backend not installable)

- **Area**: Build/Runtime
- **Evidence**: `backend/` contains `app.js`, routes, models; no `backend/package.json` present in repository.
- **Impact**: Backend dependencies cannot be installed/reproduced; prevents reliable local run, CI, and production deploy.
- **Fix options**:
  - **Option A (minimal)**: Create `backend/package.json` with explicit dependencies (express, mongoose, dotenv) and scripts.
    - **Pros**: Fast; unblocks running.
    - **Cons**: Doesn’t address security/correctness; still needs hardening work.
  - **Option B (best practice)**: Add `backend/package.json` plus lint/test tooling (eslint, jest/supertest), env validation, and structured logging.
    - **Pros**: Sets foundation for safe refactors and regression prevention.
    - **Cons**: Slightly more upfront work.
- **Validation**:
  - `npm install` succeeds in `backend/`
  - `npm run start` runs without errors
  - Smoke test: register/login/task create/list endpoints respond.
- **Owner persona**: Forge + Relay + Sable
 - **Status**: Remediated in Gate 1 (manifest + tests + lint + health endpoint added)

### B-002 (Blocker): Frontend depends on `react-scripts` but it is missing from dependencies

- **Area**: Build/Runtime
- **Evidence**: `frontend/package.json` scripts call `react-scripts`, but dependencies list does not include `react-scripts`.
- **Impact**: `npm start` and `npm build` fail; blocks running UI.
- **Fix options**:
  - **Option A (minimal)**: Add `react-scripts` at a compatible version for React 17.
  - **Option B (best practice)**: Upgrade React/tooling to a modern baseline (requires coordinated testing).
- **Validation**:
  - `npm install` and `npm start` succeed in `frontend/`
- **Owner persona**: Nova + Relay + Sable
 - **Status**: Remediated in Gate 1 (react-scripts + PostCSS tooling added)

### B-003 (Critical): Plaintext passwords stored and returned; login performs plaintext match

- **Area**: Security/Auth
- **Evidence**:
  - `backend/routes/user.js` saves `{ username, email, password }` directly.
  - `backend/routes/user.js` login uses `User.findOne({ email, password })`.
  - Responses return the full user record (risk of returning password field).
- **Impact**: Severe security vulnerability; unacceptable for public launch; credential compromise risk; compliance risk.
- **Fix options**:
  - **Option A (minimal)**: Use `bcrypt` to hash on register; compare hash on login; omit password from responses.
    - **Pros**: Standard secure baseline.
    - **Cons**: Still missing JWT/session; still missing access control.
  - **Option B (best practice)**: Implement full auth stack (JWT + refresh tokens or session cookies), password policy, account lockout/rate limit, and security headers.
    - **Pros**: Launch-grade.
    - **Cons**: More moving parts; requires careful testing.
- **Impact assessment**:
  - Will require updating frontend login/register handling to store token/session.
  - Requires data migration plan if existing users already stored with plaintext passwords.
- **Validation**:
  - Passwords are never stored or returned in plaintext.
  - Login returns a token/session indicator.
  - Negative tests: invalid password, missing fields, rate-limit behavior.
- **Owner persona**: Sentinel + Forge + Sable
 - **Status**: Remediated in Gate 2 (bcrypt hashing, JWT access token, refresh token cookie; removed password field from model/JSON)

### B-004 (Critical): No authentication/authorization on task routes (data exposure)

- **Area**: Security/Data access control
- **Evidence**: `backend/routes/task.js` allows create/list without verifying user identity; `Task.find()` returns all tasks.
- **Impact**: Any user can read/write all tasks; public data leakage.
- **Fix options**:
  - **Option A (minimal)**: Add auth middleware and scope tasks to authenticated user (`Task.find({ user: req.user.id })`).
  - **Option B (best practice)**: Role-based access control (if needed), tenant scoping, input validation, audit logs.
- **Impact assessment**:
  - Frontend must attach auth token/cookie to API calls.
  - DB needs indexes on `{ user, dueDate, completed }` for performance.
- **Validation**:
  - Unauthorized requests fail with 401.
  - A user can only see their own tasks.
- **Owner persona**: Sentinel + Forge + Index + Sable
 - **Status**: Remediated in Gate 2 (task routes protected; all queries scoped to authenticated user)

### B-005 (High): Frontend API calls likely fail in dev due to missing proxy/base URL configuration

- **Area**: Frontend-Backend integration
- **Evidence**: `frontend/src/components/Login.js` and `Register.js` call relative `/api/...` but `frontend/package.json` has no `proxy`, and backend listens on port 5000 by default.
- **Impact**: In local dev, requests will hit the frontend dev server origin and likely 404; in production, requires reverse proxy alignment.
- **Fix options**:
  - **Option A**: Add `proxy` in `frontend/package.json` pointing to backend (dev-only).
  - **Option B**: Use environment-based API base URL and configure Axios instance.
- **Validation**:
  - Login/register succeed from the UI in local dev.
- **Owner persona**: Nova + Forge + Relay + Sable

### B-006 (High): No input validation or structured error handling in backend routes

- **Area**: Correctness/Resilience
- **Evidence**: Routes accept raw request bodies and assume success; no try/catch; no schema validation; inconsistent status codes.
- **Impact**: Unhandled errors, crashes, inconsistent API behavior, increased security risk.
- **Fix options**:
  - **Option A**: Add basic validation and centralized error middleware.
  - **Option B**: Introduce a validation layer (e.g., zod/joi) and consistent error response contract.
- **Validation**:
  - Invalid inputs return 400 with consistent structure.
  - Server remains stable under malformed requests.
- **Owner persona**: Forge + Sable

### B-007 (High): Docs do not match implementation (misleads development and QA)

- **Area**: Documentation correctness
- **Evidence**:
  - `docs/API.md` documents JWT and project endpoints not implemented in `backend/`.
  - `docs/DEPLOYMENT.md` refers to `api/` and `web/` directories, but repo uses `backend/` and `frontend/`.
  - `docs/DATABASE_ERD.md` describes entities (Project, Comment) not present in code.
- **Impact**: Execution errors, wasted time, wrong assumptions, broken deployments.
- **Fix options**:
  - **Option A**: Update docs to reflect current code and clearly mark unimplemented features.
  - **Option B**: Update code to match docs (adds significant scope: JWT, projects, comments).
- **Validation**:
  - Deployment and API docs correspond to real folders/endpoints/models.
- **Owner persona**: Quill + Atlas + Forge + Nova

### B-008 (High): Python `api/app/endpoints.py` is not integrated; tests are effectively skipped

- **Area**: Quality/Repo structure
- **Evidence**:
  - `api/app/endpoints.py` defines a FastAPI router.
  - `tests/test_endpoints.py` attempts `from endpoints import Endpoints` which does not exist, so tests skip.
- **Impact**: False confidence in “testing gate”; confusing mixed stack; dead code paths.
- **Fix options**:
  - **Option A**: Remove or quarantine the Python folder/tests if this project is Node/React only.
    - **Pros**: Reduces confusion.
    - **Cons**: Might discard intended platform integration work.
  - **Option B**: Properly integrate FastAPI app with a runnable entrypoint and correct tests.
    - **Pros**: Makes Python code meaningful.
    - **Cons**: Adds a second backend stack; increases ops complexity.
- **Validation**:
  - No skipped tests due to import mismatch.
  - Repository has a clear single backend runtime (or explicitly documented two-runtime architecture).
- **Owner persona**: Atlas + Sable + Forge (and optionally a Python backend persona if chosen)

### B-009 (Medium): No user relationship enforcement between Users and Tasks

- **Area**: Data integrity
- **Evidence**: `Task` has `user` ref, but create route accepts raw body; no enforcement that task.user equals authenticated user.
- **Impact**: Integrity issues; spoofing; inconsistent UI behavior.
- **Fix options**:
  - Always set `task.user = req.user.id` server-side; ignore client-provided user id.
- **Validation**:
  - Task ownership cannot be spoofed.
- **Owner persona**: Forge + Index + Sentinel

### B-010 (Medium): Missing production hardening defaults (CORS, security headers, rate limiting, logging)

- **Area**: Production readiness
- **Evidence**: No middleware visible for CORS/helmet/rate limit; minimal console logging.
- **Impact**: Increased attack surface and operational blind spots.
- **Fix options**:
  - Add `helmet`, `cors` with explicit origins, rate limiting on auth routes, request logging.
- **Validation**:
  - Security headers present, CORS configured, rate limiting verified, logs usable in ops.
- **Owner persona**: Relay + Sentinel + Forge

## Execution plan (requires CryptoLavar approval at each gate)

### Gate 0: Decide target architecture (approval)
Decide one of:
- **Path 1 (recommended)**: Single stack Node/Express backend + React frontend; remove/quarantine Python artifacts.
- **Path 2**: Dual backend (Node + FastAPI) with explicit boundaries and ops plan.

Deliverable: architecture decision note + updated backlog priorities.
Owner: Atlas (with CryptoLavar approval)

### Gate 1: Buildability baseline (Blockers first)
- Implement B-001 and B-002.
- Establish minimal run instructions that actually work.

Quality checks:
- Smoke tests (manual) for API and UI.
- Minimal automated check: start scripts and a health endpoint.

### Gate 2: Security baseline (Critical)
- Implement B-003 and B-004.
- Add B-006 essentials (validation + error handling) to avoid security bypasses.

Quality checks:
- Auth negative tests and access control tests.
- Ensure no password leakage in responses/logs.

### Gate 3: Integration correctness
- Implement B-005 and B-009.
- Confirm UI flows work end-to-end.

Quality checks:
- E2E happy path: register, login, create task, list tasks, logout.

### Gate 4: Documentation alignment
- Implement B-007 (docs reflect reality and clearly list unimplemented features).

### Gate 5: Test suite foundation (prevent regressions)
- Establish a test pyramid:
  - Backend: unit + integration (supertest)
  - Frontend: component tests (testing-library)
  - Optional: E2E (Playwright/Cypress)
- Target: build smoke tests + key regression suite first; coverage grows after stability.

### Gate 6: Launch hardening (performance/ops)
- Implement B-010 and any performance work required after profiling.
- Add monitoring hooks and operational runbook (CryptoLavar executes infra/deploy).

## Approval checklist (what I need from CryptoLavar before coding)

For each issue cluster (Buildability, Security, Integration, Docs, Tests):
- Approve **chosen fix option** (A vs B).
- Confirm **acceptable scope** and **timelines**.
- Confirm **data migration strategy** (especially for credentials).

<!-- Signed-off-by: Sable (QA Terminator - Bug Killer) -->


