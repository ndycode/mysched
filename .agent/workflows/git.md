---
description: Git add, commit, and push with auto-generated commit message
---

# Git Commit & Push

Automatically stages, commits, and pushes changes with a readable commit message based on conversation changes.

// turbo-all

## Step 1: Review Changes

First, check what files have been modified:

```bash
git status
```

```bash
git diff --stat
```

## Step 2: Gather Commit Context

Analyze the conversation to identify:
- What features were added
- What bugs were fixed
- What was refactored
- What was improved

## Step 3: Generate Commit Message

Use conventional commit format:

```
<type>(<scope>): <short description>

<body with details>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring
- `style` - UI/styling changes
- `chore` - Maintenance tasks
- `docs` - Documentation
- `perf` - Performance improvement

**Example:**
```
feat(instructor): add alphabetical sorting and search highlighting

- Sort instructors A-Z by last name
- Add letter section headers (A, B, C...)
- Highlight matching text in search
- Add quick-scroll alphabet sidebar
- Color-code department badges
```

## Step 4: Stage All Changes

```bash
git add -A
```

## Step 5: Commit with Message

```bash
git commit -m "<generated message>"
```

## Step 6: Push to Remote

```bash
git push origin main
```

Or if on a different branch:
```bash
git push origin <current-branch>
```

## Step 7: Confirm

Report to user:
- Files committed
- Commit hash
- Push status
- Link to view commit (if GitHub/GitLab)

---

## Commit Message Templates

### Feature
```
feat(<component>): <what was added>

- Bullet point details
- Another detail
```

### Bug Fix
```
fix(<component>): <what was fixed>

- Root cause
- Solution applied
```

### Multiple Changes
```
feat(<scope>): <primary change>

Features:
- Feature 1
- Feature 2

Fixes:
- Fix 1

Improvements:
- Improvement 1
```

### Shorebird Patch
```
chore(release): deploy patch <N>

Changes in this patch:
- Change 1
- Change 2

Deployed via Shorebird OTA
```

---

## Quick Command

```powershell
git add -A; git commit -m "message"; git push
```
