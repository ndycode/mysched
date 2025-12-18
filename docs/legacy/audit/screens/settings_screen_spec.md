# Settings Screen - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `settings_screen.dart` (1,541 lines) - Main screen with all section cards
- `settings_controller.dart` (385 lines) - State management (no UI)

**Total: ~1,926 lines (1,541 UI lines)**

---

# settings_screen.dart (Lines 1-1541)

## ScreenShell Padding (Lines 641-652)
| Property | Token | Px Value |
|----------|-------|---------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxxl` | safe + 32px |
| bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 40px + safe |

## Loading Skeleton (Lines 320-340)
| Property | Token | Px Value |
|----------|-------|---------|
| skeleton gap | `spacing.lg` | 16px |
| skeleton line count (first) | 4 | - |
| skeleton line count (second) | 3 | - |

---

## Option Picker Dialog (Lines 151-273)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| insetPadding | `spacing.lg` | 16px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.statusBg` | 0.16 |
| blurRadius | `shadow.xxl` | 32px |
| offset | `AppShadowOffset.modal` | (0, 16) |

### Header
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| font | `textTheme.titleLarge` | 22px |
| fontWeight | `fontWeight.bold` | w700 |

### Options List
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.xl` | 20px |
| padding v | `spacing.md` | 12px |
| check icon size | `iconSize.md` | 20px |
| selected weight | `fontWeight.semiBold` | w600 |
| normal weight | `fontWeight.regular` | w400 |

### Footer
| Property | Token | Px Value |
|----------|-------|---------|
| list→footer gap | `spacing.md` | 12px |
| footer padding | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

## Premium Header (Lines 351-408)

### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.avatarXl` | 48px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.statusBg` | 0.16 |
| gradient end alpha | `AppOpacity.overlay` | 0.12 |
| border alpha | `AppOpacity.ghost` | 0.30 |
| icon size | `iconSize.xl` | 28px |
| icon→text gap | `spacing.lg` | 16px |

### Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.headline` | 26px |
| fontWeight | `fontWeight.bold` | w700 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |
| title→subtitle gap | `spacing.xs` | 4px |
| subtitle font | `typography.body` | 15px |
| subtitle lineHeight | `AppTypography.bodyLineHeight - 0.1` | 1.4 |

---

## Section Card Container (Lines 409-639)

### Container (repeated pattern)
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.05 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.sm` | (0, 4) |

### Sync Card (Lines 585-611)
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| (rest same as container) | | |

### Admin/Android Cards (Lines 511-568)
| Property | Token | Px Value |
|----------|-------|---------|
| blurRadius | `shadow.md` | 12px |
| (rest same as container) | | |

---

## _buildNotificationCard (Lines 662-717)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

### Quiet Week Info Box
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.md` | 12px |
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| fontWeight | `fontWeight.semiBold` | w600 |

---

## _buildScheduleCard (Lines 719-745)

| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

## _buildAlarmSettingsCard (Lines 747-830)

### Volume Slider
| Property | Token | Px Value |
|----------|-------|---------|
| trackHeight | `AppSlider.trackHeight` | 4px |
| thumbRadius | `AppSlider.thumbRadius` | 10px |
| overlayRadius | `AppSlider.overlayRadius` | 20px |
| value→slider gap | `spacing.xs` | 4px |

### Rows
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

## _buildAppearanceCard (Lines 832-900)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| theme option gap | `spacing.sm` | 8px |
| options→hint gap | `spacing.md` | 12px |

---

## _buildAndroidToolsCard (Lines 902-980)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |
| refresh button top gap | `spacing.md` | 12px |

### Refresh Button
| Property | Token | Px Value |
|----------|-------|---------|
| spinner size | `componentSize.badgeMd` | 16px |
| strokeWidth | `spacing.micro` | 2px |
| button height | `componentSize.buttonSm` | 40px |

---

## _buildAdminCard (Lines 982-1031)

| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

## _buildSupportCard (Lines 1034-1073)

| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

## _buildToggleRow (Lines 1075-1137)

| Property | Token | Px Value |
|----------|-------|---------|
| row padding v | `spacing.sm` | 8px |
| icon→content gap | `spacing.md` | 12px |
| title→description gap | `spacing.xs` | 4px |
| content→switch gap | `spacing.md` | 12px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.semiBold` | w600 |
| track alpha | `AppOpacity.track` | 0.35 |

---

## _buildStatusPill (Lines 1139-1173)

| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.md` | 12px |
| padding v | `spacing.sm` | 8px |
| borderRadius | `radius.pill` | 9999px |
| ok bg alpha | `AppOpacity.statusBg` | 0.16 |
| fontWeight | `fontWeight.bold` | w700 |

---

## _buildNavigationRow (Lines 1175-1240)

| Property | Token | Px Value |
|----------|-------|---------|
| row padding v | `spacing.sm` | 8px |
| icon→content gap | `spacing.md` | 12px |
| title→description gap | `spacing.xs` | 4px |
| content→trailing gap | `spacing.md` | 12px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.semiBold` | w600 |

---

## _buildIconBadge (Lines 1242-1254)

| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.avatarLg` | 44px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.lg` | 24px |

---

## _buildSyncCard (Lines 1256-1387)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| sync rows gap | `spacing.sm` | 8px |
| rows→queue gap | `spacing.md` | 12px |

### Queue Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.md` | 12px |
| padding v | `spacing.sm` | 8px |
| borderRadius | `radius.pill` | 9999px |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.sm` | 8px |
| fontWeight | `fontWeight.semiBold` | w600 |

### Queue Full Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.sm` | 8px |
| padding v | `spacing.xs` | 4px |
| borderRadius | `radius.pill` | 9999px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| fontWeight | `fontWeight.bold` | w700 |

### Buttons
| Property | Token | Px Value |
|----------|-------|---------|
| queue→button gap | `spacing.md` | 12px |
| button gap | `spacing.sm` | 8px |
| button height | `componentSize.buttonMd` | 48px |
| buttons→sync gap | `spacing.md` | 12px |

---

## _SyncRow (Lines 1390-1443)

| Property | Token | Px Value |
|----------|-------|---------|
| row padding v | `spacing.sm` | 8px |
| icon container size | `componentSize.avatarLg` | 44px |
| icon container radius | `radius.md` | 12px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.lg` | 24px |
| icon→label gap | `spacing.md` | 12px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.semiBold` | w600 |

---

## _ThemeOption (Lines 1445-1540)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| height | `componentSize.avatarXxl` | 80px |
| borderRadius | `radius.lg` | 16px |
| border width (selected) | `spacing.micro` | 2px |
| border width (normal) | `componentSize.divider` | 1px |
| outline border alpha | `AppOpacity.ghost` | 0.30 |
| show border alpha | `AppOpacity.dim` | 0.10 |

### Icon
| Property | Token | Px Value |
|----------|-------|---------|
| size | `iconSize.lg` | 24px |

### Check Badge
| Property | Token | Px Value |
|----------|-------|---------|
| top | `spacing.xs` | 4px |
| right | `spacing.xs` | 4px |
| padding | `spacing.micro` | 2px |
| border width | `componentSize.dividerThick` | 1.5px |
| icon size | `iconSize.check` | 12px |

### Label
| Property | Token | Px Value |
|----------|-------|---------|
| container→label gap | `spacing.sm` | 8px |
| selected weight | `fontWeight.bold` | w700 |
| normal weight | `fontWeight.medium` | w500 |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `micro` | 2 |
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `avatarXl` | 48 |
| `avatarXxl` | 80 |
| `avatarLg` | 44 |
| `buttonXs` | 32 |
| `buttonSm` | 40 |
| `buttonMd` | 48 |
| `badgeMd` | 16 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerThick` | 1.5 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `md` | 20 |
| `lg` | 24 |
| `xl` | 28 |
| `check` | 12 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `sm` | 6 |
| `md` | 12 |
| `lg` | 16 |
| `xxl` | 32 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `sm` | (0, 4) |
| `modal` | (0, 16) |

## Slider Values
| Token | Value |
|-------|-------|
| `trackHeight` | 4 |
| `thumbRadius` | 10 |
| `overlayRadius` | 20 |

## Opacity Values
| Token | Value |
|-------|-------|
| `full` | 0.95 |
| `prominent` | 0.85 |
| `track` | 0.35 |
| `ghost` | 0.30 |
| `accent` | 0.20 |
| `statusBg` | 0.16 |
| `medium` | 0.15 |
| `overlay` | 0.12 |
| `dim` | 0.10 |
| `faint` | 0.05 |

---

# ✅ STATUS: 100% TOKENIZED
All ~1,541 UI lines in `settings_screen.dart` fully use design tokens.
