# Modals - Full Spec Audit

## Files Overview
- `lib/ui/kit/modals.dart` (351 lines)

---

## _SmoothDialogRoute (Lines 7-69)

### Transition Config (Lines 14-32)
| Property | Token | Value |
|----------|-------|-------|
| barrierColor default | `AppBarrier.heavy` | rgba(0,0,0,0.54) |
| duration default | `AppMotionSystem.medium` | 250ms |
| reverseDuration | `AppMotionSystem.quick` | 150ms |

### Animations (Lines 44-68)
| Property | Token | Value |
|----------|-------|-------|
| fade interval end | `AppMotionSystem.intervalHalf` | 0.5 |
| fade interval start (reverse) | `AppMotionSystem.intervalHalf` | 0.5 |
| fade curve | `AppMotionSystem.easeOut` | cubic |
| fade reverseCurve | `AppMotionSystem.easeIn` | cubic |
| scale curve | `AppMotionSystem.overshoot` | cubic |
| scale reverseCurve | `AppMotionSystem.easeIn` | cubic |
| opacity end | `AppMotionSystem.scaleNone` | 1.0 |
| scale start | `AppMotionSystem.scalePageTransition` | 0.95 |
| scale end | `AppMotionSystem.scaleNone` | 1.0 |

---

## AppModal.showConfirmDialog (Lines 95-181)

### Dialog Styling (Lines 109-139)
| Property | Token | Value |
|----------|-------|-------|
| shape borderRadius | `AppTokens.radius.sheet` | 24px |
| titlePadding (left, right, top) | `spacing.xl` | 20px |
| titlePadding (bottom) | `spacing.sm` | 8px |
| contentPadding (left, right) | `spacing.xl` | 20px |
| contentPadding (bottom) | `spacing.lg` | 16px |
| actionsPadding | `spacing.lg` | 16px |
| title style | `AppTokens.typography.title` | 18px |
| title fontWeight | `AppTokens.fontWeight.bold` | 700 |
| message style | `AppTokens.typography.body` | 16px |

### Buttons (Lines 140-178)
| Property | Token | Value |
|----------|-------|-------|
| secondary minHeight | `AppTokens.componentSize.buttonSm` | 40px |
| danger button minWidth | 0 | 0px |
| danger button minHeight | `AppTokens.componentSize.buttonSm` | 40px |
| danger button horizontal padding | `spacing.xl` | 20px |
| danger button vertical padding | `spacing.md` | 12px |
| danger button borderRadius | `AppTokens.radius.xxl` | 28px |
| primary minHeight | `AppTokens.componentSize.buttonSm` | 40px |

---

## AppModal.showAlertDialog (Lines 183-247)

### Dialog Styling (Lines 196-246)
| Property | Token | Value |
|----------|-------|-------|
| shape borderRadius | `AppTokens.radius.sheet` | 24px |
| titlePadding (left, right, top) | `spacing.xl` | 20px |
| titlePadding (bottom) | `spacing.sm` | 8px |
| contentPadding (left, right) | `spacing.xl` | 20px |
| contentPadding (bottom) | `spacing.lg` | 16px |
| actionsPadding | `spacing.lg` | 16px |
| icon size | `AppTokens.iconSize.lg` | 22px |
| icon-title spacing | `spacing.md` | 12px |
| title style | `AppTokens.typography.title` | 18px |
| title fontWeight | `AppTokens.fontWeight.bold` | 700 |
| body style | `AppTokens.typography.body` | 16px |
| button minHeight | `AppTokens.componentSize.buttonSm` | 40px |

---

## AppModal.showInputDialog (Lines 249-349)

### Dialog Styling (Lines 266-329)
| Property | Token | Value |
|----------|-------|-------|
| shape borderRadius | `AppTokens.radius.sheet` | 24px |
| titlePadding (left, right, top) | `spacing.xl` | 20px |
| titlePadding (bottom) | `spacing.sm` | 8px |
| contentPadding (left, right) | `spacing.xl` | 20px |
| contentPadding (bottom) | `spacing.lg` | 16px |
| actionsPadding | `spacing.lg` | 16px |
| title style | `AppTokens.typography.title` | 18px |
| title fontWeight | `AppTokens.fontWeight.bold` | 700 |
| message style | `AppTokens.typography.body` | 16px |
| message spacing | `spacing.lg` | 16px |

### TextField Styling (Lines 304-327)
| Property | Token | Value |
|----------|-------|-------|
| fillColor alpha | `AppOpacity.subtle` | 0.32 |
| border borderRadius | `AppTokens.radius.md` | 12px |
| enabled border alpha | `AppOpacity.subtle` | 0.32 |
| focused border width | `AppTokens.componentSize.dividerThick` | 1.5px |
| content padding | `spacing.md` | 12px |

### Buttons (Lines 330-343)
| Property | Token | Value |
|----------|-------|-------|
| secondary minHeight | `AppTokens.componentSize.buttonSm` | 40px |
| primary minHeight | `AppTokens.componentSize.buttonSm` | 40px |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |
| `spacing.xl` | 20px |

### Radius Tokens
| Token | Value |
|-------|-------|
| `radius.md` | 12px |
| `radius.sheet` | 24px |
| `radius.xxl` | 28px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.buttonSm` | 40px |
| `componentSize.dividerThick` | 1.5px |

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.lg` | 22px |

### Typography Tokens
| Token | Value |
|-------|-------|
| `typography.body` | 16px |
| `typography.title` | 18px |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.bold` | 700 |

### Motion Tokens
| Token | Value |
|-------|-------|
| `AppMotionSystem.quick` | 150ms |
| `AppMotionSystem.medium` | 250ms |
| `AppMotionSystem.intervalHalf` | 0.5 |
| `AppMotionSystem.scaleNone` | 1.0 |
| `AppMotionSystem.scalePageTransition` | 0.95 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.subtle` | 0.32 |

### Barrier Colors
| Token | Value |
|-------|-------|
| `AppBarrier.heavy` | rgba(0,0,0,0.54) |

---

# ✅ STATUS: 100% TOKENIZED
