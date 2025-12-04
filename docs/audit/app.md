# App Directory Audit

> `lib/app/` hardcoded values (Deep analysis)
> **Last Updated**: December 5, 2024

## Summary
- **root_nav.dart**: 9 issues (SizedBox, shadow, BorderRadius)
- **bootstrap_gate.dart**: 18 issues (onboarding dialogs)
- **Total**: ~27

---

## root_nav.dart (9)

### SizedBox (7)
| Line | Type | Value | Token |
|------|------|-------|-------|
| 307 | height | 12 | `spacing.md` |
| 314 | height | 12 | `spacing.md` |
| 321 | height | 12 | `spacing.md` |
| 439 | height | 8 | `spacing.sm` |
| 487 | width | 16 | `spacing.lg` |
| 498 | height | 4 | `spacing.xs` |
| 559 | height | 14 | Custom |

### BorderRadius (1)
| Line | Value | Token |
|------|-------|-------|
| 481 | 14 | `radius.md` |

### Colors (1)
| Line | Current | Notes |
|------|---------|-------|
| 281, 541 | `Colors.black.withValues()` | Shadow - could use `colors.shadow` |

---

## bootstrap_gate.dart (18)

### fontSize (8)
| Line | Value | Context |
|------|-------|---------|
| 266 | 42 | Splash brand text |
| 561 | 20 | Dialog title |
| 570 | 14 | Dialog body |
| 615 | 13 | Loading text |
| 625 | 13 | Status text |
| 759 | 15 | Row label |
| 772 | 13 | Description |
| 831 | 12 | Pill label |

### BorderRadius (4)
| Line | Value | Token |
|------|-------|-------|
| 547 | 24 | `radius.xl` |
| 724 | 16 | `radius.lg` |
| 743 | 10 | `radius.md` |
| 825 | 8 | `radius.sm` |

### Colors + const Color() (6)
| Line | Current | Notes |
|------|---------|-------|
| 548 | `const Color(0xFFF5F7FA)` | Light mode bg |
| 723 | `Colors.white` | Light mode fallback |
| 729 | `Colors.black.withValues()` | Shadow |
| 809 | `const Color(0xFFE8EBF0)` | Light mode bg |
| 816, 818 | `const Color(0xFFFF9500)` | Warning orange |

---

## Priority

**Low priority** - These are onboarding/setup screens shown briefly. Consider:
1. Keep as-is for splash/onboarding (isolated context)
2. Or migrate systematically if uniformity is important
