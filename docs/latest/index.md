# MySched Mobile App Documentation (Latest)

This documentation bundle describes the **current state of the MySched Flutter mobile app** in this repository.

- App: **MySched** (`pubspec.yaml`: `name: mysched`)
- Source of truth: **current source code in `lib/`, plus platform code in `android/`**
- Commit: `21161727d2535f4a7d078612c9f2db3620162939`
- Last generated: 2025-12-18

## What is MySched?

MySched is an OCR-based mobile app that helps students generate a class schedule and receive reminders/alarms so they don’t miss classes. The repository includes:

- Flutter UI + services (`lib/`)
- Android native alarm + widget plumbing (`android/`)
- Supabase schema/migrations used by the app (`schema.sql`, `supabase/migrations/`)

## How to use these docs

- New developer setup: [Getting started](getting-started.md)
- App structure and data flow: [Architecture](architecture.md)
- Runtime configuration and secrets: [Configuration](configuration.md)
- Supabase backend objects referenced by the app: [Backend](backend.md)
- Alarm + notification behavior (Android): [Notifications](notifications.md)
- Test guidance: [Testing](testing.md)
- Build/release notes (including Shorebird config): [Deployment](deployment.md)
- Security posture: [Security](security.md)
- Privacy notes: [Privacy](privacy.md)
- Project contribution workflow: [Contributing](contributing.md)

## Screen inventory

The authoritative screen catalog (routes + major sheets) lives in:

- [Screens index](screens/index.md)

## Accuracy rules (important)

- These docs are derived from the current codebase. If something can’t be confirmed from code/config in this repo, it is labeled as `TODO:`.
- Legacy/reference docs may exist under `docs/legacy/reference/` and `docs/legacy/audit/`, but this `docs/latest/` bundle is intended to match the **current implementation**.

## Open questions snapshot

Some backend objects are referenced in code but are not defined in `schema.sql` or `supabase/migrations/` in this repo:

- RPCs: `is_student_id_available`, `rescan_section`, `set_class_deleted`
- Views/tables: `user_classes_v`, `user_schedule_view`, `schedule_shares`
- Edge Function: `delete_account`

Details and tracking live in: `docs/latest/_meta/report.md`.
