# Privacy Sheet - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `privacy_sheet.dart` (317 lines)

**Total: 317 UI lines**

---

# privacy_sheet.dart (Lines 1-317)

## Overlay Sheet (Lines 9-24)
| Property | Token | Px Value |
|----------|-------|---------|
| alignment | `Alignment.center` | - |
| barrierTint | `AppBarrier.medium` | 0.5 |
| padding left | `spacing.xxl` | 24px |
| padding right | `spacing.xxl` | 24px |
| padding top | `media.padding.top + spacing.xxxl` | safe + 32px |
| padding bottom | `media.padding.bottom + spacing.xxxl` | safe + 32px |

## Main Container (Lines 42-48)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| minHeight | `AppLayout.sheetMinHeight` | 200px |
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |

## Header (Lines 54-88)
| Property | Token | Px Value |
|----------|-------|---------|
| row padding h | `spacing.xs` | 4px |
| row padding v | `spacing.xs` | 4px |

### Close Button
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon size | `iconSize.sm` | 16px |
| trailing gap | `spacing.quad` | 40px |
| title font | `typography.title` | 18px |

## Scroll Area (Lines 89-299)
| Property | Token | Px Value |
|----------|-------|---------|
| padding v | `spacing.md` | 12px |

## Hero Card (Lines 95-137)
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| padding | `spacing.md` | 12px |
| border alpha | `AppOpacity.accent` | 0.20 |

### Icon Container
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.sm` | 8px |
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.md` | 20px |
| icon→text gap | `spacing.md` | 12px |
| title→body gap | `spacing.xs` | 4px |
| title weight | `fontWeight.bold` | w700 |

## Section Headers (Lines 139-146, 174-180, 217-223)
| Property | Token | Px Value |
|----------|-------|---------|
| letterSpacing | `AppLetterSpacing.sectionHeader` | 1.5px |
| fontWeight | `fontWeight.semiBold` | w600 |
| top spacing | `spacing.xxxl` | 32px |
| header→card gap | `spacing.sm` | 8px |

## Content Cards (Lines 148-172, 183-215, 226-250, 252-275)
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.lg` | 16px |
| padding | `spacing.md` | 12px |
| border alpha | `AppOpacity.accent` | 0.20 |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.soft` | 0.45 |
| info tile gap | `spacing.lg` | 16px |

## Footer (Lines 276-296)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.xxxl` | 32px |
| text button→update gap | `spacing.sm` | 8px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |
| `quad` | 40 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `md` | 20 |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.08 |
| `overlay` | 0.12 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `soft` | 0.45 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `sheetMinHeight` | 200 |

---

# ✅ STATUS: 100% TOKENIZED
All 317 UI lines in `privacy_sheet.dart` fully use design tokens.
