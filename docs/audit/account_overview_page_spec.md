# Account Overview Page - Full Spec Audit
*Last Updated: 2025-12-06 01:36*

## File: `account_overview_page.dart` (509 lines)

---

# Back Button (Lines 174-192)

| Property | Token | Px Value |
|----------|-------|----------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 16px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

---

# Screen Shell (Lines 235-241)

| Property | Token | Px Value |
|----------|-------|----------|
| padding left/right | `spacing.xl` | 20px |
| padding top | `media.padding.top + spacing.xxxl` | 32px |
| padding bottom | `spacing.quad + bottomNavSafePadding` | 40px + safe |

---

# Profile Card (Lines 245-334)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |

## Avatar
| Property | Token | Px Value |
|----------|-------|----------|
| radius | `componentSize.avatarProfile` | 48px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| placeholder icon | `iconSize.xxl + spacing.sm` | 40px |
| placeholder alpha | `AppOpacity.subtle` | 0.08 |

## Camera Button Container
| Property | Token | Px Value |
|----------|-------|----------|
| position offset | `-(spacing.xs + spacing.micro)` | -6px |
| borderRadius | `radius.xxxl` | 36px |
| shadow alpha | `AppOpacity.accent` | 0.20 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.md` | (0, 8) |
| spinner size | `componentSize.badgeMd + spacing.micro` | 18px |
| spinner stroke | `spacing.micro` | 2px |

## Content
| Property | Token | Px Value |
|----------|-------|----------|
| avatar→name gap | `spacing.md` | 12px |
| name→details gap | `spacing.xs + spacing.micro` | 6px |

---

# Security Card (Lines 337-385)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| tile gap | `spacing.lg` | 16px |

---

# Avatar Crop Dialog (Lines 405-509)

## Dialog
| Property | Token | Px Value |
|----------|-------|----------|
| borderRadius | `radius.sheet` | 32px |
| title padding l/r | `spacing.xl` | 20px |
| title padding top | `spacing.xl` | 20px |
| title padding bottom | `spacing.sm` | 8px |
| content padding l/r | `spacing.xl` | 20px |
| content padding bottom | `spacing.lg` | 16px |
| actions padding | `spacing.lg` | 16px |

## Crop Area
| Property | Token | Px Value |
|----------|-------|----------|
| dimension ratio | `AppScale.cropDialogRatio` | 0.7 |
| dimension min | `componentSize.cropDialogMin` | 200px |
| dimension max | `componentSize.cropDialogMax` | 320px |
| borderRadius | `radius.lg` | 16px |
| instruction gap | `spacing.md` | 12px |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| button height | `componentSize.buttonSm` | 40px |
| saving width | `componentSize.buttonLg + spacing.xxl` | 80px |
| spinner size | `componentSize.badgeMd + spacing.micro` | 18px |
| spinner stroke | `spacing.micro` | 2px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `micro` | 2 |
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `badgeMd` | 16 |
| `buttonSm` | 40 |
| `buttonLg` | 56 |
| `avatarProfile` | 48 |
| `cropDialogMin` | 200 |
| `cropDialogMax` | 320 |

## Opacity Values
| Token | Value |
|-------|-------|
| `subtle` | 0.08 |
| `overlay` | 0.12 |
| `accent` | 0.20 |

---

# ✅ STATUS: 100% TOKENIZED
All 509 lines in account_overview_page.dart use design tokens.
