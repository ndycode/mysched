# Schedules Preview Sheet - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `schedules_preview_sheet.dart` (860 lines)

**Total: 860 UI lines**

---

# schedules_preview_sheet.dart

## Main Container (Lines 130-157)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| maxHeight ratio | `AppLayout.sheetMaxHeightRatio` | 0.85 |
| margin horizontal | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 32px |
| offset | `AppShadowOffset.modal` | (0, 16) |

## Scroll Content (Lines 163-169)
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding top | `spacing.xl` | 20px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `spacing.lg` | 16px |

---

## Import Header (Lines 323-379)

### Close Button
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon size | `iconSize.sm` | 16px |

### Title
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.title` | 18px |
| trailing gap | `spacing.quad` | 40px |
| title→helper gap | `spacing.xs` | 4px |

---

## Section Card (Lines 382-444)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.xl` | 20px |
| padding v | `spacing.lgPlus` | 18px |
| dark bg alpha | `AppOpacity.overlay` | 0.12 |
| light bg alpha | `AppOpacity.micro` | 0.02 |

### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.avatarXxl` | 48px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| icon→text gap | `spacing.md` | 12px |

### Text
| Property | Token | Px Value |
|----------|-------|---------|
| title weight | `fontWeight.bold` | w700 |
| title→subtitle gap | `spacing.xs` | 4px |

---

## Error State (Lines 184-199)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.lg` | 16px |
| variant | `StateVariant.error` | - |
| compact | `true` | - |

---

## Day Toggle Card (Lines 564-665)

### Day Header (Lines 591-650)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| gradient start alpha | `AppOpacity.dim` | 0.18 |
| gradient end alpha | `AppOpacity.veryFaint` | 0.05 |
| border alpha | `AppOpacity.accent` | 0.20 |
| border width | `componentSize.divider` | 1px |

#### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |

#### Day Label
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.subtitle` | 15px |
| weight | `fontWeight.extraBold` | w800 |
| letterSpacing | `AppLetterSpacing.snug` | -0.5px |

#### Count Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xsHalf` | 3px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| font | `typography.caption` | 11px |
| weight | `fontWeight.bold` | w700 |
| header→tiles gap | `spacing.md` | 12px |
| tile gap | `spacing.sm + paddingAdjust` | 9px |

---

## Import Class Tile (Lines 668-800)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.md` | 12px |
| default border alpha | `AppOpacity.overlay` (dark) / `AppOpacity.subtle` (light) | 0.12 / 0.40 |
| highlight border alpha | `AppOpacity.ghost` | 0.30 |
| border width (normal) | `componentSize.dividerThin` | 0.5px |
| border width (next) | `componentSize.dividerThick` | 1.5px |

#### Shadow (Light Mode)
| Property | Token | Px Value |
|----------|-------|---------|
| shadow alpha (normal) | `AppOpacity.veryFaint` | 0.05 |
| shadow alpha (next) | `AppOpacity.highlight` | 0.08 |
| blurRadius (normal) | `shadow.xs` | 4px |
| blurRadius (next) | `shadow.md` | 8px |
| offset | `AppShadowOffset.xs` | (0, 2) |

### Title Row
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.subtitle` | 15px |
| weight | `fontWeight.bold` | w700 |
| letterSpacing | `AppLetterSpacing.compact` | -0.25px |
| title→toggle gap | `spacing.md` | 12px |

### Next Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xs` | 4px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| font | `typography.caption` | 11px |
| weight | `fontWeight.bold` | w700 |

### Info Row (Lines 767-800)
| Property | Token | Px Value |
|----------|-------|---------|
| title→info gap | `spacing.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.xs + paddingAdjust` | 5px |
| font | `typography.bodySecondary` | 13px |
| weight | `fontWeight.medium` | w500 |
| time→location gap | `spacing.lg` | 16px |

---

## Footer (Lines 221-275)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `spacing.xl` | 20px |
| borderRadius bottom | `radius.xl` bottomLeft/Right | 24px |
| border top alpha | `AppOpacity.subtle` | 0.40 |
| border top width | `componentSize.divider` | 1px |

### Action Buttons
| Property | Token | Px Value |
|----------|-------|---------|
| button gap | `spacing.md` | 12px |
| minHeight | `componentSize.buttonMd` | 48px |

### Loading Spinner
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.badgeMd` | 16px |
| strokeWidth | `componentSize.progressStroke` | 2px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `xsHalf` | 3 |
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
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerThick` | 1.5 |
| `paddingAdjust` | 1 |
| `progressStroke` | 2 |
| `badgeMd` | 16 |
| `buttonMd` | 48 |
| `avatarXxl` | 48 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `md` | 8 |
| `xxl` | 32 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `xs` | (0, 2) |
| `modal` | (0, 16) |

## Opacity Values
| Token | Value |
|-------|-------|
| `micro` | 0.02 |
| `veryFaint` | 0.05 |
| `highlight` | 0.08 |
| `overlay` | 0.12 |
| `medium` | 0.15 |
| `dim` | 0.18 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `subtle` | 0.40 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `sheetMaxHeightRatio` | 0.85 |

## Letter Spacing (px)
| Token | Value |
|-------|-------|
| `compact` | -0.25 |
| `snug` | -0.5 |

---

# ✅ STATUS: 100% TOKENIZED
All 860 UI lines in `schedules_preview_sheet.dart` fully use design tokens.
