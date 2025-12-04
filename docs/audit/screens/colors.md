# Screens - Colors Audit (Complete)

> All hardcoded Colors.* values in `lib/screens/`

## Summary
- **Total instances**: 118+
- **Colors.transparent**: ~30 (OK to keep)
- **Actionable**: ~88

---

## By File

### settings_screen.dart (27)
| Line | Current | Replace With |
|------|---------|--------------|
| 165 | `Colors.transparent` | ✅ Keep |
| 171 | `Colors.white` | `colorScheme.surface` |
| 181 | `Colors.black.withValues(alpha: 0.15)` | `colorScheme.shadow` |
| 418 | `Colors.white` | `colorScheme.surface` |
| 428 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 443 | `Colors.white` | `colorScheme.surface` |
| 453 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 468 | `Colors.white` | `colorScheme.surface` |
| 478 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 493 | `Colors.white` | `colorScheme.surface` |
| 503 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 522 | `Colors.white` | `colorScheme.surface` |
| 532 | `Colors.black.withValues(alpha: 0.05)` | `colorScheme.shadow` |
| 552 | `Colors.white` | `colorScheme.surface` |
| 562 | `Colors.black.withValues(alpha: 0.05)` | `colorScheme.shadow` |
| 595 | `Colors.white` | `colorScheme.surface` |
| 605 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 623 | `Colors.white` | `colorScheme.surface` |
| 633 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 851 | `Colors.white` | `colorScheme.onPrimary` |
| 852 | `Colors.black` | `colorScheme.onSurface` |
| 864 | `Colors.white` | `colorScheme.onPrimary` |
| 875 | `Colors.white` | `colorScheme.onPrimary` |
| 886 | `Colors.transparent` | ✅ Keep |
| 1486 | `Colors.transparent` | ✅ Keep |
| 1495 | `Colors.transparent` | ✅ Keep |
| 1525 | `Colors.white` | `colorScheme.onPrimary` |

### schedules_screen.dart (10)
| Line | Current | Notes |
|------|---------|-------|
| 141 | `Colors.transparent` | ✅ Keep |
| 151 | `Colors.transparent` | ✅ Keep |
| 165 | `Colors.transparent` | ✅ Keep |
| 263 | `Colors.white` | `colorScheme.surface` |
| 264 | `Colors.transparent` | ✅ Keep |
| 265 | `Colors.black.withValues(...)` | `colorScheme.shadow` |
| 271 | `Colors.transparent` | ✅ Keep |
| 309 | `Colors.transparent` | ✅ Keep |
| 364 | `Colors.transparent` | ✅ Keep |
| 636 | `Colors.white` | `colorScheme.surface` |

### schedules_cards.dart (10+)
| Line | Current | Replace With |
|------|---------|--------------|
| 114 | `Colors.white` | `colorScheme.surface` |
| 124 | `Colors.black.withValues(alpha: 0.06)` | `colorScheme.shadow` |
| 553 | `Colors.white` | `colorScheme.surface` |
| 563 | `Colors.black.withValues(alpha: 0.05)` | `colorScheme.shadow` |
| 681 | `Colors.white` | `colorScheme.onPrimary` |
| 1140 | `Colors.transparent` | ✅ Keep |
| 1150 | `Colors.white` | `colorScheme.surface` |
| 1162 | `Colors.black.withValues(...)` | `colorScheme.shadow` |

### schedules_messages.dart (2)
| Line | Current | Replace With |
|------|---------|--------------|
| 41 | `Colors.white` | `colorScheme.surface` |
| 53 | `Colors.black.withValues(alpha: 0.05)` | `colorScheme.shadow` |

### schedules_preview_sheet.dart (2)
| Line | Current | Replace With |
|------|---------|--------------|
| 143 | `Colors.white` | `colorScheme.surface` |
| 153 | `Colors.black.withValues(alpha: 0.15)` | `colorScheme.shadow` |

### reminders_cards.dart (8+)
| Line | Current |
|------|---------|
| Multiple | `Colors.white`, `Colors.black`, `Colors.transparent` |

### dashboard_cards.dart (6+)
| Line | Current |
|------|---------|
| Multiple | `Colors.white`, `Colors.black`, `Colors.transparent` |

---

## Color Mapping Reference

| Hardcoded | Semantic Replacement |
|-----------|---------------------|
| `Colors.white` (backgrounds) | `colorScheme.surface` |
| `Colors.white` (on primary) | `colorScheme.onPrimary` |
| `Colors.black` (text) | `colorScheme.onSurface` |
| `Colors.black.withOpacity(X)` | `colorScheme.shadow.withOpacity(X)` |
| `Colors.transparent` | ✅ Keep as-is |
| `Colors.grey` | `colorScheme.outline` |

---

## Notes

- Many `Colors.white` usages are in ternaries: `isDark ? colors.surfaceContainerHigh : Colors.white`
- Replace entire ternary with `colorScheme.surface` or `colorScheme.surfaceContainerHigh`
- `Colors.transparent` is acceptable and doesn't need replacement
