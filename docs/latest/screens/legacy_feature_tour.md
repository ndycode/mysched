# FeatureTourScreen (Unwired)

## Purpose

- Presents a multi-step “feature tour” using predefined `TourSteps`.
- Persists completion state so the tour can be skipped on subsequent runs.

Implementation: `lib/screens/onboarding/feature_tour.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` This screen is not wired into `GoRouter` and no in-app navigation reference is confirmed in the current codebase.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Page-based tour UI with:
  - step title/description/icon
  - progress dots
  - Next/Skip actions

## States (loading/empty/error/offline) + how each appears

- Primarily static; completion state is stored locally.

## Primary actions + validation rules

- Completing the tour calls `OnboardingService.instance.completeTour()`.
- Skipping also completes the tour (per current implementation).

## Data dependencies (services/repos + Supabase tables if confirmable)

- Local storage via `OnboardingService` (SharedPreferences keys `onboarding_*`).

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Persists a “tour completed” flag locally.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate if this screen becomes user-facing.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `FeatureTourScreen`.

## Related links (to other docs/latest pages)

- [Contributing](../contributing.md)
- [Screens index](index.md)

