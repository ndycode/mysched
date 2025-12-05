# Audit Documentation Index
*Last Updated: 2025-12-06*

## Quick Reference

```
docs/audit/
├── index.md                        # This file
├── screens/                        # Main app screens (6 files)
│   ├── dashboard_screen_spec.md
│   ├── schedules_screen_spec.md
│   ├── reminders_screen_spec.md
│   ├── settings_screen_spec.md
│   └── alarm_page_spec.md
├── sheets/                         # Modal dialogs (5 files)
│   ├── about_sheet_spec.md
│   ├── privacy_sheet_spec.md
│   ├── scan_options_sheet_spec.md
│   ├── scan_preview_sheet_spec.md
│   └── schedules_preview_sheet_spec.md
├── forms/                          # Form/entry pages (5 files)
│   ├── add_class_page_spec.md
│   ├── add_reminder_page_spec.md
│   ├── account_overview_page_spec.md
│   ├── auth_screens_spec.md
│   └── account_management_spec.md
├── admin/                          # Admin pages (1 file)
│   └── admin_issue_reports_page_spec.md
└── kit/                            # UI Kit components (6 files)
    ├── class_details_sheet_spec.md
    ├── reminder_details_sheet_spec.md
    ├── glass_navigation_bar_spec.md
    ├── screen_shell_spec.md
    ├── containers_spec.md
    └── modals_spec.md
```

---

## Summary

| Metric | Value |
|--------|-------|
| Total Files | 23 |
| Total Lines | ~11,500+ |
| Status | ✅ 100% Tokenized |

---

## screens/ (6 files)

Main navigation screens users interact with.

| File | Lines | Description |
|------|-------|-------------|
| [dashboard_screen_spec.md](screens/dashboard_screen_spec.md) | 3,365 | Main home/dashboard |
| [schedules_screen_spec.md](screens/schedules_screen_spec.md) | 2,881 | Schedule viewing |
| [reminders_screen_spec.md](screens/reminders_screen_spec.md) | 1,896 | Reminder management |
| [settings_screen_spec.md](screens/settings_screen_spec.md) | 1,541 | App settings |
| [alarm_page_spec.md](screens/alarm_page_spec.md) | 174 | Alarm info page |

---

## sheets/ (5 files)

Modal overlays and bottom sheets.

| File | Lines | Description |
|------|-------|-------------|
| [schedules_preview_sheet_spec.md](sheets/schedules_preview_sheet_spec.md) | 860 | Schedule preview |
| [about_sheet_spec.md](sheets/about_sheet_spec.md) | 411 | App info |
| [scan_preview_sheet_spec.md](sheets/scan_preview_sheet_spec.md) | 405 | Scan preview |
| [privacy_sheet_spec.md](sheets/privacy_sheet_spec.md) | 317 | Privacy policy |
| [scan_options_sheet_spec.md](sheets/scan_options_sheet_spec.md) | 166 | Scan options |

---

## forms/ (5 files)

Form pages for data entry and authentication.

| File | Lines | Description |
|------|-------|-------------|
| [add_class_page_spec.md](forms/add_class_page_spec.md) | 1,510 | Add custom class |
| [account_management_spec.md](forms/account_management_spec.md) | 1,284 | Email/password/delete |
| [add_reminder_page_spec.md](forms/add_reminder_page_spec.md) | 671 | Add reminder |
| [account_overview_page_spec.md](forms/account_overview_page_spec.md) | 509 | Account details |
| [auth_screens_spec.md](forms/auth_screens_spec.md) | 492 | Login/register |

---

## admin/ (1 file)

Admin-only management pages.

| File | Lines | Description |
|------|-------|-------------|
| [admin_issue_reports_page_spec.md](admin/admin_issue_reports_page_spec.md) | 803 | Issue reports |

---

## kit/ (6 files)

Reusable UI Kit components.

| File | Lines | Description |
|------|-------|-------------|
| [class_details_sheet_spec.md](kit/class_details_sheet_spec.md) | 911 | Class details modal |
| [glass_navigation_bar_spec.md](kit/glass_navigation_bar_spec.md) | 536 | Bottom nav bar |
| [screen_shell_spec.md](kit/screen_shell_spec.md) | 474 | Screen container |
| [containers_spec.md](kit/containers_spec.md) | 456 | CardX, Section, etc |
| [reminder_details_sheet_spec.md](kit/reminder_details_sheet_spec.md) | 422 | Reminder details |
| [modals_spec.md](kit/modals_spec.md) | 351 | Dialog system |

---

## Token Categories

Each spec documents these token types:

| Category | File | Example |
|----------|------|---------|
| Spacing | `tokens/spacing.dart` | `spacing.md` = 12px |
| Radius | `tokens/radius.dart` | `radius.lg` = 16px |
| Icon Sizes | `tokens/sizes.dart` | `iconSize.sm` = 16px |
| Typography | `tokens/typography.dart` | `typography.title` = 18px |
| Opacity | `tokens/opacity.dart` | `AppOpacity.overlay` = 0.12 |
| Shadow | `tokens/shadow.dart` | `shadow.md` = 8px blur |
| Component | `tokens/sizes.dart` | `componentSize.buttonMd` = 48px |
| Motion | `motion.dart` | `AppMotionSystem.quick` = 150ms |
| Layout | `tokens/layout.dart` | `AppLayout.sheetMaxWidth` = 480px |
| Interaction | `tokens/interaction.dart` | `AppInteraction.splashRadius` = 20px |

---

## Spec Document Format

Each file follows this structure:

```markdown
# [Component Name] - Full Spec Audit

## Files Overview
- source_file.dart (X lines)

## [Section Name] (Lines X-Y)
| Property | Token | Value |
|----------|-------|-------|
| padding  | spacing.md | 12px |

## Token Reference Summary
[All unique tokens used]

# ✅ STATUS: 100% TOKENIZED
```

---

## Source Mapping

| Folder | Source Path |
|--------|-------------|
| screens/ | `lib/screens/**/`, `lib/screens/*.dart` |
| sheets/ | `lib/screens/*_sheet.dart` |
| forms/ | `lib/screens/add_*.dart`, `lib/screens/*_page.dart` |
| admin/ | `lib/screens/admin_*.dart` |
| kit/ | `lib/ui/kit/*.dart` |

---

## Token System Source

All tokens defined in:
- `lib/ui/theme/tokens.dart` - Main re-exports
- `lib/ui/theme/tokens/*.dart` - Individual token files
- `lib/ui/theme/motion.dart` - Animation system

---

*Generated: 2025-12-06 | Coverage: 100%*
