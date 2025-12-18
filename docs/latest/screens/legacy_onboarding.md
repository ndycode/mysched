# OnboardingScreen (Unwired)

## Purpose

- Provides a lightweight onboarding flow focused on:
  - explaining app value
  - requesting camera + notification permissions

Implementation: `lib/screens/onboarding/onboarding_screen.dart`

## Entry points (routes/deeplinks/navigation)

- `TODO:` This screen is not wired into `GoRouter` in `lib/app/app_router.dart`.
- A route constant exists (`/onboarding` in `lib/app/routes.dart`) but is not registered.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Paged onboarding cards (PageView)
- Permissions step requests:
  - camera permission
  - notification permission (Android)

## States (loading/empty/error/offline) + how each appears

- Permission request state shows a loading label (“Enabling...”).
- If permissions are denied, shows a snack bar prompting the user to allow them.

## Primary actions + validation rules

- “Next” / “Enable & continue” buttons advance or request permissions.
- “Skip” calls `onFinished` without forcing permissions.

## Data dependencies (services/repos + Supabase tables if confirmable)

- `permission_handler` for permission requests.

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Requests system permissions.

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate with screen reader and large-text scaling if you re-enable this screen.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct tests found for `OnboardingScreen`.

## Related links (to other docs/latest pages)

- [Architecture](../architecture.md)
- [Notifications](../notifications.md)
- [Screens index](index.md)

