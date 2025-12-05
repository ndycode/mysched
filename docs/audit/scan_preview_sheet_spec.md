# Scan Preview Sheet - Full Spec Audit
*Last Updated: 2025-12-06 01:38*

## File: `scan_preview_sheet.dart` (405 lines)

---

# Sheet Container (Lines 205-402)

| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.xl` | 20px |
| bottom padding | `media.padding.bottom + viewInsets.bottom + spacing.xl` | safe + keyboard |
| maxWidth | `AppLayout.sheetMaxWidth` | 440px |
| card padding | `spacing.xl` | 20px |

---

# Header (Lines 224-269)

## Close Button
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| bg alpha | `AppOpacity.highlight` | 0.16 |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |

## Retake Button
| Property | Token | Px Value |
|----------|-------|----------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| icon size | `iconSize.sm` | 16px |
| icon alpha | `AppOpacity.high` | 0.90 |

---

# Content (Lines 271-396)

| Property | Token | Px Value |
|----------|-------|----------|
| header→helper gap | `spacing.sm` | 8px |
| helper→preview gap | `spacing.xl` | 20px |
| preview height | `AppScale.previewHeightRatio` | 0.45 |
| preview radius | `radius.lg` | 16px |
| preview min height | `componentSize.previewMd` | 200px |
| error→buttons gap | `spacing.lg` | 16px |
| preview→buttons gap | `spacing.xl` | 20px |

## Buttons
| Property | Token | Px Value |
|----------|-------|----------|
| spinner size | `componentSize.badgeMd` | 16px |
| spinner stroke | `componentSize.progressStroke` | 2.5px |
| button gap | `spacing.md` | 12px |
| button height | `componentSize.buttonMd` | 48px |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `badgeMd` | 16 |
| `buttonMd` | 48 |
| `previewMd` | 200 |
| `progressStroke` | 2.5 |

## Scale Values
| Token | Value |
|-------|-------|
| `previewHeightRatio` | 0.45 |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.16 |
| `high` | 0.90 |

---

# ✅ STATUS: 100% TOKENIZED
All 405 lines in scan_preview_sheet.dart use design tokens.
