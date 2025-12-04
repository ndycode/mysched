# Widgets Directory Audit

> `lib/widgets/` design system issues
> **Last Updated**: December 5, 2025

## Summary

| Category | Count |
|----------|-------|
| BorderRadius | 0 ✅ |
| fontSize | 1 |
| SizedBox | 3 |
| Colors | 0 ✅ |

---

## Colors ✅ COMPLETE

| File | Line | Before | After |
|------|------|--------|-------|
| schedule_list.dart | 238 | `Colors.white` | `colors.onError` |

---

## Remaining Issues (schedule_list.dart)

| Line | Pattern | Value |
|------|---------|-------|
| 100 | SizedBox(height:) | 12 |
| 306 | fontSize | 15 |
| 313 | SizedBox(width:) | 8 |
| 333 | SizedBox(height:) | 6 |

> Low priority - only 3 spacing/font issues remaining
