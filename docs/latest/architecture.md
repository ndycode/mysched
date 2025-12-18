# Architecture

This document describes the current structure of the MySched Flutter app as implemented in `lib/` and the Android platform code in `android/`.

## High-level overview

- **UI**: Flutter screens under `lib/screens/**`, plus shared UI kit under `lib/ui/**`.
- **Navigation**: `go_router` with `MaterialApp.router` (`lib/app/app_router.dart`).
- **Backend**: Supabase (Auth, PostgREST, Storage, Edge Functions) initialized in `lib/env.dart`.
- **Offline behavior**:
  - Read caching: `OfflineCacheService` stores schedule snapshots in SharedPreferences.
  - Write queue: `OfflineQueue` stores mutations for later retry when online.
  - Broadcast: `DataSync` notifies screens to refresh.
- **Alarms/notifications (Android)**: custom exact-alarm scheduling via `MethodChannel('mysched/native_alarm')` (`lib/utils/local_notifs.dart`) and Android receivers/activities under `android/app/src/main`.

## App bootstrap sequence

Entry point: `lib/main.dart`

1) Sentry init (`SENTRY_DSN` via `String.fromEnvironment`; empty DSN = no-op).
2) `runZonedGuarded` installs Flutter and platform error handlers.
3) Splash screen is preserved via `flutter_native_splash`.
4) `Env.init()` loads configuration and initializes Supabase (`lib/env.dart`).
   - If Supabase config is missing, the app shows an error UI (`_ConfigErrorApp`).
5) Theme is loaded from local prefs (`ThemeController.instance.init()`).
6) Splash is removed and the app runs `MySchedApp` (router-based).
7) Deferred init (runs while app is visible):
   - `ConnectionMonitor.startMonitoring()`
   - `OfflineQueue.init()` (background)
   - `ReminderScopeStore.initialize()` (background)
   - `NavigationChannel.init()` (background, receives Android navigation intents)
   - `DataSync.init()` (background)
   - `AppTimeFormat.init()`
   - `UserSettingsService.instance.init()`

## Navigation and routing

- Router: `lib/app/app_router.dart` (`GoRouter`)
- Initial route: `/splash` -> `BootstrapGate`
- The main authenticated shell is `/app` -> `RootNav` (bottom navigation).

Some route constants exist in `lib/app/routes.dart` but are not wired into `GoRouter` (e.g., `/timer`, `/stats`, `/onboarding`, `/shared/:code`). Treat them as **not currently routable** unless you add routes.

## Auth and role gating

`BootstrapGate` (`lib/app/bootstrap_gate.dart`) performs:

- Minimum splash display delay.
- Permission flow: camera and notifications (via `permission_handler`).
- Android alarm readiness prompt (exact alarms, notifications, full-screen intent on Android 14+, battery optimizations, OEM auto-start guidance).
- Session validation:
  - Checks for an existing Supabase session and attempts `refreshSession()`.
  - If refresh fails, forces `signOut()` to avoid stale-session loops.
- Role detection:
  - `InstructorService.checkInstructorStatus()` queries `instructors.user_id`.
- Profile completion check:
  - `AuthService.isProfileComplete()` (student_id presence).
  - Additionally, `RootNav` independently prompts for missing student ID via `StudentIdPromptSheet`.

## Service layer and data flow

Common patterns:

- Services are often singletons (`*.instance`) using `ChangeNotifier`/`ValueNotifier` for reactive state.
- Supabase access:
  - Some services use `Env.supa` (after `Env.init()`).
  - Others access `Supabase.instance.client` directly.

Key services:

- `AuthService` (`lib/services/auth_service.dart`): Supabase Auth + profile bootstrap in `profiles`, avatar upload to Storage bucket `avatars`, account deletion via Edge Function `delete_account` (definition not in this repo).
- `ScheduleApi` (`lib/services/schedule_repository.dart`): loads schedule from `user_classes_v` + `user_custom_classes` + `user_class_overrides`.
- `RemindersApi` (`lib/services/reminders_repository.dart`): CRUD for `reminders`.
- `NotifScheduler` (`lib/services/notification_scheduler.dart`): Android-only alarm resync/snooze; delegates to `LocalNotifs`.
- `UserSettingsService` (`lib/services/user_settings_service.dart`): stores settings locally and syncs to Supabase `user_settings`.
- `AdminService` (`lib/services/admin_service.dart`): checks `admins` table; reads `class_issue_reports` and writes `audit_log`.

## Offline behavior

- Connectivity: `ConnectionMonitor` polls DNS (`dns.google`) and exposes `ConnectionState` via a `ValueNotifier`.
- Queued writes:
  - `OfflineQueue` stores queued mutations in SharedPreferences (`offline_mutation_queue_v1`).
  - Mutations are executed via a handler registry (`OfflineQueue.registerHandler`) when online.
- Cached reads:
  - `OfflineCacheService` stores schedule snapshots (`offline_schedule_v1`) keyed by user ID.

## Telemetry and logging

- `TelemetryService` records events through a pluggable recorder installed in `main.dart` (currently logs to `AppLog`).
- `TelemetryService.logError` forwards exceptions to Sentry (if DSN configured).

## Related

- Backend objects: [Backend](backend.md)
- Alarm/notification system: [Notifications](notifications.md)
- Screen-level docs: [Screens index](screens/index.md)

