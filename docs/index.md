# MySched Documentation

This `docs/` folder contains documentation for the **MySched Flutter mobile app**.

## Current docs (recommended)

The up-to-date, code-derived documentation lives under `docs/latest/`.

- Start here: [Latest docs index](latest/index.md)
- Screen catalog: [Screens index](latest/screens/index.md)

## Legacy docs (historical)

These folders pre-date `docs/latest/` and may not reflect the current implementation.

- `docs/legacy/reference/` — older reference docs (architecture/API/security/design)
- `docs/legacy/audit/` — older screen/component specs
- `docs/legacy/reports/` — point-in-time reports and reviews

## Layout

```
docs/
  index.md
  latest/
  legacy/
```

## Quick links

### Latest (source of truth)

| Document | Description |
|----------|-------------|
| [Documentation home](latest/index.md) | Scope, entry points, and navigation |
| [Getting started](latest/getting-started.md) | Prereqs, install, configure, run |
| [Architecture](latest/architecture.md) | Bootstrap, navigation, services, data flow |
| [Configuration](latest/configuration.md) | Env vars/secrets and how config loads |
| [Backend](latest/backend.md) | Supabase objects referenced by the app |
| [Notifications](latest/notifications.md) | Reminders/alarms, timezones, permissions |
| [Testing](latest/testing.md) | Test commands and patterns |
| [Deployment](latest/deployment.md) | Build/release notes (incl. Shorebird) |
| [Security](latest/security.md) | Threat model + secure defaults |
| [Privacy](latest/privacy.md) | Data handling notes (code-confirmed) |
| [Contributing](latest/contributing.md) | Style + workflow + doc updates |

### Legacy (may be outdated)

| Location | Notes |
|----------|-------|
| [Reference docs](legacy/reference/ARCHITECTURE.md) | Older design/technical reference docs |
| [Audit index](legacy/audit/index.md) | Older screen/component specs |
| [Code review report](legacy/reports/CODE_REVIEW_REPORT.md) | Snapshot review notes (may be stale) |

## Root-level documentation

These files remain at the project root per convention:

| File | Purpose |
|------|---------|
| `README.md` | Project overview and quick start |
| `CHANGELOG.md` | Version history and release notes |
| `AGENTS.md` | Agent configuration |
