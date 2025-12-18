# Notifications & Alarms (Android)

MySched implements **Android exact alarms** for class reminders, plus fallback notifications.

## Key concepts

- **Class reminders**: generated from the user’s enabled classes.
- **Lead time**: the reminder fires `leadMinutes` before class start.
- **Heads-up pre-alert**: a “heads-up only” alert may be scheduled 1 minute before the main alarm.
- **Quiet week**: disables scheduling while enabled.
- **Snooze**: reschedules a one-off alarm for `minutes` in the future.

## Where the logic lives

- Scheduler: `lib/services/notification_scheduler.dart` (`NotifScheduler`)
- Flutter notification wrapper: `lib/utils/local_notifs.dart` (`LocalNotifs`)
- Android native implementation:
  - Method channel target: `android/app/src/main/kotlin/com/ici/mysched/MainActivity.kt`
  - Receivers/activities/services:
    - `android/app/src/main/java/com/ici/mysched/AlarmReceiver.java`
    - `android/app/src/main/java/com/ici/mysched/HeadsUpReceiver.java`
    - `android/app/src/main/java/com/ici/mysched/FullscreenAlarmActivity.java`
    - `android/app/src/main/java/com/ici/mysched/AlarmForegroundService.java`
    - `android/app/src/main/java/com/ici/mysched/BootReceiver.java`

## Scheduling behavior (current)

### Resync

`NotifScheduler.resync()` (Android-only) will:

1) Load preferences (SharedPreferences) and migrate legacy keys.
2) If `app_notifs` or `class_alarms` is disabled, or `quiet_week_enabled` is enabled:
   - Cancel tracked native alarms and exit.
3) Fetch the current user ID.
4) Verify exact alarm capability (`LocalNotifs.canScheduleExactAlarms()`).
5) Load enabled classes via `ScheduleApi.getMyClasses()`.
6) Build the next occurrences per class and schedule:
   - A “heads-up only” alarm ~1 minute before the main alarm (when applicable)
   - The main alarm at `classStart - leadMinutes`
7) Track scheduled IDs in SharedPreferences (`scheduled_native_alarm_ids` scoped by user).

### Snooze

`NotifScheduler.snooze(classId, minutes: ...)` will:

- Cancel any existing scheduled alarms for the class.
- If exact alarms are unavailable or quiet week is enabled:
  - Show a local “snoozed” feedback notification (non-exact).
- Otherwise schedule a one-off exact alarm for `now + minutes`.

## Permissions & device settings

MySched guides users through multiple Android settings for reliability:

- Notification permission (Android 13+)
- Exact alarm permission (Android 12+ / API 31+)
- Full-screen intent permission (Android 14+ / API 34+)
- Battery optimization exclusions (“Unrestricted” recommended)
- OEM auto-start settings (best-effort; device/manufacturer dependent)

The initial prompt happens in `BootstrapGate` (`lib/app/bootstrap_gate.dart`) using `LocalNotifs.alarmReadiness()` and related helpers.

## AndroidManifest permissions (present in this repo)

From `android/app/src/main/AndroidManifest.xml`:

- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`
- `USE_FULL_SCREEN_INTENT`
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `WAKE_LOCK`
- Foreground service permissions for alarm delivery

## User settings affecting alarms

Key settings stored in SharedPreferences / `user_settings` sync include:

- `class_alarms` (enable/disable)
- `app_notifs` (enable/disable)
- `quiet_week_enabled` (enable/disable)
- `notifLeadMinutes` (lead time)
- `snoozeMinutes` (snooze duration)
- `alarm_volume`, `alarm_vibration`, `alarm_ringtone`
- DND window settings (`dnd_*`) exist in settings sync; confirm how they’re enforced before claiming behavior.

## QA checklist (derived from code)

- Toggle `class_alarms` off/on and confirm resync cancels/recreates alarms.
- Enable “quiet week” and confirm alarms are canceled and not rescheduled.
- On Android 12+ devices, verify exact alarm permission flow works.
- On Android 14+ devices, verify full-screen intent settings prompt works.
- Verify battery optimization guidance appears when not optimized.
- Trigger “Launch alarm preview” from Settings (admin section) to confirm native fullscreen UI and snooze/dismiss behavior.
- Reboot device and confirm alarms are rehydrated (BootReceiver path).

## Known gaps / TODOs

- `READ_CALENDAR`/`WRITE_CALENDAR` permissions exist in the manifest, but calendar sync usage is not confirmed in the current Dart code (`TODO:` confirm or remove).

