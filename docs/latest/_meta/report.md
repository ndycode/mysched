# Documentation Generation Report

- Last generated: 2025-12-18
- Commit: `TODO`

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

## Snapshot metrics (tooling-derived)

Snapshot date: 2025-12-18

Tooling:
- Flutter 3.38.4 (Dart 3.10.3)

### Tests + coverage

Command: `flutter test --coverage -r json`

- Result: exit code 1 (success: false)
- Test count: 637
- Coverage (line): 8,224 / 20,736 (39.66%)
- Note: The JSON reporter did not emit failing test names; coverage may be partial because the run exited non-zero. Re-run `flutter test` to inspect failures.

### Dependencies (flutter pub outdated --json)

- Direct packages with newer versions: 13/13
  - animations 2.1.0 -> 2.1.1
  - crop_your_image 0.7.5 -> 2.0.0
  - fl_chart 0.66.2 -> 1.1.1
  - flutter_dotenv 5.2.1 -> 6.0.0
  - flutter_slidable 3.1.2 -> 4.0.3
  - go_router 13.2.5 -> 17.0.1
  - google_sign_in 6.3.0 -> 7.2.0
  - image 4.5.4 -> 4.6.0
  - image_picker 1.2.0 -> 1.2.1
  - intl 0.19.0 -> 0.20.2
  - sentry_flutter 8.14.2 -> 9.9.0
  - shared_preferences 2.5.3 -> 2.5.4
  - supabase_flutter 2.10.3 -> 2.12.0
- Dev packages with newer versions: 2/2
  - flutter_launcher_icons 0.13.1 -> 0.14.4
  - supabase 2.10.0 -> 2.10.2
- Transitive packages with newer versions: 38/45

### Performance metrics

- TODO: No automated performance benchmarks run in this snapshot.

## Link integrity checklist

Checked internal links under `docs/latest/` on 2025-12-18: **OK** (no broken relative links detected).
