# Dashboard Screen - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `dashboard_screen.dart` (1,123 lines) - Main screen orchestration
- `dashboard_cards.dart` (804 lines) - Summary, hero, list tiles
- `dashboard_schedule.dart` (586 lines) - Schedule peek section
- `dashboard_reminders.dart` (480 lines) - Reminder section
- `dashboard_messages.dart` (108 lines) - Error/info messages
- `dashboard_models.dart` (264 lines) - Data models (no UI)

**Total: ~3,365 lines**

---

# dashboard_screen.dart (Lines 1-1123)

## ScreenShell Padding
| Property | Token | Px Value |
|----------|-------|----------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `topInset + spacing.xxxl` | safe + 32px |
| bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 40px + safe |
| cacheExtent | `AppLayout.listCacheExtent` | 500px |

## Overlay Sheet Padding
| Property | Token | Px Value |
|----------|-------|----------|
| left/right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxl` | safe + 24px |
| bottom | `media.padding.bottom + spacing.xxl` | safe + 24px |

## Loading Skeleton
| Property | Token | Px Value |
|----------|-------|----------|
| shell padding left/right | `spacing.xl` | 20px |
| shell padding top | `media.padding.top + spacing.xxxl` | safe + 32px |
| shell padding bottom | `spacing.quad + bottomNavSafePadding` | 40px + safe |

---

# dashboard_cards.dart (Lines 1-804)

## _DashboardSummaryCard (Lines 4-178)

### Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.05 |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |

### Header
| Property | Token | Px Value |
|----------|-------|---------|
| title font | `typography.title` | 20px |
| title weight | `fontWeight.bold` | w700 |
| letterSpacing | `AppLetterSpacing.snug` | -0.01 |
| title→hero gap | `spacing.xl` | 20px |

### Refresh Button
| Property | Token | Px Value |
|----------|-------|---------|
| height | `componentSize.buttonXs` | 36px |
| size min | `componentSize.buttonXs` | 36px |
| borderRadius | `radius.md` | 12px |
| icon size | `iconSize.md` | 20px |

### Metric Row
| Property | Token | Px Value |
|----------|-------|----------|
| hero→metrics gap | `spacing.xl` | 20px |
| metric gap | `spacing.md` | 12px |

### Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| metrics→buttons gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

## _UpcomingHeroTile (Lines 180-439)

### Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| gradient end alpha | `AppOpacity.prominent` | 0.85 |
| shadow alpha | `AppOpacity.ghost` | 0.30 |
| blurRadius | `shadow.xl` | 20px |
| offset | `AppShadowOffset.lg` | (0, 12) |

### Status Badge
| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.md` | 12px |
| padding v | `spacing.sm - spacing.micro` | 6px |
| borderRadius | `radius.pill` | 9999px |
| bg alpha | `AppOpacity.border` | 0.18 |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.semiBold` | w600 |
| letterSpacing | `AppLetterSpacing.wider` | 0.04 |

### Live Dot
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.badgeSm` | 8px |
| margin right | `spacing.sm` | 8px |
| shadow blur | `shadow.xs` | 4px |
| shadow spread | `componentSize.divider` | 1px |
| subtitle alpha | `AppOpacity.subtle` | 0.50 |

### Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.headline` | 26px |
| fontWeight | `fontWeight.bold` | w700 |
| lineHeight | `AppLineHeight.compact` | 1.2 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |
| badge→title gap | `spacing.xl` | 20px |
| title→time gap | `spacing.lgPlus` | 18px |

### Time/Location Rows
| Property | Token | Px Value |
|----------|-------|----------|
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |
| time→date gap | `spacing.xs` | 4px |
| time→location gap | `spacing.md + spacing.micro` | 14px |
| date alpha | `AppOpacity.secondary` | 0.80 |
| location alpha | `AppOpacity.high` | 0.90 |

### Instructor Row
| Property | Token | Px Value |
|----------|-------|----------|
| top gap | `spacing.lg` | 16px |
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| avatar size | `componentSize.avatarSmDense` | 28px |
| avatar→name gap | `spacing.sm` | 8px |
| text alpha | `AppOpacity.full` | 0.95 |

---

## _EmptyHeroPlaceholder (Lines 441-514)

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
| subtitle alpha | `AppOpacity.secondary` | 0.80 |

---

## _UpcomingListTile (Lines 516-707)

### Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.lg` | 16px |
| borderRadius outer | `radius.lg` | 16px |
| borderRadius inner | `radius.md` | 12px |
| border highlight alpha | `AppOpacity.ghost` | 0.30 |
| border normal alpha (dark) | `AppOpacity.overlay` | 0.12 |
| border normal alpha (light) | `AppOpacity.barrier` | 0.40 |
| border highlight width | `componentSize.dividerThick` | 1.5px |
| border normal width | `componentSize.dividerThin` | 0.5px |
| splash alpha | `AppOpacity.faint` | 0.05 |

### Shadow
| Property | Token | Px Value |
|----------|-------|---------|
| highlight shadow alpha | `AppOpacity.highlight` | 0.08 |
| normal shadow alpha | `AppOpacity.faint` | 0.05 |
| highlight blur | `shadow.md` | 12px |
| normal blur | `shadow.sm` | 6px |
| offset | `AppShadowOffset.xs` | (0, 2) |

### Title Row
| Property | Token | Px Value |
|----------|-------|---------|
| trailing width | `componentSize.buttonMd` | 48px |
| trailing height | `componentSize.listItemSm` | 48px |
| switch scale | `AppScale.dense` | 0.85 |
| title→trailing gap | `spacing.md` | 12px |
| fontWeight | `fontWeight.bold` | w700 |
| letterSpacing | `AppLetterSpacing.compact` | -0.01 |
| disabled alpha | `AppOpacity.subtle` | 0.50 |

### Time/Location Row
| Property | Token | Px Value |
|----------|-------|---------|
| title→time gap | `spacing.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| icon alpha | `AppOpacity.muted` | 0.70 |
| icon→text gap | `spacing.xsPlus` | 6px |
| text alpha | `AppOpacity.prominent` | 0.85 |
| time→location gap | `spacing.lg` | 16px |
| secondary switch height | `componentSize.badgeLg` | 24px |
| secondary switch scale | `AppScale.compact` | 0.80 |

### Instructor Row
| Property | Token | Px Value |
|----------|-------|----------|
| time→instructor gap | `spacing.smMd` | 10px |

---

## _InstructorRow (Lines 709-768)

| Property | Token | Px Value |
|----------|-------|---------|
| avatar (dense) | `iconSize.md` | 20px |
| avatar (normal) | `iconSize.lg` | 24px |
| avatar→name gap | `spacing.xsPlus` | 6px |
| border width (inverse) | `componentSize.divider` | 1px |
| font (dense) | `typography.caption` | 12px |
| font (normal) | `typography.bodySecondary` | 14px |
| fontWeight | `fontWeight.medium` | w500 |
| inverse alpha | `AppOpacity.prominent` | 0.85 |

---

## _StatusPill (Lines 770-802)

| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.sm` | 8px |
| padding v | `spacing.xs` | 4px |
| borderRadius | `radius.pill` | 9999px |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.semiBold` | w600 |

---

# dashboard_schedule.dart (Lines 1-586)

## _DashboardSchedulePeek (Lines 4-522)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.veryFaint` | 0.06 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.sm` | (0, 4) |

### Header
| Property | Token | Px Value |
|----------|-------|---------|
| icon container size | `componentSize.avatarXl` | 48px |
| icon container radius | `radius.md` | 12px |
| icon container border | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.dim` | 0.10 |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |
| icon size | `iconSize.xl` | 28px |
| icon→text gap | `spacing.lg` | 16px |
| title→subtitle gap | `spacing.xs` | 4px |
| title font | `typography.title` | 20px |
| title weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |

### Refresh Button
| Property | Token | Px Value |
|----------|-------|---------|
| height/width | `componentSize.buttonXs` | 36px |
| borderRadius | `radius.md` | 12px |
| icon size | `iconSize.md` | 20px |
| spinner size | `componentSize.badgeMd` | 16px |
| strokeWidth | `AppInteraction.progressStrokeWidth` | 2px |

### Description & Search
| Property | Token | Px Value |
|----------|-------|----------|
| header→description gap | `spacing.md` | 12px |
| description alpha | `AppOpacity.muted` | 0.55 |
| description→search gap | `spacing.lg` | 16px |
| search padding h | `spacing.mdLg` | 14px |
| search padding v | `spacing.md` | 12px |
| search borderRadius | `radius.lg` | 16px |
| search→segment gap | `spacing.md` | 12px |

### SegmentedButton
| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.xl` | 20px |
| padding v | `spacing.smMd` | 10px |
| border width | `componentSize.dividerMedium` | 1.25px |
| border alpha (unselected) | `AppOpacity.barrier` | 0.40 |
| selected bg alpha | `AppOpacity.statusBg` | 0.12 |
| unselected alpha | `AppOpacity.prominent` | 0.85 |

### Animation
| Property | Token | Value |
|----------|-------|-------|
| size duration | `AppMotionSystem.medium` | 250ms |
| size curve | `AppMotionSystem.easeOut` | easeOut |
| switcher duration | `AppMotionSystem.standard` | 300ms |
| slide offset | `AppShadowOffset.slideIn` | (0, 0.02) |

### Section Header
| Property | Token | Px Value |
|----------|-------|----------|
| bottom margin | `spacing.md` | 12px |
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| icon box padding | `spacing.sm` | 8px |
| icon box radius | `radius.sm` | 8px |
| icon box bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |
| count badge padding h | `spacing.smMd` | 10px |
| count badge padding v | `spacing.xsHalf` | 6px |
| count badge bg alpha | `AppOpacity.overlay` | 0.12 |
| gradient start alpha | `AppOpacity.dim` | 0.10 |
| gradient end alpha | `AppOpacity.veryFaint` | 0.06 |
| border alpha | `AppOpacity.accent` | 0.20 |
| border width | `componentSize.divider` | 1px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.snug` | -0.01 |

### Row Spacing
| Property | Token | Px Value |
|----------|-------|----------|
| row gap | `spacing.sm + spacing.micro` | 10px |
| list→button gap | `spacing.lgPlus` | 18px |
| preview limit | `AppDisplayLimits.schedulePreviewCount` | 5 |

### Review Button
| Property | Token | Px Value |
|----------|-------|----------|
| height | `componentSize.buttonLg` | 56px |

### Empty State
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.divider` | 0.40 |
| bg alpha (light) | `AppOpacity.micro` | 0.04 |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| border alpha (light) | `AppOpacity.dim` | 0.10 |
| border width | `componentSize.divider` | 1px |
| icon container padding | `spacing.lg` | 16px |
| icon container bg alpha (dark) | `AppOpacity.medium` | 0.15 |
| icon container bg alpha (light) | `AppOpacity.dim` | 0.10 |
| icon size | `iconSize.xxl` | 32px |
| icon→title gap | `spacing.xl` | 20px |
| title→subtitle gap | `spacing.sm` | 8px |
| title font | `typography.subtitle` | 16px |
| title weight | `fontWeight.bold` | w700 |

---

## _ScheduleRow (Lines 524-586)

Uses `EntityTile` kit component with:
| Property | Token | Value |
|----------|-------|-------|
| metadata icons | `iconSize.sm` | 16px |
| InstructorRow component | (see kit) | - |
| StatusBadge variants | live/next/done | - |

---

# dashboard_reminders.dart (Lines 1-528)

## _DashboardReminderCard (Lines 4-239)

### Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.veryFaint` | 0.04 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.sm` | (0, 4) |

### Header Icon Container
| Property | Token | Px Value |
|----------|-------|----------|
| size | `componentSize.avatarXl` | 56px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.dim` | 0.08 |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |
| icon size | `iconSize.xl` | 28px |
| icon→text gap | `spacing.lg` | 16px |
| title→subtitle gap | `spacing.xs` | 4px |
| title font | `typography.title` | 18px |
| title weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |

### SegmentedButton
| Property | Token | Px Value |
|----------|-------|----------|
| header→segment gap | `spacing.lg` | 16px |
| padding h | `spacing.md` | 12px |
| padding v | `spacing.sm` | 8px |
| border width | `componentSize.dividerMedium` | 1.25px |
| border alpha (unselected) | `AppOpacity.barrier` | 0.40 |
| selected bg alpha | `AppOpacity.statusBg` | 0.12 |
| unselected alpha | `AppOpacity.prominent` | 0.85 |

### Content Spacing
| Property | Token | Px Value |
|----------|-------|----------|
| segment→progress gap | `spacing.md` | 12px |
| progress→list gap | `spacing.md` | 12px |
| list→actions gap | `spacing.lg` | 16px |
| tile bottom margin | `spacing.md` | 12px |
| more text top padding | `spacing.xs` | 4px |
| preview limit | `AppDisplayLimits.reminderPreviewCount` | 3 |

---

## _ReminderActions (Lines 241-304)

| Property | Token | Px Value |
|----------|-------|----------|
| wide layout breakpoint | `AppLayout.wideLayoutBreakpoint` | 480px |
| row gap (wide) | `spacing.md` | 12px |
| column gap (narrow) | `spacing.smMd` | 10px |
| button height | `componentSize.buttonMd` | 48px |

---

## _ReminderProgressPill (Lines 306-390)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.divider` | 1px |
| gradient start alpha | `AppOpacity.dim` | 0.10 |
| gradient end alpha | `AppOpacity.veryFaint` | 0.06 |
| border alpha | `AppOpacity.accent` | 0.20 |

### Icon Box
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |

### Percentage Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xsPlus` | 6px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.bold` | w700 |

### Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.subtitle` | 16px |
| fontWeight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.snug` | -0.01 |

---

## _DashboardReminderTile (Lines 392-527)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| border width | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.faint` | 0.05 |
| blurRadius | `shadow.sm` | 6px |
| offset | `AppShadowOffset.xs` | (0, 2) |

### Checkbox
| Property | Token | Px Value |
|----------|-------|---------|
| container size | `componentSize.badgeLg` | 24px |
| scale | `AppScale.enlarged` | 1.2 |
| shape borderRadius | `radius.sm` | 8px |
| border width | `componentSize.dividerThick` | 1.5px |
| border alpha | `AppOpacity.subtle` | 0.50 |
| checkbox→content gap | `spacing.md` | 12px |

### Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.subtitle` | 16px |
| fontWeight | `fontWeight.bold` | w700 |
| letterSpacing | `AppLetterSpacing.compact` | -0.01 |
| title→details gap | `spacing.xsPlus` | 6px |
| details alpha | `AppOpacity.muted` | 0.70 |

### Due Row
| Property | Token | Px Value |
|----------|-------|---------|
| details→due gap | `spacing.md` | 12px |
| icon size | `iconSize.xs` | 14px |
| icon alpha | `AppOpacity.muted` | 0.70 |
| icon→text gap | `spacing.xsPlus` | 6px |
| text alpha | `AppOpacity.prominent` | 0.85 |
| font | `typography.caption` | 12px |
| fontWeight | `fontWeight.medium` | w500 |

### Loading Spinner
| Property | Token | Px Value |
|----------|-------|----------|
| margin left | `spacing.md` | 12px |
| size | `componentSize.badgeMd` | 16px |
| strokeWidth | `AppInteraction.progressStrokeWidth` | 2px |

---

# dashboard_messages.dart (Lines 1-108)

## _DashboardMessageCard

| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.xl` | 24px |
| icon bg alpha | `AppOpacity.highlight` | 0.08 |
| icon box radius | `radius.md` | 12px |
| icon box padding | `spacing.md` | 12px |
| icon size | `iconSize.lg` | 24px |
| icon→content gap | `spacing.lg` | 16px |
| title→message gap | `spacing.xs` | 4px |
| message→buttons gap | `spacing.lg` | 16px |
| button gap | `spacing.sm` | 8px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `micro` | 2 |
| `microHalf` | 1 |
| `xs` | 4 |
| `xsPlus` | 6 |
| `xsHalf` | 6 |
| `sm` | 8 |
| `smMd` | 10 |
| `md` | 12 |
| `mdLg` | 14 |
| `lg` | 16 |
| `lgPlus` | 18 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |
| `quad` | 40 |
| `emptyStateSize` | 64 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `avatarXl` | 48 |
| `avatarSmDense` | 28 |
| `avatarXsDense` | 26 |
| `buttonXs` | 36 |
| `buttonMd` | 48 |
| `buttonLg` | 52 |
| `badgeSm` | 8 |
| `badgeMd` | 16 |
| `badgeLg` | 24 |
| `listItemSm` | 48 |
| `listItemMd` | 56 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerMedium` | 1.25 |
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
| `xs` | 4 |
| `sm` | 6 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `xs` | (0, 2) |
| `sm` | (0, 4) |
| `hero` | (0, 8) |
| `lg` | (0, 12) |
| `slideIn` | (0, 0.02) |

## Scale Values
| Token | Value |
|-------|-------|
| `dense` | 0.85 |
| `compact` | 0.80 |

## Opacity Values
| Token | Value |
|-------|-------|
| `full` | 0.95 |
| `prominent` | 0.85 |
| `secondary` | 0.80 |
| `high` | 0.90 |
| `muted` | 0.70 |
| `subtle` | 0.50 |
| `barrier` | 0.45 |
| `divider` | 0.40 |
| `ghost` | 0.30 |
| `accent` | 0.20 |
| `border` | 0.18 |
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
All ~3,365 lines across 6 dashboard files fully use design tokens.
