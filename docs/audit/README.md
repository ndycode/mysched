# Design System Audit - Complete Analysis

> Deep file-by-file analysis of entire lib/
> **Last Updated**: December 5, 2024

## ✅ FULLY MIGRATED

| Directory | Status |
|-----------|--------|
| lib/screens/ | ✅ Complete |
| lib/ui/kit/ | ✅ Complete |

---

## 🟡 REMAINING ISSUES

### lib/app/ (~20 issues)

#### root_nav.dart (7)
| Line | Type | Value | Notes |
|------|------|-------|-------|
| 181, 196, 213, 220, 234 | `Colors.transparent` | ✅ | Modal backgrounds |
| 281 | `Colors.black.withValues()` | Shadow | Consider `colors.shadow` |
| 307, 314, 321 | `SizedBox(height: 12)` | spacing | `spacing.md` |
| 439 | `SizedBox(height: 8)` | spacing | `spacing.sm` |
| 481 | `BorderRadius.circular(14)` | radius | `radius.md` |
| 487 | `SizedBox(width: 16)` | spacing | `spacing.lg` |
| 498 | `SizedBox(height: 4)` | spacing | `spacing.xs` |
| 541 | `Colors.black.withValues()` | Shadow | Consider `colors.shadow` |
| 559 | `SizedBox(height: 14)` | spacing | Custom |

#### bootstrap_gate.dart (15) - Onboarding/Setup
| Line | Type | Value | Notes |
|------|------|-------|-------|
| 266 | `fontSize: 42` | Display text | Splash screen - intentional? |
| 547 | `BorderRadius.circular(24)` | Dialog | `radius.xl` |
| 548 | `const Color(0xFFF5F7FA)` | Background | Light-mode fallback |
| 561, 570 | `fontSize: 20, 14` | Text | `typography.title/bodySecondary` |
| 615, 625 | `fontSize: 13` | Caption | `typography.caption` |
| 723 | `Colors.white` | Background | Light-mode fallback |
| 724 | `BorderRadius.circular(16)` | Card | `radius.lg` |
| 729 | `Colors.black.withValues()` | Shadow | Could use token |
| 743 | `BorderRadius.circular(10)` | Badge | `radius.md` |
| 759, 772 | `fontSize: 15, 13` | Text | `typography.body/caption` |
| 809 | `const Color(0xFFE8EBF0)` | Background | Light-mode fallback |
| 816, 818 | `const Color(0xFFFF9500)` | Warning pill | Custom orange |
| 825 | `BorderRadius.circular(8)` | Pill | `radius.sm` |
| 831 | `fontSize: 12` | Label | `typography.caption` |

---

### lib/widgets/schedule_list.dart (4)
| Line | Type | Value | Notes |
|------|------|-------|-------|
| 100 | `SizedBox(height: 12)` | spacing | `spacing.md` |
| 306 | `fontSize: 15` | Text | `typography.body` |
| 313 | `SizedBox(width: 8)` | spacing | `spacing.sm` |
| 333 | `SizedBox(height: 6)` | spacing | `spacing.xs` |

---

### lib/ui/kit/ - Intentional const Color() (6)
These use ternary for dark/light modes:

| File | Line | Purpose |
|------|------|---------|
| screen_shell.dart | 227, 322 | `const Color(0xFF1A1A1A)` light mode text |
| reminder_details_sheet.dart | 156, 165 | `const Color(0xFF1A1A1A/0xFF757575)` light mode fallback |
| overlay_sheet.dart | 10, 188 | `const Color(0x4D000000)` barrier default |
| theme_transition_host.dart | 86, 87 | `const Color(...)` transition scrim |

> These are intentional light-mode fallbacks where colorScheme doesn't have exact equivalents.

---

## Summary

| Category | lib/app/ | lib/widgets/ | Total |
|----------|----------|--------------|-------|
| BorderRadius | 5 | 0 | 5 |
| SizedBox | 7 | 3 | 10 |
| fontSize | 8 | 1 | 9 |
| Colors | 3 | 0 | 3 |
| const Color() | 4 | 0 | 4 |
| **Total** | **27** | **4** | **31** |

Plus 6 intentional const Colors in ui/kit/ (light-mode fallbacks).
