# Documentation Generation Report

- Last generated: 2025-12-18
- Commit: `21161727d2535f4a7d078612c9f2db3620162939`

## Sources consulted (primary)

### Flutter entry + routing

- `lib/main.dart`
- `lib/env.dart`
- `lib/app/app_router.dart`
- `lib/app/routes.dart`
- `lib/app/bootstrap_gate.dart`
- `lib/app/root_nav.dart`

### Major feature areas

- Auth/account:
  - `lib/services/auth_service.dart`
  - `lib/screens/auth/*`
  - `lib/screens/account/*`
- Schedule:
  - `lib/services/schedule_repository.dart`
  - `lib/services/scan_service.dart`
  - `lib/screens/schedules/*`
  - `lib/screens/scan/*`
- Reminders:
  - `lib/services/reminders_repository.dart`
  - `lib/screens/reminders/*`
  - `lib/ui/kit/reminder_details_sheet.dart`
- Notifications:
  - `lib/services/notification_scheduler.dart`
  - `lib/utils/local_notifs.dart`
  - `android/app/src/main/AndroidManifest.xml`
  - `android/app/src/main/kotlin/com/ici/mysched/MainActivity.kt`
  - `android/app/src/main/java/com/ici/mysched/*`
- Settings:
  - `lib/services/user_settings_service.dart`
  - `lib/screens/settings/settings_screen.dart`

### Backend schema context

- `schema.sql`
- `supabase/migrations/create_profile_on_signup.sql`
- `supabase/migrations/add_instructor_user_id.sql`
- `.env.example`
- `pubspec.yaml`
- `shorebird.yaml`

## Inferences made (minimized)

- “Mobile app source lives under `lib/`” is confirmed by project structure and Flutter entry point `lib/main.dart`.
- “Android alarm plumbing exists” is confirmed by method channel usage in `lib/utils/local_notifs.dart` and receivers/activities in `android/app/src/main`.
- Where routing was unclear or missing, surfaces are classified as “legacy/unwired” rather than claimed reachable.

## TODO / open questions (must be confirmed from code or DB SQL)

### Backend objects referenced but not defined in repo

- Views/tables:
  - `user_classes_v`
  - `user_schedule_view`
  - `schedule_shares`
- RPCs:
  - `is_student_id_available`
  - `rescan_section`
  - `set_class_deleted`
- Edge Functions:
  - `delete_account`

### Routing gaps

- `lib/app/routes.dart` defines `/timer`, `/stats`, `/onboarding`, `/shared/:code` but `lib/app/app_router.dart` does not register them.

### Route argument mismatch (auth sheets)

- `AuthScreen` pushes `/forgot-password` and `/verify` with `extra: {'email': ...}` maps.
- `app_router.dart` reads typed args (`ForgotPasswordScreenArgs`, `VerifyEmailScreenArgs`) or query parameters, not a generic map.

`TODO:` Align call sites and router argument parsing so the initial email is reliably prefilled.

### Android widget plumbing mismatch (potential issue)

- Native widget reads from `NextClassWidgetPrefs` preference file, but Flutter writes via the `shared_preferences` plugin (which uses `FlutterSharedPreferences`).
- Flutter also invokes `MethodChannel('com.ici.mysched/widget')`, but no native channel handler is present in this repo.

`TODO:` Confirm intended implementation and align native + Flutter sides.

### Calendar permissions

- `READ_CALENDAR` and `WRITE_CALENDAR` exist in AndroidManifest, but calendar sync usage is not confirmed in Dart code (`TODO:` confirm or remove).

## README snapshot metrics (legacy)

Moved from `README.md` on 2025-12-18 to keep the root README lean. These values are not code-confirmed; treat as historical context.

### Performance metrics (v2.3)

- Cold start: splash to dashboard in ~0.84 s on Pixel 8 Pro (profile build).
- Navigation: fade-through transitions sustain 120 fps with zero jank recorded in DevTools frame charts.
- Telemetry: `ui_perf_bootstrap_ms` reports bootstrap duration after the first frame to flag regressions early.
- Reminder sync: scheduler runs without frame drops; GC pauses stay <3 ms during profile sessions.

### Testing & coverage snapshot

- 65 Dart/widget tests cover parsing, scheduling flows, settings, and UI kit regressions (`flutter test --coverage`).
- Latest coverage snapshot (`coverage/lcov.info`) reports 1,589 / 3,559 lines hit (44.6%).
- Golden and render tests validate dashboards and settings screens at large text scales for accessibility parity.
- Release pipeline: `flutter analyze`, `dart format`, `flutter test --coverage`, and `flutter run --profile` gate every build tagged for release.

### v2.4 coverage & reliability plan

- Lift automated coverage to at least 60% with new specs spanning Supabase auth, export queue resilience, and calendar sync toggles.
- Reinforce Supabase authentication by wrapping sign-in and recovery flows in exponential backoff with `auth_retry_success` / `auth_retry_failed` telemetry.
- Replace transient snackbars in export/support flows with actionable `ErrorState` retries and track each surface via `ui_state_error`.

### Known issues (snapshot)

- None listed in README at the time of this snapshot.

### Dependencies snapshot (observed)

```
Package Name                      Current    Upgradable  Resolvable  Latest

direct dependencies:
intl                              *0.19.0    *0.19.0     0.20.2      0.20.2

dev_dependencies: all up-to-date.

transitive dependencies:
characters                        *1.4.0     *1.4.0      *1.4.0      1.4.1
file_selector_macos               *0.9.4+4   0.9.4+5     0.9.4+5     0.9.4+5
flutter_plugin_android_lifecycle  *2.0.31    2.0.32      2.0.32      2.0.32
image_picker_android              *0.8.13+1  0.8.13+5    0.8.13+5    0.8.13+5
image_picker_ios                  *0.8.13    0.8.13+1    0.8.13+1    0.8.13+1
image_picker_macos                *0.2.2     0.2.2+1     0.2.2+1     0.2.2+1
material_color_utilities          *0.11.1    *0.11.1     *0.11.1     0.13.0
meta                              *1.16.0    *1.16.0     *1.16.0     1.17.0
mime                              *1.0.6     2.0.0       2.0.0       2.0.0
path_provider_android             *2.2.19    2.2.20      2.2.20      2.2.20
path_provider_foundation          *2.4.2     2.4.3       2.4.3       2.4.3
shared_preferences_android        *2.4.13    2.4.15      2.4.15      2.4.15
shared_preferences_foundation     *2.5.4     2.5.5       2.5.5       2.5.5
url_launcher_android              *6.3.20    6.3.24      6.3.24      6.3.24
url_launcher_ios                  *6.3.4     6.3.5       6.3.5       6.3.5
url_launcher_macos                *3.2.3     3.2.4       3.2.4       3.2.4

transitive dev_dependencies:
test_api                          *0.7.6     *0.7.6      *0.7.6      0.7.7
vm_service                        *15.0.0    15.0.2      15.0.2      15.0.2

14 upgradable dependencies are locked (in pubspec.lock) to older versions.
To update these dependencies, use `flutter pub upgrade`.

1 dependency is constrained to a version that is older than a resolvable version.
To update it, edit pubspec.yaml, or run `flutter pub upgrade --major-versions`.
```

## Link integrity checklist

Checked internal links under `docs/latest/` on 2025-12-18: **OK** (no broken relative links detected).
