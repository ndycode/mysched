# Scan Preview Sheet - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `scan_preview_sheet.dart` (405 lines)

**Total: 405 UI lines**

---

# scan_preview_sheet.dart (Lines 1-405)

## Container Constraints (Lines 214-217)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |

## Padding (Lines 208-212)
| Property | Token | Px Value |
|----------|-------|---------|
| horizontal | `spacing.xl` | 20px |
| top | `spacing.xl` | 20px |
| bottom | `media.padding.bottom + viewInsets.bottom + spacing.xl` | safe + keyboard + 20px |

## CardX Container (Lines 218-219)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.xl` | 20px |

---

## Header (Lines 224-278)

### Close Button
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| icon size | `iconSize.sm` | 16px |

### Title
| Property | Token | Px Value |
|----------|-------|---------|
| font | `typography.title` | 18px |

### Retake Button (Lines 250-268)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.sm` | 8px |
| borderRadius | `radius.xl` | 24px |
| bg | `surfaceContainerHighest` | - |
| icon size | `iconSize.sm` | 16px |
| icon alpha | `AppOpacity.high` | 0.85 |

### Helper Text
| Property | Token | Px Value |
|----------|-------|---------|
| header→helper gap | `spacing.sm` | 8px |
| helper→image gap | `spacing.xl` | 20px |

---

## Image Preview (Lines 280-340)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| maxHeight | `media.size.height * AppScale.previewHeightRatio` | ~45% |
| borderRadius | `radius.lg` | 16px |

### Loading Spinner
| Property | Token | Px Value |
|----------|-------|---------|
| container height | `componentSize.previewMd` | 160px |

### Unavailable State
| Property | Token | Px Value |
|----------|-------|---------|
| bg | `surfaceContainerHigh` | - |
| text color | `colors.error` | - |

---

## Error State (Lines 341-356)
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.lg` | 16px |
| compact | `true` | - |

---

## Action Buttons (Lines 358-394)

### Row
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.xl` | 20px |
| button gap | `spacing.md` | 12px |

### Primary Button (Scan)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |
| icon | `qr_code_scanner_rounded` | - |

### Secondary Button (Retake)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |

### Loading Spinner in Button
| Property | Token | Px Value |
|----------|-------|---------|
| size | `componentSize.badgeMd` | 16px |
| strokeWidth | `componentSize.progressStroke` | 2px |

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
| `progressStroke` | 2 |
| `buttonMd` | 48 |
| `previewMd` | 160 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.08 |
| `high` | 0.85 |

## Scale
| Token | Value |
|-------|-------|
| `previewHeightRatio` | 0.45 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |

---

# ✅ STATUS: 100% TOKENIZED
All 405 UI lines in `scan_preview_sheet.dart` fully use design tokens.
