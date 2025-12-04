# Design System Audit - Master Index

> Complete audit of hardcoded values across the MySched project
> Last updated: December 5, 2024

## Project Structure

```
docs/audit/
├── README.md              ← You are here
├── screens/               ← lib/screens/
│   ├── README.md
│   ├── spacing.md
│   ├── border_radius.md
│   ├── colors.md
│   └── typography.md
├── ui/                    ← lib/ui/
│   └── README.md          (complete deep audit)
├── app/                   ← lib/app/
│   └── README.md
└── widgets/               ← lib/widgets/
    └── README.md
```

---

## Summary by Area

| Area | Radius | Colors | Typography | Spacing |
|------|--------|--------|------------|---------|
| `lib/screens/` | 12 | 118+ | 124+ | 128 |
| `lib/ui/` | 48 | 67 | 18 | 51 |
| `lib/app/` | 5 | 9 | 9 | - |
| `lib/widgets/` | 0 | 4 | 1 | - |
| **Total** | **65** | **198+** | **152** | **179** |

### lib/ui/ Breakdown

| Category | Total | Actionable | Notes |
|----------|-------|------------|-------|
| BorderRadius | 48 | 32 | 16 in app_theme.dart |
| Colors | 67 | ~35 | Many Colors.transparent |
| fontSize | 26 | 18 | 8 define tokens |
| SizedBox | 42 | 42 | All need migration |
| EdgeInsets | 9 | 9 | All need migration |

---

## Priority Order

### Phase 1: Quick Wins
- [x] `lib/screens/` BorderRadius - 12 remaining
- [ ] `lib/ui/kit/` BorderRadius - 32 remaining

### Phase 2: UI Kit Spacing
- [ ] SizedBox in detail sheets - 23 instances
- [ ] SizedBox in navigation - 5 instances
- [ ] EdgeInsets - 9 instances

### Phase 3: Colors
- [ ] glass_navigation_bar.dart - 7 instances
- [ ] containers.dart - 4 instances
- [ ] snack_bars.dart - 3 instances
- [ ] auth_shell.dart - 2 instances

### Phase 4: Typography
- [ ] class_details_sheet.dart - 5 fontSizes
- [ ] reminder_details_sheet.dart - 4 fontSizes
- [ ] alarm_preview.dart - 3 fontSizes

---

## Top Files to Fix

| File | Radius | Colors | Typography | Spacing | Total |
|------|--------|--------|------------|---------|-------|
| class_details_sheet.dart | 9 | 2 | 5 | 17 | **33** |
| glass_navigation_bar.dart | 6 | 7 | - | 6 | **19** |
| reminder_details_sheet.dart | 8 | 1 | 4 | 13 | **26** |
| schedules_cards.dart | - | 10+ | 45+ | 3 | **58+** |
| settings_screen.dart | 1 | 27 | 18 | 9 | **55** |

---

## Not Scanned (No UI Code)

- `lib/services/` ✅
- `lib/models/` ✅
- `lib/utils/` ✅
- `lib/onboarding/` ✅ (empty)
