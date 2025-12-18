# AppShell (Legacy)

## Purpose

- Shows a temporary loading shell and redirects into `/app` with a reminder scope.

Implementation: `lib/screens/app_shell.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` No GoRouter route is registered for `AppShell` in `lib/app/app_router.dart`.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Screen shell with a hero card (“Loading MySched”) and skeleton content.

## States (loading/empty/error/offline) + how each appears

- Intended as a short-lived loading placeholder.

## Primary actions + validation rules

- On first frame, calls `context.go('/app', extra: {'reminderScope': ...})`.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Reads `ReminderScopeStore.instance.value` (local state).

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Navigates immediately; no other confirmed side effects.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate if re-enabled.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `AppShell`.

## Related links (to other docs/latest pages)

- [RootNav](root_nav.md)
- [Screens index](index.md)

