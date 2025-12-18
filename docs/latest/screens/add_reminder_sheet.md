# AddReminderSheet

## Purpose

- Creates or edits a reminder (task/assignment).
- Captures title, optional details, and due date/time.

Implementation: `lib/screens/reminders/add_reminder_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from:

- `lib/app/root_nav.dart` (Quick actions)
- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/screens/reminders/reminders_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Form fields:
  - Title (required)
  - Details/notes (optional)
  - Due date and time selection controls
- Primary action:
  - Create or save changes

## States (loading/empty/error/offline) + how each appears

- Saving state disables inputs and shows loading state on the submit button.
- Error state shows inline error messaging and/or snack bars depending on failure type.
- Offline:
  - Reminder mutations can queue via `OfflineQueue` inside `RemindersApi` (create/update).

## Primary actions + validation rules

- Title: required (non-empty after trimming).
- Save:
  - Create → inserts a `reminders` row (or queues if offline).
  - Edit → updates the existing row (or queues if offline).

## Data dependencies (services/repos + Supabase tables if confirmable)

- `RemindersApi` (`lib/services/reminders_repository.dart`)
  - Reads/writes `reminders`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Triggers reminder list refresh via controller + `DataSync`.
- `TODO:` Confirm whether reminder-specific local notifications are scheduled; current code clearly schedules class alarms on Android, but reminder notification scheduling is not clearly defined.

## Accessibility notes (only what you can confirm from code)

- Uses `TextFormField` validators and standard controls.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/add_reminder_page_test.dart`

## Related links (to other docs/latest pages)

- [Reminders](reminders.md)
- [Backend](../backend.md)

