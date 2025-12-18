# AddClassSheet

## Purpose

- Creates or edits a **custom class** (manual schedule entry).
- Validates time ranges and warns about conflicts with existing classes.

Implementation: `lib/screens/schedules/add_class_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` from:

- `lib/app/root_nav.dart` (Quick actions → “Add custom class”)
- `lib/screens/dashboard/dashboard_screen.dart`
- `lib/screens/schedules/schedules_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- “Class details” card:
  - Title (required)
  - Room (optional)
- “Schedule” card:
  - Day picker
  - Start time picker
  - End time picker
- Submit/cancel controls:
  - Save button (disabled while submitting)
  - Close/cancel actions
- Conflict warning dialog:
  - Triggered when overlap is detected (`showConflictWarningDialog(...)` in `lib/utils/conflict_dialog.dart`)

## States (loading/empty/error/offline) + how each appears

- Submitting: disables inputs and shows loading state on the primary action.
- Validation errors:
  - Inline field validators (e.g., “Required”)
  - Form-level error banner for time range (“End time must be after start time.”)
- Conflict detected:
  - Modal dialog warns about overlaps; user can cancel or “Add Anyway”.
- Offline:
  - Custom class mutations may be queued via `OfflineQueue` (handled by `ScheduleApi`).

## Primary actions + validation rules

- Title: required (non-empty after trimming).
- Time range: end must be after start.
- Overlap: if conflicts exist, user must confirm to proceed.
- Save:
  - Creates or updates a custom class via `ScheduleApi`.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `ScheduleApi` (`lib/services/schedule_repository.dart`)
  - Writes `user_custom_classes`
  - May queue mutations while offline (`OfflineQueue`)
- Conflict detection:
  - `lib/utils/schedule_overlap.dart` and `lib/utils/conflict_dialog.dart`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Schedule changes cause schedule cache invalidation and UI refresh.
- Alarm resync is triggered by callers in some flows (`NotifScheduler.resync()`), not by the sheet itself.

## Accessibility notes (only what you can confirm from code)

- Uses standard `TextFormField` validation and tappable rows for pickers.
- `TODO:` Validate focus order and tap targets in a11y audit.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/add_class_page_test.dart`
- `test/screens/add_class_day_picker_test.dart`

## Related links (to other docs/latest pages)

- [Schedules](schedules.md)
- [Notifications](../notifications.md)
- [Backend](../backend.md)

