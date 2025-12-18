# Account Management Pages - Full Spec Audit

## Files Overview
- `lib/screens/change_email_page.dart` (270 lines)
- `lib/screens/change_password_page.dart` (270 lines)
- `lib/screens/delete_account_page.dart` (324 lines)
- `lib/screens/verify_email_page.dart` (420 lines)

**Total: 1,284 lines**

---

# change_email_page.dart

## ChangeEmailPage (Lines 18-269)

### Back Button (Lines 126-138)
| Property | Token | Value |
|----------|-------|-------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| CircleAvatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| backgroundColor alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `AppTokens.iconSize.sm` | 16px |

### Form Container (Lines 220-264)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |
| borderRadius | `AppTokens.radius.xl` | 20px |
| border width (dark) | `AppTokens.componentSize.divider` | 1px |
| border width (light) | `AppTokens.componentSize.dividerThin` | 0.5px |
| shadow blur | `AppTokens.shadow.md` | 8px |
| shadow offset | `AppShadowOffset.sm` | (0, 2) |
| shadow alpha | `AppOpacity.faint` | 0.04 |

### Form Fields (Lines 144-201)
| Property | Token | Value |
|----------|-------|-------|
| field spacing | `spacing.md` | 12px |
| error text fontWeight | `AppTokens.fontWeight.semiBold` | 600 |

### Buttons (Lines 251-261)
| Property | Token | Value |
|----------|-------|-------|
| button minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| spacing between buttons | `spacing.sm` | 8px |
| spacing before buttons | `spacing.xl` | 20px |

---

# change_password_page.dart

## ChangePasswordPage (Lines 11-228)

### Back Button (Lines 93-105)
| Property | Token | Value |
|----------|-------|-------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| CircleAvatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| backgroundColor alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `AppTokens.iconSize.sm` | 16px |

### Form Container (Lines 180-224)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |
| borderRadius | `AppTokens.radius.xl` | 20px |
| border width (dark) | `AppTokens.componentSize.divider` | 1px |
| border width (light) | `AppTokens.componentSize.dividerThin` | 0.5px |
| shadow blur | `AppTokens.shadow.md` | 8px |
| shadow offset | `AppShadowOffset.sm` | (0, 2) |
| shadow alpha | `AppOpacity.faint` | 0.04 |

### Password Form (Lines 111-162)
| Property | Token | Value |
|----------|-------|-------|
| field spacing | `spacing.md` | 12px |
| error text fontWeight | `AppTokens.fontWeight.semiBold` | 600 |
| spacing after helper | `spacing.lg` | 16px |

### Buttons (Lines 211-221)
| Property | Token | Value |
|----------|-------|-------|
| button minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| spacing between buttons | `spacing.sm` | 8px |

---

# delete_account_page.dart

## DeleteAccountPage (Lines 11-271)

### Back Button (Lines 95-107)
| Property | Token | Value |
|----------|-------|-------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| CircleAvatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| backgroundColor alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `AppTokens.iconSize.sm` | 16px |

### Before You Delete Section (Lines 184-224)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |
| borderRadius | `AppTokens.radius.xl` | 20px |
| border width (dark) | `AppTokens.componentSize.divider` | 1px |
| border width (light) | `AppTokens.componentSize.dividerThin` | 0.5px |
| shadow blur | `AppTokens.shadow.md` | 8px |
| shadow alpha | `AppOpacity.faint` | 0.04 |
| text spacing | `spacing.sm` | 8px |

### Confirm Section (Lines 226-253)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |
| borderRadius | `AppTokens.radius.xl` | 20px |

### Password Form (Lines 109-172)
| Property | Token | Value |
|----------|-------|-------|
| error spacing | `spacing.md` | 12px |
| error fontWeight | `AppTokens.fontWeight.semiBold` | 600 |
| button spacing | `spacing.xl` | 20px |
| buttonMd minHeight | `AppTokens.componentSize.buttonMd` | 48px |
| button borderRadius | `AppTokens.radius.xl` | 20px |

## _SuccessView (Lines 274-322)

### Success Container (Lines 285-300)
| Property | Token | Value |
|----------|-------|-------|
| container size | `AppTokens.componentSize.previewSm` | 64px |
| border width | `AppTokens.componentSize.strokeHeavy` | 3px |
| icon size | `AppTokens.iconSize.display` | 48px |

### Success Text (Lines 301-320)
| Property | Token | Value |
|----------|-------|-------|
| spacing after icon | `AppTokens.spacing.xl` | 20px |
| fontWeight title | `AppTokens.fontWeight.bold` | 700 |
| spacing after title | `AppTokens.spacing.sm` | 8px |
| spacing before button | `AppTokens.spacing.xxl` | 24px |

---

# verify_email_page.dart

## VerifyEmailPage (Lines 30-419)

### Form Error Container (Lines 256-279)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.md)` | 12px |
| margin bottom | `spacing.lg` | 16px |
| error bg alpha | `AppOpacity.highlight` | 0.08 |
| borderRadius | `AppTokens.radius.md` | 12px |
| icon-text spacing | `spacing.sm` | 8px |
| fontWeight | `AppTokens.fontWeight.semiBold` | 600 |

### Email Display (Lines 280-292)
| Property | Token | Value |
|----------|-------|-------|
| caption style | `AppTokens.typography.caption` | 12px |
| spacing after label | `spacing.xs` | 4px |
| title style | `AppTokens.typography.title` | 18px |
| spacing after email | `spacing.lg` | 16px |

### OTP Field (Lines 294-321)
| Property | Token | Value |
|----------|-------|-------|
| title style | `AppTokens.typography.title` | 18px |
| letterSpacing | `AppLetterSpacing.otpCode` | 8px |
| fontWeight | `AppTokens.fontWeight.semiBold` | 600 |

### Form Layout (Lines 322-336)
| Property | Token | Value |
|----------|-------|-------|
| helper spacing | `spacing.md` | 12px |
| bodySecondary style | `AppTokens.typography.bodySecondary` | 14px |
| button spacing | `spacing.xl` | 20px |
| button minHeight | `AppTokens.componentSize.buttonMd` | 48px |

### Hero Close Button (Lines 346-362)
| Property | Token | Value |
|----------|-------|-------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| CircleAvatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| backgroundColor alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `AppTokens.iconSize.sm` | 16px |

### Hero Chip (Lines 363-372)
| Property | Token | Value |
|----------|-------|-------|
| fontWeight | `AppTokens.fontWeight.semiBold` | 600 |

### Need a New Code Section (Lines 379-406)
| Property | Token | Value |
|----------|-------|-------|
| bodySecondary style | `AppTokens.typography.bodySecondary` | 14px |
| button spacing | `spacing.lg` | 16px |
| button minHeight | `AppTokens.componentSize.buttonMd` | 48px |

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
| `spacing.xxl` | 24px |

### Radius Tokens
| Token | Value |
|-------|-------|
| `radius.md` | 12px |
| `radius.xl` | 20px |

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.sm` | 16px |
| `iconSize.display` | 48px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.buttonMd` | 48px |
| `componentSize.divider` | 1px |
| `componentSize.dividerThin` | 0.5px |
| `componentSize.previewSm` | 64px |
| `componentSize.strokeHeavy` | 3px |

### Typography Tokens
| Token | Value |
|-------|-------|
| `typography.caption` | 12px |
| `typography.bodySecondary` | 14px |
| `typography.body` | 16px |
| `typography.title` | 18px |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.semiBold` | 600 |
| `fontWeight.bold` | 700 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.faint` | 0.04 |
| `AppOpacity.highlight` | 0.08 |
| `AppOpacity.overlay` | 0.12 |

### Interaction Tokens
| Token | Value |
|-------|-------|
| `AppInteraction.splashRadius` | 20px |
| `AppInteraction.iconButtonContainerRadius` | 18px |

### Shadow Tokens
| Token | Value |
|-------|-------|
| `shadow.md` | 8px |
| `AppShadowOffset.sm` | (0, 2) |

### Letter Spacing Tokens
| Token | Value |
|-------|-------|
| `AppLetterSpacing.otpCode` | 8px |

---

# ✅ STATUS: 100% TOKENIZED
