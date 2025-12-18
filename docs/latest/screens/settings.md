# SettingsPage

## Purpose

- Central configuration UI for appearance, notifications/alarms, and support/admin tools.
- Syncs user preferences locally and (when signed in) to Supabase.

Implementation: `lib/screens/settings/settings_screen.dart`

## Entry points (routes/deeplinks/navigation)

- Shown as tab index 3 inside `RootNav`.

## UI Anatomy (major sections; key components; sheets/dialogs)

Based on the current implementation, Settings includes:

- Appearance settings:
  - theme mode (light/dark/void/system)
  - accent color
  - time format (24h)
  - haptics
- Notifications and alarm settings:
  - class alarms toggle
  - app notifications toggle
  - quiet week toggle
  - lead time and snooze duration
  - alarm volume/vibration/ringtone pickers (Android)
  - alarm readiness status and deep links to system settings (Android)
- Support:
  - resync class reminders (`NotifScheduler.resync`)
  - About and Privacy (shown via `AppModal.legalWidget` content builders in this screen)
  - sign out
- Admin (only when admin role is present):
  - class issue reports (`IssueReportsScreen`)
  - send test heads-up notification
  - verbose logging toggle
  - launch native alarm preview

## States (loading/empty/error/offline) + how each appears

- Many toggles are instant; failures are typically shown via snack bars.
- Some sections show “unknown/blocked” states for Android readiness checks based on `LocalNotifs.alarmReadiness()`.

## Primary actions + validation rules

- Toggling settings persists locally and syncs to Supabase (see `UserSettingsService`).
- “Resync class reminders” regenerates alarms on Android.
- “Launch alarm preview” schedules a short test alarm via native channel (admin section).

## Data dependencies (services/repos + Supabase tables if confirmable)

- Local preferences:
  - SharedPreferences keys defined in `lib/app/constants.dart`
- Cloud sync:
  - `user_settings` via `UserSettingsService`
- Admin surfaces:
  - `admins`, `class_issue_reports`, `audit_log`
- Android alarm readiness:
  - `LocalNotifs` method channel + native code

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Resyncing can cancel and reschedule a large set of alarms (Android).
- Opening settings may trigger system intents (exact alarms, notifications, battery optimization, full-screen intent).

## Accessibility notes (only what you can confirm from code)

- Uses custom settings rows + Material controls; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `test/settings_test.dart`
- `test/screens/settings_page_test.dart`
- `test/screens/screens_render_test.dart` (renders SettingsPage)

## Related links (to other docs/latest pages)

- [Configuration](../configuration.md)
- [Notifications](../notifications.md)
- [Security](../security.md)
- [Screens index](index.md)

