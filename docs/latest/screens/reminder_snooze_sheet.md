# ReminderSnoozeSheet

## Purpose

- Presents common snooze duration options for a reminder.
- Returns a `Duration` to the caller, which then applies the snooze.

Implementation: `lib/screens/reminders/reminders_messages.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet<Duration>(...)` from `RemindersPage`:

- Source: `lib/screens/reminders/reminders_screen.dart` (`_snoozeReminder`)

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- List of duration options (e.g., minutes/hours) with descriptive labels
- Cancel/close affordance

## States (loading/empty/error/offline) + how each appears

- No network loading expected; options are static.

## Primary actions + validation rules

- Selecting an option returns a `Duration` (non-null) to the caller.
- Cancel returns null to the caller.

## Data dependencies (services/repos + Supabase tables if confirmable)

- None directly; the caller uses `RemindersApi` to persist snooze.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- None directly in this sheet.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Confirm that option rows are keyboard/screen-reader accessible.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `ReminderSnoozeSheet`.

## Related links (to other docs/latest pages)

- [Reminders](reminders.md)
- [Backend](../backend.md)

