# Auth Screens - Full Spec Audit
*Last Updated: 2025-12-06*

## Files Overview
- `login_page.dart` (224 lines)
- `register_page.dart` (268 lines)

**Total: 492 UI lines**

---

# login_page.dart (Lines 1-224)

## AuthShell Usage
| Property | Value |
|----------|-------|
| screenName | `'login'` |
| title | `'Welcome back'` |
| subtitle | `'Sign in to keep your reminders and schedules in sync.'` |

## Error Container (Lines 126-140)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| font | `typography.body` | 15px |
| fontWeight | `fontWeight.semiBold` | w600 |
| error→field gap | `spacing.lg` | 16px |

## Form Fields (Lines 142-182)
| Property | Token | Px Value |
|----------|-------|---------|
| field gap | `spacing.lg` | 16px |
| password→helper gap | `spacing.xs` | 4px |
| helper font | `typography.bodySecondary` | 13px |
| helper→button gap | `spacing.xl` | 20px |

## Primary Button (Lines 184-190)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |

## Bottom Actions (Lines 196-211)
| Property | Token | Px Value |
|----------|-------|---------|
| button gap | `spacing.sm` | 8px |
| secondary minHeight | `componentSize.buttonMd` | 48px |

---

# register_page.dart (Lines 1-268)

## AuthShell Usage
| Property | Value |
|----------|-------|
| screenName | `'register'` |
| title | `'Create your MySched account'` |
| subtitle | `'Join MySched to organize your schedule and reminders.'` |

## Error Container (Lines 151-165)
| Property | Token | Px Value |
|----------|-------|---------|
| padding | `spacing.md` | 12px |
| borderRadius | `radius.md` | 12px |
| bg alpha | `AppOpacity.highlight` | 0.08 |
| font | `typography.body` | 15px |
| fontWeight | `fontWeight.semiBold` | w600 |
| error→field gap | `spacing.lg` | 16px |

## Form Fields (Lines 167-233)
| Property | Token | Px Value |
|----------|-------|---------|
| field gap | `spacing.lg` | 16px |
| password→helper gap | `spacing.xs` | 4px |
| helper font | `typography.bodySecondary` | 13px |
| helper→button gap | `spacing.xl` | 20px |

## Primary Button (Lines 235-241)
| Property | Token | Px Value |
|----------|-------|---------|
| minHeight | `componentSize.buttonMd` | 48px |

## Bottom Actions (Lines 247-257)
| Property | Token | Px Value |
|----------|-------|---------|
| secondary minHeight | `componentSize.buttonMd` | 48px |

---

## AuthShell Component (Shared)

The `AuthShell` component is a reusable wrapper used by both login and register pages. It provides:
- Branded header with logo
- Title and subtitle typography
- Form container styling
- Bottom action area

### Typical Layout
| Property | Token | Px Value |
|----------|-------|---------|
| header padding | `spacing.xl` | 20px |
| title font | `typography.headline` | 22px |
| title weight | `fontWeight.bold` | w700 |
| subtitle font | `typography.body` | 15px |
| title→subtitle gap | `spacing.sm` | 8px |
| subtitle→form gap | `spacing.xl` | 20px |
| form→bottom gap | `spacing.xl` | 20px |

---

## Password Visibility Toggle
| Property | Token | Px Value |
|----------|-------|---------|
| icon (hidden) | `Icons.visibility_off` | - |
| icon (visible) | `Icons.visibility` | - |

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

## Component Sizes (px)
| Token | Value |
|-------|-------|
| `buttonMd` | 48 |

## Opacity Values
| Token | Value |
|-------|-------|
| `highlight` | 0.08 |

## Typography
| Token | Value |
|-------|-------|
| `body` | 15px |
| `bodySecondary` | 13px |
| `headline` | 22px |

## Font Weights
| Token | Value |
|-------|-------|
| `semiBold` | 600 |
| `bold` | 700 |

---

# ✅ STATUS: 100% TOKENIZED
All 492 UI lines across auth screens fully use design tokens.
