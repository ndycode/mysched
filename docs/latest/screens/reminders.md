# RemindersPage

## Purpose

- Provides a task/reminder list with scopes (e.g., “all” by default).
- Supports add/edit/delete, snooze, and completion toggling.

Implementation: `lib/screens/reminders/reminders_screen.dart`

## Entry points (routes/deeplinks/navigation)

- Shown as tab index 2 inside `RootNav`.
- GoRouter route: `/reminders` (supports `?scope=<scopeName>`).
- Native alarms can route users into reminders via `NavigationChannel` + `openReminders()` (see `lib/services/navigation_channel.dart` and `lib/utils/nav.dart`).

## UI Anatomy (major sections; key components; sheets/dialogs)

- Header actions:
  - Open account (`/account`)
  - Add reminder (`AddReminderSheet`)
  - Filter/scope selection (driven by `ReminderScope`)
- Reminder list (cards built in `reminders_cards.dart`)
- Sheets/modals:
  - `AddReminderSheet` (create/edit)
  - `ReminderDetailsSheet` (view + toggle complete + edit/delete/snooze actions)
  - `ReminderSnoozeSheet` (choose snooze duration)
- Confirmations:
  - Delete reminder (danger confirm)
  - Reset reminders (danger confirm)

## States (loading/empty/error/offline) + how each appears

- Loading/error messaging is driven by `RemindersController` and helpers in `reminders_messages.dart`.
- Offline:
  - Mutations can queue via `OfflineQueue` when offline (create/update/toggle/snooze/delete).

## Primary actions + validation rules

- Create reminder:
  - Title required (client-side).
  - Due date/time chosen in the sheet.
- Toggle completed:
  - Updates status and completion timestamp.
- Snooze:
  - Updates `due_at` and `snooze_until` on the reminder.
- Delete/reset:
  - Requires confirmation prompts.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `RemindersApi`:
  - Reads/writes: `reminders`
- Profile loading (account header actions):
  - Reads: `profiles` (via `RemindersController.loadProfile(...)`)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- `TODO:` The reminders feature refers to “scheduled notifications” in user prompts, but class alarms are primarily handled by the Android exact-alarm system documented in [Notifications](../notifications.md). Confirm any reminder-specific local notifications before claiming behavior.

## Accessibility notes (only what you can confirm from code)

- Uses standard Material widgets + custom UI kit components; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/reminders_page_test.dart`
- `test/screens/screens_render_test.dart` (renders RemindersPage with fakes)

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Notifications](../notifications.md)
- [Screens index](index.md)

