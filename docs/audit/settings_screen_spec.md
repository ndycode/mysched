# Settings Screen - Full Spec Audit
*Last Updated: 2025-12-06 01:14*

## File: `settings_screen.dart` (1,541 lines)

---

# Option Picker Dialog (Lines 151-272)

| Property | Token | Px Value |
|----------|-------|----------|
| insetPadding | `spacing.lg` | 16px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.statusBg` | 0.13 |
| blurRadius | `shadow.xxl` | 24px |
| offset | `AppShadowOffset.modal` | (0, 16) |
| title padding | `spacing.xl` | 20px |
| row padding h | `spacing.xl` | 20px |
| row padding v | `spacing.md` | 12px |
| check icon size | `iconSize.md` | 20px |
| cancel button height | `componentSize.buttonMd` | 48px |

---

# Premium Header (Lines 351-408)

| Property | Token | Px Value |
|----------|-------|----------|
| icon container | `componentSize.avatarXl` | 48px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.statusBg` | 0.13 |
| gradient end alpha | `AppOpacity.overlay` | 0.12 |
| border alpha | `AppOpacity.ghost` | 0.30 |
| icon size | `iconSize.xl` | 28px |
| icon→text gap | `spacing.lg` | 16px |
| title→subtitle gap | `spacing.xs` | 4px |

---

# Section Cards (Lines 409-640)

## Container (repeated pattern)
| Property | Token | Px Value |
|----------|-------|----------|
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.06 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.sm` | (0, 4) |

## Sync/Support Cards
| Property | Token | Px Value |
|----------|-------|----------|
| borderRadius | `radius.lg` | 16px |

---

# Screen Shell (Lines 641-652)

| Property | Token | Px Value |
|----------|-------|----------|
| padding left/right | `spacing.xl` | 20px |
| padding top | `media.padding.top + spacing.xxxl` | 32px |
| padding bottom | `spacing.quad + bottomNavSafePadding` | 40px + safe |

---

# Notification Card (Lines 662-716)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |
| quiet week banner padding | `spacing.md` | 12px |
| banner radius | `radius.md` | 12px |
| banner bg alpha | `AppOpacity.overlay` | 0.12 |

---

# Schedule Card (Lines 719-744)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

# Alarm Settings Card (Lines 747-829)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| volume label gap | `spacing.xs` | 4px |
| slider track height | `AppSlider.trackHeight` | 4px |
| slider thumb radius | `AppSlider.thumbRadius` | 10px |
| slider overlay radius | `AppSlider.overlayRadius` | 20px |
| row gap | `spacing.lg` | 16px |

---

# Appearance Card (Lines 832-899)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| option gap | `spacing.sm` | 8px |
| description gap | `spacing.md` | 12px |

---

# Android Tools Card (Lines 902-979)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |
| button gap | `spacing.md` | 12px |
| spinner size | `componentSize.badgeMd` | 16px |
| spinner stroke | `spacing.micro` | 2px |
| refresh button height | `componentSize.buttonSm` | 40px |

---

# Admin Card (Lines 982-1031)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

# Support Card (Lines 1034-1072)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

---

# _buildToggleRow (Lines 1075-1136)

| Property | Token | Px Value |
|----------|-------|----------|
| row padding v | `spacing.sm` | 8px |
| icon badge→text gap | `spacing.md` | 12px |
| title→desc gap | `spacing.xs` | 4px |
| text→switch gap | `spacing.md` | 12px |
| track alpha | `AppOpacity.track` | 0.35 |

---

# _buildStatusPill (Lines 1139-1172)

| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.md` | 12px |
| padding v | `spacing.sm` | 8px |
| borderRadius | `radius.pill` | 9999px |
| bg alpha (ok) | `AppOpacity.statusBg` | 0.13 |

---

# _buildNavigationRow (Lines 1175-1239)

| Property | Token | Px Value |
|----------|-------|----------|
| row padding v | `spacing.sm` | 8px |
| icon badge→text gap | `spacing.md` | 12px |
| title→desc gap | `spacing.xs` | 4px |
| text→trailing gap | `spacing.md` | 12px |

---

# _buildIconBadge (Lines 1242-1253)

| Property | Token | Px Value |
|----------|-------|----------|
| size | `componentSize.avatarLg` | 40px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| borderRadius | `radius.sm` | 8px |
| icon size | `iconSize.lg` | 24px |

---

# Sync Card (Lines 1256-1387)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| sync row gap | `spacing.sm` | 8px |
| status pill padding h | `spacing.md` | 12px |
| status pill padding v | `spacing.sm` | 8px |
| status pill radius | `radius.pill` | 9999px |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.sm` | 8px |
| queue full alpha | `AppOpacity.overlay` | 0.12 |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# _SyncRow (Lines 1390-1442)

| Property | Token | Px Value |
|----------|-------|----------|
| row padding v | `spacing.sm` | 8px |
| icon container | `componentSize.avatarLg` | 40px |
| container radius | `radius.md` | 12px |
| icon size | `iconSize.lg` | 24px |
| icon→text gap | `spacing.md` | 12px |
| bg alpha | `AppOpacity.medium` | 0.15 |

---

# _ThemeOption (Lines 1445-1539)

| Property | Token | Px Value |
|----------|-------|----------|
| container height | `componentSize.avatarXxl` | 64px |
| borderRadius | `radius.lg` | 16px |
| selected border width | `spacing.micro` | 2px |
| unselected border width | `componentSize.divider` | 1px |
| icon size | `iconSize.lg` | 24px |
| check icon size | `iconSize.check` | 10px |
| check border width | `componentSize.dividerThick` | 1.5px |
| check inset | `spacing.xs` | 4px |
| check padding | `spacing.micro` | 2px |
| label gap | `spacing.sm` | 8px |
| outline border alpha | `AppOpacity.ghost` | 0.30 |
| light border alpha | `AppOpacity.dim` | 0.10 |

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
| `avatarLg` | 40 |
| `avatarXl` | 48 |
| `avatarXxl` | 64 |
| `buttonSm` | 40 |
| `buttonMd` | 48 |
| `badgeMd` | 16 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerThick` | 1.5 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `check` | 10 |
| `sm` | 16 |
| `md` | 20 |
| `lg` | 24 |
| `xl` | 28 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xxl` | 24 |

## Slider Values
| Token | Value |
|-------|-------|
| `trackHeight` | 4 |
| `thumbRadius` | 10 |
| `overlayRadius` | 20 |

---

# ✅ STATUS: 100% TOKENIZED
All 1,541 lines in settings_screen.dart use design tokens.
