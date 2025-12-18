# SchedulesPage

## Purpose

- Displays the user’s weekly schedule grouped by day.
- Allows importing a schedule via scan, adding custom classes, exporting, and viewing class details.

Implementation: `lib/screens/schedules/schedules_screen.dart`

## Entry points (routes/deeplinks/navigation)

- Shown as tab index 1 inside `RootNav` (`SchedulesPage`).
- Also reachable indirectly via scan/import flow and quick actions overlay.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Header actions (based on the screen/controller responsibilities):
  - Open account (`/account`)
  - Scan schedule (scan flow)
  - Export schedule (PDF/CSV share)
  - Reset schedule (destructive)
- Day-grouped schedule list (cards from `schedules_cards.dart`)
- Sheets invoked:
  - `AddClassSheet` (add/edit custom class)
  - `ClassDetailsSheet` (view details + enable/disable + report issue)
  - `InstructorFinderSheet` (browse instructors + view schedules)
  - Scan flow: `ScanOptionsSheet` → `ScanPreviewSheet` → `SchedulesPreviewSheet`

## States (loading/empty/error/offline) + how each appears

- Loading and error states are driven by `SchedulesController` and UI helpers in `schedules_messages.dart`/`schedules_cards.dart`.
- Offline:
  - Schedule reads may fall back to cached schedule snapshots (`OfflineCacheService`).
  - Mutations can queue via `OfflineQueue` when offline.

## Primary actions + validation rules

- Add/edit custom class:
  - Title required
  - End time must be after start time
  - Overlap detection prompts the user before proceeding (conflict warning dialog)
- Export:
  - Supports PDF and CSV share payloads (implemented in `schedules_controller.dart` + `schedules_data.dart`)
- Toggle class enabled:
  - Performed through `ScheduleApi` (base classes) and `user_class_overrides`

## Data dependencies (services/repos + Supabase tables if confirmable)

- `ScheduleApi`:
  - Reads: `user_classes_v`, `user_custom_classes`, `user_sections`, `sections`, `semesters`
  - Writes: `user_class_overrides`, `user_custom_classes`, `user_sections`
- Class issue reports:
  - Writes: `class_issue_reports`
- Instructor finder:
  - Reads: `instructors`, `instructor_schedule`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- After schedule changes, the app may call `NotifScheduler.resync()` to regenerate class alarms (Android-only).
- Export uses `ShareService` and checks connectivity before sharing.

## Accessibility notes (only what you can confirm from code)

- Uses custom UI kit components; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `test/screens/schedules_page_test.dart`
- `test/screens/screens_render_test.dart` (renders SchedulesPage with fakes)
- `test/screens/schedules/schedules_controller_test.dart`

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Notifications](../notifications.md)
- [Screens index](index.md)

