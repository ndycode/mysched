---
description: Bump version and build Shorebird release for Play Store
---

# Build Release with Version Bump

Automatically bumps version and builds a Shorebird release for Play Store deployment.

// turbo-all

## Step 1: Check Current Version

Read current version from pubspec.yaml:

```bash
grep "^version:" pubspec.yaml
```

Format: `version: X.Y.Z+BUILD` (e.g., `2.0.4+14`)

## Step 2: Bump Version

Automatically increment the version:

### For PATCH bump (X.Y.Z+1):
- Increment BUILD number only (e.g., 2.0.4+14 → 2.0.4+15)

### For MINOR bump (X.Y+1.0):
- Increment Y, reset Z to 0, increment BUILD

### For MAJOR bump (X+1.0.0):
- Increment X, reset Y and Z to 0, increment BUILD

**Default: PATCH bump** (just increment BUILD number)

Update pubspec.yaml with new version.

## Step 3: Update Changelog

Add new version header to CHANGELOG.md:

```markdown
## [X.Y.Z] - YYYY-MM-DD

> 📦 **Preparing for Play Store**

### Changes
- [List changes from conversation or ask user]
```

## Step 4: Build Shorebird Release

Build release with auto-confirmation:

```bash
echo y | shorebird release --platforms android
```

This builds an AAB file optimized for Play Store with Shorebird patch support.

## Step 5: Locate Build Output

The AAB will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

## Step 6: Report to User

Confirm:
- New version number
- Location of AAB file
- Remind to upload to Play Console

---

## Quick Commands

### Patch bump only (recommended for most updates):
```powershell
# Just increment build number and release
echo y | shorebird release --platforms android
```

### Full version bump + release:
```powershell
# After manually updating pubspec.yaml version
echo y | shorebird release --platforms android
```

---

## Version Bump Script (Manual)

To bump version in pubspec.yaml:
1. Open `pubspec.yaml`
2. Change `version: X.Y.Z+BUILD` line
3. Save and run release command
