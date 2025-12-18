# StudyTimerSheet

## Purpose

- Provides a Pomodoro-style focus timer with work/break cycles.
- Optionally links a timer session to a class (via `StudyTimerService` data model).

Implementation: `lib/screens/timer/study_timer_screen.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `showStudyTimerSheet(context)` from:

- `lib/app/root_nav.dart` (function exists; not currently listed in quick actions UI there)
- `lib/screens/dashboard/dashboard_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Modal sheet container (`AppModal.sheet`)
- Timer display:
  - remaining time (MM:SS)
  - progress visualization
  - session type label (work/short break/long break)
- Controls:
  - start / pause / resume
  - stop / reset
  - skip
- Configuration controls:
  - adjust work/break durations (based on `TimerConfig` usage in service)

## States (loading/empty/error/offline) + how each appears

- Timer states:
  - idle
  - running
  - paused
  - completed
- No backend loading required for basic timer usage.

## Primary actions + validation rules

- Timer durations are managed in minutes and converted to seconds internally.
- Completed sessions:
  - are recorded in-memory in `StudyTimerService.history`
  - are persisted to Supabase via `StudySessionRepository.saveSession(...)` (fire-and-forget) when authenticated

## Data dependencies (services/repos + Supabase tables if confirmable)

- `StudyTimerService` (`lib/services/study_timer_service.dart`)
- `StudySessionRepository` (`lib/services/study_session_repository.dart`) → writes `study_sessions`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Persists completed sessions to Supabase (when signed in).

## Accessibility notes (only what you can confirm from code)

- `TODO:` Confirm timer controls are accessible (tap targets, labels) and the timer display is readable with large text.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `StudyTimerSheet`.

## Related links (to other docs/latest pages)

- [Stats sheet](stats_sheet.md)
- [Backend](../backend.md)

