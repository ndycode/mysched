---
description: Quick check of recently changed files only
---

# Quick Check Recent Changes

Fast analysis of only recently modified or staged files.

// turbo-all

## Step 1: Find Recently Changed Files

Get files changed in the last commit or staged:

```bash
git diff --name-only HEAD~1 -- "*.dart"
```

Or staged files:
```bash
git diff --cached --name-only -- "*.dart"
```

## Step 2: Analyze Only Changed Files

Run analysis on specific files:

```bash
flutter analyze [list of changed files]
```

## Step 3: Quick Pattern Check

Use grep_search tool to check changed files for:
- `print(` statements
- `TODO/FIXME` comments
- Empty catch blocks

## Step 4: Report

Summarize:
- Files checked
- Issues found
- Quick fixes needed

---

## When to Use

- Before committing changes
- Quick sanity check during development
- Faster than full codebase analysis
