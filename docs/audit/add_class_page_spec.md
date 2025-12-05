# Add Class Page - Full Spec Audit
*Last Updated: 2025-12-06 01:21*

## File: `add_class_page.dart` (1,510 lines)

---

# Menu Button (Lines 126-182)

| Property | Token | Px Value |
|----------|-------|----------|
| borderRadius | `radius.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |

---

# Page Hero (Lines 185-272)

| Property | Token | Px Value |
|----------|-------|----------|
| avatar radius | `spacing.xl` | 20px |
| header height | `componentSize.listItemSm` | 36px |
| header→card gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |
| menu height | `componentSize.buttonSm` | 40px |

---

# AddClassSheet (Lines 275-408)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| margin | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| clipRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.statusBg` | 0.13 |
| blurRadius | `shadow.xxl` | 24px |
| offset | `AppShadowOffset.modal` | (0, 16) |
| content padding | `spacing.xl` | 20px |
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| maxHeight | `AppLayout.sheetMaxHeightRatio` | 0.85 |

## Footer
| Property | Token | Px Value |
|----------|-------|----------|
| padding left/right | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding bottom | `spacing.xl + viewInsets` | 20px + keyboard |
| border alpha | `AppOpacity.ghost` | 0.30 |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# _RemindersStyleShell (Lines 411-496)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| title→date gap | `spacing.xs` | 4px |
| title→trailing gap | `spacing.xs` | 4px |
| trailing height | `componentSize.buttonSm` | 40px |
| header→banner gap | `spacing.lg` | 16px |
| banner padding | `spacing.lg` | 16px |
| banner radius | `radius.lg` | 16px |
| banner bg alpha | `AppOpacity.barrier` | 0.55 |
| icon alpha | `AppOpacity.prominent` | 0.85 |
| icon→text gap | `spacing.md` | 12px |
| banner→content gap | `spacing.xl` | 20px |

---

# Instructor Field (Lines 834-988)

## Loading Banner
| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.lgPlus` | 18px |
| borderRadius | `radius.lg` | 16px |
| spinner size | `componentSize.badgeMdPlus` | 18px |
| spinner stroke | `componentSize.progressStroke` | 2.5px |
| spinner→text gap | `spacing.md` | 12px |

## Error Banner
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| icon→text gap | `spacing.md` | 12px |

## Fields
| Property | Token | Px Value |
|----------|-------|----------|
| banner→field gap | `spacing.md` | 12px |
| dropdown→text gap | `spacing.md` | 12px |
| text→helper gap | `spacing.sm` | 8px |
| helper alpha | `AppOpacity.glassCard` | 0.70 |

---

# Form Sections (Lines 1083-1320)

## Section Container (repeated)
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.06 |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| section gap | `spacing.lg` | 16px |

## Input Fields
| Property | Token | Px Value |
|----------|-------|----------|
| content padding | `spacing.lg` | 16px |
| field borderRadius | `radius.lg` | 16px |
| focused border width | `componentSize.dividerBold` | 2px |
| fill alpha (dark) | `AppOpacity.prominent` | 0.85 |
| border alpha | `AppOpacity.fieldBorder` | 0.45 |
| field gap | `spacing.lg` | 16px |

## Day Picker Row
| Property | Token | Px Value |
|----------|-------|----------|
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.md + paddingAdjust` | 14px |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.ghost` | 0.30 |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| button height | `componentSize.buttonSm` | 40px |
| button radius | `radius.xl` | 24px |
| button gap | `spacing.md` | 12px |

---

# Day Picker Dialog (Lines 1331-1422)

| Property | Token | Px Value |
|----------|-------|----------|
| insetPadding | `spacing.lg` | 16px |
| title padding | `spacing.xl` | 20px |
| row padding h | `spacing.xl` | 20px |
| row padding v | `spacing.md` | 12px |
| check icon size | `iconSize.md` | 20px |
| footer padding | `spacing.md` | 12px |

---

# _TimeField (Lines 1425-1506)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.ghost` | 0.30 |
| icon container | `componentSize.avatarSm` | 32px |
| icon container radius | `radius.md` | 12px |
| icon bg alpha | `AppOpacity.statusBg` | 0.13 |
| icon size | `iconSize.sm` | 16px |
| icon→content gap | `spacing.md` | 12px |
| label→value gap | `spacing.xs` | 4px |
| content→chevron gap | `spacing.sm` | 8px |
| chevron size | `iconSize.md` | 20px |
| chevron alpha | `AppOpacity.soft` | 0.50 |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `lgPlus` | 18 |
| `xl` | 20 |
| `xxl` | 24 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `avatarSm` | 32 |
| `listItemSm` | 36 |
| `buttonSm` | 40 |
| `buttonMd` | 48 |
| `badgeMdPlus` | 18 |
| `progressStroke` | 2.5 |
| `paddingAdjust` | 2 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerBold` | 2 |

## Layout Values
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 440 |
| `sheetMaxHeightRatio` | 0.85 |

## Opacity Values
| Token | Value |
|-------|-------|
| `faint` | 0.06 |
| `overlay` | 0.12 |
| `statusBg` | 0.13 |
| `highlight` | 0.16 |
| `ghost` | 0.30 |
| `fieldBorder` | 0.45 |
| `soft` | 0.50 |
| `barrier` | 0.55 |
| `glassCard` | 0.70 |
| `prominent` | 0.85 |

---

# ✅ STATUS: 100% TOKENIZED
All 1,510 lines in add_class_page.dart use design tokens.
