# Scan Options Sheet - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `scan_options_sheet.dart` (166 lines)

**Total: 166 UI lines**

---

# scan_options_sheet.dart (Lines 1-166)

## Container Constraints (Lines 47-51)
| Property | Token | Px Value |
|----------|-------|---------|
| maxWidth | `AppLayout.sheetMaxWidth` | 480px |
| maxHeight ratio | `AppLayout.sheetMaxHeightRatio` | 0.85 |

## Margin (Lines 52-53)
| Property | Token | Px Value |
|----------|-------|---------|
| horizontal | `spacing.xl` | 20px |

## CardX Container (Lines 54-62)
| Property | Token | Px Value |
|----------|-------|---------|
| borderRadius | `radius.xl` | 24px |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| light border alpha | `AppOpacity.divider` | 0.50 |
| elevation | `shadow.elevationLight` | 2 |

## Scroll Content (Lines 65-71)
| Property | Token | Px Value |
|----------|-------|---------|
| padding left | `spacing.xl` | 20px |
| padding top | `spacing.xl` | 20px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `viewInsets.bottom + spacing.xl` | keyboard + 20px |

---

## Header (Lines 76-104)

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
| trailing gap | `spacing.quad` | 40px |

### Helper Text
| Property | Token | Px Value |
|----------|-------|---------|
| header→helper gap | `spacing.sm` | 8px |
| helper→preview gap | `spacing.xl + paddingAdjust * 2` | 22px |

---

## Preview Placeholder (Lines 114-130)

### Container
| Property | Token | Px Value |
|----------|-------|---------|
| height | `componentSize.previewLg` | 200px |
| borderRadius | `radius.lg` | 16px |
| bg alpha | `AppOpacity.ghost` | 0.30 |
| border alpha | `AppOpacity.accent` | 0.20 |

### Icon
| Property | Token | Px Value |
|----------|-------|---------|
| size | `iconSize.display` | 64px |
| alpha | `AppOpacity.glassCard` | 0.55 |
| icon | `credit_card` | - |

---

## Action Buttons (Lines 131-154)

### Row
| Property | Token | Px Value |
|----------|-------|---------|
| top gap | `spacing.xxl` | 24px |
| button gap | `spacing.md` | 12px |

### Primary Button (Take Photo)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |
| icon | `camera_alt_outlined` | - |

### Secondary Button (Upload)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |
| icon | `photo_library_outlined` | - |

---

# Token Reference Summary

## Spacing (px)
| Token | Value |
|-------|-------|
| `sm` | 8 |
| `md` | 12 |
| `xl` | 20 |
| `xxl` | 24 |
| `quad` | 40 |

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `paddingAdjust` | 1 |
| `buttonMd` | 48 |
| `previewLg` | 200 |

## Icon Sizes (px)
| Token | Value |
|-------|-------|
| `sm` | 16 |
| `display` | 64 |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.08 |
| `overlay` | 0.12 |
| `accent` | 0.20 |
| `ghost` | 0.30 |
| `divider` | 0.50 |
| `glassCard` | 0.55 |

## Shadow
| Token | Value |
|-------|-------|
| `elevationLight` | 2 |

## Layout
| Token | Value |
|-------|-------|
| `sheetMaxWidth` | 480 |
| `sheetMaxHeightRatio` | 0.85 |

---

# ✅ STATUS: 100% TOKENIZED
All 166 UI lines in `scan_options_sheet.dart` fully use design tokens.
