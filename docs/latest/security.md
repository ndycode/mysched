# Security

This document summarizes security-relevant behavior that can be confirmed from the current codebase.

## Threat model (high level)

MySched handles:

- Authenticated user data (Supabase Auth tokens)
- Personal profile fields (e.g., name, email, student ID)
- Schedules and reminders
- Android alarm scheduling and notification surfaces

Primary risks:

- Leaked configuration (Supabase URL/key, Sentry DSN)
- Over-broad data access if RLS is misconfigured
- PII leakage via logs or crash reports
- Unsafe storage rules for avatar uploads

## Authentication and authorization

- Auth is Supabase Auth (`supabase_flutter`).
- API access in the app is done via Supabase client using the anon key.
- `TODO:` RLS policies are not fully captured in this repo; ensure DB tables are protected by appropriate RLS and Storage policies.

## Secrets handling

- The app loads Supabase credentials from `.env` (asset) or `--dart-define` (`lib/env.dart`).
- Avoid committing real credentials. Prefer injecting via CI secrets for release builds.

## Crash reporting (Sentry)

- Sentry is initialized in `lib/main.dart` and is disabled when `SENTRY_DSN` is empty.
- The app sets `sendDefaultPii = false`.

## Logging and PII

- `TelemetryService` records events to an installed recorder (currently `AppLog` in `main.dart`) and forwards errors to Sentry.
- `TODO:` Audit log payloads to ensure no student IDs or other sensitive fields are emitted to logs/crash reports unintentionally.

## Vulnerability reporting

`TODO:` Add a public security contact (email or issue template). Until then:

- For private disclosures, define a maintainer contact and response SLA.
- For OSS distribution, add a `SECURITY.md` at repo root (if desired) and reference it here.

