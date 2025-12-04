# Screens - Spacing Audit (Complete)

> All hardcoded SizedBox and EdgeInsets in `lib/screens/`

## Summary
| Type | Count |
|------|-------|
| SizedBox(height) | 55 |
| SizedBox(width) | 29 |
| EdgeInsets hardcoded | 3 |
| **Total** | **87** |

---

## SizedBox(height) - By File

### add_class_page.dart (17)
| Line | Value | Token |
|------|-------|-------|
| 227 | 36 | Custom |
| 460 | 36 | Custom |
| 487 | 18 | `spacing.xl` |
| 907 | 12 | `spacing.md` |
| 945 | 12 | `spacing.md` |
| 978 | 8 | `spacing.sm` |
| 1023 | 8 | `spacing.sm` |
| 1076 | 16 | `spacing.lg` |
| 1122 | 10 | `spacing.md` |
| 1130 | 14 | `spacing.lg` |
| 1139 | 16 | `spacing.lg` |
| 1170 | 10 | `spacing.md` |
| 1201 | 16 | `spacing.lg` |
| 1223 | 14 | `spacing.lg` |
| 1244 | 16 | `spacing.lg` |

### add_reminder_page.dart (12)
| Line | Value | Token |
|------|-------|-------|
| 338 | 16 | `spacing.lg` |
| 372 | 10 | `spacing.md` |
| 381 | 16 | `spacing.lg` |
| 392 | 16 | `spacing.lg` |
| 414 | 10 | `spacing.md` |
| 438 | 10 | `spacing.md` |
| 446 | 14 | `spacing.lg` |
| 468 | 20 | `spacing.xl` |
| 548 | 8 | `spacing.sm` |
| 691 | 4 | `spacing.xs` |
| 762 | 2 | `spacing.xs` |

### reminders_cards.dart (9)
| Line | Value | Token |
|------|-------|-------|
| 212 | 8 | `spacing.sm` |
| 224 | 20 | `spacing.xl` |
| 576 | 4 | `spacing.xs` |
| 1181 | 4 | `spacing.xs` |
| 1195 | 24 | `spacing.xxl` |
| 1200 | 12 | `spacing.md` |
| 1211 | 10 | `spacing.md` |
| 1213 | 20 | `spacing.xl` |

### schedules_data.dart (7) - PDF Context
| Line | Value | Notes |
|------|-------|-------|
| 149 | 8 | pw.SizedBox |
| 151 | 24 | pw.SizedBox |
| 164 | 8 | pw.SizedBox |
| 166 | 24 | pw.SizedBox |
| 176 | 8 | pw.SizedBox |
| 192 | 12 | pw.SizedBox |
| 194 | 12 | pw.SizedBox |

### schedules_cards.dart (3)
| Line | Value | Token |
|------|-------|-------|
| 814 | 2 | `spacing.xs` |
| 984 | 2 | `spacing.xs` |
| 994 | 2 | `spacing.xs` |

### schedules_preview_sheet.dart (2)
| Line | Value | Token |
|------|-------|-------|
| 445 | 4 | `spacing.xs` |
| 761 | 2 | `spacing.xs` |

### Other Files
| File | Line | Value |
|------|------|-------|
| style_guide_page.dart | 75 | 16 |
| reminders_messages.dart | 147 | 8 |
| privacy_sheet.dart | 199 | 16 |
| privacy_sheet.dart | 206 | 16 |
| dashboard_cards.dart | 504 | 2 |

---

## SizedBox(width) - By File

### add_class_page.dart (10)
| Line | Value | Token |
|------|-------|-------|
| 151 | 12 | `spacing.md` |
| 161 | 12 | `spacing.md` |
| 172 | 12 | `spacing.md` |
| 1001 | 48/12 | Conditional |
| 1212 | 12 | `spacing.md` |
| 1232 | 10 | `spacing.md` |
| 1300 | 12 | `spacing.md` |
| 1465 | 12 | `spacing.md` |
| 1492 | 8 | `spacing.sm` |
| 1567 | 8 | `spacing.sm` |

### add_reminder_page.dart (9)
| Line | Value | Token |
|------|-------|-------|
| 167 | 12 | `spacing.md` |
| 426 | 12 | `spacing.md` |
| 455 | 10 | `spacing.md` |
| 478 | 12 | `spacing.md` |
| 526 | 48/12 | Conditional |
| 751 | 12 | `spacing.md` |
| 778 | 8 | `spacing.sm` |
| 820 | 8 | `spacing.sm` |

### schedules_preview_sheet.dart (3)
| Line | Value | Token |
|------|-------|-------|
| 381 | 48 | `spacing.quad` |
| 508 | 8 | `spacing.sm` |
| 771 | 20 | `spacing.xl` |

### Other Files
| File | Line | Value |
|------|------|-------|
| settings_screen.dart | 1361 | 8 |
| scan_options_sheet.dart | 103 | 48 |
| reminders_cards.dart | 1167 | 16 |
| privacy_sheet.dart | 85 | 48 |
| privacy_sheet.dart | 386 | 4 |
| admin_issue_reports_page.dart | 580 | 6 |
| about_sheet.dart | 122 | 48 |
| about_sheet.dart | 473 | 4 |

---

## EdgeInsets Hardcoded (3)

| File | Line | Current |
|------|------|---------|
| schedules_data.dart | 136 | `EdgeInsets.all(40)` (PDF) |
| about_sheet.dart | 101 | `EdgeInsets.all(8)` |
| about_sheet.dart | 506 | `EdgeInsets.all(10)` |

---

## Token Reference

| Value | Token |
|-------|-------|
| 2-4 | `AppTokens.spacing.xs` |
| 8 | `AppTokens.spacing.sm` |
| 10-12 | `AppTokens.spacing.md` |
| 14-16 | `AppTokens.spacing.lg` |
| 18-20 | `AppTokens.spacing.xl` |
| 24 | `AppTokens.spacing.xxl` |
| 32 | `AppTokens.spacing.xxxl` |
| 48 | `AppTokens.spacing.quad` |
