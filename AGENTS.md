# Repository Guidelines

## Project Structure & Module Organization
MySched is a Flutter application. Core production code lives under `lib/`, with feature folders for `screens/`, `services/`, `models/`, and shared `widgets/` and `utils/`. Platform scaffolding and native build files are in `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`. Automated tests reside in `test/`; keep fixtures and golden assets close to the specs that read them. Static assets are stored in `assets/` and are referenced in `pubspec.yaml`. Shared lint settings are defined in `analysis_options.yaml`.

## Build, Test, and Development Commands
Run these from the repository root after installing Flutter 3.3+:

```powershell
flutter pub get         # Install dependencies
flutter analyze         # Static analysis
dart format .           # Format Dart sources
flutter test            # Run unit and widget tests
flutter run             # Launch on a device
flutter build apk       # Build release APK
```

## Coding Style & Naming Conventions
Follow the Flutter style guide: two-space indentation, trailing commas on multi-line literals, and `final` locals when values do not change. Classes and enums use `PascalCase`; methods, properties, and variables use `lowerCamelCase`; files remain `snake_case.dart`. Avoid `print` in production code—prefer structured logging services. Run `dart format` before committing and ensure `flutter analyze` reports no warnings.

## Testing Guidelines
All tests should live in `test/` and mirror the `lib/` directory names (e.g., `lib/services/auth_service.dart` → `test/services/auth_service_test.dart`). Name test files with a `_test.dart` suffix and group related assertions with `group()` blocks. Aim for meaningful coverage of parsing, scheduling logic, and Supabase integrations. Use `flutter test --coverage` for larger changes and review `coverage/lcov.info` before submission.

## Commit & Pull Request Guidelines
Write commits in the imperative mood with concise subjects (e.g., `Add schedule overlap guard`). Squash WIP commits locally before opening a PR. Each PR should describe feature intent, outline testing performed, and note Supabase or platform configuration changes. Include screenshots or recordings for UI updates and link to tracking issues when available. Request at least one review and wait for CI (analyze + test) to pass before merging.

## Security & Configuration Tips
Never commit real Supabase keys or secrets; keep `lib/env.dart` populated via local `.env` files or CI secrets. When sharing build artifacts, strip personal data captured during OCR testing. Recheck Android and iOS permission prompts after changes to camera, notifications, or storage flows to stay compliant with privacy policies.
