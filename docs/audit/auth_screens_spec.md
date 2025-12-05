# Auth & Utility Screens - Full Spec Audit
*Last Updated: 2025-12-06 01:38*

This spec covers all remaining small screens in the project.

---

# verify_email_page.dart (420 lines)

## Error Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| margin bottom | `spacing.lg` | 16px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.md` | 12px |
| icon gap | `spacing.sm` | 8px |

## Form Fields
| Property | Token | Px Value |
|----------|-------|----------|
| label gap | `spacing.xs` | 4px |
| field gap | `spacing.lg` | 16px |
| helper gap | `spacing.md` | 12px |
| button gap | `spacing.xl` | 20px |
| otp letter spacing | `AppLetterSpacing.otpCode` | 4px |
| button height | `componentSize.buttonMd` | 48px |

## Close Button
| Property | Token | Px Value |
|----------|-------|----------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 16px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

---

# delete_account_page.dart (324 lines)

## Back Button
| Property | Token | Px Value |
|----------|-------|----------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 16px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

## Section Cards
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.faint` | 0.06 |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |

## Success View
| Property | Token | Px Value |
|----------|-------|----------|
| circle size | `componentSize.previewSm` | 120px |
| stroke width | `componentSize.strokeHeavy` | 2.5px |
| icon size | `iconSize.display` | 48px |
| circle→title gap | `spacing.xl` | 20px |
| title→text gap | `spacing.sm` | 8px |
| text→button gap | `spacing.xxl` | 24px |

---

# register_page.dart (268 lines)

## Error Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| gap after error | `spacing.lg` | 16px |

## Form Fields
| Property | Token | Px Value |
|----------|-------|----------|
| field gap | `spacing.lg` | 16px |
| helper gap | `spacing.xs` | 4px |
| button gap | `spacing.xl` | 20px |
| button height | `componentSize.buttonMd` | 48px |

---

# change_email_page.dart (270 lines)

## Back Button
| Property | Token | Px Value |
|----------|-------|----------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 16px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

## Form Card
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.faint` | 0.06 |
| blurRadius | `shadow.md` | 12px |
| offset | `AppShadowOffset.sm` | (0, 4) |
| field gap | `spacing.md` | 12px |
| error gap | `spacing.md` | 12px |
| form→button gap | `spacing.xl` | 20px |
| button gap | `spacing.sm` | 8px |
| button height | `componentSize.buttonMd` | 48px |

---

# change_password_page.dart (270 lines)

## Same pattern as change_email_page

---

# login_page.dart (224 lines)

## Error Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| gap after error | `spacing.lg` | 16px |

## Form Fields
| Property | Token | Px Value |
|----------|-------|----------|
| field gap | `spacing.lg` | 16px |
| helper gap | `spacing.xs` | 4px |
| button gap | `spacing.xl` | 20px |
| button height | `componentSize.buttonMd` | 48px |

---

# scan_options_sheet.dart (166 lines)

## Sheet Container
| Property | Token | Px Value |
|----------|-------|----------|
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| maxHeight | `AppLayout.sheetMaxHeightRatio` | 0.85 |
| margin | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| elevation | `shadow.elevationLight` | 1 |
| border alpha (dark) | `AppOpacity.overlay` | 0.12 |
| border alpha (light) | `AppOpacity.divider` | 0.25 |

## Close Button
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |
| balance spacer | `spacing.quad` | 40px |

## Preview Area
| Property | Token | Px Value |
|----------|-------|----------|
| height | `componentSize.previewLg` | 280px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.ghost` | 0.30 |
| border alpha | `AppOpacity.accent` | 0.20 |
| icon size | `iconSize.display` | 48px |
| icon alpha | `AppOpacity.glassCard` | 0.65 |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# alarm_page.dart (174 lines)

## Screen Shell
| Property | Token | Px Value |
|----------|-------|----------|
| padding l/r | `spacing.xl` | 20px |
| padding top | `media.padding.top + spacing.xxxl` | 32px |
| padding bottom | `spacing.quad + bottomNavSafePadding` | 40px + safe |

## Back Button
| Property | Token | Px Value |
|----------|-------|----------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 16px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

## Dialog
| Property | Token | Px Value |
|----------|-------|----------|
| barrier alpha | `AppOpacity.muted` | 0.55 |
| inset padding | `spacing.lg` | 16px |

## Bullet Items
| Property | Token | Px Value |
|----------|-------|----------|
| bottom padding | `spacing.sm` | 8px |
| icon size | `iconSize.sm` | 16px |
| icon gap | `spacing.md` | 12px |

---

# style_guide_page.dart (146 lines)

## Screen Shell
| Property | Token | Px Value |
|----------|-------|----------|
| padding l/r | `spacing.xl` | 20px |
| padding top | `media.padding.top + spacing.xxxl` | 32px |
| padding bottom | `spacing.quad` | 40px |

## Spacing Display
| Property | Token | Px Value |
|----------|-------|----------|
| card padding | `spacing.xl` | 20px |
| section gap | `spacing.md` | 12px |
| chip gap | `spacing.md` | 12px |
| chip run gap | `spacing.sm` | 8px |

---

# ✅ STATUS: 100% TOKENIZED
All 2,262 lines across 9 screens fully use design tokens.
