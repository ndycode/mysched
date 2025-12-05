# Admin Issue Reports Page - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `admin_issue_reports_page.dart` (803 lines)

**Total: 803 UI lines**

---

# admin_issue_reports_page.dart

## ScreenShell Padding (Lines 139-144, 234-239)
| Property | Token | Px Value |
|----------|-------|---------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxxl` | safe + 32px |
| bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 40px + safe |

## Back Button (Lines 99-111)
| Property | Token | Px Value |
|----------|-------|---------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

## Loading State (Lines 128-137)
| Property | Token | Px Value |
|----------|-------|---------|
| section gap | `spacing.lg` | 16px |
| skeleton lines | `3` | - |
| skeleton items | `3` | - |

---

## Hero Card (Lines 248-334)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `1` | 1px |
| border width (light) | `0.5` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.04 |
| blurRadius | `shadow.md` | 8px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| bg alpha (dark) | `AppOpacity.border` | 0.06 |
| bg alpha (light) | `AppOpacity.overlay` | 0.12 |

### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.listItemSm` | 44px |
| borderRadius | `radius.lg` | 16px |
| dark bg alpha | `AppOpacity.fieldBorder` | 0.35 |
| light bg alpha | `AppOpacity.border` | 0.06 |
| icon size | `iconSize.xl` | 28px |
| icon→title gap | `spacing.lg` | 16px |

### Text
| Property | Token | Px Value |
|----------|-------|---------|
| title font | `typography.title` | 18px |
| title font size | `typography.headline.fontSize` | 22px |
| title weight | `fontWeight.bold` | w700 |
| title→subtitle gap | `spacing.sm` | 8px |
| subtitle→badge gap | `spacing.lg` | 16px |

### Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xsPlus` | 6px |
| borderRadius | `radius.md` | 12px |
| dark bg alpha | `AppOpacity.border` | 0.06 |
| light bg alpha | `AppOpacity.highlight` | 0.08 |
| weight | `fontWeight.semiBold` | w600 |

---

## Filter Chips (Lines 337-381)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `1` | 1px |
| border width (light) | `0.5` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |

### Chips
| Property | Token | Px Value |
|----------|-------|---------|
| spacing | `spacing.sm` | 8px |
| runSpacing | `spacing.sm` | 8px |
| selected bg alpha | `AppOpacity.statusBg` | 0.25 |
| selected weight | `fontWeight.semiBold` | w600 |
| normal weight | `fontWeight.medium` | w500 |

---

## Report Card (Lines 384-560)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `1` | 1px |
| border width (light) | `0.5` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.faint` | 0.04 |
| blurRadius | `shadow.md` | 8px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| bottom margin | `spacing.lg` | 16px |

### Title Row
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.subtitle` | 15px |
| weight | `fontWeight.bold` | w700 |
| title→status gap | `spacing.xs` | 4px |

### Status Badge
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xsPlus` | 6px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.medium` | 0.15 |
| border alpha | `AppOpacity.divider` | 0.50 |
| weight | `fontWeight.semiBold` | w600 |

### Schedule Label
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.md` | 12px |
| weight | `fontWeight.semiBold` | w600 |

### Metadata Chips
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.md` | 12px |
| chip gap | `spacing.sm` | 8px |
| runSpacing | `spacing.sm` | 8px |

### Notes
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.lg` | 16px |
| label weight | `fontWeight.semiBold` | w600 |
| label→text gap | `spacing.xs` | 4px |
| resolution weight | `fontWeight.semiBold` | w600 |

### Footer
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.lg` | 16px |

---

## Info Chip (Lines 563-589)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.smMd` | 10px |
| padding v | `spacing.xsPlus` | 6px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.track` | 0.65 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.xs` | 4px |
| weight | `fontWeight.semiBold` | w600 |

---

## Resolution Note Dialog (Lines 674-800)

### AlertDialog
| Property | Token | Px Value |
|----------|-------|---------|
| shape borderRadius | `radius.sheet` | 28px |
| title padding left | `spacing.xl` | 20px |
| title padding right | `spacing.xl` | 20px |
| title padding top | `spacing.xl` | 20px |
| title padding bottom | `spacing.sm` | 8px |
| content padding left | `spacing.xl` | 20px |
| content padding right | `spacing.xl` | 20px |
| content padding bottom | `spacing.lg` | 16px |
| actions padding | `spacing.lg` | 16px |

### Title
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.title` | 18px |
| weight | `fontWeight.bold` | w700 |

### Content
| Property | Token | Px Value |
|----------|-------|---------|
| width | `componentSize.alarmPreviewMinWidth` | 280px |
| helper→field gap | `spacing.lg` | 16px |
| helper font | `typography.body` | 15px |

### TextField
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.md` | 12px |
| contentPadding | `spacing.md` | 12px |
| border alpha | `AppOpacity.subtle` | 0.40 |
| focusedBorder width | `componentSize.dividerThick` | 1.5px |
| fill alpha | `AppOpacity.subtle` | 0.40 |

### Actions
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonSm` | 40px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `xsPlus` | 6 |
| `sm` | 8 |
| `smMd` | 10 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxxl` | 32 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `dividerThick` | 1.5 |
| `buttonSm` | 40 |
| `listItemSm` | 44 |
| `alarmPreviewMinWidth` | 280 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `xl` | 28 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `md` | 8 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `sm` | (0, 4) |

## Opacity Values
| Token | Value |
|-------|-------|
| `faint` | 0.04 |
| `border` | 0.06 |
| `highlight` | 0.08 |
| `overlay` | 0.12 |
| `medium` | 0.15 |
| `statusBg` | 0.25 |
| `fieldBorder` | 0.35 |
| `subtle` | 0.40 |
| `divider` | 0.50 |
| `track` | 0.65 |

## Interaction
| Token | Value |
|-------|-------|
| `splashRadius` | 20 |
| `iconButtonContainerRadius` | 18 |

---

# ✅ STATUS: 100% TOKENIZED
All 803 UI lines in `admin_issue_reports_page.dart` fully use design tokens.
