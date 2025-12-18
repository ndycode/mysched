# ReminderDetailsSheet

## Purpose

- Shows reminder details in a sheet.
- Provides actions to toggle completion, snooze, edit, and delete.

Implementation: `lib/ui/kit/reminder_details_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from the reminders list:

- Source: `lib/screens/reminders/reminders_cards.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Reminder metadata:
  - title
  - details (if present)
  - due time/date
  - snooze state (if present)
- Actions:
  - toggle complete/pending
  - snooze
  - edit
  - delete

## States (loading/empty/error/offline) + how each appears

- Toggle busy state while completion is being updated.
- Errors are typically surfaced by the calling controller via snack bars.

## Primary actions + validation rules

- Toggle completion:
  - calls provided callbacks to update reminder status
- Snooze:
  - triggers a snooze duration picker, then applies snooze via controller
- Edit/delete:
  - edit opens `AddReminderSheet` in edit mode
  - delete requires confirmation (handled in the calling screen)

## Data dependencies (services/repos + Supabase tables if confirmable)

- Reminder mutations are performed by `RemindersApi` from the calling screen/controller:
  - `reminders` table

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Snoozing updates `due_at` and `snooze_until` on the reminder.

## Accessibility notes (only what you can confirm from code)

- Uses standard Material buttons and text; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ReminderDetailsSheet`.

## Related links (to other docs/latest pages)

- [Reminder snooze picker](reminder_snooze_sheet.md)
- [Reminders](reminders.md)

