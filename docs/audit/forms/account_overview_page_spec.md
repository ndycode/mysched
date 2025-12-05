# Account Overview Page - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `account_overview_page.dart` (509 lines)

**Total: 509 UI lines**

---

# account_overview_page.dart (Lines 1-509)

## ScreenShell Padding (Lines 235-242)
| Property | Token | Px Value |
|----------|-------|---------|
| left | `spacing.xl` | 20px |
| right | `spacing.xl` | 20px |
| top | `media.padding.top + spacing.xxxl` | safe + 32px |
| bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 40px + safe |

## Back Button (Lines 174-192)
| Property | Token | Px Value |
|----------|-------|---------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| avatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.sm` | 16px |

---

## Profile Card (Lines 245-334)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |

### Avatar
| Property | Token | Px Value |
|----------|-------|---------|
| radius | `componentSize.avatarProfile` | 56px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| placeholder icon size | `iconSize.xxl + spacing.sm` | 36px + 8px = 44px |
| placeholder alpha | `AppOpacity.subtle` | 0.40 |

### Edit Button Position
| Property | Token | Px Value |
|----------|-------|---------|
| right | `-(spacing.xs + spacing.micro)` | -6px |
| bottom | `-(spacing.xs + spacing.micro)` | -6px |
| borderRadius | `radius.xxxl` | 32px |
| shadow alpha | `AppOpacity.accent` | 0.20 |
| blurRadius | `shadow.lg` | 16px |
| offset | `AppShadowOffset.md` | (0, 8) |

### Loading Spinner
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.badgeMd + spacing.micro` | 18px |
| strokeWidth | `spacing.micro` | 2px |

### Profile Text
| Property | Token | Px Value |
|----------|-------|---------|
| avatar→name gap | `spacing.md` | 12px |
| name font size | `typography.title.fontSize` | 18px |
| name weight | `fontWeight.bold` | w700 |
| name→info gap | `spacing.xs + spacing.micro` | 6px |
| sid weight | `fontWeight.semiBold` | w600 |

---

## Security Card (Lines 337-385)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |
| row gap | `spacing.lg` | 16px |

### InfoTile Props
| Property | Value |
|----------|-------|
| iconInContainer | true |
| showChevron | true |

---

## Avatar Crop Dialog (Lines 405-507)

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
| fontWeight | `fontWeight.bold` | w700 |

### Crop Container
| Property | Token | Px Value |
|----------|-------|---------|
| dimension ratio | `AppScale.cropDialogRatio` | 0.7 |
| min dimension | `componentSize.cropDialogMin` | 200px |
| max dimension | `componentSize.cropDialogMax` | 400px |
| borderRadius | `radius.lg` | 16px |
| crop→helper gap | `spacing.md` | 12px |
| helper font | `typography.bodySecondary` | 13px |

### Actions
| Property | Token | Px Value |
|----------|-------|---------|
| button height | `componentSize.buttonSm` | 40px |
| loading container width | `componentSize.buttonLg + spacing.xxl` | 56px + 24px = 80px |
| spinner size | `componentSize.badgeMd + spacing.micro` | 18px |
| strokeWidth | `spacing.micro` | 2px |

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
| `avatarProfile` | 56 |
| `badgeMd` | 16 |
| `buttonSm` | 40 |
| `buttonLg` | 56 |
| `cropDialogMin` | 200 |
| `cropDialogMax` | 400 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `xxl` | 36 |

## Shadow Blur (px)
| Token | Value |
|-------|-------|
| `lg` | 16 |

## Shadow Offsets
| Token | Value |
|-------|-------|
| `md` | (0, 8) |

## Opacity Values
| Token | Value |
|-------|-------|
| `overlay` | 0.12 |
| `accent` | 0.20 |
| `subtle` | 0.40 |

## Interaction
| Token | Value |
|-------|-------|
| `splashRadius` | 20 |
| `iconButtonContainerRadius` | 18 |

## Scale
| Token | Value |
|-------|-------|
| `cropDialogRatio` | 0.7 |

---

# ✅ STATUS: 100% TOKENIZED
All 509 UI lines in `account_overview_page.dart` fully use design tokens.
