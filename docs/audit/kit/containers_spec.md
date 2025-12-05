# Containers - Full Spec Audit

## Files Overview
- `lib/ui/kit/containers.dart` (456 lines)

---

## CardX (Lines 28-340)

### Animation (Lines 73-89)
| Property | Token | Value |
|----------|-------|-------|
| duration | `AppMotionSystem.instant` | 50ms |
| reverseDuration | `AppMotionSystem.quick` | 150ms |
| scale begin | `AppMotionSystem.scaleNone` | 1.0 |
| scale end | `AppMotionSystem.scalePressLight` | 0.98 |
| curve | `AppMotionSystem.easeOut` | cubic |
| reverseCurve | `AppMotionSystem.snapBack` | cubic |

### Default Styling (Lines 136-158)
| Property | Token | Value |
|----------|-------|-------|
| borderRadius | `AppTokens.radius.xl` | 20px |
| default horizontal padding | `AppTokens.spacing.xl` | 20px |
| default vertical padding | `AppTokens.spacing.lgPlus` | 18px |
| animation duration | `AppTokens.motion.fast` | 200ms |

### Glass Variant (Lines 161-177)
| Property | Token | Value |
|----------|-------|-------|
| blur sigma | `AppTokens.shadow.backdropBlur` | 24px |

### Elevated Variant (Lines 238-260)
| Property | Token | Value |
|----------|-------|-------|
| hover border alpha | `AppOpacity.ghost` | 0.48 |
| dark border alpha | `AppOpacity.overlay` | 0.12 |
| border width (dark) | `AppTokens.componentSize.divider` | 1px |
| border width (light) | `AppTokens.componentSize.dividerThin` | 0.5px |
| hover shadow alpha | `AppOpacity.highlight` | 0.08 |
| normal shadow alpha | `AppOpacity.faint` | 0.04 |
| hover blur | `AppTokens.shadow.xxl` | 28px |
| normal blur | `AppTokens.shadow.xl` | 20px |
| hover offset | `AppShadowOffset.md` | (0, 4) |
| normal offset | `AppShadowOffset.sm` | (0, 2) |

### Outlined Variant (Lines 262-276)
| Property | Token | Value |
|----------|-------|-------|
| hover bg (dark) alpha | `AppOpacity.faint` | 0.04 |
| hover border alpha (dark) | `AppOpacity.subtle` | 0.32 |
| hover border alpha (light) | `AppOpacity.barrier` | 0.60 |
| normal border alpha (dark) | `AppOpacity.barrier` | 0.60 |
| normal border alpha (light) | `AppOpacity.ghost` | 0.48 |
| border width | `AppTokens.componentSize.dividerThick` | 1.5px |

### Filled Variant (Lines 278-290)
| Property | Token | Value |
|----------|-------|-------|
| hover bg alpha | `AppOpacity.overlay` | 0.12 |
| hover bg (light) alpha | `AppOpacity.faint` | 0.04 |

### Glass Variant Colors (Lines 292-315)
| Property | Token | Value |
|----------|-------|-------|
| normal bg (dark) alpha | `AppOpacity.glass` | 0.55 |
| hover bg (dark) alpha | `AppOpacity.muted` | 0.65 |
| normal bg (light) alpha | `AppOpacity.prominent` | 0.75 |
| hover border alpha | `AppOpacity.ghost` | 0.48 |
| dark border alpha | `AppOpacity.darkTint` | 0.22 |
| light border alpha | `AppOpacity.statusBg` | 0.18 |
| hover shadow alpha (dark) | `AppOpacity.darkTint` | 0.22 |
| hover shadow alpha (light) | `AppOpacity.overlay` | 0.12 |
| normal shadow alpha (dark) | `AppOpacity.ghost` | 0.48 |
| blur | `AppTokens.shadow.cardHover` | 16px |
| offset | `AppShadowOffset.lg` | (0, 6) |

### Hero Variant (Lines 317-338)
| Property | Token | Value |
|----------|-------|-------|
| hover shadow (dark) alpha | `AppOpacity.barrier` | 0.60 |
| normal shadow (dark) alpha | `AppOpacity.ghost` | 0.48 |
| hover shadow (light) alpha | `AppOpacity.ghost` | 0.48 |
| normal shadow (light) alpha | `AppOpacity.darkTint` | 0.22 |
| blur | `AppTokens.shadow.cardHover` | 16px |
| gradient alpha | `AppOpacity.prominent` | 0.75 |
| gradient (dark) start alpha | `AppOpacity.prominent` | 0.75 |
| gradient end alpha | `AppOpacity.muted` | 0.65 |

---

## Section (Lines 357-437)

### Header (Lines 376-412)
| Property | Token | Value |
|----------|-------|-------|
| bottom padding | `AppTokens.spacing.lg` | 16px |
| subtitle top padding | `AppTokens.spacing.sm` | 8px |

### Default Padding (Lines 414-418)
| Property | Token | Value |
|----------|-------|-------|
| vertical padding | `AppTokens.spacing.xl` | 20px |

### Children Spacing (Lines 423-436)
| Property | Token | Value |
|----------|-------|-------|
| default spacing | `AppTokens.spacing.md` | 12px |

---

## DividerX (Lines 440-454)

### Styling (Lines 446-452)
| Property | Token | Value |
|----------|-------|-------|
| height | `AppTokens.spacing.xl` | 20px |
| thickness | `AppTokens.componentSize.dividerThin` | 0.5px |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |
| `spacing.lgPlus` | 18px |
| `spacing.xl` | 20px |

### Radius Tokens
| Token | Value |
|-------|-------|
| `radius.xl` | 20px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.dividerThin` | 0.5px |
| `componentSize.divider` | 1px |
| `componentSize.dividerThick` | 1.5px |

### Shadow Tokens
| Token | Value |
|-------|-------|
| `shadow.cardHover` | 16px |
| `shadow.xl` | 20px |
| `shadow.xxl` | 28px |
| `shadow.backdropBlur` | 24px |

### Shadow Offset Tokens
| Token | Value |
|-------|-------|
| `AppShadowOffset.sm` | (0, 2) |
| `AppShadowOffset.md` | (0, 4) |
| `AppShadowOffset.lg` | (0, 6) |

### Motion Tokens
| Token | Value |
|-------|-------|
| `AppMotionSystem.instant` | 50ms |
| `AppMotionSystem.quick` | 150ms |
| `AppTokens.motion.fast` | 200ms |
| `AppMotionSystem.scaleNone` | 1.0 |
| `AppMotionSystem.scalePressLight` | 0.98 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.faint` | 0.04 |
| `AppOpacity.highlight` | 0.08 |
| `AppOpacity.overlay` | 0.12 |
| `AppOpacity.statusBg` | 0.18 |
| `AppOpacity.darkTint` | 0.22 |
| `AppOpacity.subtle` | 0.32 |
| `AppOpacity.ghost` | 0.48 |
| `AppOpacity.glass` | 0.55 |
| `AppOpacity.barrier` | 0.60 |
| `AppOpacity.muted` | 0.65 |
| `AppOpacity.prominent` | 0.75 |

---

# ✅ STATUS: 100% TOKENIZED
