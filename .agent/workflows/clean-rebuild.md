---
description: Clean rebuild - flutter clean, pub get, and run
---

# Clean Rebuild

Full clean rebuild of the project: flutter clean → pub get → run.

// turbo-all

## Step 1: Stop Running Instances

If there's a running flutter instance, stop it first.

## Step 2: Clean Build Artifacts

Remove all build artifacts:

```bash
flutter clean
```

This removes:
- `build/` directory
- `.dart_tool/` caches
- Generated files

## Step 3: Get Dependencies

Fetch all packages:

```bash
flutter pub get
```

This downloads all dependencies from pubspec.yaml.

## Step 4: Run the App

Start the app in debug mode:

```bash
flutter run
```

---

## One-Liner Command (Copy-Paste Ready)

```powershell
flutter clean; flutter pub get; flutter run
```

---

## When to Use

Use this workflow when:
- Build errors that won't go away
- Package conflicts after updating dependencies
- Strange behavior that might be cached
- After changing native code (Android/iOS)
- After updating Flutter SDK
