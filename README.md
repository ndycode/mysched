# MySched

An OCR-based mobile application that scans Immaculate Conception Institutions (ICI) student account cards to automatically generate class schedules and send timely reminders.

Thesis title: "MySched: An OCR-Based Mobile Application for Automated Class Scheduling and Notification System at Immaculate Conception Institutions" (October 2025)

Authors: Neil T. Daquioag, Raymond A. Zabiaga

## Overview

MySched uses:

- Google ML Kit Text Recognition for OCR scanning of student account cards
- Supabase for authentication, storage, and synchronization
- flutter_local_notifications + timezone for class reminders
- Flutter (Dart) for a cross-platform UI

## Documentation

- Current mobile app docs: [docs/latest/index.md](docs/latest/index.md)
- Screen catalog: [docs/latest/screens/index.md](docs/latest/screens/index.md)

Legacy snapshots (may be outdated): `docs/legacy/reference/` and `docs/legacy/audit/`.

## Architecture & Systems

- **Env bootstrap**: `Env.init()` reads `--dart-define` / `--dart-define-from-file` values, requires `SUPABASE_URL`/`SUPABASE_ANON_KEY` (no hardcoded fallbacks), and emits telemetry events when configuration is missing or succeeds.
- **UI kit**: `lib/ui/kit` centralizes scaffolds, buttons, and layout primitives with built-in analytics, haptics, and motion defaults aligned to the brand.
- **Telemetry**: `AnalyticsService` fronts `TelemetryService`, making it trivial to direct events to a production sink without touching call sites.
- **Theme & motion**: `AppTheme`, `AppFadeThroughPageTransitionsBuilder`, and `TelemetryNavigatorObserver` keep Material styling, transitions, and navigation metrics consistent app-wide.

## Accessibility

- Text scaling is clamped between 1.0× and 1.6× to balance readability and layout stability.
- `AppScaffold` wraps page bodies with semantic labels, while buttons and nav destinations expose accessible labels and focus highlights.
- The light palette in `AppTokens` maintains >=4.5:1 contrast for primary text and controls.

## Environment Setup

1. Populate `SUPABASE_URL` and `SUPABASE_ANON_KEY` with your Supabase project credentials.
2. Run with `--dart-define` or `--dart-define-from-file` (examples below). The app will crash at splash if the keys are missing or invalid.

Performance, coverage, and dependency snapshots live in `docs/latest/_meta/report.md`.

## Features

- Scan student account cards and extract subjects, times, rooms
- Auto-build a personalized timetable; manual edits supported
- Local notifications with timezone-aware reminders and controllable snooze
- Secure cloud sync via Supabase
- Offline schedule cache for viewing your last synced timetable without connectivity (latest snapshot overwrites on each refresh)
- Export sharable schedule bundles in PDF, plain text, or CSV formats

## Setup

1. Flutter SDK 3.3+ and a recent Android toolchain
2. Create a Supabase project and configure `lib/env.dart` with your keys/URL
3. Install dependencies and run tests

```powershell
flutter pub get
flutter test
flutter run
```

### Android run

Provide your Supabase credentials at runtime when launching on Android emulators or devices:

```powershell
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=public-anon-key
```

For repeated runs, place the values in an `.env.local` file and load them:

```text
# .env.sample
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=public-anon-key
```

```powershell
flutter run --dart-define-from-file=.env.local
```

## Permissions

- Camera – required to scan cards
- Notifications – to deliver class reminders
- Photos/Media (read) – optional gallery import on older Android versions

## Privacy

User data is stored under authenticated Supabase accounts and handled per the Data Privacy Act of 2012 (RA 10173). See [docs/latest/privacy.md](docs/latest/privacy.md) for details.

Aggregate analytics events are collected to understand feature adoption; no personally identifiable information (PII) is transmitted or stored.

## License

This academic project acknowledges open-source tools including Google ML Kit, Supabase, Flutter, and flutter_local_notifications.
### Notifications & Snooze

- Heads-up reminders fire before class using your chosen lead time.
- Snoozing a reminder immediately confirms success (toast/snackbar) and re-arms an exact alarm, even under Doze.
- Legacy installs with `alert_minutes`, `default_notif_minutes`, or `default_snooze_minutes` settings are migrated automatically to the new `notifLeadMinutes` and `snoozeMinutes` keys on first launch.
- Developers can enable verbose exact-alarm logging (e.g., during Doze testing) via `LocalNotifs.setDebugLoggingEnabled(true)` in debug builds.
- Use **Quiet week** in Settings to pause all Android alarms temporarily; reminders resume automatically when toggled off.
- A debug-only **Verbose alarm logging** toggle is available in Settings → Android tools while running debug builds.

### Android QA Checklist

1. Enable heads-up reminders; confirm lead time matches expectation.
2. Toggle Quiet week on, verify banner, and ensure alarms halt.
3. Toggle Quiet week off; force resync and confirm alarms reschedule.
4. Snooze an active reminder; observe toast and rescheduled alarm firing.
5. Enable verbose alarm logging (debug) and capture logcat under Doze mode.
6. Change lead time, restart app, and confirm persisted value.
7. With notifications disabled, verify settings react without crashes.

### Android device test

- Force Doze/idle (`adb shell cmd deviceidle force-idle`) and confirm scheduled alarms still fire.
- Snooze an active reminder and verify the replacement alarm ID logs.
- Toggle Quiet week on/off to ensure alarms pause and resume appropriately.
- From Settings ▸ Android tools, open **Open Exact Alarm Settings** and grant access if needed.

Real-device confirmation is required before release sign-off.

### Offline / Export QA Checklist

1. Sync a schedule online, then enable airplane mode and reopen the app; confirm the cached timetable loads without an error banner.
2. Return online, pull to refresh, and ensure the offline data is replaced with the latest Supabase response.
3. From the export menu, share both PDF and CSV outputs and verify each attachment opens with the expected rows.

### Maintenance & QA

- Review dependency updates monthly; prioritize safe patch/minor bumps before major migrations.
- Automated test focus: schedules, settings, notifications, and offline cache flows.
- Pending high-value tests: auth, scan, share services, and onboarding journey coverage.
