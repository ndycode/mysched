# Add Class Page - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `add_class_page.dart` (1510 lines)

**Total: 1510 UI lines**

---

# add_class_page.dart

## AddClassPage (Lines 28-272)

### Menu Button (Lines 126-183)
| Property | Token | Px Value |
|----------|-------|---------|
| shape borderRadius | `radius.md` | 12px |
| icon size | `iconSize.sm` | 16px |
| row gap | `spacing.md` | 12px |
| menu item icon→text gap | `spacing.md` | 12px |

### Hero Section (Lines 195-221)
| Property | Token | Px Value |
|----------|-------|---------|
| header height | `componentSize.listItemSm` | 44px |
| avatar radius | `spacing.xl` | 20px |
| title font size | `typography.title.fontSize` | 18px |
| title weight | `fontWeight.bold` | w700 |
| header→card gap | `spacing.xl` | 20px |

### Action Buttons (Lines 242-263)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |
| button gap | `spacing.md` | 12px |

---

## AddClassSheet (Lines 275-409)

### Container (Lines 303-327)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| maxHeight ratio | `AppLayout.sheetMaxHeightRatio` | 0.85 |
| margin horizontal | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.statusBg` | 0.25 |
| blurRadius | `shadow.xxl` | 32px |
| offset | `AppShadowOffset.modal` | (0, 16) |
| dark border alpha | `AppOpacity.overlay` | 0.12 |

### Scroll Content
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| clipRadius | `radius.xl` | 24px |

### Footer (Lines 351-399)
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `spacing.xl + viewInsets.bottom` | 20px + keyboard |
| border alpha | `AppOpacity.ghost` | 0.30 |
| button gap | `spacing.md` | 12px |
| minHeight | `componentSize.buttonMd` | 48px |

---

## _RemindersStyleShell (Lines 411-496)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |

### Header (Lines 438-466)
| Property | Token | Px Value |
|----------|-------|---------|
| title font size | `typography.title.fontSize` | 18px |
| title weight | `fontWeight.bold` | w700 |
| subtitle font size | `typography.subtitle.fontSize` | 15px |
| title→subtitle gap | `spacing.xs` | 4px |
| trailing gap | `spacing.xs` | 4px |
| trailing height | `componentSize.buttonSm` | 40px |

### Helper Box (Lines 469-490)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.barrier` | 0.10 |
| icon alpha | `AppOpacity.prominent` | 0.75 |
| icon→text gap | `spacing.md` | 12px |
| box→content gap | `spacing.xl` | 20px |

---

## AddClassForm (Lines 499-1329)

### Form Container Sections (Lines 1083-1283)

#### Card Containers
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| light shadow alpha | `AppOpacity.faint` | 0.04 |
| blurRadius | `shadow.md` | 8px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| section gap | `spacing.lg` | 16px |
| header→field gap | `spacing.md` | 12px |
| field gap | `spacing.lg` | 16px |

### Input Decoration (Lines 1054-1074)
| Property | Token | Px Value |
|----------|-------|---------|
| contentPadding h | `spacing.lg` | 16px |
| contentPadding v | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.fieldBorder` | 0.35 |
| focusedBorder width | `componentSize.dividerBold` | 2px |
| fillColor alpha | `AppOpacity.prominent` (dark) | 0.75 |

### Day Picker Row (Lines 1175-1204)
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.md + paddingAdjust` | 12px + 1px |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.ghost` | 0.30 |

### Info Chips (Lines 1228-1243)
| Property | Token | Px Value |
|----------|-------|---------|
| row gap | `spacing.md` | 12px |

---

## Instructor Field (Lines 834-988)

### Loading Banner (Lines 846-874)
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.lg` | 16px |
| padding v | `spacing.lgPlus` | 18px |
| borderRadius | `radius.lg` | 16px |
| spinner size | `componentSize.badgeMdPlus` | 20px |
| strokeWidth | `componentSize.progressStroke` | 2px |
| spinner→text gap | `spacing.md` | 12px |

### Error Banner (Lines 876-901)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon→text gap | `spacing.md` | 12px |
| banner→field gap | `spacing.md` | 12px |

### Fields (Lines 949-986)
| Property | Token | Px Value |
|----------|-------|---------|
| dropdown→text gap | `spacing.md` | 12px |
| text→helper gap | `spacing.sm` | 8px |
| helper alpha | `AppOpacity.glassCard` | 0.55 |

---

## Day Picker Dialog (Lines 1331-1422)

### Dialog
| Property | Token | Px Value |
|----------|-------|---------|
| insetPadding | `spacing.lg` | 16px |
| title padding | `spacing.xl` | 20px |
| title weight | `fontWeight.bold` | w700 |

### Day Options (Lines 1361-1395)
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.xl` | 20px |
| padding v | `spacing.md` | 12px |
| selected weight | `fontWeight.semiBold` | w600 |
| normal weight | `fontWeight.regular` | w400 |
| check icon size | `iconSize.md` | 20px |

### Footer
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |

---

## _TimeField (Lines 1425-1506)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| padding h | `spacing.md` | 12px |
| padding v | `spacing.md` | 12px |
| border alpha | `AppOpacity.ghost` | 0.30 |

### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.avatarSm` | 32px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.statusBg` | 0.25 |
| icon size | `iconSize.sm` | 16px |
| icon→text gap | `spacing.md` | 12px |

### Text
| Property | Token | Px Value |
|----------|-------|---------|
| label→value gap | `spacing.xs` | 4px |
| value weight | `fontWeight.bold` | w700 |
| value font size | `typography.subtitle.fontSize` | 15px |
| text→chevron gap | `spacing.sm` | 8px |
| chevron size | `iconSize.md` | 20px |
| chevron alpha | `AppOpacity.soft` | 0.45 |

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
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerBold` | 2 |
| `paddingAdjust` | 1 |
| `progressStroke` | 2 |
| `badgeMd` | 16 |
| `badgeMdPlus` | 20 |
| `avatarSm` | 32 |
| `buttonSm` | 40 |
| `listItemSm` | 44 |
| `buttonMd` | 48 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `md` | 20 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `md` | 8 |
| `xxl` | 32 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `sm` | (0, 4) |
| `modal` | (0, 16) |

## Opacity Values
| Token | Value |
|-------|-------|
| `faint` | 0.04 |
| `highlight` | 0.08 |
| `barrier` | 0.10 |
| `overlay` | 0.12 |
| `statusBg` | 0.25 |
| `ghost` | 0.30 |
| `fieldBorder` | 0.35 |
| `soft` | 0.45 |
| `glassCard` | 0.55 |
| `prominent` | 0.75 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `sheetMaxHeightRatio` | 0.85 |

---

# ✅ STATUS: 100% TOKENIZED
All 1510 UI lines in `add_class_page.dart` fully use design tokens.
