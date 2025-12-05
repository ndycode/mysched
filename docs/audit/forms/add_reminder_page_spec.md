# Add Reminder Page - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `add_reminder_page.dart` (671 lines)

**Total: 671 UI lines**

---

# add_reminder_page.dart

## AddReminderPage (Lines 11-49)

### ScreenShell
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.contentMaxWidthMedium` | 560px |

---

## AddReminderSheet (Lines 51-187)

### Container (Lines 79-104)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| maxHeight ratio | `AppScale.sheetHeightRatio` | 0.85 |
| margin horizontal | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 32px |
| offset | `AppShadowOffset.modal` | (0, 16) |

### Scroll Content
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| clipRadius | `radius.xl` | 24px |

### Footer (Lines 127-177)
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

## AddReminderForm (Lines 189-495)

### Field Decoration (Lines 309-329)
| Property | Token | Px Value |
|----------|-------|---------|
| contentPadding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| border alpha | `AppOpacity.fieldBorder` | 0.35 |
| focusedBorder width | `componentSize.dividerBold` | 2px |
| fillColor alpha (dark) | `AppOpacity.prominent` | 0.75 |

### Header → Form Gap
| Property | Token | Px Value |
|----------|-------|---------|
| gap | `spacing.lg` | 16px |

---

### Details Section (Lines 339-391)
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.lgPlus` | 18px |
| padding v | `spacing.lgPlus` | 18px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.subtle` | 0.40 |
| border alpha | `AppOpacity.accent` | 0.20 |
| header→field gap | `spacing.md` | 12px |
| field gap | `spacing.lg` | 16px |

---

### Time Section (Lines 393-466)
| Property | Token | Px Value |
|----------|-------|---------|
| padding h | `spacing.lgPlus` | 18px |
| padding v | `spacing.lgPlus` | 18px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.subtle` | 0.40 |
| border alpha | `AppOpacity.accent` | 0.20 |
| header→field gap | `spacing.md` | 12px |
| date/time font size | `typography.subtitle.fontSize` | 15px |

### Date/Time Row (Lines 415-435)
| Property | Token | Px Value |
|----------|-------|---------|
| field gap | `spacing.md` | 12px |

### Info Chips (Lines 447-462)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.lg` | 16px |
| chip gap | `spacing.md` | 12px |

### Error Display
| Property | Token | Px Value |
|----------|-------|---------|
| error→field gap | `spacing.md` | 12px |

---

### Action Buttons (Lines 467-491)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |
| minHeight | `componentSize.buttonMd` | 48px |

---

## Form Header (Lines 498-557)

### Sheet Variant (Lines 504-523)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon size | `iconSize.sm` | 16px |
| trailing gap | `spacing.quad` | 40px |
| title weight | `fontWeight.bold` | w700 |
| title→helper gap | `spacing.sm` | 8px |

### Page Variant
| Property | Token | Px Value |
|----------|-------|---------|
| trailing gap | `spacing.md` | 12px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `sm` | 8 |
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
| `dividerBold` | 2 |
| `buttonMd` | 48 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `xxl` | 32 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `modal` | (0, 16) |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.08 |
| `overlay` | 0.12 |
| `medium` | 0.15 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `fieldBorder` | 0.35 |
| `subtle` | 0.40 |
| `prominent` | 0.75 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `contentMaxWidthMedium` | 560 |

## Scale
| Token | Value |
|-------|-------|
| `sheetHeightRatio` | 0.85 |

---

# ✅ STATUS: 100% TOKENIZED
All 671 UI lines in `add_reminder_page.dart` fully use design tokens.
