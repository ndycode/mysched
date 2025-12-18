# Deployment

This document covers build and release tasks that can be confirmed from this repo’s configuration.

## App versioning

- Version is defined in `pubspec.yaml`:
  - `version: 2.0.5+17`

## Build commands (Flutter standard)

From the repo root:

```powershell
flutter pub get
flutter build apk
```

For iOS, use Xcode/Flutter tooling as appropriate:

```powershell
flutter build ios
```

## Shorebird (OTA patches)

This repository includes `shorebird.yaml` and depends on `shorebird_code_push`, which indicates Shorebird may be used for over-the-air updates.

- Config: `shorebird.yaml` (`app_id` is present)
- `TODO:` Confirm your release workflow (CI, Shorebird CLI commands, channel strategy) — the repo’s `.github/workflows/flutter-ci.yml` is empty.

## Rollback guidance

`TODO:` Rollback procedure depends on your distribution method (Play Store/TestFlight) and whether Shorebird patches are used. Document the exact steps once your release pipeline is defined.

