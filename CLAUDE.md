# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (requires Supabase credentials)
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key

# Or use env file
flutter run --dart-define-from-file=.env.local

# Run all tests
flutter test

# Run a single test file
flutter test test/services/auth_login_test.dart

# Run tests with coverage
flutter test --coverage

# Static analysis
flutter analyze

# Format code
dart format lib test
```

## Architecture Overview

### Application Bootstrap (`lib/main.dart`)
The app initializes in this order:
1. Sentry crash reporting (DSN via `--dart-define`)
2. Native splash preservation
3. Edge-to-edge system UI setup
4. Error handlers and telemetry recorder
5. Environment/Supabase initialization (`Env.init()`)
6. Theme controller initialization
7. Deferred service initialization (connection monitor, offline queue, data sync)

If Supabase credentials are missing, a `_ConfigErrorApp` is shown instead of the main app.

### Service Layer (`lib/services/`)
Services use singleton pattern with static `instance` getters. Key services:
- **AuthService**: Supabase authentication (login, signup, OTP, password reset)
- **ScheduleService/ScheduleRepository**: Class schedule CRUD with Supabase
- **RemindersRepository**: Reminder management
- **OfflineQueue/OfflineCacheService**: Offline-first sync with queued operations
- **DataSync**: Coordinates data synchronization across services
- **ConnectionMonitor**: Network connectivity tracking
- **NotificationScheduler**: Android alarm scheduling via `LocalNotifs`
- **TelemetryService/AnalyticsService**: Event logging (AnalyticsService wraps TelemetryService)

### Data Flow
```
UI Screen → Service (business logic) → Repository (data access) → Supabase/Local Cache
                                                                ↓
                                              OfflineQueue (when offline)
```

### UI Architecture (`lib/ui/`)

**Design Tokens** (`lib/ui/theme/tokens/`):
- Centralized tokens for colors, spacing, typography, motion, shadows, radius
- Access via `AppTokens.spacing`, `AppTokens.lightColors`, etc.
- Three color palettes: `lightColors`, `darkColors`, `voidColors`

**UI Kit** (`lib/ui/kit/`):
- Reusable components: `PrimaryButton`, `SecondaryButton`, `TertiaryButton`, `DestructiveButton`
- State displays: `StateDisplay.empty()`, `StateDisplay.error()`, `StateDisplay.success()`
- Card variants: `CardX` with `CardVariant.elevated/outlined/filled/glass/hero`
- All buttons include built-in analytics logging and haptic feedback

**Theme System** (`lib/ui/theme/app_theme.dart`):
- `AppTheme.light()`, `AppTheme.dark()`, `AppTheme.voidTheme()` factory methods
- Custom accent color support via optional parameter
- `ThemeController` manages theme mode with persistence

### Routing (`lib/app/`)
- GoRouter-based navigation defined in `app_router.dart`
- Route constants in `routes.dart` (e.g., `AppRoutes.login`, `AppRoutes.app`)
- Deep link support via `NavigationChannel`

### Native Platform Integration
**Android Notifications** (`lib/utils/local_notifs.dart`):
- MethodChannel `'mysched/native_alarm'` for exact alarm scheduling
- Handles manufacturer-specific alarm permissions (Chinese OEMs)
- `AlarmReadiness` class for checking notification permissions

### Screen Structure (`lib/screens/`)
Screens follow pattern:
- StatefulWidget with lifecycle management
- `WidgetsBindingObserver` for app lifecycle awareness
- Loading/error/content states using `StateDisplay` components
- Analytics events on key user actions

## Key Patterns

### Offline-First
Operations are queued in `OfflineQueue` when offline, synced via `DataSync` when connectivity returns. `OfflineCacheService` maintains local schedule cache.

### Analytics Integration
Most UI components automatically log events. Pattern:
```dart
AnalyticsService.instance.logEvent('event_name', params: {'key': 'value'});
```

### Error Handling
Custom exceptions in `lib/utils/app_exceptions.dart`:
- `NotAuthenticatedException`, `NetworkException`, `ValidationException`
- `NotFoundException`, `RateLimitException`, `ConflictException`

### Testing
- Tests mirror source structure under `test/`
- `test/test_helpers/supabase_stub.dart` provides mock Supabase client
- `Env.debugInstallMock()` injects test dependencies
- Widget tests use `flutter_test` with custom harnesses

## Environment Configuration
Required environment variables (via `.env` file or `--dart-define`):
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key
- `SENTRY_DSN` (optional): Sentry error reporting DSN

## Linting Rules
- Uses `flutter_lints` package
- `prefer_final_locals: true`
- `avoid_print: true`
- `unnecessary_this: false` (allowed)
