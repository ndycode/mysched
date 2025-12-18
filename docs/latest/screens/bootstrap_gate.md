# BootstrapGate (Splash)

## Purpose

- Provides the app’s initial splash/bootstrapping experience.
- Requests key permissions (camera + notifications) and prompts for Android alarm reliability settings.
- Validates the current auth session and routes the user to the correct next surface.

Implementation: `lib/app/bootstrap_gate.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter initial route: `/splash` (`lib/app/app_router.dart`)
- Navigates to:
  - `/welcome` when not signed in
  - `/app` when signed in
- Also performs session refresh via Supabase before deciding navigation.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Splash body: `AppScaffold` + `_SplashContent` (brand text + loader)
- Permission prompts:
  - Camera permission dialog (`permission_handler`)
  - Notification permission dialog (`permission_handler`)
- Android alarm readiness dialog:
  - “Enable reliable alarms” modal with status rows and deep links to system settings

## States (loading/empty/error/offline) + how each appears

- Loading: splash screen remains visible for a minimum duration and while prompts are handled.
- Permission denied: bootstrap continues, but features may be degraded; some prompts can route to system settings.
- Session invalid/stale: session refresh fails → forced `signOut()` → user is sent to `/welcome`.

## Primary actions + validation rules

- “Allow” / “Not now” decisions for permissions.
- “Open settings” actions to:
  - exact alarm permission
  - notification settings
  - battery optimization settings
  - full-screen intent settings (Android 14+)
  - OEM auto-start settings (best-effort)

## Data dependencies (services/repos + Supabase tables if confirmable)

- Supabase session state: `Env.supa.auth.currentSession`, `refreshSession()`
- Role/profile checks:
  - `InstructorService.checkInstructorStatus()` → reads `instructors` (by `user_id`)
  - `AuthService.isProfileComplete()` → reads `profiles` (student_id)
- Alarm scheduling:
  - `NotifScheduler.resync()` → uses schedule data + SharedPreferences
  - `LocalNotifs.alarmReadiness()` → Android method channel

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Requests camera + notification permissions.
- Triggers alarm readiness prompts on Android and may open system settings screens.
- Refreshes/invalidates auth session (may sign out).
- May resync class alarms after notification permission is granted.

## Accessibility notes (only what you can confirm from code)

- Uses standard Flutter `AlertDialog`/`Dialog` surfaces and labeled buttons.
- `TODO:` No explicit semantics annotations were found; validate with screen reader pass.

## Tests (existing tests that cover it; if none, TODO)

- `test/app_text_scaler_test.dart` toggles `BootstrapGate.debugBypassPermissions` for widget tests.
- `TODO:` Add focused widget tests for permission and routing decisions if you change bootstrap logic.

## Related links (to other docs/latest pages)

- [Architecture](../architecture.md)
- [Notifications](../notifications.md)
- [Configuration](../configuration.md)

