# UI Kit - Typography Audit

> `lib/ui/kit/` hardcoded fontSize values

## Summary
- **Total**: 26 instances
- **tokens.dart**: 8 (defines the typography - OK)
- **To migrate**: 18

---

## class_details_sheet.dart (5 instances)

| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 437 | 20 | `typography.title` |
| 450 | 14 | `typography.bodySecondary` |
| 746 | 16 | `typography.body` |
| 855 | 12 | `typography.caption` |
| 863 | 15 | `typography.bodySecondary` |

---

## reminder_details_sheet.dart (4 instances)

| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 154 | 20 | `typography.title` |
| 167 | 14 | `typography.bodySecondary` |
| 516 | 12 | `typography.caption` |
| 524 | 15 | `typography.bodySecondary` |

---

## screen_shell.dart (2 instances)

| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 224 | 21 | `typography.title` |
| 319 | 17 | `typography.subtitle` |

---

## brand_header.dart (2 instances)

| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 66 | 22 | `typography.title` |
| 71 | 22 | `typography.title` |

---

## alarm_preview.dart (3 instances)

| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 344 | 12 | `typography.caption` |
| 461 | 17 | `typography.subtitle` |
| 471 | 12 | `typography.caption` |

---

## Other Files

| File | Line | fontSize | Suggested |
|------|------|----------|-----------|
| status_chip.dart | 38 | 12 | `typography.caption` |
| animations.dart | 914 | 11 | `typography.caption` |

---

## Intentional (tokens.dart) ✅

These define the typography tokens - keep as-is:
```
Line 198: fontSize: 32  → display
Line 204: fontSize: 26  → headline
Line 210: fontSize: 20  → title
Line 216: fontSize: 16  → subtitle
Line 222: fontSize: 16  → body
Line 228: fontSize: 14  → bodySecondary
Line 234: fontSize: 12  → caption
Line 241: fontSize: 14  → label
```
