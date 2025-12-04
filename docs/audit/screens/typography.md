# Screens - Typography Audit (Complete)

> All hardcoded fontSize values in `lib/screens/`

## Summary
- **Total fontSize instances**: 100+
- **Target**: Replace with `AppTokens.typography.*`

---

## By File

### reminders_cards.dart (18)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 162 | 20 | `typography.title` |
| 207 | 17 | `typography.subtitle` |
| 216 | 14 | `typography.bodySecondary` |
| 374 | 13 | `typography.caption` |
| 387 | 22 | `typography.title` |
| 415 | 16 | `typography.body` |
| 445 | 15 | `typography.bodySecondary` |
| 509 | 12 | `typography.caption` |
| 571 | 28 | `typography.display` |
| 580 | 12 | `typography.caption` |
| 826 | 16 | `typography.body` |
| 875 | 14 | `typography.bodySecondary` |
| 892 | 14 | `typography.bodySecondary` |
| 920 | 12 | `typography.caption` |
| 1176 | 21 | `typography.title` |
| 1186 | 14 | `typography.bodySecondary` |
| 1297 | 17 | `typography.subtitle` |
| 1315 | 13 | `typography.caption` |

### dashboard_schedule.dart (14+)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 119 | 21 | `typography.title` |
| 129 | 14 | `typography.bodySecondary` |
| 169 | 14 | `typography.bodySecondary` |
| 184 | 16 | `typography.body` |
| 293 | 16 | `typography.body` |
| 337 | 17 | `typography.subtitle` |
| 348 | 14 | `typography.bodySecondary` |

### dashboard_cards.dart (12+)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| (multiple) | 11-28 | Various |

### schedules_preview_sheet.dart (7)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 657 | 16 | `typography.body` |
| 757 | 14 | `typography.bodySecondary` |
| 765 | 14 | `typography.bodySecondary` |
| 786 | 16 | `typography.body` |
| 817 | 11 | `typography.caption` |
| 852 | 14 | `typography.bodySecondary` |
| 875 | 14 | `typography.bodySecondary` |

### schedules_screen.dart (5)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 294 | 15 | `typography.bodySecondary` |
| 332 | 15 | `typography.bodySecondary` |
| 387 | 15 | `typography.bodySecondary` |
| 671 | 24 | `typography.headline` |
| 681 | 15 | `typography.bodySecondary` |

### schedules_cards.dart (4)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 251 | 17 | `typography.subtitle` |
| 260 | 14 | `typography.bodySecondary` |
| 998 | 11 | `typography.caption` |
| 1061 | 28 | `typography.display` |

### schedules_data.dart (4) - PDF Context
| Line | fontSize | Notes |
|------|----------|-------|
| 145 | 22 | PDF text |
| 160 | 22 | PDF text |
| 171 | 16 | PDF text |
| 181 | 14 | PDF text |

### reminders_screen.dart (3)
| Line | fontSize | Suggested Token |
|------|----------|-----------------|
| 248 | 15 | `typography.bodySecondary` |
| 291 | 15 | `typography.bodySecondary` |
| 352 | 15 | `typography.bodySecondary` |

### Other Files
| File | Line | fontSize |
|------|------|----------|
| register_page.dart | 229 | 12 |
| login_page.dart | 178 | 12 |

---

## Token Reference

| fontSize | Token |
|----------|-------|
| 32 | `AppTokens.typography.display` |
| 26 | `AppTokens.typography.headline` |
| 20-22 | `AppTokens.typography.title` |
| 16-17 | `AppTokens.typography.subtitle` or `.body` |
| 14-15 | `AppTokens.typography.bodySecondary` |
| 12-13 | `AppTokens.typography.caption` |
| 11 | `AppTokens.typography.caption` (small) |
