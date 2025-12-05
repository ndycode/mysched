# Class Details Sheet - Full Spec Audit

## Files Overview
- `lib/ui/kit/class_details_sheet.dart` (911 lines)

---

## ClassDetailsSheet (Lines 12-406)

### Container Decoration (Lines 313-327)
| Property | Token | Value |
|----------|-------|-------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| borderRadius | `AppTokens.radius.xl` | 20px |
| shadow (dark) alpha | `AppOpacity.track` | 0.24 |
| shadow (light) alpha | `AppOpacity.border` | 0.16 |
| shadow method | `AppTokens.shadow.bubble()` | custom |

### Content Padding (Lines 331-332)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.xl` | 20px |

### Loading State (Lines 343-348)
| Property | Token | Value |
|----------|-------|-------|
| height | `AppTokens.componentSize.previewMd` | 120px |

### Error State (Lines 356-375)
| Property | Token | Value |
|----------|-------|-------|
| spacing after header | `spacing.lg` | 16px |

### Report Dialog (Lines 163-258)
| Property | Token | Value |
|----------|-------|-------|
| shape borderRadius | `AppTokens.radius.sheet` | 24px |
| titlePadding (left, right, top) | `spacing.xl` | 20px |
| titlePadding (bottom) | `spacing.sm` | 8px |
| contentPadding (left, right) | `spacing.xl` | 20px |
| contentPadding (bottom) | `spacing.lg` | 16px |
| actionsPadding | `spacing.lg` | 16px |
| title fontWeight | `AppTokens.fontWeight.bold` | 700 |
| title style | `AppTokens.typography.title` | 18px |
| body style | `AppTokens.typography.body` | 16px |
| text field spacing | `spacing.lg` | 16px |
| fillColor alpha | `AppOpacity.subtle` | 0.32 |
| border outline alpha | `AppOpacity.subtle` | 0.32 |
| focusedBorder width | `AppTokens.componentSize.dividerThick` | 1.5px |
| inputPadding | `spacing.md` | 12px |
| buttonSm minHeight | `AppTokens.componentSize.buttonSm` | 40px |

---

## _ClassDetailsContent (Lines 411-615)

### Header (Lines 462-467)
| Property | Token | Value |
|----------|-------|-------|
| Uses global | `SheetHeaderRow` | kit |
| spacing after header | `spacing.xl` | 20px |

### Tags Wrap (Lines 476-492)
| Property | Token | Value |
|----------|-------|-------|
| spacing | 8 | 8px |
| runSpacing | 8 | 8px |
| Uses global | `StatusInfoChip` | kit |

### Main Details Container (Lines 496-589)
| Property | Token | Value |
|----------|-------|-------|
| container padding | `AppTokens.spacing.xl` | 20px |
| bg (dark) alpha | `AppOpacity.ghost` | 0.48 |
| bg (light) alpha | `AppOpacity.micro` | 0.02 |
| borderRadius | `AppTokens.radius.lg` | 16px |
| border (dark) alpha | `AppOpacity.overlay` | 0.12 |
| border (light) alpha | `AppOpacity.dim` | 0.40 |
| border width | `AppTokens.componentSize.divider` | 1px |
| divider padding | `AppTokens.spacing.lg` | 16px |
| divider height | `AppTokens.componentSize.divider` | 1px |
| divider alpha (dark) | `AppOpacity.medium` | 0.50 |
| divider alpha (light) | `AppOpacity.dim` | 0.40 |
| Uses global | `DetailRow` | kit |

### Instructor Section (Lines 591-594)
| Property | Token | Value |
|----------|-------|-------|
| spacing before | `spacing.lg` | 16px |

### Actions Section (Lines 596-608)
| Property | Token | Value |
|----------|-------|-------|
| spacing before | `spacing.xl` | 20px |

---

## _InstructorDetail (Lines 628-700)

### Container (Lines 640-649)
| Property | Token | Value |
|----------|-------|-------|
| padding | `AppTokens.spacing.lg` | 16px |
| bg (dark) alpha | `AppOpacity.ghost` | 0.48 |
| border (dark) alpha | `AppOpacity.overlay` | 0.12 |
| borderRadius | `AppTokens.radius.lg` | 16px |
| border width | `AppTokens.componentSize.divider` | 1px |

### Content (Lines 650-697)
| Property | Token | Value |
|----------|-------|-------|
| label fontWeight | `AppTokens.fontWeight.semiBold` | 600 |
| spacing after label | `AppTokens.spacing.md` | 12px |
| avatar size | `AppTokens.iconSize.xxl` | 40px |
| avatar-text spacing | `AppTokens.spacing.lg` | 16px |
| name fontWeight | `AppTokens.fontWeight.bold` | 700 |
| name style | `AppTokens.typography.subtitle` | 16px |
| email spacing | `AppTokens.spacing.xs` | 4px |
| email fontWeight | `AppTokens.fontWeight.medium` | 500 |

---

## _ClassDetailActions (Lines 752-911)

### Edit Button (Lines 781-792)
| Property | Token | Value |
|----------|-------|-------|
| icon size | `AppTokens.iconSize.sm` | 16px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Toggle Button (Lines 795-833)
| Property | Token | Value |
|----------|-------|-------|
| loader size | `AppInteraction.loaderSize` | 18px |
| stroke width | `AppInteraction.progressStrokeWidth` | 2px |
| icon size | `AppTokens.iconSize.md` | 20px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Report/Delete Buttons (Lines 835-911)
| Property | Token | Value |
|----------|-------|-------|
| loader size | `AppInteraction.loaderSize` | 18px |
| stroke width | `AppInteraction.progressStrokeWidth` | 2px |
| icon size | `AppTokens.iconSize.md` | 20px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.xs` | 4px |
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |
| `spacing.xl` | 20px |

### Radius Tokens
| Token | Value |
|-------|-------|
| `radius.md` | 12px |
| `radius.lg` | 16px |
| `radius.xl` | 20px |
| `radius.sheet` | 24px |

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.sm` | 16px |
| `iconSize.md` | 20px |
| `iconSize.xxl` | 40px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.buttonSm` | 40px |
| `componentSize.buttonMd` | 48px |
| `componentSize.divider` | 1px |
| `componentSize.dividerThick` | 1.5px |
| `componentSize.previewMd` | 120px |

### Typography Tokens
| Token | Value |
|-------|-------|
| `typography.body` | 16px |
| `typography.subtitle` | 16px |
| `typography.title` | 18px |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.medium` | 500 |
| `fontWeight.semiBold` | 600 |
| `fontWeight.bold` | 700 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.micro` | 0.02 |
| `AppOpacity.overlay` | 0.12 |
| `AppOpacity.border` | 0.16 |
| `AppOpacity.track` | 0.24 |
| `AppOpacity.subtle` | 0.32 |
| `AppOpacity.dim` | 0.40 |
| `AppOpacity.ghost` | 0.48 |
| `AppOpacity.medium` | 0.50 |

### Layout Tokens
| Token | Value |
|-------|-------|
| `AppLayout.sheetMaxWidth` | 480px |

### Interaction Tokens
| Token | Value |
|-------|-------|
| `AppInteraction.loaderSize` | 18px |
| `AppInteraction.progressStrokeWidth` | 2px |

---

# ✅ STATUS: 100% TOKENIZED
