# MySched Deployment Guide

This document covers build, release, and deployment procedures for MySched.

---

## Overview

MySched uses multiple deployment channels:

| Channel | Purpose | Technology |
|---------|---------|------------|
| Play Store | Full releases | Flutter APK/AAB |
| Shorebird | OTA patches | Code Push |
| Vercel | Admin dashboard | Next.js |

---

## Environment Configuration

### Required Secrets

| Secret | Purpose | Required For |
|--------|---------|--------------|
| `SUPABASE_URL` | Backend URL | All builds |
| `SUPABASE_ANON_KEY` | API key | All builds |
| `SENTRY_DSN` | Error tracking | Production |
| `GOOGLE_WEB_CLIENT_ID` | OAuth | Google Sign-In |
| `SHOREBIRD_TOKEN` | OTA patches | Shorebird releases |

### Environment Files

**Development (`.env`)**:
```env
SUPABASE_URL=https://dev-xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

**Production** (via `--dart-define`):
```bash
--dart-define=SUPABASE_URL=https://prod-xxx.supabase.co
--dart-define=SUPABASE_ANON_KEY=eyJ...
--dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx
```

---

## Android Builds

### Debug Build

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
```

### App Bundle (Play Store)

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SENTRY_DSN=$SENTRY_DSN
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Shorebird OTA Updates

Shorebird enables over-the-air code patches without Play Store review.

### Prerequisites

```bash
# Install Shorebird CLI
curl https://shorebirddev.github.io/install.sh | bash

# Login
shorebird login
```

### Initial Release

First release must go through Play Store:

```bash
shorebird release android \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### OTA Patch

Subsequent updates can be patched:

```bash
shorebird patch android \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Shorebird Configuration

`shorebird.yaml`:
```yaml
app_id: 9e7a8f3b-826e-43e3-8a23-6f53b1e8797c
# auto_update: false  # Uncomment to disable auto-update
```

---

## Version Management

### Version Format

```yaml
# pubspec.yaml
version: 2.0.5+17
#        │ │ │  └── Build number (versionCode)
#        │ │ └───── Patch
#        │ └─────── Minor
#        └───────── Major
```

### Bumping Version

```bash
# Edit pubspec.yaml
version: 2.0.6+18

# Commit
git add pubspec.yaml
git commit -m "chore: bump version to 2.0.6+18"
```

---

## Play Store Deployment

### Pre-Release Checklist

- [ ] Version bumped in `pubspec.yaml`
- [ ] CHANGELOG.md updated
- [ ] All tests passing
- [ ] Debug symbols generated
- [ ] Screenshots updated (if UI changed)

### Build and Upload

```bash
# Build AAB
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=SENTRY_DSN=$SENTRY_DSN

# Upload via Play Console or fastlane
```

### Release Tracks

| Track | Purpose |
|-------|---------|
| Internal | Team testing |
| Closed Alpha | Limited testers |
| Open Beta | Public beta |
| Production | Full release |

---

## Admin Dashboard Deployment

The admin dashboard is a separate Next.js application deployed to Vercel.

### Deploy to Vercel

```bash
cd admin-dashboard
vercel --prod
```

### Environment Variables (Vercel)

Set in Vercel project settings:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

---

## Workflows

Use these workflow commands for common tasks:

### Full Release Build

```
/build-release
```

Bumps version and builds Shorebird release.

### OTA Patch

```
/deploy-patch
```

Deploys Shorebird OTA patch to production.

### Clean Rebuild

```
/clean-rebuild
```

Cleans cache and rebuilds from scratch.

---

## Rollback Procedures

### Shorebird Rollback

```bash
# List releases
shorebird releases list --app-id 9e7a8f3b-826e-43e3-8a23-6f53b1e8797c

# Rollback to previous patch
shorebird patch rollback android --release-version 2.0.5+17
```

### Play Store Rollback

1. Go to Play Console
2. Release Management → App Releases
3. Halt rollout or rollback to previous version

---

## Monitoring

### Sentry Dashboard

Monitor crashes and errors at [sentry.io](https://sentry.io)

- Filter by release version
- Track crash-free percentage
- Review stack traces

### Analytics

User analytics tracked via:
- Supabase (database queries)
- Custom telemetry events

---

## Deployment Checklist

### Before Release

- [ ] All tests passing
- [ ] No critical Sentry errors
- [ ] Version bumped
- [ ] CHANGELOG updated
- [ ] Code reviewed and merged
- [ ] Manual smoke test on device

### After Release

- [ ] Monitor Sentry for new errors
- [ ] Check Play Console for ANRs/crashes
- [ ] Verify OTA update delivery
- [ ] Update documentation if needed

---

## Troubleshooting

### Shorebird patch fails

```bash
# Ensure you're logged in
shorebird login

# Check release exists
shorebird releases list

# Rebuild with same version
shorebird release android --force
```

### Build signing issues

Ensure keystore is configured in `android/key.properties`:

```properties
storePassword=xxx
keyPassword=xxx
keyAlias=xxx
storeFile=/path/to/keystore.jks
```

### Vercel deployment fails

```bash
# Check build logs
vercel logs

# Rebuild
vercel --force
```
