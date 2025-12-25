# MySched

An OCR-powered mobile app for ICI students. Scan your class schedule, get smart notifications, and never miss a class again.

## Overview

MySched automates class scheduling for Immaculate Conception Institutions students. The app uses optical character recognition to extract schedule data from student account cards, automatically builds a personalized timetable, and delivers timely notifications before each class.

### Core Capabilities

- **OCR Schedule Scanning** — Capture student account cards and extract subjects, times, rooms, and instructors automatically
- **Smart Notifications** — Timezone-aware reminders with customizable lead times and snooze controls
- **Cloud Sync** — Secure backup and cross-device synchronization via Supabase
- **Offline Mode** — View your schedule without internet; syncs automatically when connected
- **Export Options** — Share schedules as PDF, CSV, or plain text
- **Study Timer** — Built-in Pomodoro timer with session statistics

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter (Dart) |
| OCR Engine | Google ML Kit Text Recognition |
| Backend | Supabase (Auth, Database, Storage) |
| Notifications | flutter_local_notifications + timezone |
| OTA Updates | Shorebird Code Push |
| Crash Reporting | Sentry |

## Project Structure

```
lib/
├── app/           # App configuration, routes, constants
├── models/        # Data models and entities
├── screens/       # UI screens organized by feature
├── services/      # Business logic and API services
└── ui/
    ├── kit/       # Reusable UI components
    ├── sheets/    # Bottom sheets and modals
    └── theme/     # Design tokens, colors, typography
```

## Prerequisites

- Flutter SDK 3.3+
- Android SDK / Xcode (for iOS)
- Supabase project with configured tables

## Setup Instructions

### 1. Clone and Install

```bash
git clone https://github.com/ndycode/mysched.git
cd mysched
flutter pub get
```

### 2. Environment Configuration

Create a `.env` file with your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Run Development Server

```bash
flutter run --dart-define-from-file=.env
```

## Available Scripts

| Command | Description |
|---------|-------------|
| `flutter run` | Start development build |
| `flutter test` | Run unit and widget tests |
| `flutter build appbundle` | Build release AAB for Play Store |
| `shorebird release android` | Create Shorebird release |
| `shorebird patch android` | Push OTA update |

## Permissions

| Permission | Purpose |
|------------|---------|
| Camera | Scan student account cards |
| Notifications | Deliver class reminders |
| Photos (optional) | Import schedules from gallery |

## Privacy

All user data is stored under authenticated Supabase accounts and handled per the Data Privacy Act of 2012 (RA 10173). Analytics events are anonymized; no PII is transmitted.

## Authors

**Neil T. Daquioag** · **Raymond A. Zabiaga**

Thesis: *"MySched: An OCR-Based Mobile Application for Automated Class Scheduling and Notification System at Immaculate Conception Institutions"* (October 2025)

## License

This academic project acknowledges open-source tools including Google ML Kit, Supabase, Flutter, and Shorebird.
