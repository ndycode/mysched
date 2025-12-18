# Android Fullscreen Alarm (native)

## Purpose

- Displays a full-screen alarm UI when a class reminder fires on Android.
- Allows the user to dismiss or snooze the alarm.

Implementation: `android/app/src/main/java/com/ici/mysched/FullscreenAlarmActivity.java`

## Entry points (routes/deeplinks/navigation)

- Triggered by Android `AlarmReceiver` via a full-screen intent:
  - `android/app/src/main/java/com/ici/mysched/AlarmReceiver.java`
- Also reachable via “Launch alarm preview” in Settings (admin section), which schedules a short test alarm through the native channel.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Full-screen activity shown over lock screen (manifest enables `showWhenLocked` / `turnScreenOn`).
- Primary actions:
  - Dismiss
  - Snooze (duration derived from stored snooze minutes)
- Displays alarm metadata from intent extras:
  - subject/title
  - room
  - start/end labels
  - classId + occurrenceKey

## States (loading/empty/error/offline) + how each appears

- Activity has internal fallback auto-dismiss behavior (time-based).
- Uses a backup notification path if full-screen UI is blocked by system settings.

## Primary actions + validation rules

- Snooze duration:
  - read from shared prefs via `AlarmStore.readSnoozeMinutes(...)`
  - coerced to at least 1 minute
- Dismiss:
  - marks the occurrence as acknowledged and cancels the alarm state.

## Data dependencies (services/repos + Supabase tables if confirmable)

- SharedPreferences:
  - Reads from `FlutterSharedPreferences` (keys prefixed with `flutter.`)
    - `flutter.alarm_volume`
    - `flutter.alarm_ringtone`
    - `flutter.alarm_vibration`
- Alarm bookkeeping helpers:
  - `android/app/src/main/kotlin/com/ici/mysched/AlarmStore.kt`
  - `android/app/src/main/kotlin/com/ici/mysched/AlarmPrefsHelper.kt`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- Plays alarm sound and may vibrate (based on stored preferences).
- Can post “snoozed” feedback notifications.
- May route back into Flutter UI via `MainActivity` extras (e.g., “View reminders” action in the backup notification).

## Accessibility notes (only what you can confirm from code)

- `TODO:` Accessibility behavior is implemented in native Android layouts; validate content descriptions and focus order.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No automated tests for native alarm activity found in this repo.

## Related links (to other docs/latest pages)

- [Notifications](../notifications.md)
- [Settings](settings.md)

