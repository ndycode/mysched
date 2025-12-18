# SchedulesPreviewSheet (Import Preview)

## Purpose

- Shows a grouped-by-day preview of OCR-extracted classes.
- Lets users disable specific classes before import.
- Imports either:
  - a linked section schedule (when section ID is known), or
  - a custom/manual schedule (fallback)

Implementation: `lib/screens/scan/schedule_import_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `AppModal.sheet(...)` after `ScanPreviewSheet` succeeds:

- `lib/app/root_nav.dart`
- `lib/screens/schedules/schedules_screen.dart`

Returns a `ScheduleImportOutcome` (imported or retake) to the caller.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Header: section metadata (and a semester badge)
- Day-grouped list of classes with enable/disable toggles
- Actions:
  - Import (runs `ScanService` import method)
  - Retake (returns `ScheduleImportOutcome.retake()`)
- Error area:
  - Inline error text + “Retry import” path (when import fails)

## States (loading/empty/error/offline) + how each appears

- Saving:
  - `_saving` true while import is executing
- Error:
  - `_error` set to error message string and shown in the UI
- Retake:
  - returns to caller so scan flow can restart capture/preview steps

## Primary actions + validation rules

- Toggle individual classes:
  - Disabled classes are skipped during import.
- Import:
  - If `section.id` is present, uses section import.
  - Otherwise imports all selected rows as custom classes.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `ScanService` (`lib/services/scan_service.dart`)
  - Section import writes:
    - `user_sections` (link user to section)
    - RPC `rescan_section` (`TODO:` definition not in repo)
    - `user_class_overrides` (disabled classes)
  - Custom import writes:
    - `user_custom_classes` (via `ScheduleApi.addCustomClass(...)`)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Clears prior schedule state before importing (calls `ScheduleApi.resetAllForCurrentUser()`).
- Invalidates schedule cache after import.
- Callers may show success snack bars and switch tabs after import.

## Accessibility notes (only what you can confirm from code)

- Uses toggles and grouped lists; `TODO:` ensure group headers and toggles are accessible.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `SchedulesPreviewSheet`.

## Related links (to other docs/latest pages)

- [Schedules](schedules.md)
- [Backend](../backend.md)
- [Notifications](../notifications.md)

