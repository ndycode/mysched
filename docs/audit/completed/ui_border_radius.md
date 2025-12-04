# UI Kit - Border Radius Audit

> BorderRadius.circular in `lib/ui/` (Verified)
> **Last Updated**: December 5, 2024

## Summary
- **Total**: 18
- **Fixed**: 30+ instances migrated to `AppTokens.radius`
- **Remaining**: 18 (16 theme defaults + 2 intentional dynamic)
- **Status**: 🟢 **Complete!**

---

## ⏭️ Theme Defaults - app_theme.dart (16)

These define Flutter's MaterialTheme defaults. Keep as direct values.

| Line | Value | Context |
|------|-------|---------|
| 71 | 16 | CardTheme |
| 87 | 10 | ChipTheme |
| 102, 119, 135, 150 | 26 | Button themes |
| 162, 168, 174, 181, 187 | 16 | SegmentedButton |
| 211 | 6 | Checkbox |
| 225, 254 | 20 | SnackBar, PopupMenu |
| 232, 243 | 14 | BottomSheet, Dialog |

---

## ⏭️ Intentional Dynamic Values (2)

| File | Line | Value | Reason |
|------|------|-------|--------|
| glass_navigation_bar.dart | 427 | 34 | Half of FAB size (68/2) |
| animations.dart | 340 | 12 | Nullable fallback default |

---

## ✅ Already Migrated (30+)

- `class_details_sheet.dart` (9)
- `reminder_details_sheet.dart` (8)
- `glass_navigation_bar.dart` (5)
- `buttons.dart` (3)
- `states.dart` (2)
- `snack_bars.dart` (1)
- `status_chip.dart` (1)
- `auth_shell.dart` (1)

