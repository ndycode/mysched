# Widgets - Audit

> `lib/widgets/` design system issues

## Summary
| Category | Count |
|----------|-------|
| Colors | 4 |
| fontSize | 1 |
| BorderRadius | 0 |

---

## schedule_list.dart

### Colors (4 instances)
| Line | Current | Notes |
|------|---------|-------|
| 89 | `Colors.transparent` | ✅ Keep |
| 225 | `Colors.transparent` | ✅ Keep |
| 228 | `Colors.transparent` | ✅ Keep |
| 238 | `Colors.white` | → `colorScheme.onError` (delete icon) |

### Typography (1 instance)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 306 | 15 | `typography.bodySecondary` |
