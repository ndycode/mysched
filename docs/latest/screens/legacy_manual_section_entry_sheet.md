# ManualSectionEntrySheet (Unwired)

## Purpose

- Provides a manual fallback when OCR fails:
  - user searches/selects a section code
  - app loads classes for that section

Implementation: `lib/screens/scan/manual_section_entry_sheet.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` No confirmed call sites found for `ManualSectionEntrySheet.show(...)` in the current scan flow.
- Defined as a reusable sheet returning `ManualEntryResult`.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Text field for searching section codes
- Suggestions list (popular sections or filtered search results)
- Loading indicator while searching or loading classes
- Error text when class load fails

## States (loading/empty/error/offline) + how each appears

- Loads “popular sections” for the active semester.
- Search state shows a spinner while `_searching` is true.
- Selecting a section loads classes; failures show an inline error.

## Primary actions + validation rules

- Search triggers `.ilike('code', '%QUERY%')` against `sections` (active semester).
- Selecting a section loads `classes` for that `section_id` and returns the result.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `SemesterService` → reads `semesters` to find active semester ID
- `sections` (search + suggestions)
- `classes` joined with `instructors(...)` (to populate instructor name/avatar)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- None beyond Supabase reads.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate text field focus and list accessibility if this becomes user-facing.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `ManualSectionEntrySheet`.

## Related links (to other docs/latest pages)

- [Scan preview sheet](scan_preview_sheet.md)
- [Schedules preview sheet](schedules_preview_sheet.md)
- [Backend](../backend.md)

