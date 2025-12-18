# Export Options Sheet (Legacy)

## Purpose

- Provides a legacy schedule export sheet focused on exporting as a PDF.

Implementation: `lib/ui/sheets/export_options_sheet.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` No references found to `showExportOptionsSheet(...)` in the current UI.
- Current schedules UI appears to use a different export implementation (`SchedulesController` → PDF/CSV share).

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal sheet with:
  - “Export as PDF” option
  - info text indicating only enabled classes are exported
  - inline error banner on failure

## States (loading/empty/error/offline) + how each appears

- Exporting state shows a spinner on the export option.
- If schedule is empty, shows an inline error (“No classes to export…”).

## Primary actions + validation rules

- Export as PDF:
  - loads classes via `ScheduleApi.getMyClasses()`
  - resolves user name via `ProfileCache`
  - reads active semester name via `SemesterService`
  - calls `ScheduleExportService.exportAndShare(...)`

## Data dependencies (services/repos + Supabase tables if confirmable)

- `ScheduleApi` (schedule data)
- `ProfileCache` (profile name/email)
- `SemesterService` (`semesters`)
- `ScheduleExportService` (PDF generation + system share)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Generates a PDF file in a temp directory and opens the system share sheet.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate if re-enabled.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for this legacy export sheet.

## Related links (to other docs/latest pages)

- [Schedules](schedules.md)
- [Deployment](../deployment.md)

