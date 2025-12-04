# App - Audit

> `lib/app/` design system issues

## Summary
| Category | Count |
|----------|-------|
| BorderRadius | 5 |
| Colors | 9 |
| fontSize | 9 |

---

## root_nav.dart

### Colors (7 instances)
| Line | Current | Notes |
|------|---------|-------|
| 181, 196, 213, 220, 234 | `Colors.transparent` | ✅ Keep |
| 281 | `Colors.black.withValues(alpha: 0.18)` | → `colorScheme.shadow` |
| 378 | `Colors.transparent` | ✅ Keep |
| 541 | `Colors.black.withValues(...)` | → `colorScheme.shadow` |

### BorderRadius (1 instance)
| Line | Value | Replace With |
|------|-------|--------------|
| 481 | 14 | `radius.md` |

---

## bootstrap_gate.dart

### BorderRadius (4 instances)
| Line | Value | Replace With |
|------|-------|--------------|
| 547 | 24 | `radius.xl` |
| 724 | 16 | `radius.lg` |
| 743 | 10 | `radius.sm` |
| 825 | 8 | `radius.sm` |

### Colors (2 instances)
| Line | Current | Replace With |
|------|---------|--------------|
| 723 | `Colors.white` | `colorScheme.surface` |
| 729 | `Colors.black.withValues(alpha: 0.04)` | `colorScheme.shadow` |

### Typography (9 instances)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 266 | 42 | Custom (splash logo) |
| 561 | 20 | `typography.title` |
| 570 | 14 | `typography.bodySecondary` |
| 615 | 13 | `typography.caption` |
| 625 | 13 | `typography.caption` |
| 759 | 15 | `typography.bodySecondary` |
| 772 | 13 | `typography.caption` |
| 831 | 12 | `typography.caption` |
