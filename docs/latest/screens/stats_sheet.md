# StatsSheet

## Purpose

- Displays aggregated study statistics derived from:
  - persisted `study_sessions` records (Supabase)
  - in-memory timer history (not yet persisted)

Implementation: `lib/screens/stats/stats_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `showStatsSheet(context)` from:

- `lib/screens/dashboard/dashboard_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal sheet container (`AppModal.sheet`)
- Summary metrics:
  - today/week/month minutes
  - session counts
  - streak information
- Chart visualization (based on `StatsService.dailyData`)

## States (loading/empty/error/offline) + how each appears

- Initial load calls `StatsService.refresh()` to fetch sessions.
- If no data exists, the sheet should show zeroed/empty metrics (based on service defaults).

## Primary actions + validation rules

- No destructive actions confirmed; primarily read-only metrics.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `StatsService` (`lib/services/stats_service.dart`)
- `StudySessionRepository` (`lib/services/study_session_repository.dart`) → reads `study_sessions`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Triggers a refresh of study session data on open.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate chart readability and contrast in light/dark/void themes.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `StatsSheet`.

## Related links (to other docs/latest pages)

- [Study timer sheet](study_timer_sheet.md)
- [Backend](../backend.md)

