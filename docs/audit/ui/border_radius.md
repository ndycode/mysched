# UI Kit - Border Radius Audit

> `lib/ui/kit/` and `lib/ui/theme/` BorderRadius.circular issues

## Summary
- **lib/ui/kit/**: 32 instances
- **lib/ui/theme/**: 16 instances
- **Total**: 48 instances

---

## app_theme.dart (16 instances)

> Note: These define theme defaults - may be intentional

| Line | Value | Context |
|------|-------|---------|
| 71 | 16 | CardTheme |
| 87 | 10 | ChipTheme |
| 102 | 26 | FilledButtonTheme |
| 119 | 26 | ElevatedButtonTheme |
| 135 | 26 | OutlinedButtonTheme |
| 150 | 26 | TextButtonTheme |
| 162 | 16 | SegmentedButtonTheme |
| 168 | 16 | SegmentedButtonTheme |
| 174 | 16 | SegmentedButtonTheme |
| 181 | 16 | SegmentedButtonTheme |
| 187 | 16 | SegmentedButtonTheme |
| 211 | 6 | CheckboxTheme |
| 225 | 20 | SnackBarTheme |
| 232 | 14 | BottomSheetTheme |
| 243 | 14 | DialogTheme |
| 254 | 20 | PopupMenuTheme |

---

## class_details_sheet.dart (9 instances)

| Line | Value | Replace With |
|------|-------|--------------|
| 416 | 14 | `radius.md` |
| 464 | 12 | `radius.md` |
| 569 | 16 | `radius.lg` |
| 711 | 16 | `radius.lg` |
| 838 | 8 | `radius.sm` |
| 967 | 14 | `radius.md` |
| 996 | 14 | `radius.md` |
| 1027 | 14 | `radius.md` |
| 1052 | 14 | `radius.md` |

---

## reminder_details_sheet.dart (8 instances)

| Line | Value | Replace With |
|------|-------|--------------|
| 133 | 14 | `radius.md` |
| 181 | 12 | `radius.md` |
| 237 | 16 | `radius.lg` |
| 355 | 14 | `radius.md` |
| 367 | 14 | `radius.md` |
| 391 | 14 | `radius.md` |
| 412 | 14 | `radius.md` |
| 503 | 8 | `radius.sm` |

---

## glass_navigation_bar.dart (6 instances)

| Line | Value | Replace With |
|------|-------|--------------|
| 314 | 999 | `radius.pill` |
| 373 | 30 | `radius.xxxl` |
| 395 | 22 | `radius.xl` |
| 429 | 34 | `radius.xxxl` |
| 461 | 999 | `radius.pill` |
| 515 | 28 | `radius.xxl` |

---

## buttons.dart (3 instances)

| Line | Value | Replace With |
|------|-------|--------------|
| 91 | 26 | `radius.xxl` |
| 187 | 26 | `radius.xxl` |
| 272 | 26 | `radius.xxl` |

---

## Other Files

| File | Line | Value | Replace With |
|------|------|-------|--------------|
| states.dart | 334 | 20 | `radius.xl` |
| states.dart | 455 | 16 | `radius.lg` |
| snack_bars.dart | 81 | 20 | `radius.xl` |
| status_chip.dart | 27 | 999 | `radius.pill` |
| auth_shell.dart | 87 | 24 | `radius.xl` |
| animations.dart | 339 | 12 | `radius.md` |
