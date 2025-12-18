# MySched Developer Onboarding

Welcome! This guide will get you set up to develop MySched.

---

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Flutter | 3.3+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart | Included with Flutter | |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) |
| Xcode (macOS only) | 15+ | Mac App Store |
| VS Code (optional) | Latest | [code.visualstudio.com](https://code.visualstudio.com) |

### Verify Installation

```bash
flutter doctor
```

All checks should pass before proceeding.

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-org/mysched.git
cd mysched
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment

Create `.env` file in project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

Contact the team lead for development environment credentials.

### 4. Run the App

```bash
# Debug mode
flutter run

# With verbose logging
flutter run --dart-define=VERBOSE=true
```

---

## Project Structure

```
mysched/
├── lib/
│   ├── main.dart          # Entry point
│   ├── env.dart           # Supabase initialization
│   ├── app/               # Routing, navigation
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   ├── screens/           # Screen widgets
│   ├── ui/                # Components & theming
│   └── utils/             # Helpers
├── test/                  # Widget & unit tests
├── docs/                  # Documentation
├── .agent/workflows/      # Automation workflows
└── pubspec.yaml           # Dependencies
```

---

## Key Files to Understand

| File | Purpose |
|------|---------|
| `lib/main.dart` | App bootstrap, error handlers, service init |
| `lib/env.dart` | Supabase client setup |
| `lib/app/app_router.dart` | Navigation routes |
| `lib/services/auth_service.dart` | Authentication logic |
| `lib/services/schedule_repository.dart` | Schedule data access |
| `lib/ui/theme/tokens.dart` | Design system tokens |
| `lib/ui/kit/kit.dart` | Component exports |

---

## Development Workflow

### Branch Strategy

```
main          ← Production releases
  └── develop ← Integration branch
        └── feature/xxx ← Feature branches
        └── fix/xxx     ← Bug fix branches
```

### Code Style

- Follow Dart style guide
- Run `dart analyze` before commits
- Format with `dart format .`

### Commit Convention

```
type(scope): description

feat(auth): add Google Sign-In support
fix(schedule): correct time zone handling
docs(readme): update installation steps
refactor(services): extract notification logic
```

---

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test

```bash
flutter test test/services/auth_service_test.dart
```

### Test Coverage

```bash
flutter test --coverage
open coverage/lcov-report/index.html
```

---

## Building

### Debug Build

```bash
flutter build apk --debug
```

### Release Build

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Shorebird Patch (OTA)

```bash
shorebird patch android
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for full deployment instructions.

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter pub upgrade` | Upgrade dependencies |
| `flutter clean` | Clean build artifacts |
| `dart fix --apply` | Apply automated fixes |
| `flutter gen-l10n` | Generate localization |
| `flutter build apk --analyze-size` | Analyze APK size |

---

## Common Issues

### "Missing Supabase configuration"

Create `.env` file with valid credentials. See Step 3 above.

### "SDK version constraint"

Update Flutter: `flutter upgrade`

### Gradle build failures

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### iOS build failures (macOS)

```bash
cd ios
pod deintegrate
pod install
cd ..
```

---

## IDE Setup

### VS Code Extensions

- [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Error Lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)

### Android Studio Plugins

- Flutter
- Dart
- Flutter Enhancement Suite

---

## Getting Help

1. Check [docs/](../index.md) for comprehensive documentation
2. Search existing issues on GitHub
3. Ask in team chat
4. Create an issue with reproduction steps

---

## Next Steps

- [ ] Run the app locally
- [ ] Create a test account
- [ ] Explore the codebase
- [ ] Review [ARCHITECTURE.md](ARCHITECTURE.md)
- [ ] Read [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md)
- [ ] Make your first contribution!
