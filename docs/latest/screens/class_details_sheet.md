# ClassDetailsSheet

## Purpose

- Shows details for a class (linked or custom).
- Allows enabling/disabling (non-instructor mode) and reporting schedule issues.

Implementation: `lib/ui/kit/class_details_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from:

- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/screens/schedules/schedules_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Class metadata:
  - title/code
  - day + time range
  - room
  - instructor details (when present)
- Actions:
  - Enable/disable toggle (disabled in instructor mode)
  - “Report schedule issue” action with an input prompt for optional notes

## States (loading/empty/error/offline) + how each appears

- Loads/derives details using `ScheduleApi.fetchClassDetails(...)`.
- Toggle busy state while enabling/disabling.
- Report busy state while submitting a report.
- Errors surface via snack bars and/or inline messages.

## Primary actions + validation rules

- Toggle enable/disable:
  - For linked classes, writes to `user_class_overrides`.
  - For custom classes, writes to `user_custom_classes.enabled`.
- Report schedule issue:
  - Submits a report to `class_issue_reports` with a snapshot payload (and optional note).

## Data dependencies (services/repos + Supabase tables if confirmable)

- `ScheduleApi` (`lib/services/schedule_repository.dart`)
  - Reads `classes` and/or `user_classes_v` for details
  - Writes `user_class_overrides` (linked classes)
  - Writes `class_issue_reports` (reporting)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Callers may resync alarms after enable/disable actions (`NotifScheduler.resync()`), depending on the invoking screen.
- Reporting writes a record intended for admin review.

## Accessibility notes (only what you can confirm from code)

- Uses standard buttons and labeled rows.
- `TODO:` Ensure content is readable with large text and screen readers.

## Tests (existing tests that cover it; if none, TODO)

- `test/ui/class_details_sheet_test.dart`

## Related links (to other docs/latest pages)

- [Schedules](schedules.md)
- [Backend](../backend.md)
- [Notifications](../notifications.md)

