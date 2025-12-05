# Privacy Sheet - Full Spec Audit
*Last Updated: 2025-12-06 01:38*

## File: `privacy_sheet.dart` (317 lines)

---

# Sheet Overlay (Lines 9-24)

| Property | Token | Px Value |
|----------|-------|----------|
| padding l/r | `spacing.xxl` | 24px |
| padding top | `media.padding.top + spacing.xxxl` | 32px |
| padding bottom | `media.padding.bottom + spacing.xxxl` | 32px |
| barrier | `AppBarrier.medium` | 0.55 |
| minHeight | 360px (clamped) | 360px |

---

# Card Container (Lines 40-302)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| borderRadius | `radius.xl` | 24px |
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |

---

# Header (Lines 54-88)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xs` | 4px |

## Close Button
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |

## Balance Spacer
| Property | Token | Px Value |
|----------|-------|----------|
| width | `spacing.quad` | 40px |

---

# Scroll Content (Lines 89-299)

| Property | Token | Px Value |
|----------|-------|----------|
| padding vertical | `spacing.md` | 12px |

## Section Cards (repeated pattern)
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.lg` | 16px |
| bg alpha (dark) | `AppOpacity.ghost` | 0.30 |
| bg alpha (light) | `AppOpacity.soft` | 0.50 |
| border alpha | `AppOpacity.accent` | 0.20 |

## Hero Card Icon Container
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.sm` | 8px |
| bg alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `iconSize.md` | 20px |
| icon→content gap | `spacing.md` | 12px |

## Content Spacing
| Property | Token | Px Value |
|----------|-------|----------|
| section gap | `spacing.xxxl` | 32px |
| label→card gap | `spacing.sm` | 8px |
| title→text gap | `spacing.xs` | 4px |
| info tile gap | `spacing.lg` | 16px |

## Section Labels
| Property | Token | Px Value |
|----------|-------|----------|
| letter spacing | `AppLetterSpacing.sectionHeader` | 1.5px |

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

## Opacity Values
| Token | Value |
|-------|-------|
| `overlay` | 0.12 |
| `highlight` | 0.16 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `soft` | 0.50 |

---

# ✅ STATUS: 100% TOKENIZED
All 317 lines in privacy_sheet.dart use design tokens.
(Fixed: filledBackground() at line 36-38 → `AppOpacity.ghost`/`AppOpacity.soft`)
