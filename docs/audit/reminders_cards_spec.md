# Reminders Screen - Full Spec Audit
*Last Updated: 2025-12-06 01:12*

## File: `reminders_cards.dart` (1,165 lines)

---

# _EmptyHeroPlaceholder (Lines 115-188)

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

# ReminderSummaryCard (Lines 191-316)

## Container (CardX)
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |

## Button Heights
| Property | Token | Px Value |
|----------|-------|----------|
| New/Show buttons | `componentSize.buttonMd` | 48px |

---

# ReminderHighlightHero (Lines 319-502)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xxl` | 24px |
| borderRadius | `radius.lg` | 16px |
| gradient end alpha | `AppOpacity.prominent` | 0.85 |
| blurRadius | `shadow.xl` | 20px |
| offset | `AppShadowOffset.lg` | (0, 12) |
| shadow alpha | `AppOpacity.ghost` | 0.30 |

## Title
| Property | Token | Specs |
|----------|-------|-------|
| font | `typography.headline` | 22px |
| fontWeight | `fontWeight.bold` | w700 |
| lineHeight | `AppLineHeight.compact` | 1.2 |
| letterSpacing | `AppLetterSpacing.tight` | -0.03 |

## Time/Notes Rows
| Property | Token | Px Value |
|----------|-------|----------|
| title→time gap | `spacing.lg + spacing.xs` | 20px |
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.sm` | 8px |
| icon size | `iconSize.sm` | 16px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon→text gap | `spacing.md` | 12px |
| time→notes gap | `spacing.md + spacing.xs` | 16px |
| notes alpha | `AppOpacity.high` | 0.90 |

---

# ReminderHeroChip (Lines 505-547)

| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.sm + spacing.micro` | 10px |
| padding v | `spacing.xs + spacing.microHalf` | 5px |
| borderRadius | `radius.pill` | 9999px |
| icon size | `iconSize.xs` | 14px |
| icon→text gap | `spacing.xs + spacing.micro` | 6px |
| border alpha | `AppOpacity.borderEmphasis` | 0.25 |

---

# ReminderGroupCard (Lines 551-656)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| header→list gap | `spacing.md` | 12px |
| queued badge margin | `spacing.sm` | 8px |
| synced icon→text gap | `spacing.xs` | 4px |
| icon size | `iconSize.sm` | 16px |
| motion duration | `motion.fast` | 150ms |

---

# ReminderRow (Lines 659-866)

## Switch
| Property | Token | Value |
|----------|-------|-------|
| scale | `AppScale.dense` | 0.85 |

## Snooze Info
| Property | Token | Px Value |
|----------|-------|----------|
| icon size | `iconSize.xs` | 14px |
| icon→text gap | `spacing.sm` | 8px |

## Slidable Delete
| Property | Token | Value |
|----------|-------|-------|
| extentRatio | `AppScale.slideExtentNarrow` | 0.18 |
| margin left | `spacing.sm` | 8px |
| borderRadius | `radius.lg` | 16px |
| clipRadius | `radius.md` | 12px |
| icon→label gap | `spacing.xs` | 4px |

## Details Sheet Padding
| Property | Token | Px Value |
|----------|-------|----------|
| left/right | `spacing.xl` | 20px |
| top/bottom | `spacing.xxl` | 24px |

---

# ReminderStatusTag (Lines 868-897)

| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.sm + spacing.micro` | 10px |
| padding v | `spacing.xs + spacing.micro` | 6px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.darkTint` | 0.18 |
| bg alpha (light) | `AppOpacity.statusBg` | 0.13 |

---

# ReminderListCard (Lines 946-1058)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |

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
| header→groups gap | `spacing.xxl` | 24px |

## Subtitle
| Property | Token | Value |
|----------|-------|-------|
| alpha | `AppOpacity.tertiary` | 0.65 |

---

# Group Headers (Lines 1061-1162)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| border width | `componentSize.divider` | 1px |
| icon container padding | `spacing.sm` | 8px |
| icon container radius | `radius.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon→text gap | `spacing.md` | 12px |
| count badge padding h | `spacing.md` | 12px |
| count badge padding v | `spacing.sm` | 8px |
| count badge radius | `radius.sm` | 8px |
| count bg alpha | `AppOpacity.overlay` | 0.12 |

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
| `buttonMd` | 48 |
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

## Scale Values
| Token | Value |
|-------|-------|
| `dense` | 0.85 |
| `slideExtentNarrow` | 0.18 |

## Opacity Values
| Token | Value |
|-------|-------|
| `micro` | 0.03 |
| `dim` | 0.10 |
| `overlay` | 0.12 |
| `statusBg` | 0.13 |
| `medium` | 0.15 |
| `highlight` | 0.16 |
| `darkTint` | 0.18 |
| `accent` | 0.20 |
| `borderEmphasis` | 0.25 |
| `ghost` | 0.30 |
| `tertiary` | 0.65 |
| `secondary` | 0.80 |
| `prominent` | 0.85 |
| `high` | 0.90 |

---

# ✅ STATUS: 100% TOKENIZED
All 1,165 lines in reminders_cards.dart use design tokens.
