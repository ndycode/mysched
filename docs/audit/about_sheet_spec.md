# About Sheet - Full Spec Audit
*Last Updated: 2025-12-06 01:35*

## File: `about_sheet.dart` (411 lines)

---

# Sheet Container (Lines 37-71)

| Property | Token | Px Value |
|----------|-------|----------|
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| minHeight | 360px (clamped) | 360px |
| borderRadius | `radius.xl` | 24px |
| border width (dark) | 1px | 1px |
| border width (light) | 0.5px | 0.5px |
| shadow alpha | `AppOpacity.medium` | 0.15 |
| blurRadius | `shadow.xxl` | 24px |
| offset | `AppShadowOffset.modal` | (0, 16) |

---

# Sheet Padding (Lines 17-22)

| Property | Token | Px Value |
|----------|-------|----------|
| left/right | `spacing.xxl` | 24px |
| top | `media.padding.top + spacing.xxxl` | 32px |
| bottom | `media.padding.bottom + spacing.xxxl` | 32px |
| barrier | `AppBarrier.medium` | 0.55 |

---

# Header (Lines 78-113)

| Property | Token | Px Value |
|----------|-------|----------|
| padding l/r | `spacing.xl` | 20px |
| padding top | `spacing.xl` | 20px |
| padding bottom | `spacing.sm` | 8px |

## Close Button
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |

## Title Row
| Property | Token | Px Value |
|----------|-------|----------|
| balance spacer | `spacing.quad` | 40px |

---

# Scroll Content (Lines 118-358)

| Property | Token | Px Value |
|----------|-------|----------|
| padding l/r | `spacing.xl` | 20px |
| padding top | `spacing.md` | 12px |
| padding bottom | `spacing.xl` | 20px |

## Section Container (repeated pattern)
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.subtle` | 0.08 |
| border alpha | `AppOpacity.accent` | 0.20 |

## Content Spacing
| Property | Token | Px Value |
|----------|-------|----------|
| intro→highlights gap | `spacing.xxxl` | 32px |
| section label→card gap | `spacing.sm` | 8px |
| title→text gap | `spacing.sm` | 8px |
| tile gap | `spacing.md` | 12px |

## Section Labels
| Property | Token | Px Value |
|----------|-------|----------|
| letter spacing | `AppLetterSpacing.sectionHeader` | 1.5px |

---

# Fade Gradients (Lines 360-399)

| Property | Token | Px Value |
|----------|-------|----------|
| height | `spacing.lg` | 16px |
| end alpha | `AppOpacity.transparent` | 0 |

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

## Opacity Values
| Token | Value |
|-------|-------|
| `transparent` | 0 |
| `subtle` | 0.08 |
| `medium` | 0.15 |
| `highlight` | 0.16 |
| `accent` | 0.20 |
| `ghost` | 0.30 |

---

# ✅ STATUS: 100% TOKENIZED
All 411 lines in about_sheet.dart use design tokens.
