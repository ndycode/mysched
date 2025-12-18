# Android “Next Class” Widget (native)

## Purpose

- Provides a home screen widget that displays the next upcoming class.

Implementation:

- Widget provider: `android/app/src/main/kotlin/com/ici/mysched/widget/NextClassWidgetProvider.kt`
- Flutter-side updater: `lib/services/widget_service.dart`

## Entry points (routes/deeplinks/navigation)

- User adds the widget from the Android launcher/widget picker.
- Tapping the widget launches `MainActivity` with an intent `data` URI:
  - `mysched://schedule/today`

`TODO:` The Flutter router does not define a `/schedule/today` route in `GoRouter`. Deep link handling for this path is not confirmed.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Displays:
  - class title (code + title)
  - relative start time (“Starts in …”)
  - optional room
  - optional instructor
- Empty state:
  - “No upcoming classes”

## States (loading/empty/error/offline) + how each appears

- Widget reads cached values from SharedPreferences and renders last known state.

## Primary actions + validation rules

- No direct user input; click opens the app.

## Data dependencies (services/repos + Supabase tables if confirmable)

Native widget expects:

- Preferences file: `NextClassWidgetPrefs`
- Keys like:
  - `class_title`, `class_code`, `start_time`, `end_time`, `room`, `instructor`, `has_class`

Flutter `WidgetService` currently:

- Computes next class by calling `ScheduleApi.getMyClasses()` (Supabase-backed schedule)
- Writes values via `SharedPreferences.getInstance()` and uses keys prefixed with `NextClassWidgetPrefs_...`
- Invokes `MethodChannel('com.ici.mysched/widget').invokeMethod('updateWidget')`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- No permissions required for the widget itself.
- Uses schedule data access, which requires an authenticated user and Supabase configuration.

## Known gaps / TODOs (important)

Based on code in this repo:

- The native widget reads a dedicated preferences file (`NextClassWidgetPrefs`), but Flutter `shared_preferences` writes into `FlutterSharedPreferences` by default.
- The method channel `com.ici.mysched/widget` is invoked by Flutter, but no native channel handler is present in `android/` in this repo.

`TODO:` Align the data handoff strategy (shared prefs file + keys, or implement a native channel that writes into the expected prefs and calls `NextClassWidgetProvider.updateWidget(...)`).

## Accessibility notes (only what you can confirm from code)

- `TODO:` Validate widget layout for font scaling and contrast.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No automated tests for native widget plumbing found in this repo.

## Related links (to other docs/latest pages)

- [Backend](../backend.md)
- [Schedules](schedules.md)

