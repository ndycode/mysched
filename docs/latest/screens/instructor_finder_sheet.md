# InstructorFinderSheet

## Purpose

- Helps users find instructors relevant to their department(s).
- Allows viewing an instructor’s schedule (active semester) in-app.

Implementation: `lib/ui/kit/instructor_finder_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened from `SchedulesPage` via `AppModal.sheet(...)`:

- Source: `lib/screens/schedules/schedules_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal container: `ModalShell`
- Instructor list:
  - Fetches instructors by department and groups them (last-name initial grouping)
  - Includes search/filter UI
- Instructor details panel:
  - Displays selected instructor’s schedule (from `instructor_schedule`)

## States (loading/empty/error/offline) + how each appears

- Loading:
  - Initial instructor list load
  - Schedule load for selected instructor
- Empty:
  - “No instructors found” / “No matching instructors” states appear when lists are empty
- Errors are handled conservatively (fallback to empty lists on failure).

## Primary actions + validation rules

- Select an instructor → fetch schedule
- Search/filter → updates visible list (client-side filtering)

## Data dependencies (services/repos + Supabase tables if confirmable)

- Reads user sections:
  - `user_sections` joined with `sections(code)` to infer department
- Instructor directory:
  - `instructors` (filtered by `department`)
- Instructor schedule:
  - `instructor_schedule` view (filters `semester_active = true`)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- No confirmed side effects beyond Supabase reads.

## Accessibility notes (only what you can confirm from code)

- Uses standard list controls; `TODO:` validate grouping and search affordances with screen reader.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `InstructorFinderSheet`.

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Schedules](schedules.md)

