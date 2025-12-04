# Screens - Typography Audit

> `fontSize` in `lib/screens/`
> **Last Updated**: March 6, 2025

## Summary
- **Total matches**: 5 (all intentional)
- **UI screens**: 0 actionable (all use AppTokens.typography or textTheme)
- **Remaining**: Export-only mapping in `schedules/schedules_data.dart` now uses AppTokens typography/brand colors via PDF styles.

---

## Intentional (Export)
| File | fontSize source | Context |
|------|-----------------|---------|
| schedules/schedules_data.dart | `AppTokens.typography` mapped to `pdf.TextStyle` | PDF/plain-text export; aligned to design tokens |

---

## Actionable
- None.
