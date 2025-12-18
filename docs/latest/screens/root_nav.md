# RootNav (Main App Shell)

## Purpose

- Hosts the main authenticated app experience with bottom navigation tabs.
- Provides a “Quick actions” overlay for common actions (add class, add reminder, scan schedule).
- Coordinates shared service instances used by multiple tabs.

Implementation: `lib/app/root_nav.dart`

## Entry points (routes/deeplinks/navigation)

- GoRouter route: `/app`
- Can be reached after successful login/signup verification or from `BootstrapGate` session validation.
- `NavigationChannel` and `openReminders()` may navigate into reminders context while the app is running.

## UI Anatomy (major sections; key components; sheets/dialogs)

- Tab pages (kept alive via `Offstage`):
  - `DashboardScreen`
  - `SchedulesPage`
  - `RemindersPage`
  - `SettingsPage`
- Bottom navigation bar: `GlassNavigationBar`
- Floating “plus” quick action (inline quick action)
- Quick actions overlay:
  - “Add custom class” → opens `AddClassSheet`
  - “Add reminder” → opens `AddReminderSheet`
  - “Scan schedule” → opens scan flow (`ScanOptionsSheet` → `ScanPreviewSheet` → `SchedulesPreviewSheet`)
- Profile completion prompt:
  - `StudentIdPromptSheet.show(...)` (if `AuthService.isProfileComplete()` is false)

## States (loading/empty/error/offline) + how each appears

- The shell itself does not show a global loading state; each tab handles its own loading/empty UI.
- Quick actions overlay animates in/out and blocks taps behind it.

## Primary actions + validation rules

- Switch tabs; revisit current tab refreshes that tab’s content (via `refreshOnTabVisit()` methods).
- Quick actions:
  - Add class/reminder sheets return results (IDs/day) to trigger refresh and highlight.
  - Scan flow supports “retake” to restart capture/preview steps.

## Data dependencies (services/repos + Supabase tables if confirmable)

- Schedule data: `ScheduleApi` → `user_classes_v`, `user_custom_classes`, `user_class_overrides`, `user_sections`, `sections`, `semesters`
- Reminder data: `RemindersApi` → `reminders`
- Profile completeness: `AuthService.isProfileComplete()` → `profiles`

## Side effects (notifications/alarms, analytics/telemetry, caching, permissions)

- May trigger schedule/reminders reloads after successful sheet flows.
- Updates `ReminderScopeStore` when opening reminders via native navigation.

## Accessibility notes (only what you can confirm from code)

- Uses standard Material controls; no explicit semantics overrides found.

## Tests (existing tests that cover it; if none, TODO)

- `test/services/root_nav_controller_test.dart` covers `RootNavController` behavior (tab switching + quick action toggling).
- `TODO:` Add widget tests for the actual `RootNav` UI if you change navigation/quick actions.

## Related links (to other docs/latest pages)

- [Architecture](../architecture.md)
- [Screens index](index.md)

