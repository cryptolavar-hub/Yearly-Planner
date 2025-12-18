Copyright © 2024-2025 Q2O - Quick to Objective AI Development Platform
Created by: CryptoLavar (Project Architect & Developer) cryptolavar@gmail.com

<!-- Role: Atlas (Project Delivery Manager) -->

# 👥 Roles and Skillsets (Historical Snapshot - 2025-12-18)

[Back to root README](../../../README.md)  
[Back to docs index](../../README.md)  
[Back to History](README.md)

This document preserves an earlier roles/skillsets snapshot. The current workflow and roles are maintained in [docs/WORKFLOW.md](../../WORKFLOW.md).

## Original snapshot content (verbatim)

## Roles and Skillsets Required to Build and Launch Publicly

Scope covered:
- The **Yearly Planner** application contained in this repository.
- The surrounding **development/orchestration platform** evidenced by logs (referenced only via the copyright block above).

This is a requirements document: it describes what skills and roles are needed for a successful public launch, not necessarily what is already present in the codebase.

## Persona roster (the team I will direct under CryptoLavar)

Personas are role-hats I can switch between during phases. Each persona has a name and a mandate.

### Delivery and product

- **Atlas (Project Delivery Manager)**
  - **Mandate**: Own execution plan, sequencing, approvals, risk register, and timeline.
  - **Skills**: Roadmapping, estimation, dependency management, release planning, cross-functional coordination.
  - **Key outputs**: Milestones, sprint plans, issue register, decision log, approval gates.

- **Mercury (Product Owner)**
  - **Mandate**: Define MVP and acceptance criteria aligned to the objective: yearly planner, reminders, calendar view, todo/task list, modern UX.
  - **Skills**: Requirements, UX acceptance criteria, prioritization, metrics definition.
  - **Key outputs**: PRD, user stories, acceptance tests (written).

- **Lumen (UX/UI Designer)**
  - **Mandate**: Information architecture + modern look and feel with accessible UX.
  - **Skills**: IA, prototyping, responsive design, WCAG accessibility fundamentals, design systems.
  - **Key outputs**: Wireframes, component specs, user flows, accessibility checklist.

### Engineering (application)

- **Forge (Backend Engineer - Node/Express)**
  - **Mandate**: Build secure, correct REST API and data model for planner features.
  - **Skills**: Express, auth, validation, error handling, logging, REST design, performance basics.
  - **Key outputs**: Auth layer, CRUD endpoints, filtering/pagination, service structure.

- **Nova (Frontend Engineer - React)**
  - **Mandate**: Implement the web UI and integrate it correctly with the backend.
  - **Skills**: React, routing, state management, forms, API clients, Tailwind, accessibility basics.
  - **Key outputs**: Calendar UI, tasks UI, reminders UX, auth flows, loading/error states.

- **Index (Database Engineer - MongoDB)**
  - **Mandate**: Data model correctness, indexing, retention, and safe schema evolution.
  - **Skills**: MongoDB modeling, Mongoose, indexes, query analysis, backups, migrations strategy.
  - **Key outputs**: Schema design notes, index plan, backup/restore runbook, migration approach.

### Quality and security

- **Sable (QA Terminator - Bug Killer)**
  - **Mandate**: Prevent regressions and drive defect count to near-zero before launch.
  - **Skills**: Test planning, unit/integration/e2e strategy, test automation, reproducible bug reports, triage.
  - **Key outputs**: Test plan, automated test suites, bug tickets with repro steps and expected behavior.

- **Sentinel (Application Security Engineer)**
  - **Mandate**: Ensure launch-grade security for auth, data access, and API hardening.
  - **Skills**: OWASP Top 10, threat modeling, secure auth, secrets, dependency scanning, secure headers, rate limiting.
  - **Key outputs**: Threat model, security checklist, remediation plan, verification evidence.

### Operations and release

- **Relay (DevOps/SRE)**
  - **Mandate**: Make the system deployable, observable, and stable in production.
  - **Skills**: CI/CD, environment management, secrets, logging/metrics, TLS, reverse proxy, rollbacks.
  - **Key outputs**: Deployment runbook, CI pipeline plan, monitoring/alerting plan, rollback plan.

### Documentation and support

- **Quill (Technical Writer)**
  - **Mandate**: Ensure documentation matches reality and supports operations and onboarding.
  - **Skills**: Technical writing, runbooks, API docs, change logs.
  - **Key outputs**: Updated deployment docs, API docs, operator runbooks, session logs.

<!-- Signed-off-by: Atlas (Project Delivery Manager) -->


