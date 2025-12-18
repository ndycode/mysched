# BatteryOptimizationDialog

## Purpose

- Explains why battery optimization affects alarm reliability on Android.
- Guides users to adjust battery settings for MySched (“Unrestricted” / ignore optimizations).

Implementation: `lib/ui/kit/battery_optimization_sheet.dart`

## Entry points (routes/deeplinks/navigation)

Opened via `LocalNotifs.openBatteryOptimizationDialog(context)` from:

- `lib/app/bootstrap_gate.dart`
- `lib/screens/settings/settings_screen.dart`

## UI Anatomy (major sections; key components; sheets/dialogs)

- Dialog content explaining:
  - why battery optimization can break alarms
  - how to change settings
- Action buttons likely include:
  - open battery optimization settings (via `LocalNotifs.openBatteryOptimizationSettings(...)`)
  - close/dismiss

## States (loading/empty/error/offline) + how each appears

- No backend loading expected.

## Primary actions + validation rules

- No input validation; informational dialog with navigation to system settings.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Android method channel helpers in `LocalNotifs`:
  - `openBatteryOptimizationSettings(...)`
  - `getDeviceManufacturer()` (used elsewhere for OEM guidance)

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- May open Android system settings screens.

## Accessibility notes (only what you can confirm from code)

- Uses standard dialog patterns; ensure text is readable and scrollable on small screens.

## Tests (existing tests that cover it; if none, TODO)

- `TODO:` No direct widget test references found for `BatteryOptimizationDialog`.

## Related links (to other docs/latest pages)

- [Notifications](../notifications.md)
- [Settings](settings.md)

