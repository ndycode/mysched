---
description: Deploy a Shorebird OTA patch to production
---

# Deploy Shorebird Patch

Builds and deploys an OTA patch via Shorebird with auto-confirmation.

// turbo-all

## Step 1: Run Flutter Analyze

First ensure no errors in the codebase:

```bash
flutter analyze --no-fatal-infos
```

If there are errors, stop and fix them before proceeding.

## Step 2: Build and Deploy Patch

Deploy the patch with auto-confirmation using echo piping:

```bash
echo y | shorebird patch --platforms android
```

This will:
- Build the patch with current Flutter version
- Upload to Shorebird servers
- Promote to stable channel
- Auto-confirm with "y"

## Step 3: Update Changelog

After successful deployment, update CHANGELOG.md:
- Find the pending patches section
- Mark the deployed patch as `✅ Deployed [DATE]`
- Note the patch number shown in terminal output

## Step 4: Confirm to User

Report:
- Patch number deployed (e.g., "Patch 7")
- Any errors encountered
- Remind to test on a physical device

---

## Quick Command (Copy-Paste Ready)

```powershell
flutter analyze --no-fatal-infos; if ($?) { echo y | shorebird patch --platforms android }
```
