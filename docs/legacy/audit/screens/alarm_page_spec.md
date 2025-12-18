# Alarm Page - Full Spec Audit

## Files Overview
- `lib/screens/alarm_page.dart` (174 lines)

---

## AlarmPage (Lines 9-145)

### Back Button IconButton (Lines 19-31)
| Property | Token | Value |
|----------|-------|-------|
| splashRadius | `AppInteraction.splashRadius` | 20px |
| CircleAvatar radius | `AppInteraction.iconButtonContainerRadius` | 18px |
| backgroundColor alpha | `AppOpacity.overlay` | 0.12 |
| icon size | `AppTokens.iconSize.sm` | 16px |

### ScreenBrandHeader (Lines 33-36)
| Property | Token | Value |
|----------|-------|-------|
| Uses global component | `ScreenBrandHeader` | kit |

### Dialog (Lines 39-47)
| Property | Token | Value |
|----------|-------|-------|
| barrierColor alpha | `AppOpacity.muted` | 0.65 |
| insetPadding | `spacing.lg` | 16px |

### Main Layout (Lines 50-143)
| Property | Token | Value |
|----------|-------|-------|
| padding left | `spacing.xl` | 20px |
| padding top | `media.padding.top + spacing.xxxl` | safe + 32px |
| padding right | `spacing.xl` | 20px |
| padding bottom | `spacing.quad + AppLayout.bottomNavSafePadding` | 48px + 80px |

### Live Preview Section (Lines 64-82)
| Property | Token | Value |
|----------|-------|-------|
| spacing after title | `spacing.lg` | 16px |
| fontWeight title | `AppTokens.fontWeight.bold` | 700 |
| spacing after preview | `spacing.sm` | 8px |

### How Reminders Work Section (Lines 85-98)
| Property | Token | Value |
|----------|-------|-------|
| CardX padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |

### Heads-up Tips Section (Lines 100-114)
| Property | Token | Value |
|----------|-------|-------|
| CardX padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |

### Need to Change Section (Lines 116-134)
| Property | Token | Value |
|----------|-------|-------|
| CardX padding | `spacing.edgeInsetsAll(spacing.xl)` | 20px |

---

## _Bullet Widget (Lines 147-172)

### Layout (Lines 155-171)
| Property | Token | Value |
|----------|-------|-------|
| padding bottom | `AppTokens.spacing.sm` | 8px |
| icon size | `AppTokens.iconSize.sm` | 16px |
| spacing icon-text | `AppTokens.spacing.md` | 12px |

---

## Token Reference Summary

### Spacing Tokens
| Token | Value |
|-------|-------|
| `spacing.sm` | 8px |
| `spacing.md` | 12px |
| `spacing.lg` | 16px |
| `spacing.xl` | 20px |
| `spacing.xxxl` | 32px |
| `spacing.quad` | 48px |

### Icon Size Tokens
| Token | Value |
|-------|-------|
| `iconSize.sm` | 16px |

### Interaction Tokens
| Token | Value |
|-------|-------|
| `AppInteraction.splashRadius` | 20px |
| `AppInteraction.iconButtonContainerRadius` | 18px |

### Layout Tokens
| Token | Value |
|-------|-------|
| `AppLayout.bottomNavSafePadding` | 80px |

### Opacity Tokens
| Token | Value |
|-------|-------|
| `AppOpacity.overlay` | 0.12 |
| `AppOpacity.muted` | 0.65 |

### Font Weight Tokens
| Token | Value |
|-------|-------|
| `fontWeight.bold` | 700 |

---

# ✅ STATUS: 100% TOKENIZED
