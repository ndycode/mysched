# Schedules Screen - Full Spec Audit
*Last Updated: 2025-12-06 01:10*

## File: `schedules_cards.dart` (1,267 lines)

---

# ScheduleClassListCard (Lines 14-362)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| shadow alpha | `AppOpacity.veryFaint` | 0.05 |

## Header Icon Container
| Property | Token | Px Value |
|----------|-------|----------|
| size | `componentSize.avatarXl` | 48px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.dividerThick` | 1.5px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.dim` | 0.10 |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |
| icon size | `iconSize.xl` | 28px |
| gap to text | `spacing.lg` | 16px |

## Refresh Button
| Property | Token | Px Value |
|----------|-------|----------|
| height/width | `componentSize.buttonXs` | 36px |
| icon size | `iconSize.md` | 20px |
| spinner size | `componentSize.badgeMd` | 16px |
| borderRadius | `radius.md` | 12px |

## Day Header
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| border width | `componentSize.divider` | 1px |
| gradient start alpha | `AppOpacity.dim` | 0.10 |
| gradient end alpha | `AppOpacity.veryFaint` | 0.05 |
| border alpha | `AppOpacity.accent` | 0.20 |
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon container bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| badge padding h | `spacing.sm + spacing.micro` | 10px |
| badge padding v | `spacing.xs + spacing.microHalf` | 5px |
| badge bg alpha | `AppOpacity.overlay` | 0.12 |

## Empty State
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| border width | `componentSize.divider` | 1px |
| icon container padding | `spacing.lg` | 16px |
| icon size | `iconSize.xxl` | 32px |
| icon→title gap | `spacing.xl` | 20px |
| title→subtitle gap | `spacing.sm` | 8px |
| text alpha | `AppOpacity.secondary` | 0.80 |

---

# ScheduleGroupCard (Lines 448-524)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.hero` | (0, 8) |
| shadow alpha | `AppOpacity.highlight` | 0.16 |
| header→list gap | `spacing.md + spacing.micro` | 14px |
| row gap | `spacing.sm + spacing.micro` | 10px |

---

# ScheduleSummaryCard (Lines 527-673)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| shadow alpha | `AppOpacity.faint` | 0.06 |

## Menu Button
| Property | Token | Px Value |
|----------|-------|----------|
| size | `componentSize.buttonXs` | 36px |

## Button Heights
| Property | Token | Px Value |
|----------|-------|----------|
| Add/Scan buttons | `componentSize.buttonMd` | 48px |

---

# _ScheduleHighlightHero (Lines 676-907)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| gradient end alpha | `AppOpacity.prominent` | 0.85 |
| blurRadius | `shadow.xl` | 20px |
| offset | `AppShadowOffset.lg` | (0, 12) |
| shadow alpha | `AppOpacity.ghost` | 0.30 |

## Status Badge
| Property | Token | Px Value |
|----------|-------|----------|
| padding horizontal | `spacing.md` | 12px |
| padding vertical | `spacing.sm - spacing.micro` | 6px |
| borderRadius | `radius.pill` | 9999px |
| bg alpha | `AppOpacity.border` | 0.18 |
| live dot size | `componentSize.badgeSm` | 6px |
| dot shadow blur | `shadow.xs` | 4px |
| dot shadow spread | `componentSize.divider` | 1px |
| icon size | `iconSize.sm` | 16px |
| fontWeight | `fontWeight.semiBold` | w600 |
| letterSpacing | `AppLetterSpacing.wider` | 0.04 |

## Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.headline` | 22px |
| fontWeight | `fontWeight.bold` | w700 |
| lineHeight | `AppLineHeight.compact` | 1.2 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |

## Time/Location Rows
| Property | Token | Px Value |
|----------|-------|----------|
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon size | `iconSize.sm` | 16px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon→text gap | `spacing.md` | 12px |
| time→date gap | `spacing.xs` | 4px |
| location text alpha | `AppOpacity.high` | 0.90 |
| date alpha | `AppOpacity.secondary` | 0.80 |

## Instructor Row
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.overlay` | 0.12 |

---

# _EmptyHeroPlaceholder (Lines 910-982)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxxl` | 32px |
| bg alpha | `AppOpacity.micro` | 0.03 |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.dim` | 0.10 |
| border width | `componentSize.divider` | 1px |
| icon container | `spacing.quad + spacing.xxl` | 64px |
| gradient start alpha | `AppOpacity.medium` | 0.15 |
| gradient end alpha | `AppOpacity.highlight` | 0.16 |
| icon border alpha | `AppOpacity.accent` | 0.20 |
| icon border width | `componentSize.dividerThick` | 1.5px |
| icon size | `iconSize.xxl` | 32px |
| title gap | `spacing.xl` | 20px |
| subtitle gap | `spacing.sm` | 8px |
| text alpha | `AppOpacity.secondary` | 0.80 |

---

# _ScheduleHeroChip (Lines 985-1026)

| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.sm + spacing.micro` | 10px |
| padding v | `spacing.xs + spacing.microHalf` | 5px |
| borderRadius | `radius.pill` | 9999px |
| icon size | `iconSize.xs` | 14px |
| icon→text gap | `spacing.xs + spacing.micro` | 6px |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |

---

# ScheduleRow (Lines 1030-1169)

## Switch
| Property | Token | Value |
|----------|-------|-------|
| scale | `AppScale.dense` | 0.85 |

## Slidable Delete
| Property | Token | Px Value |
|----------|-------|----------|
| extentRatio | `AppScale.slideExtent` | 0.25 |
| margin left | `spacing.sm` | 8px |
| borderRadius | `radius.lg` | 16px |
| icon→label gap | `spacing.xs` | 4px |

---

# _ScheduleInstructorRow (Lines 1172-1221)

| Property | Token | Px Value |
|----------|-------|----------|
| avatar (dense) | `componentSize.avatarXsDense` | 22px |
| avatar (normal) | `componentSize.avatarSmDense` | 28px |
| name gap (dense) | `spacing.xs + spacing.micro` | 6px |
| name gap (normal) | `spacing.sm` | 8px |
| text alpha | `AppOpacity.full` | 0.95 |

---

# _PinnedHeaderDelegate (Lines 1224-1266)

| Property | Token | Value |
|----------|-------|-------|
| height | `componentSize.listItemMd` | 44px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `micro` | 2 |
| `microHalf` | 1 |
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
| `avatarSmDense` | 28 |
| `avatarXsDense` | 22 |
| `buttonXs` | 36 |
| `buttonMd` | 48 |
| `badgeSm` | 6 |
| `badgeMd` | 16 |
| `listItemMd` | 44 |
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
| `xs` | 4 |
| `sm` | 8 |
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

## Scale Values
| Token | Value |
|-------|-------|
| `dense` | 0.85 |
| `slideExtent` | 0.25 |

---

# ✅ STATUS: 100% TOKENIZED
All 1,267 lines in schedules_cards.dart use design tokens.
