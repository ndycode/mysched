---
description: Deep analysis of codebase for issues, improvements, and recommendations
---

# Run Deep Analysis

Performs comprehensive analysis of the entire codebase to find issues, anti-patterns, and improvement opportunities.

## Step 1: Flutter Static Analysis

Run standard Flutter analyzer:

// turbo
```bash
flutter analyze
```

Review all warnings and errors. Categorize by severity.

## Step 2: Check for Unused Code

Find unused imports and dead code:

// turbo
```bash
flutter analyze --no-fatal-infos 2>&1 | findstr /i "unused"
```

## Step 3: Dependency Audit

Check for outdated packages:

// turbo
```bash
flutter pub outdated
```

Note packages with major version updates available.

## Step 4: Deep Code Review

Manually analyze these areas:

### Architecture Issues
- [ ] Services following singleton pattern correctly?
- [ ] State management consistent across screens?
- [ ] Proper error handling in async code?

### Performance
- [ ] Rebuild optimization (const constructors)?
- [ ] Image caching implemented?
- [ ] List virtualization for long lists?

### UI/UX Consistency
- [ ] All components using `AppTokens`?
- [ ] Responsive scaling with `ResponsiveProvider`?
- [ ] Consistent spacing and typography?

### Security
- [ ] No hardcoded secrets in code?
- [ ] Proper input validation?
- [ ] Secure storage for sensitive data?

### Supabase
- [ ] RLS policies properly configured?
- [ ] Queries optimized (avoiding N+1)?
- [ ] Error handling for network failures?

## Step 5: Search for Common Issues

Check for common anti-patterns:

// turbo
```bash
rg "print\(" --type dart | head -20
```

// turbo
```bash
rg "TODO|FIXME|HACK" --type dart
```

// turbo
```bash
rg "catch \(e\) \{\s*\}" --type dart
```

## Step 6: Generate Report

Create a summary report with:

### 🔴 Critical Issues
- Must fix immediately

### 🟡 Warnings
- Should fix soon

### 🔵 Suggestions
- Nice to have improvements

### 📊 Metrics
- Total files analyzed
- Issues by category
- Recommended priorities

---

## Quick Analysis (Copy-Paste)

```powershell
flutter analyze; flutter pub outdated; rg "TODO|FIXME" --type dart | Measure-Object -Line
```
