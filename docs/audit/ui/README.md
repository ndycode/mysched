# UI Kit - Deep Audit

> Complete line-by-line analysis of `lib/ui/`

## Grand Summary

| Category | Count | Actionable | Notes |
|----------|-------|------------|-------|
| BorderRadius | 48 | 32 | 16 in app_theme (theme defaults) |
| Colors | 67 | ~35 | Many are Colors.transparent (OK) |
| fontSize | 26 | 18 | 8 in tokens.dart (defines system) |
| SizedBox | 42 | 42 | All need migration |
| EdgeInsets | 9 | 9 | All need migration |

---

## BorderRadius.circular (48 total)

### app_theme.dart (16) - Theme Defaults ⚠️
> These define Flutter's MaterialTheme defaults. Consider migrating to use `AppTokens.radius` for consistency.

| Line | Value | Context |
|------|-------|---------|
| 71 | 16 | CardTheme |
| 87 | 10 | ChipTheme |
| 102, 119, 135, 150 | 26 | Button themes |
| 162, 168, 174, 181, 187 | 16 | SegmentedButtonTheme |
| 211 | 6 | CheckboxTheme |
| 225, 254 | 20 | SnackBar, PopupMenu |
| 232, 243 | 14 | BottomSheet, Dialog |

### class_details_sheet.dart (9)
| Line | Value | Replace With |
|------|-------|--------------|
| 416 | 14 | `radius.md` |
| 464 | 12 | `radius.md` |
| 569 | 16 | `radius.lg` |
| 711 | 16 | `radius.lg` |
| 838 | 8 | `radius.sm` |
| 967, 996, 1027, 1052 | 14 | `radius.md` |

### reminder_details_sheet.dart (8)
| Line | Value | Replace With |
|------|-------|--------------|
| 133 | 14 | `radius.md` |
| 181 | 12 | `radius.md` |
| 237 | 16 | `radius.lg` |
| 355, 367, 391, 412 | 14 | `radius.md` |
| 503 | 8 | `radius.sm` |

### glass_navigation_bar.dart (6)
| Line | Value | Replace With |
|------|-------|--------------|
| 314 | 999 | `radius.pill` |
| 373 | 30 | `radius.xxxl` |
| 395 | 22 | `radius.xl` |
| 429 | 34 | Custom (FAB) |
| 461 | 999 | `radius.pill` |
| 515 | 28 | `radius.xxl` |

### buttons.dart (3)
| Line | Value | Replace With |
|------|-------|--------------|
| 91, 187, 272 | 26 | `radius.xxl` |

### Other Files
| File | Line | Value |
|------|------|-------|
| states.dart | 334 | 20 |
| states.dart | 455 | 16 |
| snack_bars.dart | 81 | 20 |
| status_chip.dart | 27 | 999 |
| auth_shell.dart | 87 | 24 |
| animations.dart | 339 | 12 |

---

## Colors.* (67 total)

### Intentional - Keep ✅

**tokens.dart (3)** - Defines color palette
- Lines 9, 33, 57: `Colors.white` for `onPrimary`

**app_theme.dart (10)** - Theme configuration
- Lines 50, 55, 62, 67, 216, 223, 230: `Colors.transparent`
- Lines 320, 335, 336: `Colors.white`, `Colors.black`, `Colors.black54`

**Colors.transparent throughout** - OK to keep

### Actionable - Migrate

#### glass_navigation_bar.dart (7)
| Line | Current | Replace With |
|------|---------|--------------|
| 41 | `Colors.white`, `Colors.white.withValues(alpha: 0.9)` | `colorScheme.surface` |
| 47 | `Colors.black.withValues(alpha: 0.42)` | `colorScheme.shadow` |
| 255 | `Colors.black54` | `colorScheme.onSurfaceVariant` |
| 281 | `Colors.transparent` | ✅ Keep |
| 357 | `Colors.white.withValues(alpha: 0.96)` | `colorScheme.surface` |
| 359 | `Colors.black`, `Colors.black.withValues(alpha: 0.08)` | `colorScheme.shadow` |
| 380 | `Colors.transparent` | ✅ Keep |

#### containers.dart (4)
| Line | Current | Replace With |
|------|---------|--------------|
| 240 | `Colors.white` | `colorScheme.surface` |
| 255-256 | `Colors.black.withValues(alpha: 0.05/0.08)` | `colorScheme.shadow` |
| 268 | `Colors.transparent` | ✅ Keep |

#### animations.dart (6+)
| Line | Current | Replace With |
|------|---------|--------------|
| 757-758 | `Colors.white/black.withValues()` | Skeleton shimmer |
| 766-767 | `Colors.white/black.withValues()` | Shimmer effect |
| 856 | `Colors.orange` | Custom warning color |
| 1081+ | `Colors.black.withValues(alpha: 0.4)` | Overlay |

#### buttons.dart (2)
| Line | Current | Replace With |
|------|---------|--------------|
| 279 | `Colors.white.withValues(alpha: 0.12)` | Hover overlay |
| 280 | `Colors.black.withValues(alpha: 0.08)` | Hover overlay |

#### snack_bars.dart (3)
| Line | Current | Replace With |
|------|---------|--------------|
| 33, 45, 57 | `Colors.white` | `colorScheme.onPrimary` |

#### auth_shell.dart (2)
| Line | Current | Replace With |
|------|---------|--------------|
| 86 | `Colors.white` | `colorScheme.surface` |
| 96 | `Colors.black.withValues(alpha: 0.15)` | `colorScheme.shadow` |

#### Other Files
| File | Line | Current |
|------|------|---------|
| hero_avatar.dart | 74, 82 | `Colors.white`, `Colors.transparent` |
| class_details_sheet.dart | 710, 837 | `Colors.white`, `Colors.transparent` |
| reminder_details_sheet.dart | 502 | `Colors.transparent` |
| overlay_sheet.dart | 197, 245 | `Colors.transparent`, `Colors.black54` |
| consent_dialog.dart | 36 | `Colors.transparent` |
| brand_scaffold.dart | 107 | `Colors.transparent` |
| brand_header.dart | 79 | `Colors.transparent` |
| layout.dart | 71 | `Colors.transparent` |
| screen_shell.dart | 164 | `Colors.transparent` |
| pressable_scale.dart | 281 | `Colors.transparent` |

---

## fontSize (26 total)

### Intentional - tokens.dart (8) ✅
These DEFINE the typography system:
```
Line 198: 32 → display
Line 204: 26 → headline
Line 210: 20 → title
Line 216: 16 → subtitle
Line 222: 16 → body
Line 228: 14 → bodySecondary
Line 234: 12 → caption
Line 241: 14 → label
```

### Actionable (18)

#### class_details_sheet.dart (5)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 437 | 20 | `typography.title` |
| 450 | 14 | `typography.bodySecondary` |
| 746 | 16 | `typography.body` |
| 855 | 12 | `typography.caption` |
| 863 | 15 | `typography.bodySecondary` |

#### reminder_details_sheet.dart (4)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 154 | 20 | `typography.title` |
| 167 | 14 | `typography.bodySecondary` |
| 516 | 12 | `typography.caption` |
| 524 | 15 | `typography.bodySecondary` |

#### alarm_preview.dart (3)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 344 | 12 | `typography.caption` |
| 461 | 17 | `typography.subtitle` |
| 471 | 12 | `typography.caption` |

#### screen_shell.dart (2)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 224 | 21 | `typography.title` |
| 319 | 17 | `typography.subtitle` |

#### brand_header.dart (2)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 66, 71 | 22 | `typography.title` |

#### Other Files
| File | Line | fontSize |
|------|------|----------|
| status_chip.dart | 38 | 12 |
| animations.dart | 914 | 11 |

---

## SizedBox (42 total)

### class_details_sheet.dart (13)
| Line | Type | Value |
|------|------|-------|
| 192 | height | 12 |
| 204 | height | 8 |
| 428 | width | 16 |
| 445 | height | 4 |
| 457 | width | 12 |
| 727 | height | 12 |
| 737 | width | 14 |
| 751 | height | 2 |
| 797 | width | 6 |
| 846 | width | 14 |
| 858 | height | 2 |
| 868 | height | 4 |
| 1084 | height | 12 |

### reminder_details_sheet.dart (10)
| Line | Type | Value |
|------|------|-------|
| 145 | width | 16 |
| 162 | height | 4 |
| 174 | width | 12 |
| 430 | height | 12 |
| 463 | width | 6 |
| 507 | width | 14 |
| 519 | height | 2 |
| 529 | height | 4 |

### glass_navigation_bar.dart (5)
| Line | Type | Value |
|------|------|-------|
| 154, 161 | width | 10 |
| 166 | width | 6 |
| 305 | height | 6 |
| 453 | height | 8 |

### battery_optimization_sheet.dart (7)
| Line | Type | Value |
|------|------|-------|
| 98, 134, 231 | height | 4 |
| 144, 150, 219 | width | 16 |

### alarm_preview.dart (4)
| Line | Type | Value |
|------|------|-------|
| 290, 296 | width | 10 |
| 336 | width | 6 |
| 465 | height | 2 |

### Other Files
| File | Line | Value |
|------|------|-------|
| brand_header.dart | 93, 233 | 6, 8 |
| brand_scaffold.dart | 89 | 16 |
| screen_shell.dart | 68 | 20 |
| status_chip.dart | 34 | 6 |

---

## EdgeInsets (9 total)

| File | Line | Current |
|------|------|---------|
| class_details_sheet.dart | 461 | `EdgeInsets.all(8)` |
| class_details_sheet.dart | 564 | `EdgeInsets.all(20)` |
| class_details_sheet.dart | 708 | `EdgeInsets.all(16)` |
| class_details_sheet.dart | 835 | `EdgeInsets.all(8)` |
| reminder_details_sheet.dart | 178 | `EdgeInsets.all(8)` |
| reminder_details_sheet.dart | 232 | `EdgeInsets.all(20)` |
| reminder_details_sheet.dart | 500 | `EdgeInsets.all(8)` |
| glass_navigation_bar.dart | 275 | `EdgeInsets.all(12)` |
| pressable_scale.dart | 337 | `EdgeInsets.all(8)` (default param) |
