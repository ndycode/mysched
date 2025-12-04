# UI Kit - Colors Audit

> `lib/ui/` Colors.* issues (excluding Colors.transparent)

## Summary
- **Total**: 65+ instances
- **Intentional** (tokens.dart, theme defaults): ~15
- **To migrate**: ~50

---

## glass_navigation_bar.dart (10+ instances)

| Line | Current | Notes |
|------|---------|-------|
| 41 | `Colors.white`, `Colors.white.withValues(alpha: 0.9)` | Nav background |
| 47 | `Colors.black.withValues(alpha: 0.42)` | Dark blur |
| 255 | `Colors.black54` | Text color |
| 281 | `Colors.transparent` | ✅ Keep |
| 357 | `Colors.white.withValues(alpha: 0.96)` | FAB background |
| 359 | `Colors.black`, `Colors.black.withValues(alpha: 0.08)` | Shadow |
| 380 | `Colors.transparent` | ✅ Keep |

---

## containers.dart (5 instances)

| Line | Current | Replace With |
|------|---------|--------------|
| 240 | `Colors.white` | `colorScheme.surface` |
| 255 | `Colors.black.withValues(alpha: 0.08)` | `colorScheme.shadow` |
| 256 | `Colors.black.withValues(alpha: 0.05)` | `colorScheme.shadow` |
| 268 | `Colors.transparent` | ✅ Keep |

---

## animations.dart (10+ instances)

| Line | Current | Notes |
|------|---------|-------|
| 757 | `Colors.white.withValues(alpha: 0.08)` | Skeleton dark |
| 758 | `Colors.black.withValues(alpha: 0.06)` | Skeleton light |
| 766 | `Colors.white.withValues(alpha: 0.1)` | Shimmer dark |
| 767 | `Colors.black.withValues(alpha: 0.04)` | Shimmer light |
| 856 | `Colors.orange` | Warning color |
| 1081 | `Colors.black.withValues(alpha: 0.4)` | Overlay |

---

## buttons.dart (3 instances)

| Line | Current | Replace With |
|------|---------|--------------|
| 279 | `Colors.white.withValues(alpha: 0.12)` | Use theme |
| 280 | `Colors.black.withValues(alpha: 0.08)` | Use theme |

---

## snack_bars.dart (3 instances)

| Line | Current | Context |
|------|---------|---------|
| 33 | `Colors.white` | Success text |
| 45 | `Colors.white` | Error text |
| 57 | `Colors.white` | Info text |

---

## auth_shell.dart (3 instances)

| Line | Current | Replace With |
|------|---------|--------------|
| 86 | `Colors.white` | `colorScheme.surface` |
| 96 | `Colors.black.withValues(alpha: 0.15)` | `colorScheme.shadow` |

---

## class_details_sheet.dart (2 instances)

| Line | Current |
|------|---------|
| 710 | `Colors.white` |
| 837 | `Colors.transparent` |

---

## reminder_details_sheet.dart (2 instances)

| Line | Current |
|------|---------|
| 502 | `Colors.transparent` |

---

## Other Files

| File | Line | Current |
|------|------|---------|
| hero_avatar.dart | 74, 82 | `Colors.white`, `Colors.transparent` |
| layout.dart | 71 | `Colors.transparent` |
| overlay_sheet.dart | 197, 245 | `Colors.transparent`, `Colors.black54` |
| screen_shell.dart | 164 | `Colors.transparent` |
| consent_dialog.dart | 36 | `Colors.transparent` |
| brand_scaffold.dart | 107 | `Colors.transparent` |
| brand_header.dart | 79 | `Colors.transparent` |
| pressable_scale.dart | 281 | `Colors.transparent` |

---

## Intentional (tokens.dart) ✅

These define the color palette - keep as-is:
- Line 9, 33, 57: `Colors.white` for `onPrimary`

## Intentional (app_theme.dart) ✅

These are theme config - keep as-is:
- Lines 50, 55, 62, 67, 216, 223, 230: `Colors.transparent`
- Lines 320, 335, 336: `Colors.white`, `Colors.black`, `Colors.black54`
