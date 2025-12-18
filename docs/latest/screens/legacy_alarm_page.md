# AlarmPage (Legacy)

## Purpose

- Provides an informational screen explaining class reminder behavior and includes an alarm preview mock.

Implementation: `lib/screens/reminders/reminders_info_screen.dart` (`AlarmPage`)

## Entry points (routes/deeplinks/navigation)

- `TODO:` No GoRouter route or in-app navigation reference is confirmed for this screen in the current codebase.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Screen shell layout with:
  - live preview mock
  - explanatory text about alarm scheduling
  - a button to open a fullscreen mock overlay

## States (loading/empty/error/offline) + how each appears

- Primarily static content.

## Primary actions + validation rules

- Opens a mock full-screen overlay for demonstration.

## Data dependencies (services/repos + Supabase tables if confirmable)

- None directly; uses UI kit mock widgets.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- None confirmed (mock only).

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate if this screen becomes user-facing.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `AlarmPage`.

## Related links (to other docs/latest pages)

- [Notifications](../notifications.md)
- [Screens index](index.md)

