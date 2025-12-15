---
description: Update CHANGELOG.md with conversation changes and patch notes
---

# Update Changelog Workflow

When the user triggers this workflow (mentions `/update-changelog`), automatically gather all changes and update the changelog.

// turbo-all

## Step 1: Gather Conversation Changes

Automatically review all changes made during this conversation:
- Check the walkthrough.md or task.md artifacts if they exist
- Review any edited files from the conversation history
- Create a comprehensive list of features, fixes, and improvements

## Step 2: Check Current Version Info

Run these commands to get current version and patch info:

```bash
# Check pubspec version
grep "^version:" pubspec.yaml
```

```bash
# Check shorebird patches (if available)
shorebird patch list --platform android 2>&1 | head -20
```

## Step 3: Read Current CHANGELOG.md

View the existing changelog to find:
- Current version header format
- Last patch number used
- Existing categories

```bash
head -70 CHANGELOG.md
```

## Step 4: Determine Next Patch Number

From the CHANGELOG, find the last patch number (e.g., "Patch 6") and use the next number for new changes. If there are no patches yet for the current version, start with Patch 1.

## Step 5: Update CHANGELOG.md

Add changes at the TOP of the file (after `# Changelog` header) using this format:

### For changes not yet deployed:
```markdown
### 🔧 Patches (OTA via Shorebird)

#### Patch N: Short Title
- **Feature/Fix Name**: Description of what was changed
- Additional bullet points for details

> ⏳ Pending deployment
```

### Category Emojis:
- 🎨 **UI/Design** - Visual updates, styling
- ✨ **Features** - New functionality
- 🛠️ **Bug Fixes** - Fixed issues
- 🔧 **Patches** - Shorebird OTA updates
- ⚡ **Performance** - Speed improvements

## Step 6: Mark as Complete

After updating, inform the user:
- What was added to the changelog
- The patch number used
- Remind them to run `shorebird patch --platforms android` when ready to deploy

---

## Quick Reference

**Version location**: `pubspec.yaml` line 4 (format: `X.Y.Z+BUILD`)

**CHANGELOG format**:
```markdown
## [VERSION] - DATE

### 🔧 Patches (OTA via Shorebird)

#### Patch N: Title
- **Change**: Description

> ⏳ Pending deployment
```
