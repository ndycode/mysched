# Screen Shell - Full Spec Audit

## Files Overview
- `lib/ui/kit/screen_shell.dart` (474 lines)

---

## ScreenShell (Lines 19-188)

### Default Padding (Lines 49-55)
| Property | Token | Value |
|----------|-------|-------|
| left | `AppLayout.pagePaddingHorizontal` | 20px |
| top | `media.padding.top + AppTokens.spacing.xxxl` | safe + 32px |
| right | `AppLayout.pagePaddingHorizontal` | 20px |
| bottom | `AppTokens.spacing.quad` | 48px |

### Content Layout (Lines 65-72)
| Property | Token | Value |
|----------|-------|-------|
| maxWidth check | `AppLayout.contentMaxWidthExtraWide` | 720px |
| maxWidth (wide) | `AppLayout.contentMaxWidthWide` | 640px |
| maxWidth (normal) | `AppLayout.contentMaxWidth` | 560px |
| hero spacing | `AppTokens.spacing.xl` | 20px |
| section spacing | `AppTokens.spacing.lg` | 16px |

### Refresh Indicator (Lines 162-170)
| Property | Token | Value |
|----------|-------|-------|
| displacement | `AppTokens.componentSize.refreshDisplacement` | 40px |

---

## ScreenHeroCard (Lines 192-278)

### Layout (Lines 213-277)
| Property | Token | Value |
|----------|-------|-------|
| padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |
| title style | `AppTokens.typography.headline` | 24px |
| title fontWeight | `AppTokens.fontWeight.extraBold` | 800 |
| title letterSpacing | `AppLetterSpacing.tight` | -0.5px |
| subtitle spacing | `spacing.xs` | 4px |
| subtitle style | `AppTokens.typography.bodySecondary` | 14px |
| subtitle fontWeight | `AppTokens.fontWeight.medium` | 500 |
| trailing spacing | `spacing.md` | 12px |
| chips spacing | `spacing.lg` | 16px |
| chips wrap spacing | `spacing.md` | 12px |
| chips runSpacing | `spacing.sm` | 8px |
| body spacing | `spacing.lg` | 16px |
| leading spacing | `spacing.md` | 12px |

---

## ScreenSection (Lines 282-366)

### Header (Lines 304-344)
| Property | Token | Value |
|----------|-------|-------|
| title fontWeight | `AppTokens.fontWeight.extraBold` | 800 |
| title fontSize | `AppTokens.typography.subtitle.fontSize` | 16px |
| title letterSpacing | `AppLetterSpacing.snug` | -0.25px |
| subtitle spacing | `spacing.xs` | 4px |
| subtitle fontWeight | `AppTokens.fontWeight.medium` | 500 |
| trailing spacing | `spacing.sm` | 8px |
| content spacing | `spacing.lg` | 16px |

### Card Styling (Lines 350-365)
| Property | Token | Value |
|----------|-------|-------|
| decorated padding | `spacing.edgeInsetsAll(spacing.lg)` | 16px |
| Uses global | `CardX` | kit |

---

## ScreenStickyGroup (Lines 370-437)

### Header Delegate (Lines 383-426)
| Property | Token | Value |
|----------|-------|-------|
| headerHeight | 56 | 56px (param) |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.xs` | 4px |
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |
| `spacing.xl` | 20px |
| `spacing.xxxl` | 32px |
| `spacing.quad` | 48px |

### Layout Tokens
| Token | Value |
|-------|-------|
| `AppLayout.pagePaddingHorizontal` | 20px |
| `AppLayout.contentMaxWidth` | 560px |
| `AppLayout.contentMaxWidthWide` | 640px |
| `AppLayout.contentMaxWidthExtraWide` | 720px |

### Component Size Tokens
| Token | Value |
|-------|-------|
| `componentSize.refreshDisplacement` | 40px |

### Typography Tokens
| Token | Value |
|-------|-------|
| `typography.bodySecondary` | 14px |
| `typography.subtitle` | 16px |
| `typography.headline` | 24px |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.medium` | 500 |
| `fontWeight.extraBold` | 800 |

### Letter Spacing Tokens
| Token | Value |
|-------|-------|
| `AppLetterSpacing.snug` | -0.25px |
| `AppLetterSpacing.tight` | -0.5px |

---

# ✅ STATUS: 100% TOKENIZED
