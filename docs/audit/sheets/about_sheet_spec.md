# About Sheet - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `about_sheet.dart` (411 lines)

**Total: 411 UI lines**

---

# about_sheet.dart (Lines 1-411)

## Overlay Sheet (Lines 10-25)
| Property | Token | Px Value |
|----------|-------|---------|
| alignment | `Alignment.center` | - |
| barrierTint | `AppBarrier.medium` | 0.5 |
| padding left | `spacing.xxl` | 24px |
| padding right | `spacing.xxl` | 24px |
| padding top | `media.padding.top + spacing.xxxl` | safe + 32px |
| padding bottom | `media.padding.bottom + spacing.xxxl` | safe + 32px |

## Main Container (Lines 47-71)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| minHeight | `AppLayout.sheetMinHeight` | 200px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | `componentSize.divider` | 1px |
| border width (light) | `componentSize.dividerThin` | 0.5px |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 32px |
| offset | `AppShadowOffset.modal` | (0, 16) |

## Header (Lines 78-114)
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding right | `spacing.xl` | 20px |
| padding top | `spacing.xl` | 20px |
| padding bottom | `spacing.sm` | 8px |

### Close Button
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon size | `iconSize.sm` | 16px |
| trailing gap | `spacing.quad` | 40px |
| title font | `typography.title` | 18px |

## Scroll Area (Lines 115-401)
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `spacing.xl` | 20px |

## Content Cards (Lines 128-337)
| Property | Token | Px Value |
|----------|-------|---------|
| card padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.subtle` | 0.40 |
| border alpha | `AppOpacity.accent` | 0.20 |
| section gap | `spacing.xxxl` | 32px |
| title→content gap | `spacing.sm` | 8px |
| info tile gap | `spacing.md` | 12px |

## Section Headers (Lines 157-164, 210-217, 256-262)
| Property | Token | Px Value |
|----------|-------|---------|
| letterSpacing | `AppLetterSpacing.sectionHeader` | 1.5px |
| fontWeight | `fontWeight.semiBold` | w600 |
| header→card gap | `spacing.sm` | 8px |

## Fade Overlays (Lines 360-399)
| Property | Token | Px Value |
|----------|-------|---------|
| height | `spacing.lg` | 16px |
| start alpha | full | - |
| end alpha | `AppOpacity.transparent` | 0.0 |

## Footer (Lines 339-356)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.xxxl` | 32px |
| text button→update gap | `spacing.sm` | 8px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
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
| `dividerThin` | 0.5 |
| `divider` | 1 |

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
| `transparent` | 0.0 |
| `highlight` | 0.08 |
| `medium` | 0.15 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `subtle` | 0.40 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `sheetMinHeight` | 200 |

---

# ✅ STATUS: 100% TOKENIZED
All 411 UI lines in `about_sheet.dart` fully use design tokens.
