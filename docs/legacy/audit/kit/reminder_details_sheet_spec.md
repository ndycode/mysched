# Reminder Details Sheet - Full Spec Audit

## Files Overview
- `lib/ui/kit/reminder_details_sheet.dart` (422 lines)

---

## ReminderDetailsSheet (Lines 9-306)

### Container (Lines 78-92)
| Property | Token | Value |
|----------|-------|-------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| maxHeight | `AppLayout.sheetMaxHeightRatio` | 0.85 |
| borderRadius | `AppTokens.radius.xl` | 20px |
| shadow (dark) alpha | `AppOpacity.fieldBorder` | 0.20 |
| shadow (light) alpha | `AppOpacity.border` | 0.16 |
| shadow method | `AppTokens.shadow.modal()` | custom |

### Content Padding (Lines 95-96)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.xl` | 20px |

### Premium Header (Lines 104-175)

#### Icon Container (Lines 107-130)
| Property | Token | Value |
|----------|-------|-------|
| size | `AppTokens.componentSize.buttonLg` | 56px |
| gradient start alpha | `AppOpacity.medium` | 0.50 |
| gradient end alpha | `AppOpacity.dim` | 0.40 |
| borderRadius | `AppTokens.radius.md` | 12px |
| border alpha | `AppOpacity.borderEmphasis` | 0.28 |
| border width | `AppTokens.componentSize.dividerThick` | 1.5px |
| icon size | `AppTokens.iconSize.xl` | 24px |

#### Title/Subtitle (Lines 131-157)
| Property | Token | Value |
|----------|-------|-------|
| spacing icon-title | `AppTokens.spacing.lg` | 16px |
| title style | `AppTokens.typography.title` | 18px |
| title fontWeight | `AppTokens.fontWeight.extraBold` | 800 |
| title letterSpacing | `AppLetterSpacing.tight` | -0.5px |
| title lineHeight | `AppLineHeight.headline` | 1.2 |
| subtitle spacing | `AppTokens.spacing.xs` | 4px |
| subtitle style | `AppTokens.typography.bodySecondary` | 14px |
| subtitle fontWeight | `AppTokens.fontWeight.medium` | 500 |
| subtitle alpha (dark) | `AppOpacity.muted` | 0.65 |

#### Close Button Container (Lines 158-173)
| Property | Token | Value |
|----------|-------|-------|
| spacing before | `AppTokens.spacing.md` | 12px |
| padding | `AppTokens.spacing.sm` | 8px |
| bg alpha | `AppOpacity.faint` | 0.04 |
| borderRadius | `AppTokens.radius.md` | 12px |
| icon size | `AppTokens.iconSize.md` | 20px |

### Header After Spacing (Line 176)
| Property | Token | Value |
|----------|-------|-------|
| spacing | `spacing.xl` | 20px |

### Tags Section (Lines 185-211)
| Property | Token | Value |
|----------|-------|-------|
| spacing/runSpacing | 8 | 8px |
| Uses global | `StatusInfoChip` | kit |

### Main Details Container (Lines 215-274)
| Property | Token | Value |
|----------|-------|-------|
| padding | `AppTokens.spacing.xl` | 20px |
| bg (dark) alpha | `AppOpacity.ghost` | 0.48 |
| bg (light) alpha | `AppOpacity.micro` | 0.02 |
| borderRadius | `AppTokens.radius.lg` | 16px |
| border (dark) alpha | `AppOpacity.overlay` | 0.12 |
| border (light) alpha | `AppOpacity.dim` | 0.40 |
| border width | `AppTokens.componentSize.divider` | 1px |
| divider padding | `AppTokens.spacing.lg` | 16px |
| divider height | `AppTokens.componentSize.divider` | 1px |
| divider alpha (dark) | `AppOpacity.medium` | 0.50 |
| Uses global | `DetailRow` | kit |

### Actions Spacing (Line 276)
| Property | Token | Value |
|----------|-------|-------|
| spacing | `spacing.xl` | 20px |

---

## _ReminderActions (Lines 308-419)

### Edit Button (Lines 332-342)
| Property | Token | Value |
|----------|-------|-------|
| icon size | `AppTokens.iconSize.sm` | 16px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Snooze Button (Lines 343-354)
| Property | Token | Value |
|----------|-------|-------|
| icon size | `AppTokens.iconSize.sm` | 16px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Toggle Button (Lines 355-378)
| Property | Token | Value |
|----------|-------|-------|
| loader size | `AppInteraction.loaderSize` | 18px |
| stroke width | `AppInteraction.progressStrokeWidth` | 2px |
| icon size | `AppTokens.iconSize.md` | 20px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Delete Button (Lines 379-399)
| Property | Token | Value |
|----------|-------|-------|
| loader size | `AppInteraction.loaderSize` | 18px |
| stroke width | `AppInteraction.progressStrokeWidth` | 2px |
| icon size | `AppTokens.iconSize.md` | 20px |
| minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| borderRadius | `AppTokens.radius.md` | 12px |

### Button Spacing (Lines 408-418)
| Property | Token | Value |
|----------|-------|-------|
| spacing between | `AppTokens.spacing.md` | 12px |

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

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.sm` | 16px |
| `iconSize.md` | 20px |
| `iconSize.xl` | 24px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.buttonMd` | 48px |
| `componentSize.buttonLg` | 56px |
| `componentSize.divider` | 1px |
| `componentSize.dividerThick` | 1.5px |

### Typography Tokens
| Token | Value |
|-------|-------|
| `typography.bodySecondary` | 14px |
| `typography.title` | 18px |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.medium` | 500 |
| `fontWeight.extraBold` | 800 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.micro` | 0.02 |
| `AppOpacity.faint` | 0.04 |
| `AppOpacity.overlay` | 0.12 |
| `AppOpacity.border` | 0.16 |
| `AppOpacity.fieldBorder` | 0.20 |
| `AppOpacity.borderEmphasis` | 0.28 |
| `AppOpacity.dim` | 0.40 |
| `AppOpacity.ghost` | 0.48 |
| `AppOpacity.medium` | 0.50 |
| `AppOpacity.muted` | 0.65 |

### Layout Tokens
| Token | Value |
|-------|-------|
| `AppLayout.sheetMaxWidth` | 480px |
| `AppLayout.sheetMaxHeightRatio` | 0.85 |

### Interaction Tokens
| Token | Value |
|-------|-------|
| `AppInteraction.loaderSize` | 18px |
| `AppInteraction.progressStrokeWidth` | 2px |

### Letter Spacing Tokens
| Token | Value |
|-------|-------|
| `AppLetterSpacing.tight` | -0.5px |

### Line Height Tokens
| Token | Value |
|-------|-------|
| `AppLineHeight.headline` | 1.2 |

---

# ✅ STATUS: 100% TOKENIZED
