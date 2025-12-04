# UI Kit - Typography Audit

> `fontSize` in `lib/ui/` (fresh grep)
> **Last Updated**: March 6, 2025

## Summary
- **Total matches**: 17
- **tokens.dart**: 8 (defines the system)
- **Tokenized usages**: 8 (brand_header, screen_shell, alarm_preview, status_chip) – already on AppTokens.typography
- **Intentional dynamic**: 1 (hero_avatar letter uses avatar radius to scale with size)
- **Actionable**: 0

---

## Intentional - tokens.dart (8)
Lines 198, 204, 210, 216, 222, 228, 234, 241 define the typography tokens.

---

## Intentional dynamic (1)
- `hero_avatar.dart` – fallback letter scales with avatar radius for proportional sizing.

---

## Actionable (0)
- None.
