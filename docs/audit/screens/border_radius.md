# Screens - Border Radius Audit

> `lib/screens/` BorderRadius.circular issues

## Summary
- **Total**: 12 instances

---

## All Instances

| File | Line | Value | Replace With |
|------|------|-------|--------------|
| settings_screen.dart | 1423 | 10 | `radius.sm` |
| schedules_preview_sheet.dart | 144 | 24 | `radius.xl` |
| reminders_cards.dart | 932 | 14 | `radius.md` |
| reminders_cards.dart | 1155 | 14 | `radius.md` |
| admin_issue_reports_page.dart | 268 | 24 | `radius.xl` |
| admin_issue_reports_page.dart | 366 | 24 | `radius.xl` |
| admin_issue_reports_page.dart | 422 | 24 | `radius.xl` |
| add_reminder_page.dart | 90 | 24 | `radius.xl` |
| add_class_page.dart | 1084 | 20 | `radius.xl` |
| add_class_page.dart | 1144 | 20 | `radius.xl` |
| add_class_page.dart | 1249 | 20 | `radius.xl` |
| about_sheet.dart | 68 | 24 | `radius.xl` |

---

## By File

### add_class_page.dart (3)
```dart
// Lines 1084, 1144, 1249
borderRadius: BorderRadius.circular(20),
// → borderRadius: AppTokens.radius.xl,
```

### admin_issue_reports_page.dart (3)
```dart
// Lines 268, 366, 422
borderRadius: BorderRadius.circular(24),
// → borderRadius: AppTokens.radius.xl,
```

### reminders_cards.dart (2)
```dart
// Lines 932, 1155
borderRadius: BorderRadius.circular(14),
// → borderRadius: AppTokens.radius.md,
```

### Single Instances
- `settings_screen.dart:1423` → `radius.sm`
- `schedules_preview_sheet.dart:144` → `radius.xl`
- `add_reminder_page.dart:90` → `radius.xl`
- `about_sheet.dart:68` → `radius.xl`
