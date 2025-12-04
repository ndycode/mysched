# Screens - Spacing Audit

> SizedBox hardcoded values in `lib/screens/`
> **Last Updated**: December 5, 2024

## Summary
- **Total remaining**: 9 (7 PDF context + 2 intentional)
- **Previous count**: 87
- **Status**: 🟢 **90%+ reduction!**

---

## Remaining Instances (By File)

### schedules_data.dart (7) - PDF Context ⏭️ Skip
| Line | Type | Value | Notes |
|------|------|-------|-------|
| 149 | height | 8 | pw.SizedBox (PDF) |
| 151 | height | 24 | pw.SizedBox (PDF) |
| 164 | height | 8 | pw.SizedBox (PDF) |
| 166 | height | 24 | pw.SizedBox (PDF) |
| 176 | height | 8 | pw.SizedBox (PDF) |
| 192 | height | 12 | pw.SizedBox (PDF) |
| 194 | height | 12 | pw.SizedBox (PDF) |

### add_class_page.dart (2) - Intentional ⏭️ Skip
| Line | Type | Value | Notes |
|------|------|-------|-------|
| 227 | height | 36 | Container height, not spacing |
| 460 | height | 36 | Container height, not spacing |

---

## ✅ Fully Migrated Files

- add_class_page.dart (28 → 2 intentional)
- add_reminder_page.dart (19 → 0)
- reminders_cards.dart (10 → 0)
- schedules_preview_sheet.dart (5 → 0)
- privacy_sheet.dart (4 → 0)
- about_sheet.dart (4 → 0)
- settings_screen.dart (1 → 0)
- schedules_cards.dart (3 → 0)
- scan_options_sheet.dart (1 → 0)
- reminders_messages.dart (1 → 0)
- dashboard_cards.dart (1 → 0)
- admin_issue_reports_page.dart (1 → 0)
- style_guide_page.dart (1 → 0)

---

## Token Reference

| Value | Token |
|-------|-------|
| 2-4 | `AppTokens.spacing.xs` |
| 8 | `AppTokens.spacing.sm` |
| 10-12 | `AppTokens.spacing.md` |
| 16 | `AppTokens.spacing.lg` |
| 48 | `AppTokens.spacing.quad` |

