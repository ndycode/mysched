# Add Reminder Page - Full Spec Audit
*Last Updated: 2025-12-06 01:33*

## File: `add_reminder_page.dart` (671 lines)

---

# AddReminderSheet (Lines 51-186)

## Container
| Property | Token | Px Value |
|----------|-------|----------|
| margin | `spacing.xl` | 20px |
| borderRadius | `radius.xxl` | 28px |
| clipRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 24px |
| offset | `AppShadowOffset.modal` | (0, 16) |
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| maxHeight | `AppScale.sheetHeightRatio` | 0.85 |
| content padding | `spacing.xl` | 20px |

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

# AddReminderForm (Lines 189-668)

## Input Fields
| Property | Token | Px Value |
|----------|-------|----------|
| content padding | `spacing.lg` | 16px |
| borderRadius | `radius.lg` | 16px |
| focused border width | `componentSize.dividerBold` | 2px |
| fill alpha (dark) | `AppOpacity.prominent` | 0.85 |
| border alpha | `AppOpacity.fieldBorder` | 0.45 |

## Section Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.lgPlus` | 18px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.subtle` | 0.08 |
| border alpha | `AppOpacity.accent` | 0.20 |
| section gap | `spacing.lg` | 16px |

## Content
| Property | Token | Px Value |
|----------|-------|----------|
| header→content gap | `spacing.lg` | 16px |
| header→field gap | `spacing.md` | 12px |
| field gap | `spacing.lg` | 16px |
| date/time field gap | `spacing.md` | 12px |
| error gap | `spacing.md` | 12px |
| info chip gap | `spacing.lg` | 16px |
| info chip row gap | `spacing.md` | 12px |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| form→buttons gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# _buildHeader (Lines 498-557)

## Back Button (Page mode)
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |

## Content
| Property | Token | Px Value |
|----------|-------|----------|
| trailing gap (sheet) | `spacing.quad` | 40px |
| trailing gap (page) | `spacing.md` | 12px |
| title→helper gap | `spacing.sm` | 8px |

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
| `buttonMd` | 48 |
| `dividerThin` | 0.5 |
| `divider` | 1 |
| `dividerBold` | 2 |

## Layout Values
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 440 |
| `sheetHeightRatio` | 0.85 |

## Opacity Values
| Token | Value |
|-------|-------|
| `subtle` | 0.08 |
| `overlay` | 0.12 |
| `medium` | 0.15 |
| `highlight` | 0.16 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `fieldBorder` | 0.45 |
| `prominent` | 0.85 |

---

# ✅ STATUS: 100% TOKENIZED
All 671 lines in add_reminder_page.dart use design tokens.
