# Getting Started

This guide is for the **MySched mobile app** in this repository (Flutter/Dart).

## Prerequisites

- Flutter SDK compatible with `pubspec.yaml` (`sdk: ">=3.3.0 <4.0.0"`)
- Android Studio (for Android SDK/emulator) and/or Xcode (for iOS)
- A Supabase project (URL + anon key)

## Install dependencies

From the repo root:

```powershell
flutter pub get
```

## Configure Supabase

MySched requires `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

### Option A: `.env` file (loaded at runtime)

1) Copy `.env.example` to `.env` and fill in values.
2) Ensure `.env` is listed as an asset in `pubspec.yaml` (it is in this repo).

### Option B: `--dart-define`

You can also pass values at build/run time:

```powershell
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

If env init fails, the app will show a configuration error screen saying Supabase config is missing.

## Optional: Sentry crash reporting

Sentry is initialized in `lib/main.dart` and is a no-op unless you provide a DSN:

```powershell
flutter run --dart-define=SENTRY_DSN=...
```

The app sets `sendDefaultPii = false`.

## Run the app

```powershell
flutter run
```

### First-run prompts (expected)

The app asks for:

- Camera permission (schedule scanning)
- Notification permission (Android)
- Android alarm readiness prompts (exact alarms, notification settings, full-screen intent on Android 14+, battery optimization, and OEM auto-start guidance)

If you deny permissions, the app may still run, but schedule scanning and/or reliable alarms may be degraded.

## Common issues

### “Missing Supabase configuration”

- Confirm `.env` exists and contains `SUPABASE_URL` + `SUPABASE_ANON_KEY`, or pass them via `--dart-define`.
- Note: `.env` is loaded via `package:flutter_dotenv` in `lib/env.dart`.

### Alarms don’t fire reliably on Android

- Ensure the app has permission to schedule exact alarms.
- Disable battery optimization for MySched (“Unrestricted” where available).
- On Android 14+ (API 34+), allow “full-screen intent” for alarms.
- Some OEM devices require enabling auto-start for background reliability.

See: [Notifications](notifications.md).

