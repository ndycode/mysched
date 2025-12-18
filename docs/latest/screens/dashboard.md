# DashboardScreen

## Purpose

- Provides a “home” overview of today/next items.
- Surfaces quick actions and shortcuts into schedules and reminders.
- Offers access to study timer and stats sheets.

Implementation: `lib/screens/dashboard/dashboard_screen.dart`

## Entry points (routes/deeplinks/navigation)

- Shown as tab index 0 inside `RootNav`.

## UI Anatomy (major sections; key components; sheets/dialogs)

Based on the current file structure and sheet invocations, the dashboard includes:

- Schedule summary cards (uses `ScheduleApi`)
- Reminder summary cards (uses `RemindersApi`)
- Quick actions:
  - Add class (`AddClassSheet`)
  - Add reminder (`AddReminderSheet`)
  - Scan schedule (scan flow)
  - Study timer (`StudyTimerSheet`)
  - Stats (`StatsSheet`)
- Class detail drill-in (`ClassDetailsSheet`)

## States (loading/empty/error/offline) + how each appears

`TODO:` The exact loading/empty visuals are implemented in dashboard card widgets; confirm exact states by reviewing `lib/screens/dashboard/dashboard_*` widgets.

## Primary actions + validation rules

- Opens sheets for add/edit flows and class details.
- Triggers study timer and stats sheets.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Schedule: `ScheduleApi` (tables/views documented in [Backend](../backend.md))
- Reminders: `RemindersApi` → `reminders`
- Class details: `ScheduleApi.fetchClassDetails()` → `classes`/`user_classes_v`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- May schedule/resync alarms after schedule changes (via other flows).
- `TODO:` No dashboard-specific telemetry events were identified beyond shared services.

## Accessibility notes (only what you can confirm from code)

- Uses standard Material widgets and custom UI kit components.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/dashboard_screen_test.dart`
- `test/screens/screens_render_test.dart` (renders DashboardScreen with fakes)

## Related links (to other docs/latest pages)

- [Screens index](index.md)
- [Notifications](../notifications.md)

