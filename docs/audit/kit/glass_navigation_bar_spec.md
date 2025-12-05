# Glass Navigation Bar - Full Spec Audit

## Files Overview
- `lib/ui/kit/glass_navigation_bar.dart` (536 lines)

---

## GlassNavigationBar (Lines 9-167)

### Background Colors (Lines 36-48)
| Property | Token | Value |
|----------|-------|-------|
| light alpha (solid=false) | `AppOpacity.high` | 0.85 |
| dark alpha (solid=false) | `AppOpacity.dense` | 0.92 |
| shadow (dark) alpha | `AppOpacity.shadowDark` | 0.18 |
| shadow (light) alpha | `AppOpacity.shadowStrong` | 0.12 |
| blur sigma | `AppTokens.shadow.action` | 16px |

### Padding (Lines 53-59)
| Property | Token | Value |
|----------|-------|-------|
| horizontal padding | `AppTokens.spacing.lg` | 16px |
| vertical padding | `AppTokens.spacing.md` | 12px |
| bottom padding (fab) | `AppTokens.spacing.md` | 12px |
| bottom padding (no fab) | `AppTokens.spacing.sm` | 8px |

### Nav Surface (Lines 61-85)
| Property | Token | Value |
|----------|-------|-------|
| borderRadius | `AppTokens.radius.xxl` | 28px |
| shadow method | `AppTokens.shadow.navBar()` | custom |
| animation duration | `AppMotionSystem.quick` | 150ms |
| animation curve | `AppMotionSystem.easeOut` | cubic |

### Floating FAB Position (Lines 109-110)
| Property | Token | Value |
|----------|-------|-------|
| top offset | -22 | -22px |

### Destination Spacing (Lines 150-163)
| Property | Token | Value |
|----------|-------|-------|
| inline quick action spacing | `AppTokens.spacing.md` | 12px |
| item gap spacing | `AppTokens.spacing.xs` | 4px |

---

## _GlassNavItem (Lines 170-327)

### Animation Setup (Lines 199-224)
| Property | Token | Value |
|----------|-------|-------|
| duration | `AppMotionSystem.quick` | 150ms |
| scale begin | `AppMotionSystem.scaleNone` | 1.0 |
| scale end | `AppMotionSystem.scaleEmphasis` | 1.12 |
| indicator width end | `AppMotionSystem.indicatorWidth` | 20px |
| curve | `AppMotionSystem.easeOut` | cubic |
| reverseCurve | `AppMotionSystem.easeIn` | cubic |

### Highlight Colors (Lines 249-251)
| Property | Token | Value |
|----------|-------|-------|
| highlight (dark) alpha | `AppOpacity.shadowBubble` | 0.25 |
| highlight (light) alpha | `AppOpacity.overlay` | 0.12 |
| hover (dark) alpha | `AppOpacity.highlight` | 0.08 |
| hover (light) alpha | `AppOpacity.faint` | 0.04 |

### Icon Container (Lines 267-299)
| Property | Token | Value |
|----------|-------|-------|
| duration | `AppMotionSystem.quick` | 150ms |
| padding | `AppTokens.spacing.md` | 12px |
| borderRadius | `AppTokens.radius.lg` | 16px |
| inner duration | `AppMotionSystem.instant` | 50ms |
| icon size | `AppTokens.iconSize.lg` | 22px |

### Indicator (Lines 300-322)
| Property | Token | Value |
|----------|-------|-------|
| spacing above | `AppTokens.spacing.xs` | 4px |
| height | `AppTokens.componentSize.progressHeight` | 3px |
| borderRadius | `AppTokens.radius.pill` | 999px |
| glow alpha | `AppOpacity.divider` | 0.36 |
| glow blur | `AppTokens.shadow.xs` | 4px |
| glow spread | `AppTokens.shadow.spreadXs` | 0px |

---

## _FloatingQuickActionButton (Lines 330-473)

### Shadow Color (Line 349)
| Property | Token | Value |
|----------|-------|-------|
| bubble (dark) alpha | `AppOpacity.shadowAction` | 0.35 |
| bubble (light) alpha | `AppOpacity.darkTint` | 0.22 |

### Label Background (Lines 350-354)
| Property | Token | Value |
|----------|-------|-------|
| dark bg alpha | `AppOpacity.dense` | 0.92 |
| light shadow (dark) alpha | `AppOpacity.subtle` | 0.32 |
| light shadow (light) alpha | `AppOpacity.border` | 0.16 |

### Outer Decorative Ring (Lines 361-381)
| Property | Token | Value |
|----------|-------|-------|
| bottom offset | -18 | -18px |
| width | `AppTokens.componentSize.navBubbleLabelWidth` | 100px |
| height | `AppTokens.componentSize.navBubbleLabelHeight` | 44px |
| borderRadius | `AppTokens.radius.xxxl` | 32px |
| border alpha | `AppOpacity.border` | 0.16 |
| border width | `AppTokens.componentSize.dividerBold` | 2px |
| gradient end alpha | `AppOpacity.highlight` | 0.08 |

### Inner Decorative Ring (Lines 383-410)
| Property | Token | Value |
|----------|-------|-------|
| bottom offset | -8 | -8px |
| width | `AppTokens.componentSize.navBubbleInnerWidth` | 80px |
| height | `AppTokens.componentSize.navBubbleInnerHeight` | 36px |
| borderRadius | `AppTokens.radius.xl` | 20px |
| border alpha | `AppOpacity.darkTint` | 0.22 |
| border width | `AppTokens.componentSize.dividerNav` | 1.5px |
| gradient start (dark) alpha | `AppOpacity.high` | 0.85 |
| gradient start (light) alpha | `AppOpacity.solid` | 1.0 |
| gradient end (dark) alpha | `AppOpacity.skeletonLight` | 0.65 |
| gradient end (light) alpha | `AppOpacity.labelGradient` | 0.88 |
| shadow blur | `AppTokens.shadow.lg` | 12px |
| shadow offset | `AppShadowOffset.lg` | (0, 6) |

### Main Bubble (Lines 412-444)
| Property | Token | Value |
|----------|-------|-------|
| duration | `AppMotionSystem.quick` | 150ms |
| size | `AppTokens.componentSize.navBubbleSize` | 56px |
| borderRadius | `AppTokens.radius.pill` | 999px |
| blur (active) | `AppTokens.shadow.navBubbleActive` | 24px |
| blur (inactive) | `AppTokens.shadow.navBubbleInactive` | 12px |
| offset (active) | `AppShadowOffset.navBubbleActive` | (0, 8) |
| offset (inactive) | `AppShadowOffset.navBubbleInactive` | (0, 4) |
| spread (active) | `AppTokens.shadow.spreadMd` | 2px |
| rotation (active) | `AppMotionSystem.rotationToggle` | 0.125 |
| rotation duration | `AppMotionSystem.medium` | 250ms |
| icon size | `AppTokens.iconSize.fab` | 28px |

### Label Container (Lines 447-471)
| Property | Token | Value |
|----------|-------|-------|
| spacing above | `AppTokens.spacing.sm` | 8px |
| horizontal padding | `spacing.md` | 12px |
| vertical padding | `spacing.xs` | 4px |
| borderRadius | `AppTokens.radius.pill` | 999px |
| shadow blur | `AppTokens.shadow.md` | 8px |
| shadow offset | `AppShadowOffset.md` | (0, 4) |
| fontWeight | `AppTokens.fontWeight.semiBold` | 600 |

---

## _InlineQuickActionButton (Lines 477-535)

### Container (Lines 491-533)
| Property | Token | Value |
|----------|-------|-------|
| width | `AppTokens.componentSize.navItemWidth` | 64px |
| height | `AppTokens.componentSize.navItemHeight` | 64px |
| offset | `AppShadowOffset.navFabLift` | (0, -12) |
| fab size | `AppTokens.componentSize.navFabSize` | 48px |
| borderRadius | `AppTokens.radius.xxl` | 28px |
| shadow (active) alpha | `AppOpacity.shadowBubble` | 0.25 |
| shadow (inactive) alpha | `AppOpacity.border` | 0.16 |
| blur (active) | `AppTokens.shadow.glow` | 20px |
| blur (inactive) | `AppTokens.shadow.action` | 16px |
| offset (active) | `AppShadowOffset.navFabActive` | (0, 6) |
| offset (inactive) | `AppShadowOffset.navFabInactive` | (0, 3) |
| spread (active) | `AppTokens.shadow.spreadSm` | 1px |
| icon size | `AppTokens.iconSize.xl` | 24px |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.xs` | 4px |
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |

### Radius Tokens
| Token | Value |
|-------|-------|
| `radius.lg` | 16px |
| `radius.xl` | 20px |
| `radius.xxl` | 28px |
| `radius.xxxl` | 32px |
| `radius.pill` | 999px |

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.lg` | 22px |
| `iconSize.xl` | 24px |
| `iconSize.fab` | 28px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.progressHeight` | 3px |
| `componentSize.dividerBold` | 2px |
| `componentSize.dividerNav` | 1.5px |
| `componentSize.navBubbleLabelWidth` | 100px |
| `componentSize.navBubbleLabelHeight` | 44px |
| `componentSize.navBubbleInnerWidth` | 80px |
| `componentSize.navBubbleInnerHeight` | 36px |
| `componentSize.navBubbleSize` | 56px |
| `componentSize.navItemWidth` | 64px |
| `componentSize.navItemHeight` | 64px |
| `componentSize.navFabSize` | 48px |

### Shadow Tokens
| Token | Value |
|-------|-------|
| `shadow.xs` | 4px |
| `shadow.md` | 8px |
| `shadow.lg` | 12px |
| `shadow.action` | 16px |
| `shadow.glow` | 20px |
| `shadow.navBubbleInactive` | 12px |
| `shadow.navBubbleActive` | 24px |
| `shadow.spreadXs` | 0px |
| `shadow.spreadSm` | 1px |
| `shadow.spreadMd` | 2px |

### Shadow Offset Tokens
| Token | Value |
|-------|-------|
| `AppShadowOffset.md` | (0, 4) |
| `AppShadowOffset.lg` | (0, 6) |
| `AppShadowOffset.navFabLift` | (0, -12) |
| `AppShadowOffset.navFabActive` | (0, 6) |
| `AppShadowOffset.navFabInactive` | (0, 3) |
| `AppShadowOffset.navBubbleActive` | (0, 8) |
| `AppShadowOffset.navBubbleInactive` | (0, 4) |

### Motion Tokens
| Token | Value |
|-------|-------|
| `AppMotionSystem.instant` | 50ms |
| `AppMotionSystem.quick` | 150ms |
| `AppMotionSystem.medium` | 250ms |
| `AppMotionSystem.scaleNone` | 1.0 |
| `AppMotionSystem.scaleEmphasis` | 1.12 |
| `AppMotionSystem.indicatorWidth` | 20px |
| `AppMotionSystem.rotationToggle` | 0.125 |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.faint` | 0.04 |
| `AppOpacity.highlight` | 0.08 |
| `AppOpacity.overlay` | 0.12 |
| `AppOpacity.shadowStrong` | 0.12 |
| `AppOpacity.border` | 0.16 |
| `AppOpacity.shadowDark` | 0.18 |
| `AppOpacity.darkTint` | 0.22 |
| `AppOpacity.shadowBubble` | 0.25 |
| `AppOpacity.subtle` | 0.32 |
| `AppOpacity.shadowAction` | 0.35 |
| `AppOpacity.divider` | 0.36 |
| `AppOpacity.skeletonLight` | 0.65 |
| `AppOpacity.high` | 0.85 |
| `AppOpacity.labelGradient` | 0.88 |
| `AppOpacity.dense` | 0.92 |
| `AppOpacity.solid` | 1.0 |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.semiBold` | 600 |

---

# ✅ STATUS: 100% TOKENIZED
