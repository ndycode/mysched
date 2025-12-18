# MySched Architecture

This document describes the system architecture, data flow, and technical structure of MySched.

---

## Overview

MySched is a Flutter-based mobile application for academic schedule management, targeting students at Immaculate Conception Institutions (ICI). The app scans student account cards via OCR to automatically generate class schedules and send intelligent notifications.

### Technology Stack

| Layer | Technology |
|-------|------------|
| **Mobile Framework** | Flutter 3.3+ |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime) |
| **State Management** | ValueNotifier, ChangeNotifier |
| **Navigation** | go_router |
| **OTA Updates** | Shorebird Code Push |
| **Error Tracking** | Sentry |
| **OCR** | Google ML Kit (on-device) |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter App                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Screens   │  │  UI Kit     │  │    Theme System         │  │
│  │  (Pages)    │  │ (Components)│  │  (Tokens, Motion)       │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                      │                │
│  ┌──────┴────────────────┴──────────────────────┴─────────────┐ │
│  │                     Service Layer                           │ │
│  │  ┌─────────────┐ ┌──────────────┐ ┌────────────────────┐   │ │
│  │  │AuthService  │ │ScheduleRepo  │ │RemindersRepository │   │ │
│  │  │             │ │              │ │                    │   │ │
│  │  └─────────────┘ └──────────────┘ └────────────────────┘   │ │
│  │  ┌─────────────┐ ┌──────────────┐ ┌────────────────────┐   │ │
│  │  │OfflineQueue │ │NotifScheduler│ │ConnectionMonitor   │   │ │
│  │  └─────────────┘ └──────────────┘ └────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                   │
│  ┌───────────────────────────┴───────────────────────────────┐   │
│  │                    Data Layer (Env)                        │   │
│  │                 Supabase Client Singleton                  │   │
│  └───────────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │    Supabase Cloud   │
                    │  ┌───────────────┐  │
                    │  │  PostgreSQL   │  │
                    │  │  (15 tables)  │  │
                    │  └───────────────┘  │
                    │  ┌───────────────┐  │
                    │  │  Auth + RLS   │  │
                    │  └───────────────┘  │
                    └─────────────────────┘
```

---

## Directory Structure

```
lib/
├── main.dart              # App bootstrap, Sentry init, error handlers
├── env.dart               # Supabase client initialization
│
├── app/                   # App-level configuration
│   ├── app_router.dart    # go_router configuration
│   ├── routes.dart        # Route constants
│   ├── constants.dart     # App-wide constants
│   ├── bootstrap_gate.dart # Auth state → route decision
│   └── root_nav.dart      # Bottom navigation shell
│
├── models/                # Data models
│   ├── schedule_class.dart
│   ├── instructor.dart
│   ├── semester.dart
│   ├── section.dart
│   └── reminder_scope.dart
│
├── services/              # Business logic layer (33 services)
│   ├── auth_service.dart           # Authentication
│   ├── schedule_repository.dart    # Class schedule CRUD
│   ├── reminders_repository.dart   # Reminders CRUD
│   ├── notification_scheduler.dart # Local notifications
│   ├── offline_queue.dart          # Offline write queue
│   ├── connection_monitor.dart     # Network state
│   └── ...
│
├── screens/               # Screen widgets (organized by feature)
│   ├── auth/              # Login, register, verify
│   ├── account/           # Account management
│   └── ...
│
├── ui/                    # UI components and theming
│   ├── kit/               # Reusable components (72 files)
│   ├── theme/             # Design system tokens
│   └── sheets/            # Bottom sheet components
│
└── utils/                 # Utility functions
    ├── app_log.dart       # Logging utilities
    ├── nav.dart           # Navigation helpers
    └── local_notifs.dart  # Notification utilities
```

---

## Service Layer

Services are singletons accessed via `.instance` pattern. They encapsulate business logic and data access.

### Core Services

| Service | Responsibility |
|---------|----------------|
| `AuthService` | Authentication, profile management, Google Sign-In |
| `ScheduleRepository` | Class schedule CRUD, section management |
| `RemindersRepository` | Reminder CRUD, filtering, completion |
| `NotificationScheduler` | Local notification scheduling and alarms |
| `StudyTimerService` | Pomodoro-style study session tracking |
| `StatsService` | Usage analytics and study statistics |

### Infrastructure Services

| Service | Responsibility |
|---------|----------------|
| `ConnectionMonitor` | Network connectivity monitoring |
| `OfflineQueue` | Queued write operations when offline |
| `DataSync` | Background data synchronization |
| `OfflineCacheService` | Local caching for offline access |
| `TelemetryService` | Event logging and crash reporting |
| `ThemeController` | Theme mode and accent color management |
| `UserSettingsService` | User preferences sync |

### Service Initialization

Services are initialized in `main.dart` during app bootstrap:

```dart
// Critical path (awaited)
await Env.init();
await ThemeController.instance.init();
await UserSettingsService.instance.init();

// Deferred (fire and forget)
ConnectionMonitor.instance.startMonitoring();
OfflineQueue.instance.init();
DataSync.instance.init();
```

---

## Data Flow

### Authentication Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ AuthScreen  │───▶│ AuthService │───▶│  Supabase   │
└─────────────┘    └─────────────┘    │    Auth     │
                          │           └─────────────┘
                          ▼
                   ┌─────────────┐
                   │BootstrapGate│ ── checks auth state
                   └─────────────┘
                          │
                    ┌─────┴─────┐
                    ▼           ▼
              ┌─────────┐  ┌─────────┐
              │ RootNav │  │ Welcome │
              │(logged) │  │(guest)  │
              └─────────┘  └─────────┘
```

### Schedule Data Flow

```
1. User scans card (OCR)
         ↓
2. ScanService extracts text
         ↓
3. ScheduleRepository.upsertSection()
         ↓
4. Supabase (or OfflineQueue if offline)
         ↓
5. NotificationScheduler reschedules alarms
         ↓
6. UI refreshes via stream/notifier
```

### Offline-First Pattern

```
┌─────────────────────────────────────────────────────┐
│                    Write Operation                   │
└──────────────────────────┬──────────────────────────┘
                           │
                    ┌──────┴──────┐
                    │  Online?    │
                    └──────┬──────┘
                     │           │
                   Yes           No
                     │           │
                     ▼           ▼
              ┌──────────┐ ┌─────────────┐
              │ Supabase │ │ OfflineQueue│
              │  Direct  │ │   .enqueue()│
              └──────────┘ └──────┬──────┘
                                  │
                                  ▼ (when online)
                           ┌──────────────┐
                           │ OfflineQueue │
                           │   .flush()   │
                           └──────────────┘
```

---

## Database Schema

MySched uses Supabase (PostgreSQL) with Row Level Security. See `schema.sql` for full DDL.

### Core Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User profile data (linked to auth.users) |
| `semesters` | Academic semesters |
| `sections` | Class sections (e.g., "BSIT-3A") |
| `classes` | Individual class entries |
| `instructors` | Instructor directory |
| `reminders` | User reminders |
| `study_sessions` | Pomodoro session history |
| `user_sections` | User ↔ Section relationship |
| `user_settings` | User preferences |
| `user_class_overrides` | Per-class notification overrides |
| `user_custom_classes` | User-created custom classes |

### Key Relationships

```
auth.users
    │
    └── profiles (1:1)
    │
    └── user_sections (1:many) ─── sections ─── classes
    │
    └── reminders (1:many)
    │
    └── study_sessions (1:many)
    │
    └── user_settings (1:1)
```

---

## Navigation

MySched uses `go_router` for declarative navigation.

### Route Structure

| Route | Screen | Purpose |
|-------|--------|---------|
| `/splash` | BootstrapGate | Initial auth check |
| `/welcome` | WelcomeScreen | Onboarding entry |
| `/login` | AuthScreen (login) | Email/password login |
| `/register` | AuthScreen (register) | New account |
| `/verify` | VerifyEmailScreen | OTP verification |
| `/app` | RootNav | Main app shell |
| `/account` | AccountScreen | Profile settings |
| `/reminders` | RemindersPage | Reminder management |

### Navigation Flow

```
App Launch
    │
    ▼
BootstrapGate (checks auth)
    │
    ├── Has session? ──▶ /app (RootNav)
    │
    └── No session? ──▶ /welcome
```

---

## State Management

MySched uses lightweight state management:

- **ValueNotifier/ChangeNotifier**: For simple reactive state
- **Streams**: For Supabase realtime subscriptions
- **SharedPreferences**: For persisted user preferences

### Example: Theme State

```dart
class ThemeController {
  static final instance = ThemeController._();
  
  final ValueNotifier<AppThemeMode> mode = ValueNotifier(AppThemeMode.system);
  final ValueNotifier<Color?> accentColor = ValueNotifier(null);
  
  // UI rebuilds via ValueListenableBuilder
}
```

---

## Error Handling

Errors are captured at multiple levels:

1. **Flutter Errors**: `FlutterError.onError` → Sentry
2. **Platform Errors**: `PlatformDispatcher.instance.onError` → Sentry
3. **Zone Errors**: `runZonedGuarded` → TelemetryService
4. **Service Errors**: Try-catch with telemetry logging

See [ERROR_HANDLING.md](ERROR_HANDLING.md) for detailed patterns.

---

## Performance Considerations

- **Lazy loading**: Services init on first access
- **Deferred init**: Non-critical services run in background
- **List virtualization**: ListView.builder with cacheExtent
- **Image caching**: Avatar images cached locally
- **Skeleton screens**: UI remains responsive during loads

See [PERFORMANCE.md](PERFORMANCE.md) for optimization guidelines.

---

## Security

- **Row Level Security**: All tables protected by RLS policies
- **Token storage**: Handled by Supabase Flutter SDK
- **No PII in logs**: Sentry configured with `sendDefaultPii: false`
- **On-device OCR**: Images processed locally, never uploaded

See [SECURITY.md](SECURITY.md) for security guidelines.
