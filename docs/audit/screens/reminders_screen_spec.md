# Reminders Screen - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `reminders_screen.dart` (565 lines) - Main screen orchestration
- `reminders_cards.dart` (1,165 lines) - Summary, hero, list, row components  
- `reminders_controller.dart` (385 lines) - State management (no UI)
- `reminders_data.dart` (82 lines) - Data models (no UI)
- `reminders_messages.dart` (166 lines) - Message cards, snooze sheet

**Total: ~2,363 lines (1,896 UI lines)**

---

# reminders_screen.dart (Lines 1-565)

## ScreenShell Padding
| Property | Token | Px Value |
|----------|-------|---------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxxl` | safe + 32px |
| bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 40px + safe |
| cacheExtent | `AppLayout.listCacheExtent` | 500px |

## Overlay Sheet Padding (Lines 89-100)
| Property | Token | Px Value |
|----------|-------|---------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxl` | safe + 24px |
| bottom | `media.padding.bottom + spacing.xxl` | safe + 24px |

## Loading Skeleton (Lines 382-404)
| Property | Token | Px Value |
|----------|-------|---------|
| skeleton gap | `spacing.lg` | 16px |
| skeleton line count | 2 | - |
| skeleton item count | 3 | - |

---

## PopupMenuButton (Lines 170-350)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| elevation (dark) | `shadow.sm` | 8px |
| elevation (light) | `shadow.md` | 12px |
| shadow alpha (dark) | `AppOpacity.ghost` | 0.30 |
| shadow alpha (light) | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.lg` | 24px |
| icon alpha | `AppOpacity.high` | 0.90 |

### Menu Items
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.md` | 12px |
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.md` | 20px |
| icon→text gap | `spacing.lg` | 16px |
| font | `typography.bodySecondary` | 14px |
| fontWeight | `fontWeight.medium` | w500 |

### Divider
| Property | Token | Px Value |
|----------|-------|---------|
| height | `componentSize.divider` | 1px |
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.sm` | 8px |
| gradient alpha (dark) | `AppOpacity.accent` | 0.20 |
| gradient alpha (light) | `AppOpacity.divider` | 0.40 |

---

## Empty State Card (Lines 449-511)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.xxl` | 24px |
| padding v | `spacing.quad` | 40px |
| borderRadius | `radius.xl` | 24px |
| border alpha | `AppOpacity.divider` | 0.40 |

### Icon Circle
| Property | Token | Px Value |
|----------|-------|---------|
| size | `spacing.emptyStateSize` | 64px |
| icon size | `spacing.quad` | 40px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.highlight` | 0.08 |
| border alpha | `AppOpacity.accent` | 0.20 |
| border width | `componentSize.dividerThick` | 1.5px |

### Text
| Property | Token | Specs |
|----------|-------|-------|
| title font | `typography.headline` | 26px |
| title weight | `fontWeight.bold` | w700 |
| title letterSpacing | `AppLetterSpacing.tight` | -0.03 |
| title→body gap | `spacing.md` | 12px |
| body font | `typography.bodySecondary` | 14px |
| body lineHeight | `AppLineHeight.body` | 1.5 |
| circle→title gap | `spacing.xxlPlus` | 28px |

---

## Bottom Spacing (Lines 530-534)
| Property | Token | Px Value |
|----------|-------|---------|
| height | `spacing.quad + media.padding.bottom + spacing.xl` | 40 + safe + 20px |

---

# reminders_cards.dart (Lines 1-1165)

## _EmptyHeroPlaceholder (Lines 115-189)

| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xxxl` | 32px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.micro` | 0.04 |
| border alpha | `AppOpacity.dim` | 0.10 |
| border width | `componentSize.divider` | 1px |
| circle size | `spacing.emptyStateSize` | 64px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.highlight` | 0.08 |
| circle border alpha | `AppOpacity.accent` | 0.20 |
| circle border width | `componentSize.dividerThick` | 1.5px |
| icon size | `iconSize.xxl` | 32px |
| circle→title gap | `spacing.xl` | 20px |
| title→subtitle gap | `spacing.sm` | 8px |
| title font | `typography.subtitle` | 16px |
| subtitle alpha | `AppOpacity.secondary` | 0.80 |

---

## ReminderSummaryCard (Lines 191-317)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |

### Header
| Property | Token | Px Value |
|----------|-------|---------|
| title font | `typography.title` | 20px |
| title weight | `fontWeight.bold` | w700 |
| title letterSpacing | `AppLetterSpacing.snug` | -0.01 |
| title→hero gap | `spacing.xl` | 20px |

### Metric Row
| Property | Token | Px Value |
|----------|-------|---------|
| hero→metrics gap | `spacing.xl` | 20px |
| metric gap | `spacing.md` | 12px |

### Buttons
| Property | Token | Px Value |
|----------|-------|---------|
| metrics→buttons gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

## ReminderHighlightHero (Lines 319-503)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| gradient end alpha | `AppOpacity.prominent` | 0.85 |
| shadow alpha | `AppOpacity.ghost` | 0.30 |
| blurRadius | `shadow.xl` | 20px |
| offset | `AppShadowOffset.lg` | (0, 12) |

### Chip Row
| Property | Token | Px Value |
|----------|-------|---------|
| chip→subtitle gap | `spacing.md` | 12px |
| chip bg alpha | `AppOpacity.accent` | 0.20 |
| subtitle alpha | `AppOpacity.prominent` | 0.85 |

### Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.headline` | 26px |
| fontWeight | `fontWeight.bold` | w700 |
| lineHeight | `AppLineHeight.compact` | 1.2 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |
| chip→title gap | `spacing.xl` | 20px |
| title→time gap | `spacing.xl` | 20px |

### Time/Details Rows
| Property | Token | Px Value |
|----------|-------|---------|
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |
| time→details gap | `spacing.lg` | 16px |
| details text alpha | `AppOpacity.high` | 0.90 |

---

## ReminderHeroChip (Lines 505-548)

| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.sm + spacing.micro` | 10px |
| padding v | `spacing.xs + spacing.microHalf` | 5px |
| borderRadius | `radius.pill` | 9999px |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |
| icon size | `iconSize.xs` | 14px |
| icon→text gap | `spacing.xs + spacing.micro` | 6px |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.semiBold` | w600 |

---

## ReminderRow (Lines 659-866)

### EntityTile Usage
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| switch scale | `AppScale.dense` | 0.85 |

### Slidable Delete
| Property | Token | Px Value |
|----------|-------|---------|
| extentRatio | `AppScale.slideExtentNarrow` | 0.18 |
| margin left | `spacing.sm` | 8px |
| borderRadius | `radius.lg` | 16px |
| icon→label gap | `spacing.xs` | 4px |

### Snooze Info Row
| Property | Token | Px Value |
|----------|-------|---------|
| icon size | `iconSize.xs` | 14px |
| icon→text gap | `spacing.sm` | 8px |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.semiBold` | w600 |

---

## ReminderStatusTag (Lines 868-898)

| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.sm + spacing.micro` | 10px |
| padding v | `spacing.xs + spacing.micro` | 6px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.darkTint` | 0.25 |
| bg alpha (light) | `AppOpacity.statusBg` | 0.16 |
| fontWeight | `fontWeight.semiBold` | w600 |

---

## ReminderListCard (Lines 946-1163)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |

### Header Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.avatarXl` | 48px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.dim` | 0.10 |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |
| icon size | `iconSize.xl` | 28px |
| icon→text gap | `spacing.lg` | 16px |
| title→subtitle gap | `spacing.xs` | 4px |
| title font | `typography.headline` | 26px |
| title weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |
| subtitle alpha | `AppOpacity.tertiary` | 0.75 |

### Content Spacing
| Property | Token | Px Value |
|----------|-------|---------|
| header→groups gap | `spacing.xxl` | 24px |
| header→group gap | `spacing.md` | 12px |
| row gap | `spacing.md` | 12px |
| group gap | `spacing.xl` | 20px |

### Group Header
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| border width | `componentSize.divider` | 1px |
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.md` | 12px |
| icon container bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |
| count badge padding h | `spacing.md` | 12px |
| count badge padding v | `spacing.sm` | 8px |
| count badge bg alpha | `AppOpacity.overlay` | 0.12 |
| count badge radius | `radius.sm` | 8px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.snug` | -0.01 |

### Gradient Colors (Overdue/Today/Default)
| Variant | Start Alpha | End Alpha | Border Alpha |
|---------|-------------|-----------|--------------|
| Overdue (dark) | `AppOpacity.medium` | `AppOpacity.dim` | `AppOpacity.accent` |
| Overdue (light) | `AppOpacity.dim` | `AppOpacity.faint` | `AppOpacity.accent` |
| Today (dark) | `AppOpacity.medium` | `AppOpacity.dim` | `AppOpacity.accent` |
| Today (light) | `AppOpacity.dim` | `AppOpacity.faint` | `AppOpacity.accent` |
| Default (dark) | surfaceContainerHighest | surfaceContainerHigh | `AppOpacity.medium` |
| Default (light) | surfaceContainerHigh | surfaceContainer | `AppOpacity.ghost` |

---

# reminders_messages.dart (Lines 1-166)

## ReminderMessageCard (Lines 6-84)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.faint` | 0.05 |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |

### Content
| Property | Token | Px Value |
|----------|-------|---------|
| icon→title gap | `spacing.md` | 12px |
| title→message gap | `spacing.sm` | 8px |
| message→button gap | `spacing.lg` | 16px |
| button height | `componentSize.buttonMd` | 48px |
| fontWeight | `fontWeight.bold` | w700 |

---

## ReminderSnoozeSheet (Lines 86-165)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.xxl` | 24px |
| padding top | `spacing.xxl` | 24px |
| padding bottom | `viewPadding.bottom + spacing.lg` | safe + 16px |
| borderRadius top | `radius.xxl` | 28px |

### Handle
| Property | Token | Px Value |
|----------|-------|---------|
| width | `componentSize.progressWidth` | 36px |
| height | `componentSize.progressHeight` | 4px |
| borderRadius | `radius.micro` | 2px |
| bg alpha | `AppOpacity.divider` | 0.40 |
| handle→title gap | `spacing.xl` | 20px |

### Content
| Property | Token | Px Value |
|----------|-------|---------|
| title→entry gap | `spacing.sm` | 8px |
| entry→subtitle gap | `spacing.sm` | 8px |
| subtitle→options gap | `spacing.lg` | 16px |
| fontWeight | `fontWeight.bold` | w700 |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `micro` | 2 |
| `microHalf` | 1 |
| `xs` | 4 |
| `xsPlus` | 6 |
| `sm` | 8 |
| `smMd` | 10 |
| `md` | 12 |
| `lg` | 16 |
| `lgPlus` | 18 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxlPlus` | 28 |
| `xxxl` | 32 |
| `quad` | 40 |
| `emptyStateSize` | 64 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `avatarXl` | 48 |
| `buttonMd` | 48 |
| `progressWidth` | 36 |
| `progressHeight` | 4 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerThick` | 1.5 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `xs` | 14 |
| `sm` | 16 |
| `md` | 20 |
| `lg` | 24 |
| `xl` | 28 |
| `xxl` | 32 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `sm` | 6 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `xs` | (0, 2) |
| `sm` | (0, 4) |
| `lg` | (0, 12) |

## Scale Values
| Token | Value |
|-------|-------|
| `dense` | 0.85 |
| `slideExtentNarrow` | 0.18 |

## Opacity Values
| Token | Value |
|-------|-------|
| `full` | 0.95 |
| `prominent` | 0.85 |
| `secondary` | 0.80 |
| `high` | 0.90 |
| `tertiary` | 0.75 |
| `muted` | 0.70 |
| `subtle` | 0.50 |
| `barrier` | 0.45 |
| `divider` | 0.40 |
| `ghost` | 0.30 |
| `borderEmphasis` | 0.25 |
| `darkTint` | 0.25 |
| `accent` | 0.20 |
| `statusBg` | 0.16 |
| `medium` | 0.15 |
| `overlay` | 0.12 |
| `dim` | 0.10 |
| `highlight` | 0.08 |
| `veryFaint` | 0.06 |
| `faint` | 0.05 |
| `micro` | 0.04 |

---

# ✅ STATUS: 100% TOKENIZED
All ~1,896 UI lines across 3 reminders UI files fully use design tokens.
