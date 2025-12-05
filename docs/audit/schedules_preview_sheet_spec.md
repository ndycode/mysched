# Schedules Preview Sheet - Full Spec Audit
*Last Updated: 2025-12-06 01:23*

## File: `schedules_preview_sheet.dart` (860 lines)

---

# Sheet Container (Lines 130-282)

| Property | Token | Px Value |
|----------|-------|----------|
| margin | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 24px |
| offset | `AppShadowOffset.modal` | (0, 16) |
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| maxHeight | `AppLayout.sheetMaxHeightRatio` | 0.85 |

## Content Padding
| Property | Token | Px Value |
|----------|-------|----------|
| left/right/top | `spacing.xl` | 20px |
| bottom | `spacing.lg` | 16px |

## Footer Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding left/right | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding bottom | `spacing.xl` | 20px |
| border radius (bottom) | `radius.xl` | 24px |
| border alpha | `AppOpacity.subtle` | 0.08 |
| border width | `componentSize.divider` | 1px |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| spinner size | `componentSize.badgeMd` | 16px |
| spinner stroke | `componentSize.progressStroke` | 2.5px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# _ImportHeader (Lines 323-379)

| Property | Token | Px Value |
|----------|-------|----------|
| close button padding | `spacing.sm` | 8px |
| close button bg alpha | `AppOpacity.highlight` | 0.16 |
| close button radius | `radius.xl` | 24px |
| close icon size | `iconSize.sm` | 16px |
| title→helper gap | `spacing.xs` | 4px |
| balance spacer | `spacing.quad` | 40px |

---

# _SectionCard (Lines 382-444)

| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.xl` | 20px |
| padding v | `spacing.lgPlus` | 18px |
| bg alpha (dark) | `AppOpacity.overlay` | 0.12 |
| bg alpha (light) | `AppOpacity.micro` | 0.03 |
| icon container | `componentSize.avatarXxl` | 64px |
| icon container radius | `radius.lg` | 16px |
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon→text gap | `spacing.md` | 12px |
| title→subtitle gap | `spacing.xs` | 4px |

---

# _DayToggleCard (Lines 564-665)

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
| icon bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |
| count badge padding h | `spacing.smMd` | 10px |
| count badge padding v | `spacing.xsHalf` | 5px |
| count bg alpha | `AppOpacity.overlay` | 0.12 |

## Spacing
| Property | Token | Px Value |
|----------|-------|----------|
| header→tiles gap | `spacing.md` | 12px |
| tile gap | `spacing.sm + paddingAdjust` | 10px |

---

# _ImportClassTile (Lines 668-858)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.md` | 12px |
| border width (highlight) | `componentSize.dividerThick` | 1.5px |
| border width (normal) | `componentSize.dividerThin` | 0.5px |
| border alpha (highlight) | `AppOpacity.ghost` | 0.30 |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| border alpha (light) | `AppOpacity.subtle` | 0.08 |
| shadow alpha (highlight) | `AppOpacity.highlight` | 0.16 |
| shadow alpha (normal) | `AppOpacity.veryFaint` | 0.05 |
| blurRadius (highlight) | `shadow.md` | 12px |
| blurRadius (normal) | `shadow.xs` | 4px |
| offset | `AppShadowOffset.xs` | (0, 2) |

## Content
| Property | Token | Px Value |
|----------|-------|----------|
| title→meta gap | `spacing.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.xs + paddingAdjust` | 6px |
| location gap | `spacing.lg` | 16px |
| meta→instructor gap | `spacing.sm + paddingAdjust` | 10px |

## Next Badge
| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xs` | 4px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |

## Instructor Row
| Property | Token | Px Value |
|----------|-------|----------|
| avatar | `componentSize.badgeLg` | 20px |
| avatar bg alpha | `AppOpacity.medium` | 0.15 |
| avatar→text gap | `spacing.sm` | 8px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `xsHalf` | 5 |
| `sm` | 8 |
| `smMd` | 10 |
| `md` | 12 |
| `lg` | 16 |
| `lgPlus` | 18 |
| `xl` | 20 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `badgeMd` | 16 |
| `badgeLg` | 20 |
| `avatarXxl` | 64 |
| `buttonMd` | 48 |
| `progressStroke` | 2.5 |
| `paddingAdjust` | 2 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerThick` | 1.5 |

## Opacity Values
| Token | Value |
|-------|-------|
| `micro` | 0.03 |
| `veryFaint` | 0.05 |
| `subtle` | 0.08 |
| `dim` | 0.10 |
| `overlay` | 0.12 |
| `medium` | 0.15 |
| `highlight` | 0.16 |
| `accent` | 0.20 |
| `ghost` | 0.30 |

---

# ✅ STATUS: 100% TOKENIZED
All 860 lines in schedules_preview_sheet.dart use design tokens.
