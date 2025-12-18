# Screens Index

This is the catalog of **user-facing screens and major sheets** in the current MySched mobile app codebase.

> Note: Some files in `lib/screens/**` appear unused/unwired in the current router. These are listed under “Legacy/unwired surfaces”.

## Routed pages (GoRouter)

| Surface | Route | Implementation |
|---|---|---|
| Splash/bootstrap gate | `/splash` | `lib/app/bootstrap_gate.dart` → `BootstrapGate` |
| Welcome | `/welcome` | `lib/screens/auth/welcome_screen.dart` → `WelcomeScreen` |
| Auth (login/register) | `/login`, `/register` | `lib/screens/auth/login_screen.dart` → `AuthScreen` |
| Forgot password (sheet route) | `/forgot-password` | `lib/screens/auth/forgot_password_screen.dart` (launches `ForgotPasswordSheet`) |
| Verify email (sheet route) | `/verify` | `lib/screens/account/verify_email_screen.dart` (launches `VerifyEmailSheet`) |
| Main app shell | `/app` | `lib/app/root_nav.dart` → `RootNav` |
| Reminders (deep link page) | `/reminders` | `lib/screens/reminders/reminders_screen.dart` via `lib/screens/reminders_page.dart` |
| Account overview | `/account` | `lib/screens/account/account_screen.dart` → `AccountOverviewPage` |
| Change email (sheet route) | `/account/change-email` | `lib/screens/account/change_email_screen.dart` (launches `ChangeEmailSheet`) |
| Change password (sheet route) | `/account/change-password` | `lib/screens/account/change_password_screen.dart` (launches `ChangePasswordSheet`) |
| Delete account (sheet route) | `/account/delete` | `lib/screens/account/delete_account_screen.dart` (launches `DeleteAccountSheet`) |
| Style guide | `/style-guide` | `lib/screens/style_guide_page.dart` → `StyleGuidePage` |

## Bottom navigation tabs (inside `RootNav`)

| Tab | Implementation |
|---|---|
| Dashboard | `lib/screens/dashboard/dashboard_screen.dart` |
| Schedules | `lib/screens/schedules/schedules_screen.dart` (`SchedulesPage`) |
| Reminders | `lib/screens/reminders/reminders_screen.dart` (`RemindersPage`) |
| Settings | `lib/screens/settings/settings_screen.dart` (`SettingsPage`) |

## Major modal sheets / dialogs (Flutter)

| Surface | Entry point (examples) | Implementation |
|---|---|---|
| Add class | Quick actions; schedules page | `lib/screens/schedules/add_class_screen.dart` → `AddClassSheet` |
| Class details | Dashboard, Schedules | `lib/ui/kit/class_details_sheet.dart` → `ClassDetailsSheet` |
| Instructor finder | Schedules | `lib/ui/kit/instructor_finder_sheet.dart` → `InstructorFinderSheet` |
| Scan options | Quick actions; schedules page | `lib/screens/scan/scan_options_screen.dart` → `ScanOptionsSheet` |
| Scan preview | Scan flow | `lib/screens/scan/scan_preview_screen.dart` → `ScanPreviewSheet` |
| Schedule import preview | Scan flow | `lib/screens/scan/schedule_import_screen.dart` → `SchedulesPreviewSheet` |
| Add reminder | Quick actions; reminders page | `lib/screens/reminders/add_reminder_screen.dart` → `AddReminderSheet` |
| Reminder details | Reminders list | `lib/ui/kit/reminder_details_sheet.dart` → `ReminderDetailsSheet` |
| Reminder snooze picker | Reminders | `lib/screens/reminders/reminders_messages.dart` → `ReminderSnoozeSheet` |
| Study timer | Quick actions (dashboard) | `lib/screens/timer/study_timer_screen.dart` → `StudyTimerSheet` |
| Stats | Dashboard | `lib/screens/stats/stats_screen.dart` → `StatsSheet` |
| Student ID prompt | Post-login profile completion | `lib/ui/sheets/student_id_prompt_sheet.dart` |
| Forgot password flow | Auth | `lib/screens/auth/forgot_password_sheet.dart` + related sheets |
| Verify email flow | Auth/account | `lib/screens/account/verify_email_sheet.dart` |
| Change email/password/delete account | Account | `lib/screens/account/*_sheet.dart` |
| Battery optimization guidance | Bootstrap + settings | `lib/ui/kit/battery_optimization_sheet.dart` |
| Scan consent dialog | Scan flow | `lib/ui/kit/consent_dialog.dart` |
| Scan error modal | Scan flow | `lib/screens/scan/scan_error_modal.dart` |

## Platform-native user-facing surfaces (Android)

| Surface | Implementation | Notes |
|---|---|---|
| Fullscreen alarm UI | `android/app/src/main/java/com/ici/mysched/FullscreenAlarmActivity.java` | Used by exact-alarm delivery |
| Next class widget | `android/app/src/main/kotlin/com/ici/mysched/widget/NextClassWidgetProvider.kt` | Data plumbing appears incomplete (`TODO:`) |

## Legacy/unwired surfaces (present in code, not confirmed reachable)

| Surface | Implementation | Notes |
|---|---|---|
| About sheet (legacy) | `lib/screens/about_screen.dart` | Not referenced by current settings UI |
| Privacy sheet (legacy) | `lib/screens/privacy_screen.dart` | Not referenced by current settings UI |
| AppShell (legacy) | `lib/screens/app_shell.dart` | Appears unused |
| Alarm info page (legacy) | `lib/screens/reminders/reminders_info_screen.dart` | Appears unused |
| Onboarding screen | `lib/screens/onboarding/onboarding_screen.dart` | Not routed in `GoRouter` |
| Feature tour screen | `lib/screens/onboarding/feature_tour.dart` | Not routed in `GoRouter` |
| Export options sheet | `lib/ui/sheets/export_options_sheet.dart` | Not referenced in current UI |
| Manual section entry sheet | `lib/screens/scan/manual_section_entry_sheet.dart` | Defined, not confirmed reachable |

## Screen docs

Each surface has a dedicated doc under `docs/latest/screens/`:

- [bootstrap_gate](bootstrap_gate.md)
- [welcome](welcome.md)
- [auth](auth.md)
- [root_nav](root_nav.md)
- [dashboard](dashboard.md)
- [schedules](schedules.md)
- [add_class_sheet](add_class_sheet.md)
- [class_details_sheet](class_details_sheet.md)
- [instructor_finder_sheet](instructor_finder_sheet.md)
- [scan_options_sheet](scan_options_sheet.md)
- [scan_preview_sheet](scan_preview_sheet.md)
- [schedules_preview_sheet](schedules_preview_sheet.md)
- [reminders](reminders.md)
- [add_reminder_sheet](add_reminder_sheet.md)
- [reminder_details_sheet](reminder_details_sheet.md)
- [reminder_snooze_sheet](reminder_snooze_sheet.md)
- [settings](settings.md)
- [account_overview](account_overview.md)
- [verify_email_sheet](verify_email_sheet.md)
- [forgot_password_sheet](forgot_password_sheet.md)
- [reset_password_verify_sheet](reset_password_verify_sheet.md)
- [new_password_sheet](new_password_sheet.md)
- [change_email_sheet](change_email_sheet.md)
- [change_password_sheet](change_password_sheet.md)
- [delete_account_sheet](delete_account_sheet.md)
- [student_id_prompt_sheet](student_id_prompt_sheet.md)
- [study_timer_sheet](study_timer_sheet.md)
- [stats_sheet](stats_sheet.md)
- [battery_optimization_dialog](battery_optimization_dialog.md)
- [scan_consent_dialog](scan_consent_dialog.md)
- [scan_error_modal](scan_error_modal.md)
- [issue_reports](issue_reports.md)
- [style_guide](style_guide.md)
- [android_fullscreen_alarm](android_fullscreen_alarm.md)
- [android_next_class_widget](android_next_class_widget.md)
- [legacy_about_sheet](legacy_about_sheet.md)
- [legacy_privacy_sheet](legacy_privacy_sheet.md)
- [legacy_alarm_page](legacy_alarm_page.md)
- [legacy_onboarding](legacy_onboarding.md)
- [legacy_feature_tour](legacy_feature_tour.md)
- [legacy_app_shell](legacy_app_shell.md)
- [legacy_export_options_sheet](legacy_export_options_sheet.md)
- [legacy_manual_section_entry_sheet](legacy_manual_section_entry_sheet.md)
